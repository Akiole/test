include $(ROOTDIR)/rules.mk

PKG_NAME:=ebtables
PKG_VERSION:=2.0.10-4

PKG_SOURCE:=ebtables-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.netfilter.org/pub/ebtables/
PKG_HASH:=dc6f7b484f207dc712bfca81645f45120cb6aee3380e77a1771e9c34a9a4455d
PKG_BUILD_DIR:=$(BUILD_DIR)/ebtables-v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
TARGET_CFLAGS += -Wno-error -Wno-implicit-function-declaration -D__THROW= -D_NETINET_IF_ETHER_H -Du_int8_t=uint8_t -Du_int16_t=uint16_t -Du_int32_t=uint32_t -Du_int64_t=uint64_t -DETH_ALEN=6 -DETH_ZLEN=60

define Build/Compile
	$(MAKE_VARS) \
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		$(MAKE_FLAGS) \
		CC=$(TARGET_CC) \
		CFLAGS="$(TARGET_CFLAGS)" \
		static
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/static $(ROMFSDIR)/bin/ebtables
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ethertypes $(ROMFSDIR)/etc_ro/ethertypes
