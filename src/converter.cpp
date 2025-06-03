#include <opencv2/videoio.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/core.hpp>

#include <iostream>
#include <fstream>

#include "palette.hpp"

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 200

uint8_t getColorIndex(const cv::Vec3b& color) {
    return std::find(PALETTE.begin(), PALETTE.end(), color) - PALETTE.begin();
}

cv::Vec3b findNearestColor(const cv::Vec3b& color) {
    cv::Vec3b nearestColor;
    uint32_t distance = 255 * 255 * 3;

    for (const cv::Vec3b& paletteColor : PALETTE) {
        int8_t r = color[0] - paletteColor[0];
        int8_t g = color[1] - paletteColor[1];
        int8_t b = color[2] - paletteColor[2];

        uint32_t currentDistance = (r * r) + (g * g) + (b * b);

        if (currentDistance < distance) {
            nearestColor = paletteColor;
            distance = currentDistance;
        }
    }

    return nearestColor;
}

void applyDithering(cv::Mat& image) {
    for (size_t y = 0; y < SCREEN_HEIGHT; y++) {
        for (size_t x = 0; x < SCREEN_WIDTH; x++) {
            cv::Vec3b oldPixel = image.at<cv::Vec3b>(y, x);
            cv::Vec3b newPixel = findNearestColor(oldPixel);

            cv::Vec3b quantError = oldPixel - newPixel;

            if (x + 1 < SCREEN_WIDTH) {
                image.at<cv::Vec3b>(y, x + 1) += quantError * 7 / 16;
            }

            if (y + 1 < SCREEN_HEIGHT) {
                if (x > 0) {
                    image.at<cv::Vec3b>(y + 1, x - 1) += quantError * 3 / 16;
                }

                image.at<cv::Vec3b>(y + 1, x) += quantError * 5 / 16;

                if (x + 1 < SCREEN_WIDTH) {
                    image.at<cv::Vec3b>(y + 1, x + 1) += quantError * 1 / 16;
                }
            }

            image.at<cv::Vec3b>(y, x) = newPixel;
        }
    }
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

    for (size_t index = 0; index < length; index++) {
        capture >> frame;

        if (frame.empty()) {
            break;
        }

        cv::resize(frame, frame, cv::Size(SCREEN_WIDTH, SCREEN_HEIGHT));
        applyDithering(frame);

        uint8_t runLength = 1;
        uint8_t runByte;

        for (size_t y = 0; y < SCREEN_HEIGHT; y++) {
            for (size_t x = 0; x < SCREEN_WIDTH; x++) {
                uint8_t currentByte = getColorIndex(frame.at<cv::Vec3b>(y, x));

                if (runByte == currentByte && runLength < 255) {
                    runLength++; continue;
                }

                file.write(reinterpret_cast<char*>(&runLength), 1);
                file.write(reinterpret_cast<char*>(&runByte), 1);

                runLength = 1;
                runByte = currentByte;
            }
        }
    }

    file.close();
    capture.release();

    return 0;
}