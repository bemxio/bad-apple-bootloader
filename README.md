# bad-apple-bootloader
A bootloader, specifically made for playing [Bad Apple](https://www.youtube.com/watch?v=UkgK8eUdpAo).
Inspired by the [GRUB](https://github.com/noeamiot/Bad-Apple-on-GRUB) version, and my urge for low-level programming.

## Usage
To build the bootloader in the easiest way, just follow the instructions below.

You can do it the manual way with an assembler, a video to ASCII converter and a virtualization software of your choice too, but then, you're on your own.

### Installing dependencies
For Windows, you can install [`scoop`](https://scoop.sh/) and run:
```powershell
scoop install nasm make python
```

As for Linux, all of the packages should be in your default package manager. Here's an example for Ubuntu:
```bash
sudo apt install nasm make python3
```

If you want to run the bootloader, you need to install QEMU as well, which can be done with either `scoop install qemu` or `sudo apt install qemu`, depending on your operating system.

Once you have Python installed, you will also need to install the dependencies for the `vid2data` converter. Simply do:
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
~~Sadly, it's really difficult to get the original speed of the video, since the CPU cannot keep a stable frame rate. If you want to get closer to the original speed, you can try to increase or decrease the `DELAY_TIME` value on line 63 in [`src/print.asm`](src/print.asm).~~

~~In the future, I might implement something bigger, like a custom interrupt handler, to get a stable frame rate. But for now, playing around with the `DELAY_TIME` value is the only thing you can try to make it run more faithfully.~~

After like a month or maybe even more, I finally understood how to set up the PIT and add a handler in the IVT, thus, the framerate is now fully faithful to the original! If it's still going too slow/fast though, you might need to adjust the `PIT_RELOAD_VALUE` value on line 2 in [`src/pit.asm`](src/pit.asm).

To calculate the reload value, simply use the equation:
```
Reload Value = floor(1193182 / FPS)
```
where `FPS` is the framerate of the original video.

## FAQ

### Why?
There are two main reasons for this project:

Firstly, I wanted to learn more about low-level programming, more specifically Assembly. I already made [an operating system](https://github.com/bemxio/bemxos), however, the Assembly side has attracted me the most. I wanted to challenge myself into using it for something bigger, in order to properly learn registers, interrupts and things like that. Perhaps, in the future, I will step into NES development!

Secondly, no one has done this before. As mentioned above, there is a GRUB version of it, but I wanted to make it from scratch, with bare Assembly, keeping it as minimal as possible. I also wanted to make it as easy to use as possible, so that anyone can put their own video in and build it.

### How does it work?
The `bootloader.bin` file is split into two parts - the first one is the bootloader itself, with all of the code, and the second one is the video data. 
The code reads each frame from the video data (for technical nerds, it uses LBA, using the "Extended Read Sectors From Drive" function) and displays it on the screen, by iterating over each character and calling an interrupt for each one.

## Contributions
Contributions are welcome, really welcome, in fact! If you want to contribute, whether it's just a simple question or a whole pull request, feel free to do so.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.