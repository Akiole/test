include $(ROOTDIR)/rules.mk

PKG_NAME:=sqm-qos

include $(INCLUDE_DIR)/package.mk

define Build/Configure
endef

define Build/Compile
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(CP) ./files/* $(ROMFSDIR)/
