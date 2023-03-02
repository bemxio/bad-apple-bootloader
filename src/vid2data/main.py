import numpy as np
import cv2

from argparse import ArgumentParser
from pathlib import Path

def get_filling_amount(size: int) -> int:
    amount = 0

    while amount < size:
        amount += 512

    return amount - size + 1

def process_frame(frame: np.array, width: int, height: int) -> bytes:
    shades = [0b00, 0b01, 0b10, 0b11]
    choices = 256 // len(shades)

    data = b""

    for row in range(height):
        for column in range(width):
            data += bytes(shades[frame[row, column] // choices])

    return data + (b"\0" * get_filling_amount(width * height))
        
def main(input_path: Path, output_path: Path, width: int = 80, height: int = 25):
    if not input_path.exists():
        raise FileNotFoundError(f"input path `{input_path}` does not exist")

    video = cv2.VideoCapture(str(input_path))
    
    if not video.isOpened():
        raise RuntimeError(f"could not open video file `{input_path}`")

    length = int(video.get(cv2.CAP_PROP_FRAME_COUNT))
    size = width * height

    print(f"Frame size: {size} bytes ({round(size / 512)} sectors)")
    print(f"Terminal size: {width}x{height} (width x height)")
    print(f"Total frames: {length} ({round(length / 30, 2)} seconds")
    
    data = b""

    for index in range(length):
        success, frame = video.read()

        if not success:
            raise RuntimeError(f"failed to read frame #{index}")

        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        data += process_frame(frame, width=width, height=height)

        print(f"Frame {index}/{length} ({round(index / length * 100, 2)}%)", end="\r")

    with open(output_path, "wb") as file:
        file.write(data)

if __name__ == "__main__":
    parser = ArgumentParser(description="A script for converting videos to an ASCII stream (for use with the bootloader)")

    parser.add_argument("input_path", type=Path, help="The input path to the video file.")
    parser.add_argument("--output_path", "-o", type=Path, help="The output path to the data file.", default=Path("video.bin"))

    parser.add_argument("--width", type=int, help="The width of the screen.", default=320)
    parser.add_argument("--height", type=int, help="The height of the screen.", default=200)

    main(**vars(parser.parse_args()))