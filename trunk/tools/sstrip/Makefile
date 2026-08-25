include $(ROOTDIR)/rules.mk

PKG_NAME := sstrip
PKG_VERSION := 2.1
SRC_DIR := ./$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL := 1

include $(INCLUDE_DIR)/package.mk

# macOS lacks elf.h/byteswap.h, use bundled headers
DARWIN_INC := $(if $(filter Darwin,$(shell uname)),-I$(ROOTDIR)/tools/include/darwin,)

define Build/Compile
	@echo "==> Compiling $(PKG_NAME)..."
	# ELF read/write helper library
	+$(MAKE) -C $(PKG_BUILD_DIR)/elfrw CFLAGS="-Wall -Wextra -O3 $(DARWIN_INC)" libelfrw.a
	# sstrip main binary (remove unused ELF sections to reduce size)
	$(CC) $(CFLAGS) $(DARWIN_INC) -c $(PKG_BUILD_DIR)/sstrip.c -o $(PKG_BUILD_DIR)/sstrip.o
	$(CC) $(LDFLAGS) -o $(PKG_BUILD_DIR)/sstrip \
		$(PKG_BUILD_DIR)/sstrip.o \
		$(PKG_BUILD_DIR)/elfrw/libelfrw.a
endef

define Build/Install
	@echo "==> Installing $(PKG_NAME)..."
	$(INSTALL_DIR) $(ROOTDIR)/tools/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sstrip $(ROOTDIR)/tools/bin/
endef

$(eval $(call BuildPackage,sstrip))
