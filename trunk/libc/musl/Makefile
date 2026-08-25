# =============================================================================
# musl C Library Makefile
# musl is prebuilt with the toolchain; this file only copies runtime libraries to romfs
# =============================================================================

include $(ROOTDIR)/rules.mk

.PHONY: all romfs clean

# Toolchain sysroot path; use CONFIG_CROSS_COMPILE to avoid hardcoding
MUSL_SYSROOT := $(CONFIG_CROSS_COMPILER_ROOT)/$(CONFIG_CROSS_COMPILE)/sysroot
INSTALLED_MARKER := $(STAGING_DIR)/.installed_musl

all:
	@echo "Checking musl installation..."
	@if [ ! -f $(INSTALLED_MARKER) ]; then \
		echo "Installing musl..."; \
		$(INSTALL_DIR) $(STAGING_DIR); \
		touch $(INSTALLED_MARKER); \
		echo "musl installed."; \
	else \
		echo "musl already installed."; \
	fi

romfs:
	@echo "Copying musl libraries to ROMFS..."
	@$(INSTALL_DIR) $(ROMFSDIR)/lib
	@$(INSTALL_DIR) $(ROMFSDIR)/bin
	# libc.so (also serves as dynamic linker in musl)
	@$(CP) $(MUSL_SYSROOT)/usr/lib/libc.so $(ROMFSDIR)/lib/
	# Optional libraries (may not be provided by some toolchains)
	@$(CP) $(MUSL_SYSROOT)/lib/libgcc_s.so.* $(ROMFSDIR)/lib/ 2>/dev/null || true
	@$(CP) $(MUSL_SYSROOT)/lib/libatomic.so.* $(ROMFSDIR)/lib/ 2>/dev/null || true
	# musl dynamic linker and ldd are both symlinks to libc.so
	@ln -sf libc.so $(ROMFSDIR)/lib/ld-musl-mipsel.so.1
	@ln -sf ../lib/libc.so $(ROMFSDIR)/bin/ldd
	@echo "musl libraries copied to ROMFS."

clean:
	@echo "Cleaning musl installation..."
	@rm -f $(INSTALLED_MARKER)
	@echo "musl cleaned."
