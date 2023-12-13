# bad-apple-bootloader
A bootloader, specifically made for playing [Bad Apple](https://www.youtube.com/watch?v=UkgK8eUdpAo).
Inspired by the [GRUB](https://github.com/noeamiot/Bad-Apple-on-GRUB) version, and my urge for low-level programming.

Check out the video [here](https://www.youtube.com/watch?v=eKCEhFYnbD8)!

## Usage
To build the bootloader in the easiest way, just follow the instructions below.

You can do it the manual way with an assembler, a video to ASCII converter and a virtualization software of your choice too, but then, you're on your own.

### Installing dependencies
For Windows, you can install [Scoop](https://scoop.sh/) and run:
```powershell
scoop install nasm make ffmpeg python
```

As for Linux, all of the packages should be in your default package manager. Here's an example for Ubuntu:
```bash
sudo apt install nasm make ffmpeg python3
```

If you want to run the bootloader, you need to install QEMU as well, which can be done with either `scoop install qemu` or `sudo apt install qemu`, depending on your operating system.

Once you have Python installed, you will also need to install the dependencies for the ASCII converter. Simply do:
```bash
python3 -m pip install -r src/vid2data/requirements.txt
```
and all of the needed packages will be installed. For Windows, you might need to write `py`/`python` instead of `python3`.

### Building
Before building the bootloader, you will need to do a couple of things. 

1. Download the video to be played. It can be anything you like, however grayscale videos work best. You can download the original Bad Apple video from [here](https://archive.org/details/TouhouBadApple).
2. Open the [`Makefile`](Makefile) and edit variables according to your configuration. The one you will most likely need to change is `VIDEO`, which should be set to the path of the video you downloaded in the previous step.
3. Simply run `make` in the root directory of the project.

This will build the bootloader in the `build/bootloader.bin` file.
If you installed QEMU and want to run the bootloader, you can do so by running `make run` in the root directory of the project.

### Troubleshooting

#### `qemu-system-i386: -accel kvm: invalid accelerator kvm`
By default, the Makefile uses KVM as an accelerator for QEMU. Since KVM is exclusive to Linux, you might need to change it to something else. If you are on Windows or macOS, you can comment the `QEMUFLAGS` variable altogether, the default one should work fine. If it doesn't work fine (runs really slowly), feel free to experiment with different accelerators (you can find a list of them [here](https://www.qemu.org/docs/master/system/introduction.html#virtualisation-accelerators)).

#### It's too slow/fast and/or the frame rate is unstable!
~~In the future, I might implement something bigger, like a custom interrupt handler, to get a stable frame rate.~~

After like a month or maybe even more, I finally understood how to set up the PIT and add a handler in the IVT, thus, the framerate is now fully faithful to the original!
If it is still too slow, that means your CPU might not be able to handle the video at the original framerate. In that case, you can change the `FPS` variable in the `Makefile` to a lower value.

## FAQ

### Why?
There are two main reasons for this project:

Firstly, I wanted to learn more about low-level programming, more specifically Assembly. I already made [an operating system](https://github.com/bemxio/bemxos), however, the Assembly side has attracted me the most. I wanted to challenge myself into using it for something bigger, in order to properly learn registers, interrupts and things like that. Perhaps, in the future, I will step into NES development!

~~Secondly, no one has done this before.~~
Actually, I was wrong. [@redstone_flash5774](https://www.youtube.com/channel/UCxL3ay5lRA4KvCX56sRIUeA) made their version and uploaded it to YouTube [here](https://www.youtube.com/watch?v=DsJH3SNYqvM). I didn't notice it at all in those 6 months, just found it out when I was uploading my video on YouTube. Still, our approaches to do it are different, and they have not uploaded the source code, so I guess I can still be proud of it!

### How does it work?
The `bootloader.bin` file is split into two parts - the first one is the bootloader itself, with all of the code, and the second one is the video data. 
The code reads each frame from the video data and displays it on the screen, by iterating over each character and calling an interrupt for each one.

## Contributions
Contributions are welcome, really welcome, in fact! If you want to contribute, whether it's just a simple question or a whole pull request, feel free to do so.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
