# =====================================================
# Padavan Firmware Build System - Top-Level Makefile
#
# Required:
#   macOS: brew install bash gawk gcc gnu-sed gnu-tar gpatch m4 xz wget curl git python3 ccache cmake pkg-config
#   Linux: apt install build-essential gawk wget curl git python3 ccache cmake pkg-config
#
# Optional:
#   macOS: brew install meson ninja
#   Linux: apt install meson ninja-build
#
# Notes:
#   - macOS requires GNU sed/tar because build scripts use GNU extensions
#   - GNU gcc is required for building the cross toolchain from source on macOS
#   - ccache is optional but highly recommended for repeated builds
#   - Xcode Command Line Tools must be installed on macOS (xcode-select --install)
# =====================================================

# === Project Layout ===
TOPDIR          := $(CURDIR)
SOURCE_DIR      := $(TOPDIR)/trunk
TEMPLATE_DIR    := $(SOURCE_DIR)/configs/templates
CONFIG_FILE     := $(SOURCE_DIR)/.config

include $(SOURCE_DIR)/host-tools.mk

# === Toolchain ===
TOOLCHAIN       ?= mipsel-linux-musl
TOOLCHAIN_ROOT  := $(TOPDIR)/toolchain
TOOLCHAIN_PATH  := $(TOOLCHAIN_ROOT)/$(TOOLCHAIN)
TOOLCHAIN_CC    := $(TOOLCHAIN_PATH)/bin/$(TOOLCHAIN)-gcc

# Host platform detection for selecting matching prebuilt toolchain
# e.g. darwin-arm64, darwin-x86_64, linux-x86_64, linux-aarch64
# HOST_OS_LOWER / HOST_ARCH provided by host-tools.mk
TOOLCHAIN_PLATFORM := $(HOST_OS_LOWER)-$(HOST_ARCH)

# Prebuilt toolchain URL: platform-specific only.
# Release asset naming: <toolchain>-<os>-<arch>.tar.xz  (e.g. mipsel-linux-musl-darwin-arm64.tar.xz)
# Tarball top-level is the triplet dir (e.g. mipsel-linux-musl/), extracted into toolchain/ root.
TOOLCHAIN_RELEASE_BASE ?= https://github.com/TurBoTse/padavan/releases/download/toolchain
TOOLCHAIN_TARBALL := $(TOOLCHAIN)-$(TOOLCHAIN_PLATFORM).tar.xz
TOOLCHAIN_URL ?= $(TOOLCHAIN_RELEASE_BASE)/$(TOOLCHAIN_TARBALL)

