# constants
CXX = g++
CXXFLAGS = -std=c++11 -O2 $(shell pkg-config --cflags opencv4)
LIBS = $(shell pkg-config --libs opencv4)

SRC_DIR = src/vid2data
BUILD_DIR = build

SOURCE = main.cpp
EXECUTABLE = vid2data.exe

# targets
all: $(BUILD_DIR)/$(EXECUTABLE)

clean:
	rm -rf $(BUILD_DIR)/$(EXECUTABLE)

# rules
$(BUILD_DIR)/$(EXECUTABLE): $(SRC_DIR)/$(SOURCE)
	mkdir -p $(BUILD_DIR)

	$(CXX) $(CXXFLAGS) $^ -o $@