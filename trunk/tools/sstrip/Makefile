include $(ROOTDIR)/rules.mk

PKG_NAME := sstrip
PKG_VERSION := 3.2
# sstrip is part of the ELFkickers suite by Brian Raiter
# https://www.muppetlabs.com/~breadbox/software/elfkickers.html
PKG_SOURCE := ELFkickers-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL := https://www.muppetlabs.com/~breadbox/pub/software/
PKG_HASH := 9b81e6c53e0c94fc198d9882eb737156f36d565152dc32118897c77b06a2687c
# Tarball extracts to ELFkickers-3.2/, not sstrip-3.2/
PKG_BUILD_DIR := $(BUILD_DIR)/ELFkickers-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL:=1

# macOS lacks elf.h/byteswap.h, use bundled compatibility headers
DARWIN_INC := $(if $(IS_DARWIN),-I$(ROOTDIR)/tools/include/darwin,)

define Build/Compile
	@echo "==> Compiling $(PKG_NAME)..."
	# ELF read/write helper library (prerequisite for sstrip)
	+$(MAKE) -C $(PKG_BUILD_DIR)/elfrw CFLAGS="-Wall -Wextra -O3 $(DARWIN_INC)" libelfrw.a
	# sstrip main binary — removes unused ELF sections to reduce file size
	$(CC) $(CFLAGS) $(DARWIN_INC) -I$(PKG_BUILD_DIR)/elfrw -c $(PKG_BUILD_DIR)/sstrip/sstrip.c -o $(PKG_BUILD_DIR)/sstrip/sstrip.o
	$(CC) $(LDFLAGS) -o $(PKG_BUILD_DIR)/sstrip/sstrip \
		$(PKG_BUILD_DIR)/sstrip/sstrip.o \
		$(PKG_BUILD_DIR)/elfrw/libelfrw.a
endef

define Build/Install
	@echo "==> Installing $(PKG_NAME)..."
	$(INSTALL_DIR) $(ROOTDIR)/tools/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sstrip/sstrip $(ROOTDIR)/tools/bin/
endef

$(eval $(call BuildPackage,sstrip))
