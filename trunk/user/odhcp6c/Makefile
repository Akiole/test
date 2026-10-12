include $(ROOTDIR)/rules.mk

PKG_NAME:=odhcp6c

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += \
	-D_GNU_SOURCE \
	-I$(PKG_BUILD_DIR) \
	-Os -Wall

ODHCP6C_OBJS = \
	config.o \
	dhcpv6.o \
	odhcp6c.o \
	ra.o \
	script.o \
	md5.o

define Build/Compile
	(cd $(PKG_BUILD_DIR) && \
		$(TARGET_CC) $(TARGET_CFLAGS) -c config.c -o config.o && \
		$(TARGET_CC) $(TARGET_CFLAGS) -c dhcpv6.c -o dhcpv6.o && \
		$(TARGET_CC) $(TARGET_CFLAGS) -c odhcp6c.c -o odhcp6c.o && \
		$(TARGET_CC) $(TARGET_CFLAGS) -c ra.c -o ra.o && \
		$(TARGET_CC) $(TARGET_CFLAGS) -c script.c -o script.o && \
		$(TARGET_CC) $(TARGET_CFLAGS) -c md5.c -o md5.o && \
		$(TARGET_CC) $(TARGET_LDFLAGS) -o odhcp6c $(ODHCP6C_OBJS) -lresolv \
	)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/odhcp6c $(ROMFSDIR)/sbin/odhcp6c
