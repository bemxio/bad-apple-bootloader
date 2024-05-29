#!/usr/bin/python3

from pathlib import Path
from argparse import ArgumentParser

import cv2

PALETTE = (0, 85, 170, 255)

def main(input_path: Path, output_path: Path, screen_width: int, screen_height: int):
    if not input_path.exists():
        raise FileNotFoundError(f"Input path `{input_path}` does not exist.")

    size = screen_width * screen_height

    print(f"Frame size: {size} bytes ({round(size / 512)} sectors)")
    print(f"Screen size: {screen_width}x{screen_height} (width x height)")

    video = cv2.VideoCapture(str(input_path))
    file = open(output_path, "wb")

    length = int(video.get(cv2.CAP_PROP_FRAME_COUNT))

    index = 1
    success = True
    
    #video.set(cv2.CAP_PROP_POS_FRAMES, 1000)

    for index in range(1, length + 1):
        success, frame = video.read()

        if not success:
            break

        frame = cv2.resize(frame, (screen_width, screen_height))
        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

        data = b""

        for row in range(screen_height):
            for column in range(screen_width):
                pixel = frame[row, column]
                pixel = PALETTE[round(pixel / 85)]

                data += pixel.to_bytes(1)

        file.write(data)
        #file.write(bytes(filling))

        print(f"Frame {index}/{length} ({round(index / length * 100, 2)}%)", end="\r")

    file.close()
    video.release()

if __name__ == "__main__":
    parser = ArgumentParser(description="A script for converting a video for use with the bootloader.")

    parser.add_argument("input_path", type=Path, help="The input path to the video.")
    parser.add_argument("--output_path", "-o", type=Path, help="The output path to the data file.", default=Path("video.bin"))

    parser.add_argument("--screen_width", type=int, help="The width of the screen.", default=320)
    parser.add_argument("--screen_height", type=int, help="The height of the screen.", default=200)

    args = parser.parse_args()

    main(
        args.input_path,
        args.output_path,

        args.screen_width,
        args.screen_height
    )