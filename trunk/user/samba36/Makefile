include $(ROOTDIR)/rules.mk

PKG_NAME:=samba36
PKG_VERSION:=3.6.25
SRC_DIR:=./samba-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_PATH:=source3
CONFIGURE_PREFIX:=/

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -fR $(CURDIR)/$(SRC_DIR)/. $(PKG_BUILD_DIR)/
	# source3/configure is gitignored; regenerate it from configure.in so
	# that patches/100-configure_fixes.patch (bug 5910 cross-compile fix)
	# has a file to patch.
	@if [ ! -f $(PKG_BUILD_DIR)/source3/configure ]; then \
		echo "Regenerating source3/configure..."; \
		(cd $(PKG_BUILD_DIR)/source3 && autoconf -Im4 -I../m4 -I../lib/replace); \
	fi
	$(Build/Patch)
	# source3 Makefile references ../librpc/build_idl.sh and ../pidl/pidl;
	# ensure these top-level dirs exist in the build dir (symlink if missing)
	@for dir in librpc pidl codepages lib include buildtools m4 script; do \
		if [ ! -e $(PKG_BUILD_DIR)/$$dir ] && [ -d $(SRC_DIR)/$$dir ]; then \
			ln -sf $(CURDIR)/$(SRC_DIR)/$$dir $(PKG_BUILD_DIR)/$$dir; \
		fi; \
	done
endef

EXTRA_CPPFLAGS := -DNDEBUG -DSHMEM_SIZE=524288 -D_LARGEFILE_SOURCE=1 -D_LARGE_FILES=1

ifeq ($(CONFIG_FIRMWARE_INCLUDE_SMBD_SYSLOG),y)
EXTRA_CFLAGS += -DMAX_DEBUG_LEVEL="0"
else
EXTRA_CFLAGS += -DMAX_DEBUG_LEVEL="-1"
endif

CONFIGURE_VARS += \
	ac_cv_lib_attr_getxattr=no \
	ac_cv_search_getxattr=no \
	ac_cv_file__proc_sys_kernel_core_pattern=no \
	libreplace_cv_HAVE_C99_VSNPRINTF=yes \
	libreplace_cv_HAVE_GETADDRINFO=yes \
	libreplace_cv_HAVE_IFACE_IFCONF=yes \
	libreplace_cv_HAVE_UTIME=yes \
	libreplace_cv_HAVE_UTIMES=yes \
	ac_cv_func_utime=yes \
	ac_cv_func_utimes=yes \
	LINUX_LFS_SUPPORT=yes \
	samba_cv_CC_NEGATIVE_ENUM_VALUES=yes \
	samba_cv_HAVE_GETTIMEOFDAY_TZ=yes \
	samba_cv_HAVE_IFACE_IFCONF=yes \
	samba_cv_HAVE_KERNEL_OPLOCKS_LINUX=yes \
	samba_cv_HAVE_SECURE_MKSTEMP=yes \
	samba_cv_HAVE_WRFILE_KEYTAB=no \
	samba_cv_USE_SETREUID=yes \
	samba_cv_USE_SETRESUID=yes \
	samba_cv_have_setreuid=yes \
	samba_cv_have_setresuid=yes \
	ac_cv_header_zlib_h=no \
	samba_cv_zlib_1_2_3=no \
	ac_cv_path_PYTHON="" \
	ac_cv_path_PYTHON_CONFIG="" \
	PKG_CONFIG_PATH="$(STAGING_DIR)/lib/pkgconfig"

CONFIGURE_ARGS += \
	--enable-external-libtdb=no \
	--disable-external-libtalloc \
	--disable-dmalloc \
	--disable-iprint \
	--disable-fam \
	--disable-krb5developer \
	--disable-developer \
	--disable-debug \
	--disable-avahi \
	--disable-cups \
	--disable-pie \
	--disable-relro \
	--disable-static \
	--disable-swat \
	--enable-shared-libs \
	--with-libiconv="$(STAGING_DIR)/lib" \
	--with-codepagedir=/usr/share/samba \
	--with-configdir=/etc \
	--with-included-iniparser \
	--with-included-popt=no \
	--with-rootsbindir=/sbin \
	--with-lockdir=/var/locks \
	--with-syslog \
	--with-nmbdsocketdir=/var/nmbd \
	--with-piddir=/var/run \
	--with-privatedir=/etc/samba \
	--with-sendfile-support \
	--without-acl-support \
	--without-cluster-support \
	--without-ads \
	--without-krb5 \
	--without-ldap \
	--without-pam \
	--without-utmp \
	--without-quotas \
	--without-sys-quotas \
	--without-winbind \
	--without-libtdb \
	--without-libtalloc \
	--without-libnetapi \
	--without-libsmbclient \
	--without-libsmbsharemodes \
	--without-libtevent \
	--without-libaddns \
	--with-shared-modules=pdb_tdbsam,pdb_wbc_sam,idmap_nss,nss_info_template,auth_winbind,auth_wbc,auth_domain

define Build/Compile
	MAKEFLAGS="$(MAKEFLAGS) DYNEXP= PICFLAG= MODULES=" $(MAKE) -C $(PKG_BUILD_DIR)/source3 basics
	MAKEFLAGS="$(MAKEFLAGS) DYNEXP= PICFLAG= MODULES=" $(MAKE) -j$(HOST_NCPU) -C $(PKG_BUILD_DIR)/source3
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
ifeq ($(CONFIG_FIRMWARE_INCLUDE_SMBD),y)
	$(ROMFSINST) $(PKG_BUILD_DIR)/source3/bin/samba_multicall /sbin/smbmulti
	$(ROMFSINST) -s smbmulti /sbin/smbd
	$(ROMFSINST) -s smbmulti /sbin/nmbd
	$(ROMFSINST) -s /sbin/smbmulti /bin/smbpasswd
	mkdir -p $(ROMFSDIR)/usr/share/samba
	cp -fP $(PKG_BUILD_DIR)/codepages/*.dat $(ROMFSDIR)/usr/share/samba
else
ifeq ($(CONFIG_FIRMWARE_INCLUDE_WINS),y)
	$(ROMFSINST) $(PKG_BUILD_DIR)/source3/bin/nmbd /sbin/nmbd
endif
endif
