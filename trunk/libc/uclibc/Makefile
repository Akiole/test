include $(ROOTDIR)/rules.mk

UCLIBC_SYSROOT := $(CONFIG_CROSS_COMPILER_ROOT)/$(CONFIG_CROSS_COMPILE)/sysroot

all:
	@if [ ! -f $(STAGING_DIR)/.installed_uclibc ]; then \
		mkdir -p $(STAGING_DIR); \
		touch $(STAGING_DIR)/.installed_uclibc; \
	fi

romfs:
	@mkdir -p $(ROMFSDIR)/lib
	$(ROMFSINST) -p +x $(UCLIBC_SYSROOT)/usr/bin/ldd /bin/ldd
	cp -fP $(UCLIBC_SYSROOT)/lib/libuClibc*.so* $(ROMFSDIR)/lib/
	cp -fP $(UCLIBC_SYSROOT)/lib/libc.so.0 $(ROMFSDIR)/lib/
	cp -fP $(UCLIBC_SYSROOT)/lib/ld-uClibc*.so* $(ROMFSDIR)/lib/
	cp -fP $(UCLIBC_SYSROOT)/lib/libgcc_s.so.* $(ROMFSDIR)/lib/
	cp -fP $(UCLIBC_SYSROOT)/lib/libthread_db*.so* $(ROMFSDIR)/lib/
	cp -fP $(UCLIBC_SYSROOT)/lib/libatomic.so.* $(ROMFSDIR)/lib/

clean:
	@rm -f $(STAGING_DIR)/.installed_uclibc
