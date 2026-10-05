############################################################################
# Top-Level Makefile for Padavan-based Firmware
#
# Copyright (c) 2001-2004, SnapGear (www.snapgear.com)
# Copyright (c) 2001, Lineo
# Copyright (c) 2025-2026, TurBoTse
############################################################################

# === Configuration Check ===
ifeq ($(wildcard .config),)
  $(error .config file not found. Run './configure' first.)
endif

include .config
include versions.inc
include host-tools.mk

# Explicit default goal: host-tools.mk defines 'print-darwin-gnu-path'
# before 'all', which would otherwise become the default target.
.DEFAULT_GOAL := all

# === Directory Layout ===
ROOTDIR          := $(CURDIR)
LINUXDIR         := $(CONFIG_LINUXDIR)
LINUXINCDIR      := $(ROOTDIR)/$(LINUXDIR)/include
SCRIPTSDIR       := $(ROOTDIR)/config/scripts
ROMFSDIR         := $(ROOTDIR)/romfs
STAGEDIR         := $(ROOTDIR)/stage
IMAGEDIR         := $(ROOTDIR)/images
MERGE_DIR        := $(ROOTDIR)/merge
MERGE_ROOTFS     := $(MERGE_DIR)/$(CONFIG_FIRMWARE_PRODUCT_ID)/rootfs
LINUX_CONFIG     := $(ROOTDIR)/$(LINUXDIR)/.config

# macOS host lacks <elf.h>; provide glibc-compatible one for kernel host tools
# HOMEBREW_PREFIX is already defined by host-tools.mk (with /opt/homebrew fallback).
# HOST_EXTRACFLAGS is passed as an ENV prefix (before the command) so the kernel's
# own `HOST_EXTRACFLAGS +=` (scripts/dtc libfdt, selinux host tools) still appends:
# passing it as a command-line override silently discards those, breaking
# scripts/dtc (libfdt_env.h not found). HOSTLOADLIBES_* stay on the command line
# to override the kconfig makefile's auto-detected values.
ifdef IS_DARWIN
KERNEL_HOST_EXTRACFLAGS := HOST_EXTRACFLAGS="-I$(ROOTDIR)/tools/include/darwin -I$(HOMEBREW_PREFIX)/opt/gettext/include"
KERNEL_HOST_LDLIBS := HOSTLOADLIBES_conf="-L$(HOMEBREW_PREFIX)/opt/gettext/lib -lintl" HOSTLOADLIBES_mconf="-L$(HOMEBREW_PREFIX)/opt/gettext/lib -lintl"
endif

PROJECT_CONFIG   := $(ROOTDIR)/.config
TFTPDIR          := $(or $(TFTPDIR),\
                         $(if $(filter-out n,$(CONFIG_TFTPDIR)),$(CONFIG_TFTPDIR)),\
                         /tftpboot)

# === Toolchain ===
CONFIG_CROSS_COMPILER_PATH := $(CONFIG_CROSS_COMPILER_ROOT)/bin
CONFIG_CMAKE_TOOLCHAIN_FILE := $(ROOTDIR)/vendors/cmake/cross-mipsel-linux.cmake
KERNEL_HEADERS_PATH        := $(CONFIG_CROSS_COMPILER_ROOT)/$(CONFIG_CROSS_COMPILE)/sysroot/usr/include

# === Tools ===
TOOLS_DIR        := $(ROOTDIR)/tools
TOOLBIN_DIR      := $(TOOLS_DIR)/bin
DEPMOD           := $(TOOLS_DIR)/depmod.sh
ROMFSINST        := $(TOOLS_DIR)/romfs-inst.sh
UNPACKTRX        := $(TOOLS_DIR)/unpack-trx.sh
STRIPROMFS       := $(TOOLS_DIR)/strip-romfs.sh
# Built host tools are symlinked into TOOLBIN_DIR by tools/Makefile;
# TOOLBIN_DIR is prepended to PATH so they can also be invoked directly.
# sstrip is optional: only set when CONFIG_FIRMWARE_PERFORM_SSTRIP=y;
# consumers check [ -x "$SSTRIP_TOOL" ] before use
SSTRIP_TOOL      := $(if $(filter y,$(CONFIG_FIRMWARE_PERFORM_SSTRIP)),$(TOOLBIN_DIR)/sstrip)
LZMA_TOOL        := $(TOOLBIN_DIR)/lzma
MKIMAGE_TOOL     := $(TOOLBIN_DIR)/mkimage
MKSQUASHFS_TOOL  := $(TOOLBIN_DIR)/mksquashfs
UNSQSHFS_TOOL    := $(TOOLBIN_DIR)/unsquashfs

