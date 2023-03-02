# constants
CXX = g++
CXXFLAGS = -std=c++11 -O2
LIBS = $(shell pkg-config --cflags --libs opencv4)

SRC_DIR = .
BUILD_DIR = ../../build

SOURCE = main.cpp
EXECUTABLE = vid2data

# targets
all: $(BUILD_DIR)/$(EXECUTABLE)

clean:
	rm -rf $(BUILD_DIR)/$(EXECUTABLE)

# rules
$(BUILD_DIR)/$(EXECUTABLE): $(SRC_DIR)/$(SOURCE)
	mkdir -p $(BUILD_DIR)

	$(CXX) $(CXXFLAGS) -o $@ $^ $(LIBS)