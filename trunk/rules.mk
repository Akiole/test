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

TARGET_LINKER?=bfd
TARGET_LDFLAGS+= -fuse-ld=$(TARGET_LINKER)
# --gc-sections discards unused sections; pair with -ffunction-sections/
# -fdata-sections in the toolchain CFLAGS to shrink firmware binaries
TARGET_LDFLAGS+= -Wl,--gc-sections

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

ifneq ($(CONFIG_CCACHE),)
  TARGET_CC:= ccache $(TARGET_CC)
  TARGET_CXX:= ccache $(TARGET_CXX)
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

DISABLE_IPV6 := $(if $(CONFIG_FIRMWARE_ENABLE_IPV6),,--disable-ipv6)

# Build all libraries as shared (dynamic) by default
LIBS_BUILD_SHARED:=y