# === Auto-discovered target products ===
PRODUCTS        := $(notdir $(basename $(wildcard $(TEMPLATE_DIR)/*.config)))

# Toolchain verification is provided by host-tools.mk as VERIFY_TOOLCHAIN_FUNC
# (parameterized: verify_tc <prefix> <triplet>).  Used by toolchain / toolchain-download.

.PHONY: all build clean distclean deps toolchain-deps toolchain toolchain-download toolchain-build toolchain-package $(PRODUCTS)

all: build

# Install all build dependencies automatically via the system package manager.
# macOS: Homebrew (brew).  Linux: apt (Debian/Ubuntu).
# Run once before the first build:  make deps
# This is the single source of truth for build dependencies — CI workflows
# (build.yml, custom.yml) call `make deps` instead of maintaining duplicate lists.
deps:
	@echo "\033[1;36m===> 📦 Installing build dependencies...\033[0m"
	@if [ "$(HOST_OS)" = "Darwin" ]; then \
		if ! command -v brew >/dev/null 2>&1; then \
			echo "\033[1;31m===> ❌ Homebrew not found. Install from https://brew.sh\033[0m"; exit 1; \
		fi; \
		echo "==> Using Homebrew (macOS)"; \
		export HOMEBREW_NO_REQUIRE_TAP_TRUST=1; \
		brew untap aws/tap 2>/dev/null || true; \
		brew install autoconf automake bash bc binutils bison ccache cmake coreutils curl diffutils \
		            file findutils flex gawk gcc gettext git gmp gnu-sed gnu-tar gpatch grep gperf \
		            help2man jq libmpc libtool lzo m4 make mpfr ncurses pkg-config python3 texinfo wget xz; \
		pip3 install docutils 2>/dev/null || true; \
		echo ""; \
		echo "\033[1;32m===> ✅ macOS dependencies installed.\033[0m"; \
	else \
		if ! command -v apt-get >/dev/null 2>&1; then \
			echo "\033[1;31m===> ❌ apt-get not found. Unsupported Linux distro, install deps manually.\033[0m"; exit 1; \
		fi; \
		echo "==> Using apt (Debian/Ubuntu)"; \
		sudo apt-get update && sudo apt-get install -y \
			autoconf automake autopoint bc build-essential bison ccache cmake cpio \
			fakeroot flex gawk gettext gperf help2man jq kmod libltdl-dev liblzma-dev \
			liblzo2-dev libmpc-dev libmpfr-dev libncurses-dev libgmp-dev libtool-bin \
			pkg-config python3-docutils texinfo unzip xxd zlib1g-dev zip; \
		echo ""; \
		echo "\033[1;32m===> ✅ Linux dependencies installed.\033[0m"; \
	fi

# Install only the minimal dependencies required to build the cross toolchain
# via crosstool-ng (no firmware-build extras like ccache/cmake/python3).
# Used by CI toolchain workflow:  make toolchain-deps
toolchain-deps:
	@echo "\033[1;36m===> 📦 Installing toolchain build dependencies...\033[0m"
	@if [ "$(HOST_OS)" = "Darwin" ]; then \
		if ! command -v brew >/dev/null 2>&1; then \
			echo "\033[1;31m===> ❌ Homebrew not found. Install from https://brew.sh\033[0m"; exit 1; \
		fi; \
		echo "==> Using Homebrew (macOS)"; \
		export HOMEBREW_NO_REQUIRE_TAP_TRUST=1; \
		brew untap aws/tap 2>/dev/null || true; \
		brew install autoconf automake bash bc binutils bison coreutils curl diffutils findutils \
		            flex gawk gcc gettext git gmp gnu-sed gnu-tar gpatch grep gperf help2man \
		            libmpc libtool lzo m4 make mpfr ncurses pkg-config python3 texinfo unzip wget xz; \
		echo ""; \
		echo "\033[1;32m===> ✅ macOS toolchain dependencies installed.\033[0m"; \
	else \
		if ! command -v apt-get >/dev/null 2>&1; then \
			echo "\033[1;31m===> ❌ apt-get not found. Unsupported Linux distro, install deps manually.\033[0m"; exit 1; \
		fi; \
		echo "==> Using apt (Debian/Ubuntu)"; \
		sudo apt-get update && sudo apt-get install -y \
			autoconf automake bc build-essential bison cpio curl flex gawk gettext git gperf \
			help2man libltdl-dev libmpc-dev libmpfr-dev libgmp-dev libncurses-dev libtool-bin \
			pkg-config python3 texinfo unzip wget xz-utils; \
		echo ""; \
		echo "\033[1;32m===> ✅ Linux toolchain dependencies installed.\033[0m"; \
	fi

# Toolchain: use local if present and complete, else download prebuilt, else build from source
# Completeness check: gcc --version + key binaries (ld/as/ar/ranlib/strip/objcopy) + sysroot headers + crt1.o
toolchain:
	@$(VERIFY_TOOLCHAIN_FUNC) \
	if verify_tc "$(TOOLCHAIN_PATH)" "$(TOOLCHAIN)"; then \
		echo "\033[1;32m===> ✅ Toolchain ready (local, verified): $(TOOLCHAIN)\033[0m"; \
	else \
		echo "\033[1;36m===> 🔎 Toolchain not found or incomplete, acquiring $(TOOLCHAIN)...\033[0m"; \
		$(MAKE) toolchain-download || $(MAKE) toolchain-build; \
	fi

# Delegate download to toolchain/Makefile (single source of truth).
# TOOLCHAIN_URL is passed through so top-level overrides propagate down.
toolchain-download:
	@$(VERIFY_TOOLCHAIN_FUNC) \
	if verify_tc "$(TOOLCHAIN_PATH)" "$(TOOLCHAIN)"; then \
		echo "\033[1;32m===> ✅ Toolchain already present (verified): $(TOOLCHAIN), skip download\033[0m"; \
	else \
		$(MAKE) -C "$(TOOLCHAIN_ROOT)" download \
			CT_TARGET="$(TOOLCHAIN)" \
			CT_PREFIX="$(TOOLCHAIN_PATH)" \
			TOOLCHAIN_URL="$(TOOLCHAIN_URL)"; \
	fi

# Build toolchain from source via crosstool-ng.
# Auto-packages the result (toolchain/Makefile 'build' calls 'package').
toolchain-build:
	@echo "\033[1;33m===> 🔨 Building toolchain from source...\033[0m"
	@$(MAKE) -C "$(TOOLCHAIN_ROOT)" build CT_TARGET="$(TOOLCHAIN)" CT_PREFIX="$(TOOLCHAIN_PATH)"
	@if ! "$(TOOLCHAIN_CC)" --version >/dev/null 2>&1; then \
		echo "\033[1;31m===> ❌ Toolchain source build failed\033[0m"; exit 1; \
	fi

# Package an already-built toolchain into a platform-specific tarball.
# Delegates to toolchain/Makefile 'package' (single source of truth).
# Output: toolchain/$(TOOLCHAIN_TARBALL), e.g. mipsel-linux-musl-darwin-arm64.tar.xz
toolchain-package:
	@$(MAKE) -C "$(TOOLCHAIN_ROOT)" package CT_TARGET="$(TOOLCHAIN)" CT_PREFIX="$(TOOLCHAIN_PATH)"

build: toolchain
	@echo "\033[1;36m===> 🔎 Validating firmware configuration...\033[0m"
	@if [ ! -f "$(CONFIG_FILE)" ]; then \
		echo "\033[1;31m===> ❌ Missing .config file.\033[0m"; \
		echo "\033[1;36m===> 💡 Available build targets:\033[0m"; \
		for p in $(PRODUCTS); do echo "  - $$p"; done; \
		exit 1; \
	fi
	@echo "\033[1;32m===> 🛠️ Initiating firmware compilation ($(JOBS) jobs)...\033[0m"
	@$(MAKE) -C $(SOURCE_DIR) all

# Device-specific firmware configuration and build
# TOOLCHAIN resolution priority:
#   1. Command-line / environment override (e.g. make TOOLCHAIN=mipsel-linux-uclibc K2P-USB)
#   2. CONFIG_TOOLCHAIN_LIBC in the template (musl/uclibc)
#   3. Default: musl
TOOLCHAIN_OVERRIDE := $(filter command line environment,$(origin TOOLCHAIN))
$(PRODUCTS):
	@if [ -n "$(TOOLCHAIN_OVERRIDE)" ]; then \
		TC="$(TOOLCHAIN)"; \
		LIBC=$$(echo "$$TC" | $(SED_READ) 's/^mipsel-linux-//'); \
	else \
		LIBC=$$($(GREP) -m1 '^CONFIG_TOOLCHAIN_LIBC=' "$(TEMPLATE_DIR)/$@.config" 2>/dev/null | cut -d= -f2); \
		LIBC=$${LIBC:-musl}; \
		TC="mipsel-linux-$$LIBC"; \
	fi; \
	echo "\033[1;36m===> ⚙️ Setting up configuration for target: $@ (libc: $$LIBC)\033[0m"; \
	cp -f "$(TEMPLATE_DIR)/$@.config" "$(CONFIG_FILE)"; \
	printf '\n%s\n%s\n%s\n%s\n%s\n' \
		"CONFIG_CROSS_COMPILE=$$TC" \
		"CONFIG_CROSS_COMPILER_ROOT=$(TOOLCHAIN_ROOT)/$$TC" \
		"TOOLCHAIN_URL=$(TOOLCHAIN_URL)" \
		"CONFIG_CCACHE=y" \
		"CONFIG_CCACHE_DIR=$(SOURCE_DIR)" \
		>> "$(CONFIG_FILE)"; \
	echo "\033[1;32m===> 📝 Configuration generated: $(CONFIG_FILE)\033[0m"; \
	$(MAKE) build TOOLCHAIN="$$TC"

clean:
	@echo "\033[1;36m===> 🧼 Cleaning build environment...\033[0m"
	@$(MAKE) -C $(SOURCE_DIR) clean
	@rm -f $(CONFIG_FILE)
	@echo "\033[1;32m===> ♻️  Clean completed.\033[0m"

distclean: clean
	@echo "\033[1;36m===> 🧼 Removing toolchain...\033[0m"
	@rm -rf $(TOOLCHAIN_PATH)
	@rm -f $(TOOLCHAIN_ROOT)/$(TOOLCHAIN_TARBALL)
	@echo "\033[1;32m===> ♻️  Distclean completed.\033[0m"
