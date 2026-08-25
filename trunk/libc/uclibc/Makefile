# =============================================================================
# uClibc C Library Makefile
# uClibc is prebuilt with the toolchain; this file only copies runtime libraries to romfs
# =============================================================================

include $(ROOTDIR)/rules.mk

.PHONY: all romfs clean

# Toolchain sysroot path; use CONFIG_CROSS_COMPILE to avoid hardcoding
UCLIBC_SYSROOT := $(CONFIG_CROSS_COMPILER_ROOT)/$(CONFIG_CROSS_COMPILE)/sysroot
INSTALLED_MARKER := $(STAGING_DIR)/.installed_uclibc

all:
	@echo "Checking uClibc installation..."
	@if [ ! -f $(INSTALLED_MARKER) ]; then \
		echo "Installing uClibc..."; \
		$(INSTALL_DIR) $(STAGING_DIR); \
		touch $(INSTALLED_MARKER); \
		echo "uClibc installed."; \
	else \
		echo "uClibc already installed."; \
	fi

romfs:
	@echo "Copying uClibc libraries to ROMFS..."
	@$(INSTALL_DIR) $(ROMFSDIR)/lib
	@$(INSTALL_DIR) $(ROMFSDIR)/bin
	# ldd utility
	@if [ -f $(UCLIBC_SYSROOT)/usr/bin/ldd ]; then \
		$(CP) $(UCLIBC_SYSROOT)/usr/bin/ldd $(ROMFSDIR)/bin/; \
		chmod +x $(ROMFSDIR)/bin/ldd; \
	fi
	# uClibc main library (naming varies by version; try all)
	@$(CP) $(UCLIBC_SYSROOT)/lib/libuClibc*.so* $(ROMFSDIR)/lib/ 2>/dev/null || true
	@$(CP) $(UCLIBC_SYSROOT)/lib/libc.so.0 $(ROMFSDIR)/lib/ 2>/dev/null || true
	# Dynamic linker and runtime libraries
	@$(CP) $(UCLIBC_SYSROOT)/lib/ld-uClibc*.so* $(ROMFSDIR)/lib/ 2>/dev/null || true
	@$(CP) $(UCLIBC_SYSROOT)/lib/libgcc_s.so.* $(ROMFSDIR)/lib/ 2>/dev/null || true
	@$(CP) $(UCLIBC_SYSROOT)/lib/libatomic.so.* $(ROMFSDIR)/lib/ 2>/dev/null || true
	@$(CP) $(UCLIBC_SYSROOT)/lib/libthread_db*.so* $(ROMFSDIR)/lib/ 2>/dev/null || true
	@echo "uClibc libraries copied to ROMFS."

clean:
	@echo "Cleaning uClibc installation..."
	@rm -f $(INSTALLED_MARKER)
	@echo "uClibc cleaned."
