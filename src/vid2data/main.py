from toascii import Video, GrayscaleConverter, ConverterOptions
from toascii.gradients import OXXO
import numpy as np

from argparse import ArgumentParser
from typing import Generator
from pathlib import Path

class CustomConverter(GrayscaleConverter):
    def _asciify_image(self, image: np.ndarray) -> Generator[bytes, None, None]:
        g_l_m = len(self.options.gradient) - 1

        for row in image:
            for b, g, r in row:
                yield self.options.gradient[int((self._luminosity(r, g, b) / 255) * g_l_m)]

def get_filling_amount(size: int) -> int:
    amount = 0

    while amount < size:
        amount += 512

    return amount - size + 1

def main(input_path: Path, output_path: Path, width: int = 80, height: int = 25):
    if not input_path.exists():
        raise FileNotFoundError(f"input path `{input_path}` does not exist")

    options = ConverterOptions(gradient=OXXO, width=width, height=height)
    video = Video(str(input_path), converter=CustomConverter(options))

    size = width * height
    filling = b"\0" * get_filling_amount(size)

    print(f"Frame size: {size} bytes ({round(size / 512)} sectors, with {len(filling)} bytes of filling)")
    print(f"Terminal size: {width}x{height} (width x height)")

    data = b""

    for index, text in enumerate(video.get_ascii_frames(), start=1):
        if index == 1:
            length = video.source.frame_count

        data += text.encode("utf-8")[:-1] + filling

        print(f"Frame {index}/{length} ({round(index / length * 100, 2)}%)", end="\r")

    with open(output_path, "wb") as file:
        file.write(data)

if __name__ == "__main__":
    parser = ArgumentParser(description="A script for converting videos to an ASCII stream (for use with the bootloader)")

    parser.add_argument("input_path", type=Path, help="The input path to the video file.")
    parser.add_argument("--output_path", "-o", type=Path, help="The output path to the data file.", default=Path("video.bin"))
    parser.add_argument("--width", type=int, help="The width of the terminal.", default=80)
    parser.add_argument("--height", type=int, help="The height of the terminal.", default=25)

    main(**vars(parser.parse_args()))