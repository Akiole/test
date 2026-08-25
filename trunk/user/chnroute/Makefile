include $(ROOTDIR)/rules.mk

PKG_NAME:=chnroute
PKG_VERSION:=1.0

include $(INCLUDE_DIR)/package.mk

CHNROUTE_URL := http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest

define Build/Prepare
	@echo "Data package"
endef

define Build/Compile
	@if [ ! -f chnroute.bz2 ]; then \
		wget -t3 -4 --timeout=5 -O chnroute.txt.tmp '$(CHNROUTE_URL)' && \
		awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $$4, 32-log($$5)/log(2)) }' < chnroute.txt.tmp > chnroute.txt && \
		rm -f chnroute.txt.tmp && tar jcf chnroute.bz2 chnroute.txt chnlist_mini.txt; \
	fi
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	chmod -R +x ./scripts
	$(ROMFSINST) ./scripts/ /usr/bin/
	$(ROMFSINST) -d ./chnroute.bz2 /etc_ro/chnroute.bz2
