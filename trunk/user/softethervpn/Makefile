include $(ROOTDIR)/rules.mk

PKG_NAME:=softethervpn
PKG_VERSION:=4.38-9760
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

# Upstream ships CRLF line endings; the patches are LF.  Normalise source
# files to LF before applying patches so gpatch does not reject them with
# "different line endings".
define Build/Patch
	@find $(PKG_BUILD_DIR) -type f \( -name '*.c' -o -name '*.h' -o -name '*.mak' \) -print0 | $(XARGS) -0 $(SED) 's/\r$$//'
	$(call Build/Patch/Default)
endef

HAMCORE_DIR := src/bin/BuiltHamcoreFiles/unix

# MIPS16 interlinking for smaller binary on the target

TARGET_CFLAGS += -minterlink-mips16

# The upstream hand-written makefile only adds -I./src etc.; tell it where
# the cross-compiled openssl / readline / ncurses / zlib / iconv live.

EXTRA_CFLAGS += -I$(STAGING_DIR)/include
EXTRA_LDFLAGS += -L$(STAGING_DIR)/lib

# Upstream ./configure picks a makefile by the *build* host OS (uname -s),
# which would give us macos_64bit.mak on a macOS builder. Force the Linux
# 32-bit makefile that the patch below is written against.

define Build/Configure
	cp -f $(PKG_BUILD_DIR)/src/makefiles/linux_32bit.mak $(PKG_BUILD_DIR)/Makefile
endef

# Future-date hamcore.se2 so the generated Makefile never rebuilds it.
# rules.mk already sets IS_DARWIN via $(shell uname), reuse it.

ifeq ($(IS_DARWIN),)
TOUCH_TIME := $(shell date -d next-day +%Y%m%d%H%M)
else
TOUCH_TIME := $(shell date -v+1d +%Y%m%d%H%M)
endif

define Build/Prepare
	$(call Build/Prepare/Default)
	mkdir -p \
		$(PKG_BUILD_DIR)/tmp/objs/Mayaqua \
		$(PKG_BUILD_DIR)/tmp/objs/Cedar \
		$(PKG_BUILD_DIR)/tmp/as \
		$(PKG_BUILD_DIR)/bin/vpnserver \
		$(PKG_BUILD_DIR)/bin/vpnclient \
		$(PKG_BUILD_DIR)/bin/vpnbridge \
		$(PKG_BUILD_DIR)/bin/vpncmd \
		$(PKG_BUILD_DIR)/$(HAMCORE_DIR)
	cp -f $(PKG_BUILD_DIR)/hamcore.se2 $(PKG_BUILD_DIR)/$(HAMCORE_DIR)/hamcore.se2
	touch -t $(TOUCH_TIME) $(PKG_BUILD_DIR)/$(HAMCORE_DIR)/hamcore.se2
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SOFTETHERVPN_CMD),y)
	$(ROMFSINST) -d -p +x $(PKG_BUILD_DIR)/bin/vpncmd/vpncmd /etc_ro/softethervpn/vpncmd
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SOFTETHERVPN_CLIENT),y)
	$(ROMFSINST) -d -p +x $(PKG_BUILD_DIR)/bin/vpnclient/vpnclient /etc_ro/softethervpn/vpnclient
endif
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SOFTETHERVPN_SERVER),y)
	$(ROMFSINST) -d -p +x $(PKG_BUILD_DIR)/bin/vpnserver/vpnserver /etc_ro/softethervpn/vpnserver
endif
	$(ROMFSINST) -d -S $(PKG_BUILD_DIR)/hamcore.se2 /etc_ro/softethervpn/hamcore.se2
	$(ROMFSINST) $(CURDIR)/softethervpn.sh /usr/bin/softethervpn.sh
