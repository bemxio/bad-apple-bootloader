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

## FAQ

### Why?
There are two main reasons for this project:

Firstly, I wanted to learn more about low-level programming, more specifically Assembly. I already made [an operating system](https://github.com/bemxio/bemxos), however, the Assembly side has attracted me the most. I wanted to challenge myself into using it for something bigger, in order to properly learn registers, interrupts and things like that. Perhaps, in the future, I will step into NES development!

Secondly, no one has done this before. As mentioned above, there is a GRUB version of it, but I wanted to make it from scratch, with bare Assembly, keeping it as minimal as possible. I also wanted to make it as easy to use as possible, so that anyone can put their own video in and build it.

### How does it work?
The `bootloader.bin` file is split into two parts - the first one is the bootloader itself, with all of the code, and the second one is the video data. 
The code reads each frame from the video data (for technical nerds, it uses LBA, using the "Extended Read Sectors From Drive" function) and displays it on the screen, by iterating over each character and calling an interrupt for each one.

<!--
### Why is it so fast?
The ["Wait"](http://www.ctyme.com/intr/rb-1525.htm) function didn't work and kept breaking disk reads, that's why as of now, I left it as it is. I might try to fix it in the future (from what I've searched so far, I will need to use interrupt handlers for that). 
If you want to get closer to the original speed, you can uncomment the lines 26-27 in `src/bootloader.asm`. That will make the bootloader wait for keyboard input instead of jumping instantly. With that, you can just hold down any key, and the video will play at a speed closer to the original.
-->

## Contributions
Contributions are welcome, really welcome, in fact! If you want to contribute, whether it's just a simple question or a whole pull request, feel free to do so.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.