include $(ROOTDIR)/rules.mk

PKG_NAME:=iproute2
PKG_VERSION:=5.12.0
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ip/ip $(ROMFSDIR)/bin/ip
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SQM),y)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tc/tc $(ROMFSDIR)/bin/tc
endif
