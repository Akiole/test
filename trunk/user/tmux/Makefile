include $(ROOTDIR)/rules.mk

PKG_NAME:=tmux
PKG_VERSION:=2.9
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define TmuxPreConfigure
	(cd $(PKG_BUILD_DIR); \
	sh autogen.sh; \
	)
endef

Hooks/Configure/Pre += TmuxPreConfigure

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tmux $(ROMFSDIR)/usr/bin/tmux