# === Architecture Configuration ===
ifeq ($(wildcard config.arch),config.arch)
  ifeq ($(filter %_default,$(MAKECMDGOALS)),)
    include config.arch
    export ARCH_CONFIG := $(ROOTDIR)/config.arch
  endif
endif

# === Kernel Build Commands ===
ifneq ($(SUBARCH),)
  MAKEARCH        := $(MAKE) ARCH=$(SUBARCH) CROSS_COMPILE=$(CROSS_COMPILE)
  MAKEARCH_KERNEL := $(MAKE) ARCH=$(ARCH) SUBARCH=$(SUBARCH) CROSS_COMPILE=$(CROSS_COMPILE)
else
  MAKEARCH        := $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)
  MAKEARCH_KERNEL := $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)
endif

# === ccache Setup ===
# DARWIN_GNU_PATH from host-tools.mk provides all GNU tool dirs on macOS (single source of truth).
BASE_PATH := $(TOOLBIN_DIR):$(if $(IS_DARWIN),$(DARWIN_GNU_PATH):,)$(CONFIG_CROSS_COMPILER_PATH):$(PATH):$(TOOLS_DIR)

ifeq ($(CONFIG_CCACHE),y)
  CCACHE_BIN := $(or $(CONFIG_CCACHE_BIN),$(shell command -v ccache 2>/dev/null))
  ifeq ($(CCACHE_BIN),)
    $(warning [ccache] not found, disabling CONFIG_CCACHE)
    override CONFIG_CCACHE := n
    PATH := $(BASE_PATH)
  else
    CCACHE_DIR                 := $(or $(CONFIG_CCACHE_DIR),$(ROOTDIR))/.ccache
    CCACHE_WRAPPER_DIR         := $(CONFIG_CROSS_COMPILER_ROOT)/ccache-wrappers
    WRAPPERS                   := $(addprefix $(CROSS_COMPILE), gcc g++ cc c++ cpp)
    PATH := $(CCACHE_WRAPPER_DIR):$(BASE_PATH)
    export CCACHE_DIR
  endif
else
  PATH := $(BASE_PATH)
endif
export PATH

# === Exported Variables ===
export \
  VENDOR PRODUCT CONFIG_WITHOUT_KERNEL CONFIG_CCACHE \
  CONFIG_CROSS_COMPILER_ROOT CONFIG_CROSS_COMPILER_PATH CONFIG_CROSS_COMPILE \
  CROSS_COMPILE CONFIG_CMAKE_TOOLCHAIN_FILE KERNEL_HEADERS_PATH \
  SSTRIP_TOOL LZMA_TOOL MKIMAGE_TOOL MKSQUASHFS_TOOL UNSQSHFS_TOOL \
  PROJECT_CONFIG LINUX_CONFIG ROOTDIR LINUXDIR ROMFSDIR STAGEDIR MERGE_DIR SCRIPTSDIR IMAGEDIR RELFILES TFTPDIR \
  FIRMWARE_KERNEL_VER FIRMWARE_ROOTFS_VER FIRMWARE_BUILDS_VER FIRMWARE_BUILDS_REV VERSIONPKG VERSIONSTR \
  ROMFSINST UNPACKTRX STRIPTOOL OBJCOPY

# === Build Targets ===
DIRS := libc libs user

.PHONY: all config dep tools unpack_trx linux modules modules_install modules_copy bin_copy \
        romfs romfs.subdirs romfs.post image \
        sparse sparseall subdirs clean tools_clean kernel_clean distclean ccache-wrappers

