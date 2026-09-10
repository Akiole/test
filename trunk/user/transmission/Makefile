include $(ROOTDIR)/rules.mk

PKG_NAME:=transmission
PKG_VERSION:=3.00
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

include $(INCLUDE_DIR)/cmake.mk
PKG_INSTALL:=1

CMAKE_BINARY_SUBDIR:=build
TARGET_CFLAGS += -D_LFS64_LARGEFILE -Wno-implicit-fallthrough
TARGET_LDFLAGS += -lnghttp2

CMAKE_OPTIONS += \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.10 \
	-DENABLE_CLI=OFF \
	-DENABLE_DAEMON=ON \
	-DENABLE_GTK=OFF \
	-DENABLE_LIGHTWEIGHT=ON \
	-DENABLE_NLS=OFF \
	-DENABLE_QT=OFF \
	-DENABLE_TESTS=OFF \
	-DINSTALL_DOC=OFF \
	-DUSE_SYSTEM_MINIUPNPC=OFF \
	-DUSE_SYSTEM_NATPMP=OFF \
	-DUSE_SYSTEM_UTP=OFF \
	-DWITH_SYSTEMD=OFF \
	-DWITH_INOTIFY=ON \
	-DWITH_CRYPTO=openssl

# miniupnpc headers must be reachable from the internal copy include path

define transmission_miniupnpc_headers
	mkdir -p $(PKG_BUILD_DIR)/third-party/miniupnpc/include/miniupnp
	$(CP) $(PKG_BUILD_DIR)/third-party/miniupnpc/*.h $(PKG_BUILD_DIR)/third-party/miniupnpc/include/miniupnp/
endef

Hooks/Prepare/Post += transmission_miniupnpc_headers

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(CONFIG_FIRMWARE_INCLUDE_TRANSMISSION_WEB_CONTROL),y)
	$(INSTALL_DIR) $(ROMFSDIR)/usr/share/transmission
	$(CP) ./transmission-control/web $(ROMFSDIR)/usr/share/transmission/
else
	$(CP) $(PKG_BUILD_DIR)/web $(ROMFSDIR)/usr/share/transmission/ 2>/dev/null || true
endif
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/daemon/transmission-daemon $(ROMFSDIR)/usr/bin/transmission-daemon
	$(INSTALL_BIN) ./transmission.sh $(ROMFSDIR)/usr/bin/transmission.sh
