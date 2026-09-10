include $(ROOTDIR)/rules.mk

PKG_NAME:=busybox
PKG_VERSION:=1.37.0
SRC_DIR:=./$(PKG_NAME)-$(PKG_VERSION)

# Busybox is a large legacy codebase; suppress noisy warnings that fire
# on every applet compilation (const-qualifier in syslogd name tables,
# always_inline heuristics in xshared).
EXTRA_CFLAGS := -Wno-discarded-qualifiers -Wno-inline

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(MAKE_FLAGS) \
		CONFIG_PREFIX=$(ROMFSDIR) \
		install
