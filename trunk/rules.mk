export LC_ALL := C

include $(dir $(lastword $(MAKEFILE_LIST)))host-tools.mk

TOPDIR:=$(ROOTDIR)

DL_DIR:=$(TOPDIR)/download
INCLUDE_DIR:=$(TOPDIR)/include
SCRIPT_DIR:=$(TOPDIR)/tools
BUILD_DIR:=$(TOPDIR)/build
STAGING_DIR:=$(STAGEDIR)
TOOLCHAIN_DIR:=$(CONFIG_CROSS_COMPILER_ROOT)
PKG_CONFIG_LIBDIR:=$(STAGING_DIR)/lib/pkgconfig:$(STAGING_DIR)/share/pkgconfig
# SYSROOT_DIR makes pkg-config prepend the staging path to -L/-I flags;
# without it, .pc files with empty prefix (our --prefix="") resolve to
# host paths like -L/lib, causing host-lib leakage or "not found" errors.
PKG_CONFIG_SYSROOT_DIR:=$(STAGING_DIR)

export TOPDIR PKG_CONFIG_LIBDIR PKG_CONFIG_SYSROOT_DIR
export TMP_DIR:=$(TOPDIR)/build/tmp

GNU_TARGET_NAME:=$(HOST_TARGET)
GNU_HOST_NAME:=$(HOST_BUILD)

TARGET_CROSS:=$(CROSS_COMPILE)

TARGET_CFLAGS:=$(CFLAGS)
TARGET_CXXFLAGS:=$(CXXFLAGS)
TARGET_LDFLAGS:=$(LDFLAGS)

# ---------------------------------------------------------------------------
# C-only warning flags: config.arch sets CXXFLAGS += $(CFLAGS), which leaks
# C-specific -Wno-* options into C++ builds and produces "valid for C/ObjC
# but not for C++" cc1plus warnings.  Strip them here.
# ---------------------------------------------------------------------------
C_ONLY_WARNING_FLAGS := \
	-Wno-pointer-sign \
	-Wno-implicit-function-declaration \
	-Wno-implicit-int \
	-Wno-incompatible-pointer-types \
	-Wno-int-conversion
TARGET_CXXFLAGS := $(filter-out $(C_ONLY_WARNING_FLAGS),$(TARGET_CXXFLAGS))

# ---------------------------------------------------------------------------
# GCC 14+ compatibility: old code (K&R prototypes, missing includes, loose
# function pointers) used to compile with warnings only; GCC 14 promoted
# several of these to errors.  Suppress them globally so individual packages
# don't each need -Wno-* workarounds.  (C only; C++ has different defaults.)
# ---------------------------------------------------------------------------
TARGET_CFLAGS += \
	-Wno-implicit-function-declaration \
	-Wno-implicit-int \
	-Wno-incompatible-pointer-types \
	-Wno-int-conversion

# ---------------------------------------------------------------------------
# GCC 14 + gnulib / old-code noise: many upstream packages bundle gnulib whose
# rpl_free/rpl_malloc renaming trips -Wmismatched-dealloc, and cross-compile
# targets ignore various __attribute__s.  These are harmless and appear in
# dozens of files per package; suppress globally instead of per-package.
# ---------------------------------------------------------------------------
TARGET_CFLAGS += \
	-Wno-mismatched-dealloc \
	-Wno-attributes \
	-Wno-logical-not-parentheses
TARGET_CXXFLAGS += \
	-Wno-mismatched-dealloc \
	-Wno-attributes \
	-Wno-logical-not-parentheses

# ---------------------------------------------------------------------------
# Common include paths and feature macros shared by most packages.
# - include/shared: Padavan-internal headers (nvram, shared utils etc.)
# - _LARGEFILE64_SOURCE / _FILE_OFFSET_BITS=64: 32-bit MIPS large-file
#   support, needed by nfs-utils, samba36, transmission and friends.
# ---------------------------------------------------------------------------
TARGET_CFLAGS += \
	-I$(STAGING_DIR)/include/shared \
	-D_LARGEFILE64_SOURCE \
	-D_FILE_OFFSET_BITS=64
TARGET_CXXFLAGS += \
	-I$(STAGING_DIR)/include/shared \
	-D_LARGEFILE64_SOURCE \
	-D_FILE_OFFSET_BITS=64
TARGET_CPPFLAGS += \
	-I$(STAGING_DIR)/include/shared \
	-D_LARGEFILE64_SOURCE \
	-D_FILE_OFFSET_BITS=64

TARGET_LINKER?=bfd
TARGET_LDFLAGS+= -fuse-ld=$(TARGET_LINKER)
# --gc-sections discards unused sections; pair with -ffunction-sections/
# -fdata-sections in the toolchain CFLAGS to shrink firmware binaries
TARGET_LDFLAGS+= -Wl,--gc-sections
# Staging dir holds third-party libs (nvram, shared, etc.) installed by
# other packages; add it globally so individual packages don't each need
# their own -L$(STAGING_DIR)/lib.
TARGET_LDFLAGS+= -L$(STAGING_DIR)/lib
# -rpath-link lets the linker resolve transitive dependencies (e.g.
# libmbedcrypto.so -> libz.so.1) that live in staging but outside the
# toolchain sysroot.  Without it, ld warns "libz.so.1 not found".
TARGET_LDFLAGS+= -Wl,-rpath-link,$(STAGING_DIR)/lib