# Force serial execution for top-level targets; sub-parallelism via $(JOBS)
.NOTPARALLEL:

# === Default Build Flow ===
ifeq ($(CONFIG_WITHOUT_KERNEL),y)
  all: dep tools unpack_trx libc_only libs_only user_only romfs image
else
  all: dep tools linux libc_only libs_only user_only romfs image
endif

# === Configuration and Dependencies ===
ifeq ($(CONFIG_CCACHE),y)
config: ccache-wrappers
endif

config:
	@echo "\033[1;34m===> 🛠️ Configuring build environment for firmware...\033[0m"
	@if [ ! -d "$(CONFIG_CROSS_COMPILER_PATH)" ] || [ ! -x "$(CONFIG_CROSS_COMPILER_PATH)/$(CROSS_COMPILE)gcc" ]; then \
		echo "\033[1;31m===> ❌ Cross-compiler path $(CONFIG_CROSS_COMPILER_PATH) invalid or compiler $(CROSS_COMPILE)gcc not found\033[0m"; \
		echo "\033[1;33m===> ℹ️ Please verify CONFIG_CROSS_COMPILER_ROOT and CONFIG_CROSS_COMPILE in .config\033[0m"; \
		exit 1; \
	fi
	@case "$(CONFIG_CROSS_COMPILE)" in \
		*musl*|*uclibc*) \
			if [ ! -f "$(KERNEL_HEADERS_PATH)/sys/queue.h" ]; then \
				echo "\033[1;36m===> 🔧 sys/queue.h missing, installing from local source...\033[0m"; \
				mkdir -p "$$(dirname "$(KERNEL_HEADERS_PATH)/sys/queue.h")" && \
				cp -f "$(ROOTDIR)/tools/include/queue.h" "$(KERNEL_HEADERS_PATH)/sys/queue.h" && \
				echo "\033[1;32m===> ✅ queue.h installed.\033[0m"; \
			else \
				echo "\033[1;32m===> ✅ queue.h already exists.\033[0m"; \
			fi; \
			if [ ! -f "$(KERNEL_HEADERS_PATH)/utime.h" ]; then \
				echo "\033[1;36m===> 🔧 utime.h missing, installing from local source...\033[0m"; \
				cp -f "$(ROOTDIR)/tools/include/utime.h" "$(KERNEL_HEADERS_PATH)/utime.h" && \
				echo "\033[1;32m===> ✅ utime.h installed.\033[0m"; \
			else \
				echo "\033[1;32m===> ✅ utime.h already exists.\033[0m"; \
			fi; \
			;; \
	esac
	@./configure || { echo "\033[1;31m===> ❌ Configuration failed, check ./configure output for details (error code: $$?)\033[0m"; exit 1; }
	@if [ "$(CONFIG_CCACHE)" = "y" ]; then \
		echo "\033[1;32m===> ⚙️ ccache enabled, cache directory: $(CCACHE_DIR), binary: $(CCACHE_BIN)\033[0m"; \
	else \
		echo "\033[1;33m===> ℹ️ ccache disabled (ccache not found or CONFIG_CCACHE=n)\033[0m"; \
	fi

ifeq ($(CONFIG_CCACHE),y)
ccache-wrappers:
	@mkdir -p "$(CCACHE_WRAPPER_DIR)"
	@for bin in $(WRAPPERS); do \
		target="$(CCACHE_WRAPPER_DIR)/$$bin"; \
		if [ -L "$$target" ]; then \
			link=$$(readlink "$$target"); \
			if [ "$$link" = "$(CCACHE_BIN)" ]; then \
				echo "\033[1;33m→ Wrapper $$target exists — skipping creation\033[0m" >&2; \
				continue; \
			fi; \
		fi; \
		if [ -e "$$target" ]; then \
			echo "\033[1;33m→ Wrapper $$target exists but incorrect — recreating\033[0m" >&2; \
			rm -f "$$target"; \
		fi; \
		echo "\033[1;32m→ Creating wrapper: $$target\033[0m" >&2; \
		ln -sf "$(CCACHE_BIN)" "$$target" || { \
			echo "\033[1;31m===> ❌ Failed to create wrapper $$target (error code: $$?)\033[0m" >&2; \
			exit 1; \
		}; \
	done
	@for bin in $(WRAPPERS); do \
		if [ ! -e "$(CCACHE_WRAPPER_DIR)/$$bin" ]; then \
			echo "\033[1;31m===> ❌ ccache wrapper $(CCACHE_WRAPPER_DIR)/$$bin not created\033[0m" >&2; \
			exit 1; \
		fi; \
	done
