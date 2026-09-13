# constants
AS = nasm
ASFLAGS = -f bin

CC = gcc
CFLAGS = -Wall -O2

QEMU = qemu-system-i386
QEMUFLAGS = -accel kvm -serial stdio

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

ifdef DEBLOAT
	ASFLAGS += -DSIZE_OPTIMIZED
endif

# phony
.PHONY: all run clean

# targets
all: $(BUILD_DIR)/$(EXECUTABLE)

run: $(BUILD_DIR)/$(EXECUTABLE)
	$(QEMU) $(QEMUFLAGS) -drive format=raw,file=$^

clean:
	$(RM) -r build

# rules
$(BUILD_DIR)/$(EXECUTABLE): $(BUILD_DIR)/bootsector.bin $(BUILD_DIR)/frames.bin
	cat $^ > $@

$(BUILD_DIR)/bootsector.bin: $(SRC_DIR)/bootsector.asm $(SOURCES) | $(BUILD_DIR)
	$(AS) $(ASFLAGS) -DPIT_RELOAD_VALUE=$(RELOAD_VALUE) -DFRAME_AMOUNT=$(FRAME_AMOUNT) $< -o $@

$(BUILD_DIR)/frames.bin: $(BUILD_DIR)/compressor $(VIDEO_PATH) $(PALETTE_PATH) | $(BUILD_DIR)
	ffmpeg -i $(VIDEO_PATH) -f rawvideo -pix_fmt rgb24 -s 16x16 -i $(PALETTE_PATH) \
		-filter_complex '[0:v]scale=320:200[scaled];[scaled][1:v]paletteuse=dither=sierra2' \
		-f rawvideo -pix_fmt rgb24 - | $(BUILD_DIR)/compressor > $@

$(BUILD_DIR)/compressor: $(SRC_DIR)/compressor.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $^ -o $@ 

$(BUILD_DIR):
	mkdir -p $@