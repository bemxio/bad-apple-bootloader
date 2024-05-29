# constants
CXX = g++
CXXFLAGS = -O2
CXXLIBS = -I/usr/include/opencv4 -lopencv_videoio -lopencv_imgproc -lopencv_core

AS = nasm
ASFLAGS = -f bin

PYTHON = python3

QEMU = qemu-system-i386
QEMUFLAGS = -accel kvm

SRC_DIR = src
BUILD_DIR = build

SOURCES = $(sort $(wildcard $(SRC_DIR)/*.asm))
EXECUTABLE = bootloader.bin

VIDEO_PATH = video.flv

FPS = $(shell mediainfo --Output='Video;%FrameRate_Num%' $(VIDEO_PATH))
FRAME_COUNT = $(shell mediainfo --Output='Video;%FrameCount%' $(VIDEO_PATH))
RELOAD_VALUE = $(shell expr 1193182 / $(FPS))

# targets
all: $(BUILD_DIR)/$(EXECUTABLE)

run: $(BUILD_DIR)/$(EXECUTABLE)
	$(QEMU) $(QEMUFLAGS) -drive format=raw,file=$^ 

clean:
	rm -rf build

# rules
$(BUILD_DIR)/$(EXECUTABLE): $(BUILD_DIR)/code.bin $(BUILD_DIR)/data.bin
	cat $^ > $@

$(BUILD_DIR)/code.bin: $(SOURCES) | $(BUILD_DIR)
	$(AS) $(ASFLAGS) -DPIT_RELOAD_VALUE=$(RELOAD_VALUE) -DFRAME_AMOUNT=$(FRAME_COUNT) $< -o $@

$(BUILD_DIR)/data.bin: $(VIDEO_PATH) $(BUILD_DIR)/converter | $(BUILD_DIR)
	$(BUILD_DIR)/converter $< $@

$(BUILD_DIR)/converter: $(SRC_DIR)/converter.cpp | $(BUILD_DIR)
	$(CXX) $(CXXLIBS) $(CXXFLAGS) $< -o $@

$(BUILD_DIR):
	mkdir -p $@