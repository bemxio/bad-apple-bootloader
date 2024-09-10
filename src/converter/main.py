from pathlib import Path
from typing import Generator
from argparse import ArgumentParser

import numpy as np
from toascii import Video, GrayscaleConverter, ConverterOptions
from toascii.gradients import BLOCK, HIGH, LOW, OXXO

GRADIENTS = {
    "block": BLOCK,
    "high": HIGH,
    "low": LOW,
    "oxxo": OXXO
}

class CustomConverter(GrayscaleConverter):
    def __init__(self, options):
        super().__init__(options)

        self.gradient = options.gradient
        self.g_l_m = len(self.gradient) - 1

    def _asciify_image(self, image: np.ndarray) -> Generator[bytes, None, None]:
        for row in image:
            for b, g, r in row:
                yield self.gradient[int((self._luminosity(r, g, b) / 255) * self.g_l_m)]

def main(input_path: Path, output_path: Path, gradient: str = "oxxo", width: int = 80, height: int = 25):
    if not input_path.exists(): # raise an error if the input path does not exist
        raise FileNotFoundError(f"Input path `{input_path}` does not exist.") 

    # initialize the video and the converter
    options = ConverterOptions(gradient=GRADIENTS[gradient], width=width, height=height)
    video = Video(str(input_path), converter=CustomConverter(options))

    # calculate the size of the frame and the filling
    size = width * height
    filling = 512 - (size % 512) + 1

    # print information about the video
    print(f"Frame size: {size} bytes ({round(size / 512)} sectors, with {filling} bytes of filling)")
    print(f"Terminal size: {width}x{height} (width x height)")

    with open(output_path, "wb") as file: # open the file in binary write mode
        for index, text in enumerate(video.get_ascii_frames(), start=1): # iterate over the frames
            if index == 1:
                length = video.source.frame_count # get the total number of frames

            # encode text to bytes, slice the last character and add filler bytes
            file.write(text.encode("utf-8")[:-1] + (b"\0" * filling))

            # print the progress
            print(f"Frame {index}/{length} ({round(index / length * 100, 2)}%)", end="\r")

if __name__ == "__main__":
    parser = ArgumentParser(description="A script for converting videos to an ASCII stream (for use with the bootloader).")

    # add the arguments
    parser.add_argument("input_path", type=Path, help="The input path to the video file.")
    parser.add_argument("--output_path", "-o", type=Path, help="The output path to the data file.", default=Path("video.bin"))

    parser.add_argument("--gradient", type=str, help="The character pattern to use with the ASCII stream.", choices=GRADIENTS.keys(), default="oxxo")

    parser.add_argument("--width", type=int, help="The width of the terminal.", default=80)
    parser.add_argument("--height", type=int, help="The height of the terminal.", default=25)

    # parse the arguments
    args = parser.parse_args()

    # run the main function
    main(args.input_path, args.output_path, args.gradient, args.width, args.height)
