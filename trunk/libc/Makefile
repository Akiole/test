# =============================================================================
# C Library Top-Level Makefile
# Auto-select musl or uClibc based on CROSS_COMPILE prefix (both prebuilt with toolchain)
# =============================================================================

.EXPORT_ALL_VARIABLES:
.PHONY: all romfs clean

ifndef ROOTDIR
# Resolve to absolute path: a relative '..' would break when sub-makes
# inherit it, since their CWD may be deeper.
ROOTDIR := $(abspath ..)
endif

ifndef ROMFSDIR
ROMFSDIR = $(ROOTDIR)/romfs
endif

include $(PROJECT_CONFIG)
include $(ARCH_CONFIG)

# Auto-detect libc: CROSS_COMPILE looks like "mipsel-linux-musl-"
LIBC = $(if $(findstring musl,$(CROSS_COMPILE)),musl,uclibc)

all:
	@echo "\033[1;30;43m BUILD \033[0m \033[1;30;44m libc ($(LIBC)) \033[0m"
	@$(MAKE) -C $(LIBC)
	@echo "\033[1;30;42m libc ($(LIBC)) \033[0m build complete"

romfs:
	@echo "\033[1;30;42m ROMFS \033[0m \033[1;30;44m libc ($(LIBC)) \033[0m"
	@$(MAKE) -C $(LIBC) romfs
	@echo "\033[1;30;42m libc ($(LIBC)) \033[0m installation complete"

clean:
	@echo "\033[1;30;42m CLEAN \033[0m \033[1;30;44m libc ($(LIBC)) \033[0m"
	@$(MAKE) -C $(LIBC) clean
	@echo "\033[1;30;42m libc ($(LIBC)) \033[0m clean complete"
