# constants
AS = nasm
ASFLAGS = -f bin

SOURCE_DIR = src
BUILD_DIR = build

MAIN_SOURCE = main.asm
EXECUTABLE = bootloader.bin

# targets
all: $(BUILD_DIR)/$(EXECUTABLE)

run: $(BUILD_DIR)/$(EXECUTABLE)
	qemu-system-i386 -drive format=raw,file=$^

clean:
	rm -rf build

# rules
$(BUILD_DIR)/$(EXECUTABLE): $(SOURCE_DIR)/$(MAIN_SOURCE)
	mkdir -p $(BUILD_DIR)

	$(AS) $(ASFLAGS) $^ -o $@