# =============================================================================
# U-Boot mkimage with ASUS TAIL header support (host build tool)
#
# Built with the host compiler (not the cross toolchain).  Installed to
# tools/bin/ which is prepended to PATH during firmware image generation.
# This is a self-contained host tool — no package.mk / autotools overhead.
# =============================================================================

PKG_NAME := mkimage
SRC_DIR  := src

# Resolve ROOTDIR: exported by top-level Makefile in full builds; fall back
# to relative path when building tools standalone (make -C tools mkimage_only).
ROOTDIR  ?= $(abspath ../..)
BIN_DIR  ?= $(ROOTDIR)/tools/bin

SOURCES := $(SRC_DIR)/mkimage.c $(SRC_DIR)/crc32.c
HEADERS := $(SRC_DIR)/image.h

# tools/Makefile exports CC=gcc CFLAGS=-Wall -O2; append our include path.
CFLAGS  += -I$(SRC_DIR)

.PHONY: all clean

all: $(BIN_DIR)/mkimage

$(BIN_DIR)/mkimage: $(SOURCES) $(HEADERS)
	@echo "==> Compiling $(PKG_NAME)..."
	@mkdir -p $(BIN_DIR)
	$(CC) $(CFLAGS) -o $@ $(SOURCES)

clean:
	rm -f $(BIN_DIR)/mkimage
