# Compiler and flags
CC = gcc
AS = as
CFLAGS = -O0 -march=rv64imafdc
ASFLAGS = -g

# Directories
SRC_DIR = src
BUILD_DIR = build

# Source and target files
SRC_FILES = $(wildcard $(SRC_DIR)/*.s)
OBJ_FILES = $(patsubst $(SRC_DIR)/%.s,$(BUILD_DIR)/%.o,$(SRC_FILES))
TARGET = myconvert

all: $(TARGET)

$(TARGET): $(OBJ_FILES)
	$(CC) $(CFLAGS) -static -o $@ $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s $(SRC_DIR)/myconvert.h
	$(AS) -I$(SRC_DIR) $(ASFLAGS)  -o $@ $<

clean:
	find . -name '*~' -type f -delete
	rm -f $(TARGET) $(OBJ_FILES)
