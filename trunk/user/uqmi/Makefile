include $(ROOTDIR)/rules.mk

PKG_NAME:=uqmi
PKG_VERSION:=1.0
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -I. -Wmissing-declarations
TARGET_LDFLAGS += -Llibubox -lubox

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(ROMFSINST) $(PKG_BUILD_DIR)/uqmi /bin/uqmi
