from PIL import Image
import cv2

from argparse import ArgumentParser
from pathlib import Path

# constants
BRIGHTNESS_THRESHOLD = 0.5
TERMINAL_SIZE = (80, 25)

LIGHT_CHARACTER = b"#"
DARK_CHARACTER = b" "

def read_frame(capture: cv2.VideoCapture, index: int) -> Image.Image:
    capture.set(cv2.CAP_PROP_POS_FRAMES, index)

    ret, frame = capture.read()

    frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    frame = Image.fromarray(frame)

    return frame

def convert_to_binary(frame: Image.Image) -> bytes:
    image = frame.convert("L")
    image = image.resize(TERMINAL_SIZE)

    data = b""

    for pixel in image.getdata():
        if pixel / 255 >= BRIGHTNESS_THRESHOLD:
            data += LIGHT_CHARACTER
        else:
            data += DARK_CHARACTER

    data += b"\0" * 48

    return data
    
def main(input_path: Path, output_path: Path):
    if not input_path.exists():
        raise FileNotFoundError(f"input path `{input_path}` does not exist")

    capture = cv2.VideoCapture(str(input_path))
    frame_count = int(capture.get(cv2.CAP_PROP_FRAME_COUNT))

    data = b""

    if not capture.isOpened():
        raise RuntimeError(f"could not open video file `{input_path}`")

    for index in range(int(capture.get(cv2.CAP_PROP_FRAME_COUNT))):
        data += convert_to_binary(read_frame(capture, index))

        print(f"Converted frame {index + 1}/{frame_count}", end="\r")
    
    with open(output_path, "wb") as file:
        file.write(data)

if __name__ == "__main__":
    parser = ArgumentParser(description="A script for converting videos to an ASCII stream (for use with the bootloader)")

    parser.add_argument("input_path", type=Path, help="The input path to the video file.")
    parser.add_argument("--output_path", "-o", type=Path, help="The output path to the data file.", default=Path("video.bin"))

    main(**vars(parser.parse_args()))