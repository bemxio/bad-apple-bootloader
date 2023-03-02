// includes
#include <opencv2/videoio.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/core.hpp>

#include <string>
#include <vector>

#include <cstdio>
#include <cmath>

// defines
#define VIDEO_WIDTH 320
#define VIDEO_HEIGHT 200

#define SECTOR_SIZE 512.0f

#define SHADE_COUNT 4
#define SHADE_THRESHOLD (float)(256 / SHADE_COUNT)

const char shades[SHADE_COUNT] = {0x00, 0x01, 0x02, 0x03};

// main code
int main(int argc, char** argv) {
    // check if the number of arguments is correct
    if (argc != 3) {
        fprintf(stderr, "error: not enough arguments\n"); return -1;
    }

    // get the input and output paths
    std::string input_path = argv[argc - 2];
    std::string output_path = argv[argc - 1];

    // open video file
    cv::VideoCapture capture(input_path);
    cv::Mat frame;

    // check if the video file was opened
    if (!capture.isOpened()) {
        fprintf(stderr, "error: could not open video file '%s'\n", input_path.c_str()); return -1;
    }

    // get the video length and frame size
    int length = (int)capture.get(cv::CAP_PROP_FRAME_COUNT);
    int size = VIDEO_WIDTH * VIDEO_HEIGHT;
    int sectors = round(size / SECTOR_SIZE);

    // print basic info
    printf("Frame size: %d bytes (%d sectors)\n", size, sectors);
    printf("Screen size: %dx%d (width x height)\n", VIDEO_WIDTH, VIDEO_HEIGHT);
    printf("Total frames: %d\n", length);

    // process the video
    std::vector<char> data;

    while (true) {
        capture >> frame;

        // check if the frame is empty
        if (frame.empty()) {
            break;
        }

        // convert the frame to grayscale and resize it
        cv::cvtColor(frame, frame, cv::COLOR_BGR2GRAY);
        cv::resize(frame, frame, cv::Size(VIDEO_WIDTH, VIDEO_HEIGHT));

        // convert the pixels into binary data
        for (int column = 0; column < VIDEO_WIDTH; column++) {
            for (int row = 0; row < VIDEO_HEIGHT; row++) {
                // get the pixel value
                int pixel = frame.at<uchar>(row, column);

                // convert the pixel value to a shade of gray
                //int shade = round(pixel / SHADE_THRESHOLD);

                // add the shade of gray to the data
                //data.push_back(shades[shade]);
            
                data.push_back(pixel);
            }
        }

        // print the progress
        printf("Frame %d/%d processed\r", (int)data.size() / size, length);
    }

    // write the data to a file
    FILE* file = fopen(output_path.c_str(), "wb");

    if (file == NULL) {
        fprintf(stderr, "error: could not open output file '%s'\n", output_path.c_str()); return -1;
    }

    fwrite(data.data(), 1, data.size(), file);
    fclose(file);

    return 0;
}   