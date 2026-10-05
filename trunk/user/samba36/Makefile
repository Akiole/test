include $(ROOTDIR)/rules.mk

PKG_NAME:=samba36
PKG_VERSION:=3.6.25
PKG_SOURCE:=samba-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.samba.org/ftp/samba/stable/
PKG_HASH:=8f2c8a7f2bd89b0dfd228ed917815852f7c625b2bc0936304ac3ed63aaf83751
# Tarball top-level dir is samba-3.6.25, not samba36-3.6.25
PKG_BUILD_DIR:=$(BUILD_DIR)/samba-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_PATH:=source3
CONFIGURE_PREFIX:=/

define Build/Prepare
	$(PKG_UNPACK)
	# Always regenerate source3/configure from configure.in so that
	# patches/100-configure_fixes.patch (bug 5910 cross-compile fix)
	# has a matching file to patch (the shipped configure differs).
	@echo "Regenerating source3/configure..."; \
	rm -f $(PKG_BUILD_DIR)/source3/configure; \
	(cd $(PKG_BUILD_DIR)/source3 && autoheader -Im4 -I../m4 -I../lib/replace && autoconf -Im4 -I../m4 -I../lib/replace)
	# Skip runtime test programs when cross-compiling (they would fail with
	# "cannot run test program while cross compiling"). Replace as_fn_error
	# with a no-op so the cached CONFIGURE_VARS values are used instead.
	$(SED) 's/as_fn_error $$? "cannot run test program while cross compiling/: "/g' $(PKG_BUILD_DIR)/source3/configure
	# include/version.h is gitignored; create a minimal one for the build.
	@if [ ! -f $(PKG_BUILD_DIR)/source3/include/version.h ]; then \
		echo "Creating source3/include/version.h..."; \
		printf '#ifndef _samba_version_h_\n#define _samba_version_h_\n\n#define SAMBA_VERSION_MAJOR 3\n#define SAMBA_VERSION_MINOR 6\n#define SAMBA_VERSION_RELEASE 25\n#define SAMBA_VERSION_REVISION ""\n#define SAMBA_VERSION_PRE_RELEASE 0\n#define SAMBA_VERSION_RC_RELEASE 0\n#define SAMBA_VERSION_VENDOR_PATCH 0\n#define SAMBA_VERSION_STRING "3.6.25"\n#define SAMBA_VERSION_OFFICIAL_STRING "3.6.25"\n#define SAMBA_VERSION_COMMIT_TIME ""\n\n#endif\n' > $(PKG_BUILD_DIR)/source3/include/version.h; \
	fi
	$(Build/Patch)
	# The CVE preparation patch renames rng_fault_state to fault_state in
	# the struct definition and hand-written code, but the PIDL-generated
	# files in librpc/gen_ndr/ still reference the old name. Fix them all.
	find $(PKG_BUILD_DIR)/source3/librpc/gen_ndr -name '*.c' -print0 | $(XARGS) -0 $(SED) 's/rng_fault_state/fault_state/g'
	# Update config.sub/config.guess to modern versions that recognize arm64.
	cp -f $(CURDIR)/config.sub $(PKG_BUILD_DIR)/source3/config.sub
	cp -f $(CURDIR)/config.guess $(PKG_BUILD_DIR)/source3/config.guess
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
