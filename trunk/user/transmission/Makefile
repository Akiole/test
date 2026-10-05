include $(ROOTDIR)/rules.mk

PKG_NAME:=transmission
PKG_VERSION:=3.00
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/transmission/transmission/releases/download/$(PKG_VERSION)/
PKG_HASH:=9144652fe742f7f7dd6657716e378da60b751aaeda8bef8344b3eefc4db255f2

include $(INCLUDE_DIR)/package.mk

include $(INCLUDE_DIR)/cmake.mk
PKG_INSTALL:=1

CMAKE_BINARY_SUBDIR:=build
TARGET_CFLAGS += -D_LFS64_LARGEFILE -Wno-implicit-fallthrough
TARGET_LDFLAGS += -lnghttp2

# CMake toolchain file for ExternalProject subprojects (miniupnpc, natpmp, utp, dht)
# Ensures cross-compilation settings are inherited by ExternalProject sub-builds
define Build/Prepare
	$(call Build/Prepare/Default)
	# Upgrade cmake_minimum_required for CMake 4.x compatibility
	find $(PKG_BUILD_DIR) -name 'CMakeLists.txt' -exec $(SED) 's/cmake_minimum_required *(VERSION *2\.[0-9]*)/cmake_minimum_required(VERSION 3.10)/' {} +
	# Generate cross-compilation toolchain file
	@echo "set(CMAKE_SYSTEM_NAME Linux)" > $(PKG_BUILD_DIR)/toolchain.cmake
	@echo "set(CMAKE_SYSTEM_VERSION 1)" >> $(PKG_BUILD_DIR)/toolchain.cmake
	@echo "set(CMAKE_SYSTEM_PROCESSOR mips)" >> $(PKG_BUILD_DIR)/toolchain.cmake
	@echo "set(CMAKE_C_COMPILER $(TARGET_CC))" >> $(PKG_BUILD_DIR)/toolchain.cmake
	@echo "set(CMAKE_CXX_COMPILER $(TARGET_CXX))" >> $(PKG_BUILD_DIR)/toolchain.cmake
	@echo "set(CMAKE_ASM_COMPILER $(TARGET_CC))" >> $(PKG_BUILD_DIR)/toolchain.cmake
	@echo "set(CMAKE_AR $(TARGET_AR))" >> $(PKG_BUILD_DIR)/toolchain.cmake
	@echo "set(CMAKE_NM $(TARGET_NM))" >> $(PKG_BUILD_DIR)/toolchain.cmake
	@echo "set(CMAKE_RANLIB $(TARGET_RANLIB))" >> $(PKG_BUILD_DIR)/toolchain.cmake
	@echo "set(CMAKE_FIND_ROOT_PATH $(STAGING_DIR) $(TOOLCHAIN_DIR))" >> $(PKG_BUILD_DIR)/toolchain.cmake
	@echo "set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)" >> $(PKG_BUILD_DIR)/toolchain.cmake
	@echo "set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)" >> $(PKG_BUILD_DIR)/toolchain.cmake
	@echo "set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)" >> $(PKG_BUILD_DIR)/toolchain.cmake
	@echo "set(CMAKE_OSX_ARCHITECTURES \"\")" >> $(PKG_BUILD_DIR)/toolchain.cmake
	@echo "set(CMAKE_POLICY_VERSION_MINIMUM 3.10)" >> $(PKG_BUILD_DIR)/toolchain.cmake
endef

CMAKE_OPTIONS += \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS_RELEASE="-DNDEBUG -Wno-inline" \
	-DCMAKE_TOOLCHAIN_FILE=$(PKG_BUILD_DIR)/toolchain.cmake \
	-DENABLE_CLI=OFF \
	-DENABLE_DAEMON=ON \
	-DENABLE_GTK=OFF \
	-DENABLE_NLS=OFF \
	-DENABLE_QT=OFF \
	-DENABLE_TESTS=OFF \
	-DENABLE_UTILS=OFF \
	-DINSTALL_DOC=OFF \
	-DUSE_SYSTEM_EVENT2=ON \
	-DUSE_SYSTEM_MINIUPNPC=OFF \
	-DUSE_SYSTEM_NATPMP=OFF \
	-DUSE_SYSTEM_UTP=OFF \
	-DWITH_SYSTEMD=OFF \
	-DWITH_INOTIFY=ON \
	-DWITH_CRYPTO=openssl

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(CONFIG_FIRMWARE_INCLUDE_TRANSMISSION_WEB_CONTROL),y)
	$(INSTALL_DIR) $(ROMFSDIR)/usr/share/transmission
	$(CP) ./transmission-control/web $(ROMFSDIR)/usr/share/transmission/
else
	$(CP) $(PKG_BUILD_DIR)/web/public_html $(ROMFSDIR)/usr/share/transmission/web 2>/dev/null || true
endif
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/daemon/transmission-daemon $(ROMFSDIR)/usr/bin/transmission-daemon
	$(INSTALL_BIN) ./transmission.sh $(ROMFSDIR)/usr/bin/transmission.sh
