#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

// constants
#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 200

#define FRAME_SIZE (SCREEN_WIDTH * SCREEN_HEIGHT * 3) // RGB24 pixel format
#define PALETTE_SIZE 256 * 3 // RGB24, 256 colors

#define PALETTE_PATH "palette.bin"

// functions
uint8_t get_palette_index(uint8_t* palette, uint8_t* buffer, size_t index) {
    uint8_t r, g, b;

    r = buffer[index];
    g = buffer[index + 1];
    b = buffer[index + 2];

    for (size_t i = 0; i < PALETTE_SIZE; i += 3) {
        if (palette[i] == r && palette[i + 1] == g && palette[i + 2] == b) {
            return (uint8_t)(i / 3);
        }
    }

    fprintf(stderr,
        "Warning: Color #%02X%02X%02X not found in palette. Using default index $28.\n", r, g, b);

    return 0x28; // default if color not found in palette
}

int main(int argc, char** argv) {
    // variables
    uint8_t buffer[FRAME_SIZE];
    uint8_t palette[PALETTE_SIZE];

    // load palette
    FILE* file = fopen(PALETTE_PATH, "rb");

    if (!file) {
        fprintf(stderr, "Error: Could not open palette file '%s'\n", PALETTE_PATH); return 1;
    } else if (fread(palette, sizeof(uint8_t), PALETTE_SIZE, file) != PALETTE_SIZE) {
        fprintf(stderr, "Error: Failed to read palette from file '%s'\n", PALETTE_PATH);
        fclose(file);

        return 1;
    }

    fclose(file);

    // compression loop
    while (fread(buffer, sizeof(uint8_t), FRAME_SIZE, stdin) == FRAME_SIZE) {
        uint8_t runLength = 1;
        uint8_t runByte;

        for (size_t i = 0; i < FRAME_SIZE; i += 3) {
            uint8_t currentByte = get_palette_index(palette, buffer, i);

            if (i == 0) {
                runByte = currentByte;
            } else if (currentByte == runByte && runLength < 255) {
                runLength++;
            } else {
                fwrite(&runLength, sizeof(uint8_t), 1, stdout);
                fwrite(&runByte, sizeof(uint8_t), 1, stdout);

                runLength = 1;
                runByte = currentByte;
            }
        }

        fwrite(&runLength, sizeof(uint8_t), 1, stdout);
        fwrite(&runByte, sizeof(uint8_t), 1, stdout);

        fflush(stdout);
    }

    // cleanup
    fclose(stdin);
    fclose(stdout);

    return 0;
}