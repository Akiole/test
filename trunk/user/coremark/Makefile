include $(ROOTDIR)/rules.mk

PKG_NAME:=coremark

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	$(call Build/Prepare/Default)
	$(SED) 's#CC = gcc##' $(PKG_BUILD_DIR)/linux/core_portme.mak
	$(SED) 's#<malloc.h>#<stdlib.h>#' $(PKG_BUILD_DIR)/linux/core_portme.c
endef

define Build/Compile
	$(MAKE) -j$(HOST_NCPU) -C $(PKG_BUILD_DIR) \
		XCFLAGS="-DMULTITHREAD=8 -DUSE_PTHREAD" \
		PORT_DIR=linux \
		LFLAGS_END="-lpthread" \
		compile
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/coremark.exe $(ROMFSDIR)/usr/bin/coremark