endif

dep: config
	@echo "\033[1;34m===> 🔍 Preparing kernel configuration for $(FIRMWARE_KERNEL_VER).$(FIRMWARE_ROOTFS_VER)...\033[0m"
	@$(KERNEL_HOST_EXTRACFLAGS) $(MAKEARCH_KERNEL) $(KERNEL_HOST_LDLIBS) -C $(LINUXDIR) olddefconfig || { echo "\033[1;31m===> ❌ Kernel olddefconfig failed (error code: $$?)\033[0m"; exit 1; }
	@$(KERNEL_HOST_EXTRACFLAGS) $(MAKEARCH_KERNEL) $(KERNEL_HOST_LDLIBS) -C $(LINUXDIR) modules_prepare || { echo "\033[1;31m===> ❌ Kernel modules_prepare failed (error code: $$?)\033[0m"; exit 1; }
	@echo "\033[1;32m===> ✅ Kernel configuration prepared\033[0m"

# === Tool Build ===
tools:
	@echo "\033[1;34m===> 🔨 Building tools for firmware...\033[0m"
	@$(MAKE) $(JOBS) -C tools || { echo "\033[1;31m===> ❌ Tools build failed (error code: $$?)\033[0m"; exit 1; }
	@for tool in $(LZMA_TOOL) $(MKIMAGE_TOOL) $(MKSQUASHFS_TOOL) $(UNSQSHFS_TOOL); do \
		if [ ! -x "$$tool" ]; then \
			echo "\033[1;31m===> ❌ Tool $$tool not found or not executable\033[0m"; \
			exit 1; \
		fi; \
	done
	@echo "\033[1;32m===> ✅ Tools build completed\033[0m"

# === Firmware Extraction ===
unpack_trx:
	@echo "\033[1;34m===> 📦 Extracting TRX firmware to $(MERGE_DIR)...\033[0m"
	@$(UNPACKTRX) || { echo "\033[1;31m===> ❌ TRX unpack failed (error code: $$?)\033[0m"; exit 1; }
	@echo "\033[1;32m===> ✅ TRX firmware extracted\033[0m"

# === Kernel Build ===
linux:
	@echo "\033[1;30;43m BUILD \033[0m \033[1;30;44m Linux kernel version $(FIRMWARE_KERNEL_VER).$(FIRMWARE_ROOTFS_VER)...\033[0m"
	@$(KERNEL_HOST_EXTRACFLAGS) $(MAKEARCH_KERNEL) $(KERNEL_HOST_LDLIBS) $(JOBS) -C $(LINUXDIR) $(LINUXTARGET) || { echo "\033[1;31m===> ❌ Kernel build failed (error code: $$?)\033[0m"; exit 1; }
	@[ -f $(LINUXDIR)/vmlinux ] && ln -f $(LINUXDIR)/vmlinux $(LINUXDIR)/linux || \
		{ echo "\033[1;31m===> ❌ Failed to link vmlinux to linux\033[0m"; exit 1; }
	@echo "\033[1;32m===> ✅ Kernel build completed\033[0m"

