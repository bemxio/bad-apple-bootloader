#include <opencv2/videoio.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/core.hpp>

#include <iostream>
#include <fstream>

#include "palette.hpp"

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 200

unsigned char getClosestColor(cv::Vec3b pixel) {
    unsigned char result = 0;
    int distance = 255 * 255 * 3;

    for (size_t index = 0; index < 256; index++) {
        unsigned char* color = PALETTE[index];

        char r = pixel[0] - color[0];
        char g = pixel[1] - color[1];
        char b = pixel[2] - color[2];

        int current = (r * r) + (g * g) + (b * b);

        if (current < distance) {
            result = index;
            distance = current;
        }
    }

    return result;
}

int main(int argc, char** argv) {
    if (argc != 3) {
        std::cout << "Usage: " << argv[0] << " <input> <output>" << std::endl; return 1;
    }

    char* input_path = argv[1];
    char* output_path = argv[2];

    cv::VideoCapture capture(input_path);
    cv::Mat frame;

    if (!capture.isOpened()) {
        std::cerr << "Error: Could not open video file '" << input_path << "'" << std::endl; return 1;
    }

    std::ofstream file(output_path, std::ios::out | std::ios::binary);

    if (!file.is_open()) {
        std::cerr << "Error: Could not open output file '" << output_path << "'" << std::endl; return 1;
    }

    size_t size = SCREEN_WIDTH * SCREEN_HEIGHT;
    size_t sectors = round(size / 512.0);
    size_t length = (size_t)capture.get(cv::CAP_PROP_FRAME_COUNT);

    //std::cout << "Frame size: " << size << " bytes (" << sectors << " sectors)" << std::endl;
    //std::cout << "Screen size: " << SCREEN_WIDTH << " x " << SCREEN_HEIGHT << std::endl;
    //std::cout << "Total frames: " << length << std::endl;

    unsigned char data[size];

    for (size_t index = 1; index <= length; index++) {
        capture >> frame;

        if (frame.empty()) {
            break;
        }

        cv::resize(frame, frame, cv::Size(SCREEN_WIDTH, SCREEN_HEIGHT));

        for (size_t row = 0; row < SCREEN_HEIGHT; row++) {
            for (size_t column = 0; column < SCREEN_WIDTH; column++) {
                data[(row * SCREEN_WIDTH) + column] = getClosestColor(frame.at<cv::Vec3b>(row, column));
            }
        }

        file.write(reinterpret_cast<char*>(data), size);
    }

    file.close();
    capture.release();

    return 0;
}