TARGET_AR:=$(TARGET_CROSS)gcc-ar
TARGET_RANLIB:=$(TARGET_CROSS)gcc-ranlib
TARGET_NM:=$(TARGET_CROSS)gcc-nm
TARGET_CC:=$(TARGET_CROSS)gcc
TARGET_CXX:=$(TARGET_CROSS)g++
TARGET_LD:=$(TARGET_CROSS)ld.$(TARGET_LINKER)

TARGET_CC_NOCACHE:=$(TARGET_CC)
TARGET_CXX_NOCACHE:=$(TARGET_CXX)

# ---------------------------------------------------------------------------
# LTO capability detection
# ---------------------------------------------------------------------------
# Probe the cross compiler only when LTO is requested (CONFIG_USE_LTO=y), so
# plain builds pay no shell overhead. The check is feature-based instead of a
# version test: it looks for lto1 (the LTO front-end) and liblto_plugin* (the
# linker plugin) inside GCC's libexec dir. This catches toolchains built with
# --disable-lto / --disable-plugin instead of letting cc1 fail mid-build.
LTO_CFLAGS  :=
LTO_LDFLAGS :=
LTO_ENABLED :=

ifdef CONFIG_USE_LTO
  __gcc_lto_wrapper := $(shell $(TARGET_CC_NOCACHE) -print-prog-name=lto-wrapper 2>/dev/null)
  __gcc_libexec_dir := $(patsubst %/,%,$(dir $(__gcc_lto_wrapper)))
  __gcc_has_lto1    := $(wildcard $(__gcc_libexec_dir)/lto1)
  __gcc_has_plugin  := $(wildcard $(__gcc_libexec_dir)/liblto_plugin*)

  ifneq ($(__gcc_has_lto1),)
    ifneq ($(__gcc_has_plugin),)
      # Full LTO: slim (IR-only) objects + linker plugin at link time.
      # -flto=auto parallelizes WPA via the GNU make jobserver (recipes must
      # use +$(MAKE) for the jobserver FDs to propagate; package.mk already
      # does). Slim objects keep build dirs small and speed up archiving.
      LTO_CFLAGS  := -flto=auto -fno-fat-lto-objects
      LTO_LDFLAGS := -flto=auto -fuse-linker-plugin
    else
      # lto1 present but no linker plugin: fall back to fat LTO objects so a
      # plain ld can still link the native code portion.
      LTO_CFLAGS  := -flto=auto
      LTO_LDFLAGS := -flto=auto
    endif
    LTO_ENABLED := yes
  else
    $(warning [rules.mk] CONFIG_USE_LTO=y but $(TARGET_CC) was built without LTO support (lto1 missing).)
    $(warning [rules.mk] Rebuild the toolchain with CT_CC_GCC_USE_LTO=y and CT_BINUTILS_PLUGINS=y in crosstool-ng.)
  endif
endif

# Assembly must not receive -flto; hand-written .S files are always native and
# mixing the flag into ASFLAGS only adds noise.
TARGET_ASFLAGS:=$(filter-out $(LTO_CFLAGS),$(TARGET_CFLAGS))

ifeq ($(CONFIG_CCACHE),y)
  # ccache is invoked via PATH wrappers (symlinks created by trunk/Makefile,
  # prepended to PATH).  We only set CCACHE_* environment variables here —
  # do NOT prefix TARGET_CC with `ccache`, that would double-wrap and conflict
  # with the wrappers (ccache would find its own symlink first in PATH).
  CCACHE_DIR           := $(or $(CONFIG_CCACHE_DIR),$(TOPDIR))/.ccache
  CCACHE_BASEDIR       := $(TOPDIR)
  CCACHE_COMPILERCHECK := %compiler% -dumpmachine; %compiler% -dumpversion
  CCACHE_SLOPPINESS    := pch_defines,time_macros,lto
  export CCACHE_DIR CCACHE_BASEDIR CCACHE_COMPILERCHECK CCACHE_SLOPPINESS
endif

TARGET_CONFIGURE_OPTS := \
  AR="$(TARGET_AR)" \
  AS="$(TARGET_CC) -c $(TARGET_ASFLAGS)" \
  LD="$(TARGET_LD)" \
  NM="$(TARGET_NM)" \
  CC="$(TARGET_CC)" \
  GCC="$(TARGET_CC)" \
  CXX="$(TARGET_CXX)" \
  RANLIB="$(TARGET_RANLIB)" \
  STRIP="$(TARGET_CROSS)strip" \
  OBJCOPY="$(TARGET_CROSS)objcopy" \
  OBJDUMP="$(TARGET_CROSS)objdump" \
  SIZE="$(TARGET_CROSS)size"

DISABLE_IPV6 := $(if $(filter y,$(CONFIG_FIRMWARE_ENABLE_IPV6)),,--disable-ipv6)

# Build all libraries as shared (dynamic) by default
LIBS_BUILD_SHARED:=y

# ---------------------------------------------------------------------------
# Post-install hook: fix libtool .la libdir paths
# ---------------------------------------------------------------------------
# Autotools packages configured with --prefix="" write libdir='/lib' into
# their .la files.  At build time the libraries actually live in
# $(STAGING_DIR)/lib, so libtool warns "library was moved" on every link.
# Rewrite libdir to the real staging path after each package install.
define FixLibtoolLaPaths
	@find $(STAGING_DIR) -name '*.la' 2>/dev/null -exec $(SED) "s|^libdir='.*'|libdir='$(STAGING_DIR)/lib'|" {} + || true
endef
Hooks/Install/Post += FixLibtoolLaPaths