# === Kernel Modules ===
modules:
	@echo "\033[1;34m===> 🔨 Building kernel modules for $(FIRMWARE_KERNEL_VER).$(FIRMWARE_ROOTFS_VER)...\033[0m"
	@if $(GREP) -q 'CONFIG_MODULES=y' $(LINUX_CONFIG); then \
		mkdir -p $(LINUXDIR)/modules; \
		$(KERNEL_HOST_EXTRACFLAGS) $(MAKEARCH_KERNEL) $(KERNEL_HOST_LDLIBS) $(JOBS) -C $(LINUXDIR) modules || \
			{ echo "\033[1;31m===> ❌ Module build failed (error code: $$?)\033[0m"; exit 1; }; \
	else \
		echo "\033[1;33m===> ℹ️ Kernel module support disabled in $(LINUX_CONFIG)\033[0m"; \
	fi
	@echo "\033[1;32m===> ✅ Kernel modules build completed\033[0m"

modules_install:
	@echo "\033[1;34m===> 📦 Installing kernel modules to $(ROMFSDIR)/lib/modules...\033[0m"
	@mkdir -p $(ROMFSDIR)/lib/modules
	@if $(GREP) -q 'CONFIG_MODULES=y' $(LINUX_CONFIG); then \
		$(MAKEARCH_KERNEL) -C $(LINUXDIR) INSTALL_MOD_PATH=$(ROMFSDIR) DEPMOD=$(DEPMOD) modules_install || \
			{ echo "\033[1;31m===> ❌ Module installation failed (error code: $$?)\033[0m"; exit 1; }; \
	else \
		echo "\033[1;33m===> ℹ️ Kernel module support disabled in $(LINUX_CONFIG)\033[0m"; \
	fi
	@echo "\033[1;32m===> ✅ Kernel modules installation completed\033[0m"

modules_copy:
	@echo "\033[1;34m===> 📦 Copying merged kernel modules to $(ROMFSDIR)/lib/modules...\033[0m"
	@mkdir -p $(ROMFSDIR)/lib/modules
	@if [ ! -d "$(MERGE_ROOTFS)/lib/modules" ]; then \
		echo "\033[1;33m===> ℹ️ No modules directory found at $(MERGE_ROOTFS)/lib/modules\033[0m"; \
	else \
		cp -rfa $(MERGE_ROOTFS)/lib/modules/. $(ROMFSDIR)/lib/modules/ || \
			{ echo "\033[1;31m===> ❌ Module copy failed (error code: $$?)\033[0m"; exit 1; }; \
		echo "\033[1;32m===> ✅ Modules copied to $(ROMFSDIR)/lib/modules\033[0m"; \
	fi

# === Binary Copy ===
bin_copy:
	@echo "\033[1;34m===> 📦 Copying merged binaries to $(ROMFSDIR)...\033[0m"
	@mkdir -p $(ROMFSDIR)
	@if [ ! -f "$(MERGE_DIR)/file_list" ]; then \
		echo "\033[1;33m===> ℹ️ No binary file list found at $(MERGE_DIR)/file_list\033[0m"; \
	else \
		$(GREP) -v '^#' "$(MERGE_DIR)/file_list" | while read -r f; do \
			[ -z "$$f" ] && continue; \
			if [ -f "$(MERGE_ROOTFS)/$$f" ]; then \
				mkdir -p "$$(dirname "$(ROMFSDIR)/$$f")"; \
				cp -fP "$(MERGE_ROOTFS)/$$f" "$(ROMFSDIR)/$$f" || \
					{ echo "\033[1;31m===> ❌ Failed to copy $$f (error code: $$?)\033[0m"; exit 1; }; \
				echo "\033[1;32m===> ✅ Copied $$f to $(ROMFSDIR)/$$f\033[0m"; \
			else \
				echo "\033[1;33m===> ℹ️ Skipping missing file: $$f\033[0m"; \
			fi; \
		done; \
	fi
	@echo "\033[1;32m===> ✅ Binary copy completed\033[0m"

# === ROMFS Build ===
ifeq ($(CONFIG_WITHOUT_KERNEL),y)
  romfs: romfs.subdirs modules_copy bin_copy romfs.post
else
  romfs: romfs.subdirs modules_install romfs.post
endif

romfs.subdirs: $(patsubst %,%_romfs,vendors $(DIRS))
	@echo "\033[1;32m===> ✅ ROMFS subdirectories processed\033[0m"

