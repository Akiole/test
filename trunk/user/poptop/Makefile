include $(ROOTDIR)/rules.mk

PKG_NAME:=pptpd
PKG_VERSION:=1.5.0
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-bcrelay

CONFIGURE_VARS += \
	ac_cv_header_libintl_h=no \
	ac_cv_func_logwtmp=yes \
	CFLAGS="$(TARGET_CFLAGS) -Wno-error=implicit-function-declaration -Wno-incomplete-type -Wno-unused-variable"

MAKE_FLAGS += \
	COPTS="$(TARGET_CFLAGS)" \
	INSTALL="install"

define Build/Prepare
	$(call Build/Prepare/Default)
	$(SED) 's/MSG_DONTWAIT|MSG_TRYHARD/MSG_DONTWAIT/g' $(PKG_BUILD_DIR)/bcrelay.c
	if [ -f $(PKG_BUILD_DIR)/plugins/pptpd-logwtmp.c ]; then \
		$(SED) '1i #include <sys/types.h>' $(PKG_BUILD_DIR)/plugins/pptpd-logwtmp.c; \
		$(SED) '1i #include <sys/socket.h>' $(PKG_BUILD_DIR)/plugins/pptpd-logwtmp.c; \
		$(SED) '1i #include <utmp.h>' $(PKG_BUILD_DIR)/plugins/pptpd-logwtmp.c; \
		echo '#define logwtmp(a,b,c) do {} while(0)' >> $(PKG_BUILD_DIR)/plugins/pptpd-logwtmp.c; \
	fi
endef

define Build/Configure
	$(call Build/Configure/Default)
	$(SED) '/^for d in plugins/d' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's/^subdirs = plugins/subdirs =/' $(PKG_BUILD_DIR)/Makefile
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pptpd $(ROMFSDIR)/usr/sbin/pptpd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pptpctrl $(ROMFSDIR)/usr/sbin/pptpctrl
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bcrelay $(ROMFSDIR)/usr/sbin/bcrelay
