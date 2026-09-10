# ============================================================
# Local crosstool-ng toolchain build (macOS + Linux)
# crosstool-ng 1.29.0 with custom samples; kernel headers from ../trunk/linux-4.4.x
#
# Sample configs live in trunk/libc/<libc>/<target>/crosstool.config
#
# Required:
#   macOS: brew install autoconf automake bash binutils bison coreutils diffutils findutils \
#                  flex gawk gcc gettext gnu-sed gnu-tar gpatch grep gperf help2man \
#                  libtool m4 make ncurses pkg-config texinfo wget xz
#   Linux: apt install autoconf automake bison flex gawk gperf gettext help2man libtool \
#                  texinfo libncurses-dev
#
# Optional (for some source packages):
#   macOS: brew install meson ninja subversion
#   Linux: apt install meson ninja-build subversion
#
# Usage:
#   make -C toolchain build       # build from source (musl default)
#   make -C toolchain download    # download prebuilt toolchain
#   make -C toolchain package     # package built toolchain
#
# Environment variables:
#   CT_TARGET=mipsel-linux-musl   # build musl instead of uclibc
#   CT_LOCAL_TARBALLS_DIR=/path   # source tarball cache (default: toolchain/tarballs)
#                                 # set empty to disable: CT_LOCAL_TARBALLS_DIR=
#   CT_PREFIX=/path               # install prefix (default: toolchain/<target>)
# ============================================================

TOPDIR       := $(CURDIR)
CT_VERSION   := 1.29.0
CT_TARGET    ?= mipsel-linux-musl
CT_PREFIX    ?= $(TOPDIR)/$(CT_TARGET)

include $(TOPDIR)/../trunk/host-tools.mk

# Paths
CT_DIR       := $(TOPDIR)/crosstool-ng-$(CT_VERSION)
CT_URL       := https://github.com/crosstool-ng/crosstool-ng/releases/download/crosstool-ng-$(CT_VERSION)/crosstool-ng-$(CT_VERSION).tar.xz

# Source tarball cache (default: toolchain/tarballs)
# Override: CT_LOCAL_TARBALLS_DIR=/path/to/cache
# Disable:  CT_LOCAL_TARBALLS_DIR=
TARBALLS_DIR := $(TOPDIR)/tarballs
CT_LOCAL_TARBALLS_DIR ?= $(TARBALLS_DIR)

# Toolchain samples: trunk/libc/<libc>/<target>/
CT_LIBC      := $(lastword $(subst -, ,$(CT_TARGET)))
SAMPLE_DIR   := $(TOPDIR)/../trunk/libc/$(CT_LIBC)/$(CT_TARGET)

# Platform-specific tarball naming for GitHub Releases
# HOST_OS_LOWER / HOST_ARCH provided by host-tools.mk
TOOLCHAIN_PLATFORM := $(HOST_OS_LOWER)-$(HOST_ARCH)
TOOLCHAIN_TARBALL  := $(CT_TARGET)-$(TOOLCHAIN_PLATFORM).tar.xz
TOOLCHAIN_RELEASE_BASE ?= https://github.com/TurBoTse/padavan/releases/download/toolchain
TOOLCHAIN_URL      ?= $(TOOLCHAIN_RELEASE_BASE)/$(TOOLCHAIN_TARBALL)

# musl lacks sys/queue.h (BSD extension); install from trunk/tools/include
QUEUE_H_LOCAL := $(TOPDIR)/../trunk/tools/include/queue.h

ifeq ($(IS_DARWIN),Darwin)
# Reuse HOMEBREW_PREFIX / DARWIN_GNU_PATH / SED / TAR / PATCH from host-tools.mk
# (single source of truth — do not redefine them here).
CT_BREW_PATH := $(DARWIN_GNU_PATH)
NPROC := $(HOST_NCPU)
# host-tools.mk already overrides $(MAKE) to gmake on Darwin.
CT_MAKE := $(MAKE)

# Force a valid macOS deployment target.  On newer macOS (darwin27+),
# crosstool-NG derives -mmacosx-version-min=18.0 from uname -r, but the
# system assembler (/usr/bin/as, clang-based) rejects versions it doesn't
# know.  Pin to a widely-supported version that both GNU GCC and clang accept.
MACOSX_DEPLOYMENT_TARGET := 14.0

