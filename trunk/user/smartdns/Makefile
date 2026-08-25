include $(ROOTDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=48.2
SRC_DIR:=./$(PKG_NAME)-Release$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

# MIPS32R2 lacks 64-bit atomics; link libatomic for __atomic_*_8
EXTRA_LDFLAGS += -latomic

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(ROMFSDIR)/usr/bin/smartdns
	$(INSTALL_BIN) ./smartdns.sh $(ROMFSDIR)/usr/bin/smartdns.sh
	$(INSTALL_DIR) $(ROMFSDIR)/etc_ro
	$(INSTALL_DATA) ./conf/*.conf $(ROMFSDIR)/etc_ro/
