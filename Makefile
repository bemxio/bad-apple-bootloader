# constants
CXX = g++
CXXFLAGS = -O2
CXXLIBS = -I/usr/include/opencv4 -lopencv_videoio -lopencv_imgproc -lopencv_core

AS = nasm
ASFLAGS = -f bin

QEMU = qemu-system-i386
QEMUFLAGS = -accel kvm

SRC_DIR = src
BUILD_DIR = build

SOURCES = $(sort $(wildcard $(SRC_DIR)/*.asm))
EXECUTABLE = bad_apple.img

VIDEO_PATH = video.flv

FPS = $(shell mediainfo --Output='Video;%FrameRate_Num%' $(VIDEO_PATH))
FRAME_COUNT = $(shell mediainfo --Output='Video;%FrameCount%' $(VIDEO_PATH))
RELOAD_VALUE = $$((1193182 / $(FPS)))

ASCII_GRADIENT = oxxo

# phony
.PHONY: all run clean

# targets
all: $(BUILD_DIR)/$(EXECUTABLE)

run: $(BUILD_DIR)/$(EXECUTABLE)
	$(QEMU) $(QEMUFLAGS) -drive format=raw,file=$^ 

clean:
	$(RM) -r build

# rules
$(BUILD_DIR)/$(EXECUTABLE): $(BUILD_DIR)/bootloader.bin $(BUILD_DIR)/data.bin
	cat $^ > $@

$(BUILD_DIR)/bootloader.bin: $(SOURCES) | $(BUILD_DIR)
	$(AS) $(ASFLAGS) -DPIT_RELOAD_VALUE=$(RELOAD_VALUE) -DFRAME_AMOUNT=$(FRAME_COUNT) $< -o $@

$(BUILD_DIR)/data.bin: $(VIDEO_PATH) $(BUILD_DIR)/converter | $(BUILD_DIR)
	$(BUILD_DIR)/converter $< $@

$(BUILD_DIR)/converter: $(SRC_DIR)/converter.cpp | $(BUILD_DIR)
	$(CXX) $(CXXLIBS) $(CXXFLAGS) $< -o $@

$(BUILD_DIR):
	mkdir -p $@