# GNU GCC is required as the host compiler for building cross-GCC on macOS.
# /usr/bin/gcc is a clang shim and does not support GCC-specific flags
# (e.g. -print-multi-os-directory) used by the GCC build system.
#
# Host GCC version: prefer the same major version as the toolchain's target
# GCC (read from crosstool.config, e.g. CT_GCC_V_13=y → gcc-13).  Using a
# matching version avoids incompatibilities between new host GCC and old
# bundled tools (e.g. m4 1.4.20 fails to build with GCC 16).
# Falls back to the highest installed version if the matching one isn't found.
TOOLCHAIN_GCC_MAJOR := $(shell $(SED_READ) -n 's/^CT_GCC_V_\([0-9]*\)=y/\1/p' "$(SAMPLE_DIR)/crosstool.config" 2>/dev/null | head -1)
GNU_GCC_VER := $(shell if [ -n "$(TOOLCHAIN_GCC_MAJOR)" ] && [ -x "$(HOMEBREW_PREFIX)/bin/gcc-$(TOOLCHAIN_GCC_MAJOR)" ]; then echo "$(TOOLCHAIN_GCC_MAJOR)"; else ls "$(HOMEBREW_PREFIX)"/bin/gcc-* 2>/dev/null | grep -oE '[0-9]+$$' | sort -rn | head -1; fi)
ifeq ($(GNU_GCC_VER),)
$(error No GNU GCC found via Homebrew. Install with: brew install gcc)
endif
HOST_CC := $(HOMEBREW_PREFIX)/bin/gcc-$(GNU_GCC_VER)
HOST_CXX := $(HOMEBREW_PREFIX)/bin/g++-$(GNU_GCC_VER)
else
NPROC := $(HOST_NCPU)
CT_MAKE := $(MAKE)
HOST_CC := gcc
HOST_CXX := g++
endif

.PHONY: all build download package install-queue-h toolchain-info clean distclean

all: build

# Build toolchain from source via crosstool-ng, then auto-package it.
build:
	@CT_TARBALL="$(TOPDIR)/crosstool-ng-$(CT_VERSION).tar.xz"; \
	if [ ! -d "$(CT_DIR)" ]; then \
		if [ -f "$$CT_TARBALL" ]; then \
			echo "==> using local crosstool-ng-$(CT_VERSION).tar.xz"; \
		else \
			echo "==> downloading crosstool-ng-$(CT_VERSION) ..."; \
			curl -fSsL -o "$$CT_TARBALL" "$(CT_URL)" || \
			{ echo "Error: Failed to download crosstool-ng"; rm -f "$$CT_TARBALL"; exit 1; }; \
		fi; \
		$(TAR) -xJf "$$CT_TARBALL" -C "$(TOPDIR)" || \
		{ echo "Error: Failed to extract crosstool-ng (tarball may be corrupted)"; rm -f "$$CT_TARBALL"; exit 1; }; \
	fi
	@mkdir -p "$(TARBALLS_DIR)"
	@if [ -x "$(CT_PREFIX)/bin/$(CT_TARGET)-gcc" ] && ! "$(CT_PREFIX)/bin/$(CT_TARGET)-gcc" --version >/dev/null 2>&1; then \
		echo "==> removing unusable (foreign-platform) toolchain at $(CT_PREFIX)"; \
		rm -rf "$(CT_PREFIX)"; \
	fi
	@set -e; \
		cd "$(CT_DIR)"; \
	if [ -n "$(IS_DARWIN)" ]; then \
		if [ ! -x ./ct-ng ]; then \
			echo "==> building crosstool-ng on macOS"; \
			export PATH="$(CT_BREW_PATH):$$PATH:$(HOMEBREW_PREFIX)/opt/binutils/bin"; \
			export CPPFLAGS="-I$(HOMEBREW_PREFIX)/opt/ncurses/include -I$(HOMEBREW_PREFIX)/opt/gettext/include"; \
			export LDFLAGS="-L$(HOMEBREW_PREFIX)/opt/ncurses/lib -L$(HOMEBREW_PREFIX)/opt/gettext/lib"; \
			export CC=clang; \
			export CXX=clang++; \
			./bootstrap; \
			./configure --enable-local; \
			PATH="$(CT_BREW_PATH):$$PATH" $(CT_MAKE) -j$(NPROC); \
		fi; \
		unset CC CXX CFLAGS LDFLAGS CPPFLAGS CXXFLAGS; \
		HOST_CC_BINDIR="$(CT_DIR)/.hostcc-bin"; \
		mkdir -p "$$HOST_CC_BINDIR"; \
		ln -sf "$(HOST_CC)" "$$HOST_CC_BINDIR/gcc"; \
		ln -sf "$(HOST_CXX)" "$$HOST_CC_BINDIR/g++"; \
		export PATH="$$HOST_CC_BINDIR:$(CT_BREW_PATH):$$PATH"; \
		export MACOSX_DEPLOYMENT_TARGET="$(MACOSX_DEPLOYMENT_TARGET)"; \
	else \
		if [ ! -x ./ct-ng ]; then \
			echo "==> building crosstool-ng on Linux"; \
			./bootstrap; \
			./configure --enable-local; \
			$(CT_MAKE) -j$(NPROC); \
		fi; \
		unset CC CXX CFLAGS LDFLAGS CPPFLAGS CXXFLAGS; \
	fi; \
	echo "==> configuring $(CT_TARGET)"; \
	DEFCONFIG="$(SAMPLE_DIR)/crosstool.config" ./ct-ng defconfig; \
	if [ -n "$(CT_LOCAL_TARBALLS_DIR)" ]; then \
		echo "==> using local tarballs dir: $(CT_LOCAL_TARBALLS_DIR)"; \
		echo "CT_LOCAL_TARBALLS_DIR=\"$(CT_LOCAL_TARBALLS_DIR)\"" >> .config; \
	fi; \
	echo "==> building toolchain (this may take a while)"; \
	./ct-ng build; \
	echo "==> toolchain built at $(CT_PREFIX)"
	@$(MAKE) install-queue-h
	@$(MAKE) package

