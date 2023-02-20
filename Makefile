# constants
AS = nasm
ASFLAGS = -f bin

PYTHON = python.exe
QEMU = qemu-system-i386.exe

SRC_DIR = src
BUILD_DIR = build

SOURCE = bootloader.asm
EXECUTABLE = bootloader.bin

VIDEO_PATH = video.flv

# targets
all: $(BUILD_DIR)/$(EXECUTABLE)

run: $(BUILD_DIR)/$(EXECUTABLE)
	qemu-system-i386.exe -drive format=raw,file=$^

clean:
	rm -rf build

# rules
$(BUILD_DIR)/$(EXECUTABLE): $(BUILD_DIR)/code.bin $(BUILD_DIR)/data.bin
	cat $(BUILD_DIR)/code.bin $(BUILD_DIR)/data.bin > $(BUILD_DIR)/$(EXECUTABLE)

$(BUILD_DIR)/code.bin: $(SRC_DIR)/$(SOURCE)
	mkdir -p $(BUILD_DIR)

	$(AS) $(ASFLAGS) $^ -o $(BUILD_DIR)/code.bin

$(BUILD_DIR)/data.bin: $(VIDEO_PATH)
	mkdir -p $(BUILD_DIR)

	$(PYTHON) $(SRC_DIR)/vid2data/main.py $(VIDEO_PATH) -o $(BUILD_DIR)/data.bin