include $(ROOTDIR)/rules.mk

PKG_NAME:=nfs-utils
PKG_VERSION:=2.6.1
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += -fvisibility=hidden -Drpc_uint=uint32_t

# replace nfs-utils' aggressive -Werror=* AM_CFLAGS set (tirpc's newer
# xdrproc_t prototypes trip them on rpcgen-generated code).  GCC 14
# -Wno-incompatible-pointer-types is supplied globally via rules.mk.

MAKE_FLAGS += AM_CFLAGS="-Drpc_uint=uint32_t"

# musl lacks sys/ttycom.h; nfs-utils headers expect it to exist

define nfs_prepare_ttycom
	mkdir -p $(STAGING_DIR)/include/sys
	touch $(STAGING_DIR)/include/sys/ttycom.h
endef

Hooks/Prepare/Post += nfs_prepare_ttycom

CONFIGURE_VARS += \
	knfsd_cv_bsd_signals=no \
	ac_cv_func_getrpcbynumber=yes \
	ac_cv_func_getrpcbynumber_r=yes \
	PKG_CONFIG_PATH=$(STAGING_DIR)/lib/pkgconfig \
	PKG_CONFIG_SYSROOT_DIR=$(STAGING_DIR)

CONFIGURE_ARGS += \
	--prefix=/ \
	--disable-ipv6 \
	--disable-mount \
	--disable-mountconfig \
	--disable-nfsdcltrack \
	--disable-nfsv4 \
	--disable-nfsv41 \
	--disable-uuid \
	--disable-gss \
	--enable-tirpc \
	--without-gssglue \
	--without-krb5 \
	--without-tcp-wrappers

define Build/Configure
	(cd $(PKG_BUILD_DIR); \
		./autogen.sh; \
		$(CONFIGURE_VARS) \
		./configure \
			$(CONFIGURE_ARGS); \
	)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(ROMFSINST) -p +x /usr/bin/nfsd.sh
	$(ROMFSINST) $(PKG_BUILD_DIR)/utils/exportfs/exportfs /sbin/exportfs
	$(ROMFSINST) $(PKG_BUILD_DIR)/utils/nfsd/nfsd /sbin/rpc.nfsd
	$(ROMFSINST) $(PKG_BUILD_DIR)/utils/mountd/mountd /sbin/rpc.mountd