# Package the built toolchain into a platform-specific tarball for GitHub Releases.
# Excludes build.log.bz2 and ccache-wrappers/ to keep the tarball small.
# Output: $(TOPDIR)/$(TOOLCHAIN_TARBALL), e.g. mipsel-linux-musl-darwin-arm64.tar.xz
package:
	@if [ ! -x "$(CT_PREFIX)/bin/$(CT_TARGET)-gcc" ]; then \
		echo "==> Error: toolchain not found at $(CT_PREFIX), cannot package"; exit 1; \
	fi
	@echo "==> packaging toolchain: $(TOOLCHAIN_TARBALL)"
	@pkg_dir="$$(dirname "$(CT_PREFIX)")"; pkg_name="$$(basename "$(CT_PREFIX)")"; \
	 cd "$$pkg_dir" && $(TAR) -cJf "$(TOPDIR)/$(TOOLCHAIN_TARBALL)" --exclude=build.log.bz2 --exclude=ccache-wrappers "$$pkg_name"
	@echo "==> toolchain packaged: $(TOPDIR)/$(TOOLCHAIN_TARBALL)"

# Print toolchain component versions in key=value format (for CI release notes).
# Reads from the generated crosstool-NG .config after a successful build.
# Usage: make -C toolchain toolchain-info CT_TARGET=mipsel-linux-musl
toolchain-info:
	@CT_CONFIG="$(CT_DIR)/.config"; \
	if [ ! -f "$$CT_CONFIG" ]; then \
		echo "Error: .config not found at $$CT_CONFIG (run 'make build' first)"; exit 1; \
	fi; \
	extract_ver() { \
		$(GREP) -oE "$$1" "$$CT_CONFIG" 2>/dev/null | head -1 | \
			$(SED_READ) -E 's/.*_V_([0-9_]+)=y/\1/;s/_/./g'; \
	}; \
	GCC_VER=$$(extract_ver 'CT_GCC_V_[0-9_]+=y'); \
	BINUTILS_VER=$$(extract_ver 'CT_BINUTILS_V_[0-9_]+=y'); \
	LINUX_VER=$$(extract_ver 'CT_LINUX_V_[0-9_]+=y'); \
	GDB_VER=$$(extract_ver 'CT_GDB_V_[0-9_]+=y'); \
	if $(GREP) -q 'CT_LIBC_MUSL=y' "$$CT_CONFIG"; then \
		LIBC="musl"; LIBC_VER=$$(extract_ver 'CT_MUSL_V_[0-9_]+=y'); \
	elif $(GREP) -q 'CT_LIBC_UCLIBC_NG=y' "$$CT_CONFIG"; then \
		LIBC="uClibc-ng"; LIBC_VER=$$(extract_ver 'CT_UCLIBC_NG_V_[0-9_]+=y'); \
	fi; \
	echo "CT_TARGET=$(CT_TARGET)"; \
	echo "CT_VERSION=$(CT_VERSION)"; \
	echo "HOST_OS=$(HOST_OS)"; \
	echo "HOST_ARCH=$(HOST_ARCH)"; \
	echo "TOOLCHAIN_PLATFORM=$(TOOLCHAIN_PLATFORM)"; \
	echo "TOOLCHAIN_TARBALL=$(TOOLCHAIN_TARBALL)"; \
	echo "GCC_VER=$${GCC_VER:-N/A}"; \
	echo "BINUTILS_VER=$${BINUTILS_VER:-N/A}"; \
	echo "LINUX_VER=$${LINUX_VER:-N/A}"; \
	echo "LIBC=$${LIBC:-N/A}"; \
	echo "LIBC_VER=$${LIBC_VER:-N/A}"; \
	echo "GDB_VER=$${GDB_VER:-N/A}"

