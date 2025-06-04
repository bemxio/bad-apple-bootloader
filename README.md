# Bad Apple Bootloader
A program running inside the boot sector, specifically made for playing [Bad Apple](https://www.youtube.com/watch?v=UkgK8eUdpAo).
Inspired by the [GRUB](https://github.com/noeamiot/Bad-Apple-on-GRUB) version, and my urge for low-level programming.

Check out the video showcasing it [here](https://www.youtube.com/watch?v=eKCEhFYnbD8)!

## Usage
To build the bootloader in the easiest way, just follow the instructions below.

You can do it the manual way with an assembler, a converter that will genenerate the video data for you and a virtualization software of your choice too, but then, you're on your own.

### Dependencies
For Windows, you can install [Scoop](https://scoop.sh/) and run:
```powershell
scoop install nasm make mediainfo opencv
```

As for Linux, all of the packages should be in your default package manager. Here's an example for Debian-based distros:
```bash
sudo apt install nasm make mediainfo libopencv-dev
```

If you want to run the project, you need to install QEMU as well, by either using Scoop on Windows (`scoop install qemu`) or using your package manager on Linux (`sudo apt install qemu` for Debian).

### Building
Before building the project, you will need to do a couple of things. 

1. Download the video you want to be played. It can be anything you like, however grayscale videos work best. You can download the original Bad Apple video from [here](https://archive.org/details/TouhouBadApple).
2. Open the [`Makefile`](Makefile) and edit variables according to your configuration. The one you will most likely need to change is `VIDEO_PATH`, which should be set to the path of the video you downloaded in the previous step.
3. Simply run `make` in the root directory of the project.

After it's done, you should have a `build/image.img` file containing the bootsector code and the video data.
If you installed QEMU and want to execute the aforementioned image, you can do so by running `make run` in the root directory of the project.

### Troubleshooting
#### `qemu-system-i386: -accel kvm: invalid accelerator kvm`
By default, the Makefile uses KVM as an accelerator for QEMU. Since KVM is only available on Linux, you might need to change it to something else. If you are on Windows or macOS, you can comment the `QEMUFLAGS` variable altogether, QEMU should pick the best accelerator by default. If it doesn't work fine, feel free to experiment with different accelerators (you can find a list of them [here](https://www.qemu.org/docs/master/system/introduction.html#virtualisation-accelerators)).

#### It's too slow/fast and/or the frame rate is unstable!
~~In the future, I might implement something bigger, like a custom interrupt handler, to get a stable frame rate.~~ After like a month or maybe even more, I finally understood how to set up the PIT and add a handler in the IVT, thus, the framerate is now fully faithful to the original!
If it is still too slow, that means your CPU might not be able to handle the video at the original framerate.

## FAQ
### Why?
There are two main reasons for this project:

Firstly, I wanted to learn more about low-level programming, more specifically Assembly. I already made [an operating system](https://github.com/bemxio/bemxos), however, the Assembly side has attracted me the most. I wanted to challenge myself into using it for something bigger, in order to properly learn registers, interrupts and things like that. Perhaps, in the future, I will step into NES development!

~~Secondly, no one has done this before.~~
Actually, I was wrong. [@redstone_flash5774](https://www.youtube.com/channel/UCxL3ay5lRA4KvCX56sRIUeA) made their version and uploaded it to YouTube [here](https://www.youtube.com/watch?v=DsJH3SNYqvM). I didn't notice it at all while working on this, just found it out when I was uploading my showcase video on YouTube. Still, our approaches to do it are different, and they have not uploaded the source code, so I guess I can still be proud of it!

### How?
The `image.img` file is split into two parts - the first one is the bootsector code itself, and the second one is the video data.
The code reads each frame from the video data and displays it on the screen, by iterating over each frame, reading it from the disk to the video memory.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Contributions are welcome, really welcome, in fact! If you want to contribute, whether it's just a simple question or a whole pull request, feel free to do so.