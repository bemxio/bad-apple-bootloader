#include <opencv2/videoio.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/core.hpp>

#include <iostream>
#include <fstream>

#include <cstdint>
#include <cstddef>
#include <cmath>

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 200

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

    std::ofstream file(output_path, std::ios::out | std::ios::binary | std::ios::app);

    if (!file.is_open()) {
        std::cerr << "Error: Could not open output file '" << output_path << "'" << std::endl; return 1;
    }

    size_t size = SCREEN_WIDTH * SCREEN_HEIGHT;
    size_t sectors = round(size / 512.0);
    size_t length = (size_t)capture.get(cv::CAP_PROP_FRAME_COUNT);

    //std::cout << "Frame size: " << size << " bytes (" << sectors << " sectors)" << std::endl;
    //std::cout << "Screen size: " << SCREEN_WIDTH << "x" << SCREEN_HEIGHT << " (width x height)" << std::endl;
    //std::cout << "Total frames: " << length << std::endl;

    uint8_t data[size];
    uint8_t pixel;

    //capture.set(cv::CAP_PROP_POS_FRAMES, 1000);

    for (int index = 1; index <= length; index++) {
        capture >> frame;

        if (frame.empty()) {
            break;
        }

        cv::cvtColor(frame, frame, cv::COLOR_BGR2GRAY);
        cv::resize(frame, frame, cv::Size(SCREEN_WIDTH, SCREEN_HEIGHT));

        for (int row = 0; row < SCREEN_HEIGHT; row++) {
            for (int column = 0; column < SCREEN_WIDTH; column++) {
                pixel = frame.at<uchar>(row, column);
                pixel = round(pixel / 85.0) * 85;

                data[(row * SCREEN_WIDTH) + column] = pixel;
            }
        }

        file.write(reinterpret_cast<char*>(data), size);
    }

    return 0;
}