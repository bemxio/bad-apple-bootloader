# constants
CXX = g++
CXXFLAGS = -I/usr/include/opencv5 -O3
CXXLIBS = -lopencv_videoio -lopencv_imgproc -lopencv_core

SRC_DIR = .
BUILD_DIR = ../../build

SOURCES = $(wildcard $(SRC_DIR)/*.cpp)
HEADERS = $(wildcard $(SRC_DIR)/*.hpp)
OBJECTS = $(patsubst $(SRC_DIR)/%.cpp,$(BUILD_DIR)/%.o,$(SOURCES))

# targets
all: $(BUILD_DIR)/converter

clean:
	$(RM) -r $(BUILD_DIR)

# rules
$(BUILD_DIR)/converter: $(OBJECTS) | $(BUILD_DIR)
	$(CXX) $(CXXLIBS) $^ -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp $(HEADERS) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR):
	mkdir -p $@