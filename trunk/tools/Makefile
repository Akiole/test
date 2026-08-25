# =============================================================================
# Host Tools Makefile
# Tools run on the build host (kernel compression, image generation,
# SquashFS creation, etc.). Must use host compiler, NOT the cross toolchain.
# All built binaries are installed into tools/bin/ (prepended to PATH).
# =============================================================================

include ../host-tools.mk

.PHONY: all clean

# Host compiler configuration
CC     = gcc
CXX    = g++
CFLAGS = -Wall -O2
export CC CXX CFLAGS

-include $(LINUX_CONFIG)

# Host tools (built independently, no interdependencies)
# lzma      - LZMA compressor (kernel image compression)
# mkimage   - U-Boot image generator (with ASUS TAIL support)
# squashfs  - SquashFS filesystem tools (mksquashfs / unsquashfs)
# sstrip    - ELF binary size reducer (optional, used only when enabled)
SUBDIRS = lzma mkimage squashfs sstrip

BUILD_TARGETS := $(patsubst %,%_only,$(SUBDIRS))
CLEAN_TARGETS := $(patsubst %,%_clean,$(SUBDIRS))

all: $(BUILD_TARGETS)

clean: $(CLEAN_TARGETS)
	@rm -rf $(CURDIR)/bin
	@echo "\033[1;30;42m CLEAN \033[0m Done"

%_only:
	@echo "\033[1;30;43m BUILD \033[0m \033[1;30;44m $(@:_only=) \033[0m"
	$(MAKE) -C $(@:_only=)

%_clean:
	@echo "\033[1;30;42m CLEAN \033[0m \033[1;30;44m $(@:_clean=) \033[0m"
	-$(MAKE) -C $(@:_clean=) clean