# musl does not ship sys/queue.h (BSD extension); some packages
# (e.g. libwebsockets) depend on it. Install from trunk/tools/include.
install-queue-h:
	@if [ "$(CT_TARGET)" = "mipsel-linux-musl" ]; then \
		QH="$(CT_PREFIX)/$(CT_TARGET)/sysroot/usr/include/sys/queue.h"; \
		if [ ! -f "$$QH" ]; then \
			echo "==> installing sys/queue.h from local source"; \
			mkdir -p "$$(dirname "$$QH")"; \
			cp -f "$(QUEUE_H_LOCAL)" "$$QH" || \
			{ echo "Error: Failed to copy queue.h"; exit 1; }; \
		fi; \
	fi

download:
	@$(VERIFY_TOOLCHAIN_FUNC) \
	if verify_tc "$(CT_PREFIX)" "$(CT_TARGET)"; then \
		echo "==> toolchain already present (verified): $(CT_PREFIX)"; \
	else \
		if [ -f "$(TOPDIR)/$(TOOLCHAIN_TARBALL)" ]; then \
			echo "==> using local toolchain tarball: $(TOOLCHAIN_TARBALL)"; \
			rm -rf "$(CT_PREFIX)"; \
			$(TAR) -xJf "$(TOPDIR)/$(TOOLCHAIN_TARBALL)" -C "$(TOPDIR)" || \
			{ echo "Error: Failed to extract local tarball"; rm -rf "$(CT_PREFIX)"; exit 1; }; \
		else \
			echo "==> downloading prebuilt $(CT_TARGET) ($(TOOLCHAIN_PLATFORM)) ..."; \
			echo "    url: $(TOOLCHAIN_URL)"; \
			rm -rf "$(CT_PREFIX)"; \
			curl -fLsS --retry 3 -o "$(CT_PREFIX).tar.xz" "$(TOOLCHAIN_URL)" && \
			$(TAR) -xJf "$(CT_PREFIX).tar.xz" -C "$(TOPDIR)" && \
			rm -f "$(CT_PREFIX).tar.xz" || \
			{ echo "Error: Failed to download/extract prebuilt toolchain"; rm -rf "$(CT_PREFIX)" "$(CT_PREFIX).tar.xz"; exit 1; }; \
		fi; \
		verify_tc "$(CT_PREFIX)" "$(CT_TARGET)" || \
		{ echo "Error: Toolchain incomplete after extract/download"; rm -rf "$(CT_PREFIX)"; rm -f "$(TOPDIR)/$(TOOLCHAIN_TARBALL)"; exit 1; }; \
	fi
	@$(MAKE) install-queue-h
	@echo "==> toolchain ready at $(CT_PREFIX)"

clean:
	@if [ -d "$(CT_DIR)" ]; then \
		cd "$(CT_DIR)"; \
		[ -x ./ct-ng ] && ./ct-ng distclean || true; \
		[ -f Makefile ] && $(CT_MAKE) distclean || true; \
	fi
	@echo "==> cleaned crosstool-ng build artifacts"

distclean: clean
	@if [ -n "$(CT_PREFIX)" ] && [ "$(CT_PREFIX)" != "/" ] && [ "$(CT_PREFIX)" != "$(TOPDIR)" ] && [ "$(CT_PREFIX)" != "." ]; then \
		rm -rf "$(CT_PREFIX)"; \
		echo "==> removed $(CT_PREFIX)"; \
	else \
		echo "==> refusing to remove unsafe CT_PREFIX: $(CT_PREFIX)"; \
	fi
	@rm -f "$(TOPDIR)/crosstool-ng-$(CT_VERSION).tar.xz" "$(TOPDIR)/$(TOOLCHAIN_TARBALL)"
	@echo "==> removed source/toolchain tarballs"
