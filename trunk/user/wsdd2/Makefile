include $(ROOTDIR)/rules.mk

PKG_NAME:=wsdd2

include $(INCLUDE_DIR)/package.mk


$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wsdd2 $(ROMFSDIR)/sbin/wsdd2
