# constants
AS = nasm
ASFLAGS = -f bin

QEMU = qemu-system-i386.exe

SRC_DIR = src
BUILD_DIR = build

SOURCE = bootloader.asm
EXECUTABLE = bootloader.bin

# targets
all: $(BUILD_DIR)/$(EXECUTABLE)

run: $(BUILD_DIR)/$(EXECUTABLE)
	qemu-system-i386.exe -drive format=raw,file=$^

clean:
	rm -rf build

# rules
$(BUILD_DIR)/$(EXECUTABLE): $(SRC_DIR)/$(SOURCE)
	mkdir -p $(BUILD_DIR)

	$(AS) $(ASFLAGS) $^ -o $@