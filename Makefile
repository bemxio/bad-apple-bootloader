# constants
AS = nasm
ASFLAGS = -f bin

CC = gcc
CFLAGS = -Wall -O2

QEMU = qemu-system-i386
QEMUFLAGS = -accel kvm -audiodev alsa,id=snd0 -device sb16,audiodev=snd0 -serial stdio

SRC_DIR = src
BUILD_DIR = build

SOURCES = $(wildcard $(SRC_DIR)/*.asm)
EXECUTABLE = image.img

VIDEO_PATH = video.mp4
PALETTE_PATH = palette.bin

# other constants calculated at build time
define ffprobe
$(shell ffprobe -v error -select_streams v:0 \
	-show_entries stream=$(1) \
	-of default=noprint_wrappers=1:nokey=1 $(2))
endef

FPS = $$(( $(call ffprobe,avg_frame_rate,$(VIDEO_PATH)) ))
FRAME_AMOUNT = $(call ffprobe,nb_frames,$(VIDEO_PATH))
RELOAD_VALUE = $$((1193182 / $(FPS)))

DEBLOAT = 1

ifdef DEBLOAT
	ASFLAGS += -DSIZE_OPTIMIZED
endif

# phony
.PHONY: all run clean

# targets
all: $(BUILD_DIR)/$(EXECUTABLE)

run: $(BUILD_DIR)/$(EXECUTABLE)
	$(QEMU) $(QEMUFLAGS) -drive format=raw,file=$^

run-vbox: $(BUILD_DIR)/$(EXECUTABLE)
	rm -rf /tmp/vbox && mkdir -p /tmp/vbox

	VBoxManage convertfromraw $< /tmp/vbox/image.vdi --format VDI
	VBoxManage createvm --basefolder /tmp/vbox --name "Bad Apple Bootloader" --register
	VBoxManage modifyvm "Bad Apple Bootloader" --memory 4 --cpus 1 --audio-driver default --audio-controller sb16 --audio-out on
	VBoxManage storagectl "Bad Apple Bootloader" --name "IDE Controller" --add ide --controller PIIX4
	VBoxManage storageattach "Bad Apple Bootloader" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium /tmp/vbox/image.vdi
	VBoxManage startvm "Bad Apple Bootloader" --type gui

clean:
	$(RM) -r build

# rules
$(BUILD_DIR)/$(EXECUTABLE): $(BUILD_DIR)/bootsector.bin $(BUILD_DIR)/sound.bin
	cat $^ > $@

$(BUILD_DIR)/bootsector.bin: $(SRC_DIR)/bootsector.asm $(BUILD_DIR)/frames.bin $(SOURCES) | $(BUILD_DIR)
	$(AS) $(ASFLAGS) -DPIT_RELOAD_VALUE=$(RELOAD_VALUE) -DFRAME_AMOUNT=$(FRAME_AMOUNT) \
		-DAUDIO_DATA_OFFSET=$$(( $(shell stat -c %s $(BUILD_DIR)/frames.bin) + 512 + 1 )) \
		$< -o $@

$(BUILD_DIR)/frames.bin: $(BUILD_DIR)/compressor $(VIDEO_PATH) $(PALETTE_PATH) | $(BUILD_DIR)
	ffmpeg -i $(VIDEO_PATH) -f rawvideo -pix_fmt rgb24 -s 16x16 -i $(PALETTE_PATH) \
		-filter_complex '[0:v]scale=320:200[scaled];[scaled][1:v]paletteuse=dither=sierra2' \
		-f rawvideo -pix_fmt rgb24 - | $(BUILD_DIR)/compressor > $@

	truncate -s %512 $@

$(BUILD_DIR)/sound.bin: $(VIDEO_PATH) | $(BUILD_DIR)
	ffmpeg -i $(VIDEO_PATH) -f s16le -ac 2 -ar 44100 -acodec pcm_s16le -vn $@
	truncate -s %512 $@

$(BUILD_DIR)/compressor: $(SRC_DIR)/compressor.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $^ -o $@ 

$(BUILD_DIR):
	mkdir -p $@