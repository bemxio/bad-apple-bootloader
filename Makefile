# constants
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

# targets
all: $(BUILD_DIR)/$(EXECUTABLE)

run: $(BUILD_DIR)/$(EXECUTABLE)
	$(QEMU) $(QEMUFLAGS) -drive format=raw,file=$^ 

clean:
	rm -rf build

# rules
$(BUILD_DIR)/$(EXECUTABLE): $(BUILD_DIR)/code.bin $(BUILD_DIR)/data.bin
	cat $^ > $@

$(BUILD_DIR)/code.bin: $(SOURCES)
	mkdir -p $(BUILD_DIR)

	$(AS) $(ASFLAGS) $< -o $@

$(BUILD_DIR)/data.bin: $(VIDEO_PATH)
	mkdir -p $(BUILD_DIR)

	$(PYTHON) $(SRC_DIR)/vid2data/main.py $< -o $@