romfs.post:
	@echo "\033[1;34m===> 🧩 Post-processing ROMFS in $(ROMFSDIR)...\033[0m"
	@if [ ! -d "$(ROMFSDIR)" ]; then \
		echo "\033[1;31m===> ❌ ROMFS directory $(ROMFSDIR) does not exist\033[0m"; \
		exit 1; \
	fi
	@find $(ROMFSDIR) -type d -name CVS -exec rm -rf {} + 2>/dev/null || \
		{ echo "\033[1;33m===> ⚠️ Warning: Failed to remove some CVS directories\033[0m"; }
	@$(STRIPROMFS) || { echo "\033[1;31m===> ❌ ROMFS stripping failed (error code: $$?)\033[0m"; exit 1; }
	@$(MAKEARCH) $(JOBS) -C vendors romfs.post || { echo "\033[1;31m===> ❌ Vendors romfs.post failed (error code: $$?)\033[0m"; exit 1; }
	@echo "\033[1;32m===> ✅ ROMFS post-processing completed\033[0m"

# === Firmware Image ===
image: romfs
	@echo "\033[1;34m===> 🧱 Generating firmware image in $(IMAGEDIR)...\033[0m"
	@mkdir -p $(IMAGEDIR)
	@echo "[*] Building image with $(JOBS) job(s)..."
	@$(MAKEARCH) $(JOBS) -C vendors image || \
		{ echo "\033[1;31m===> ❌ Image generation failed (error code: $$?)\033[0m"; exit 1; }
	@{ \
		echo ""; \
		echo "\033[1;33m🎉 Firmware Image Summary:\033[0m"; \
		echo " 📦 Toolchain       : $(CONFIG_CROSS_COMPILE)"; \
		echo " 📂 Toolchain Path  : $(or $(CONFIG_CROSS_COMPILER_ROOT),Not set)"; \
		echo " 🌐 Toolchain URL   : $(or $(TOOLCHAIN_URL),Not set)"; \
		echo " 💬 Firmware Image Size:"; \
		if ls $(IMAGEDIR)/*.trx >/dev/null 2>&1; then \
			for f in $(IMAGEDIR)/*.trx; do \
				size=$$(ls -lh "$$f" | awk '{print $$5}'); \
				echo " 📄 $$f: $$size"; \
			done; \
		else \
			echo " ⚠️ No .trx files found in \033[1;36m$(IMAGEDIR)\033[0m"; \
		fi; \
		echo ""; \
		echo "\033[1;33m📡 Default Firmware Login Info:\033[0m"; \
		echo " 🌐 IP Address : $(or $(LANIP),192.168.2.1)"; \
		echo " 👤 Username   : $(or $(SIGNACCOUNT),admin)"; \
		echo " 🔐 Password   : $(or $(SIGNPASSWORD),admin)"; \
		echo ""; \
		echo "\033[1;32m✅ Build completed at: $$(date)\033[0m"; \
		echo ""; \
	}

# === Sparse Checking ===
sparse:
	@echo "\033[1;34m===> 🔍 Performing sparse check on kernel...\033[0m"
	@$(MAKEARCH_KERNEL) -C $(LINUXDIR) C=1 $(LINUXTARGET) || { echo "\033[1;31m===> ❌ Sparse check failed (error code: $$?)\033[0m"; exit 1; }
	@echo "\033[1;32m===> ✅ Sparse check completed\033[0m"

sparseall:
	@echo "\033[1;34m===> 🔍 Performing full sparse check on kernel...\033[0m"
	@$(MAKEARCH_KERNEL) -C $(LINUXDIR) C=2 $(LINUXTARGET) || { echo "\033[1;31m===> ❌ Full sparse check failed (error code: $$?)\033[0m"; exit 1; }
	@echo "\033[1;32m===> ✅ Full sparse check completed\033[0m"

# === Subdirectory Build ===
subdirs: $(patsubst %,%_only,$(DIRS))

# === Clean Targets ===
clean: tools_clean kernel_clean $(patsubst %,%_clean,$(DIRS))
	@echo "\033[1;33m===> 🧹 Cleaning build artifacts for firmware...\033[0m"
	@rm -rf $(STAGEDIR) $(ROMFSDIR) $(IMAGEDIR) $(MERGE_DIR) $(ROOTDIR)/build
	@rm -rf $(LINUXDIR)/net/ipsec/alg/libaes $(LINUXDIR)/net/ipsec/alg/perlasm
	@rm -f $(LINUXDIR)/arch/mips/ramdisk/*.gz $(LINUXDIR)/linux
	@echo "\033[1;32m===> ✅ Clean completed\033[0m"

distclean: clean
	@echo "\033[1;33m===> 🧹 Removing all build and configuration artifacts for firmware...\033[0m"
ifeq ($(CONFIG_CCACHE),y)
	@echo "\033[1;33m===> 🧹 Removing ccache wrappers...\033[0m"
	@rm -rf $(CCACHE_WRAPPER_DIR) || { echo "\033[1;31m===> ❌ Failed to remove $(CCACHE_WRAPPER_DIR) (error code: $$?)\033[0m"; exit 1; }
endif
	@rm -rf $(ROOTDIR)/build/tmp
	@rm -f .config config.arch
	@echo "\033[1;32m===> ✅ Distclean completed\033[0m"

tools_clean:
	@echo "\033[1;33m===> 🧹 Cleaning tools directory...\033[0m"
	@$(MAKE) -C tools clean || { echo "\033[1;31m===> ❌ Tools clean failed (error code: $$?)\033[0m"; exit 1; }
	@echo "\033[1;32m===> ✅ Tools clean completed\033[0m"

kernel_clean:
	@echo "\033[1;33m===> 🧹 Cleaning kernel source in $(LINUXDIR)...\033[0m"
	@$(MAKEARCH_KERNEL) -C $(LINUXDIR) distclean || { echo "\033[1;31m===> ❌ Kernel clean failed (error code: $$?)\033[0m"; exit 1; }
	@echo "\033[1;32m===> ✅ Kernel clean completed\033[0m"

# === Generic Rules ===
# Use Make built-in functions instead of expr to avoid spawning subshells
%_romfs:
	@if [ "$(dir $@)" != "./" ]; then \
		d="$(patsubst %/,%,$(dir $@))"; \
		t="$(notdir $@)"; \
		$(MAKEARCH) $(JOBS) -C $$d $$t || { echo "\033[1;31m===> ❌ Romfs failed in $$d (target: $$t). See above for details.\033[0m"; exit 1; }; \
	else \
		$(MAKEARCH) $(JOBS) -C $(@:_romfs=) romfs || { echo "\033[1;31m===> ❌ Romfs failed for $(@:_romfs=). See above for details.\033[0m"; exit 1; }; \
	fi

%_only:
	@if [ "$(dir $@)" != "./" ]; then \
		d="$(patsubst %/,%,$(dir $@))"; \
		t="$(notdir $@)"; \
		$(MAKEARCH) -C $$d $$t || { echo "\033[1;31m===> ❌ Build failed in $$d (target: $$t). See above for the failing package.\033[0m"; exit 1; }; \
	else \
		$(MAKEARCH) -C $(@:_only=) || { echo "\033[1;31m===> ❌ Build failed in $(@:_only=). See above for the failing package.\033[0m"; exit 1; }; \
	fi

%_clean:
	@if [ "$(dir $@)" != "./" ]; then \
		d="$(patsubst %/,%,$(dir $@))"; \
		t="$(notdir $@)"; \
		$(MAKEARCH) $(JOBS) -C $$d $$t || { echo "\033[1;33m===> ⚠️ Clean failed in $$d (target: $$t), continuing.\033[0m"; }; \
	else \
		$(MAKEARCH) $(JOBS) -C $(@:_clean=) clean || { echo "\033[1;33m===> ⚠️ Clean failed for $(@:_clean=), continuing.\033[0m"; }; \
	fi