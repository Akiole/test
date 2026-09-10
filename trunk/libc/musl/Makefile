include $(ROOTDIR)/rules.mk

MUSL_SYSROOT := $(CONFIG_CROSS_COMPILER_ROOT)/$(CONFIG_CROSS_COMPILE)/sysroot

all:
	@if [ ! -f $(STAGING_DIR)/.installed_musl ]; then \
		mkdir -p $(STAGING_DIR); \
		touch $(STAGING_DIR)/.installed_musl; \
	fi

romfs:
	@mkdir -p $(ROMFSDIR)/lib $(ROMFSDIR)/bin
	cp -fP $(MUSL_SYSROOT)/usr/lib/libc.so $(ROMFSDIR)/lib/
	cp -fP $(MUSL_SYSROOT)/lib/libgcc_s.so.* $(ROMFSDIR)/lib/
	cp -fP $(MUSL_SYSROOT)/lib/libatomic.so.* $(ROMFSDIR)/lib/
	ln -sf libc.so $(ROMFSDIR)/lib/ld-musl-mipsel.so.1
	ln -sf libc.so $(ROMFSDIR)/lib/ld-musl-mipsel-sf.so.1
	ln -sf ../lib/libc.so $(ROMFSDIR)/bin/ldd

clean:
	@rm -f $(STAGING_DIR)/.installed_musl
