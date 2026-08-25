include $(ROOTDIR)/rules.mk

PKG_NAME:=xray
PKG_VERSION:=26.3.27
SRC_DIR:=./Xray-core-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

XRAY_GO_ENV := GOOS=linux GOARCH=mipsle CGO_ENABLED=1 CC="$(TARGET_CC)"
XRAY_LDFLAGS := -X github.com/xtls/xray-core/core.build=$(PKG_VERSION) -s -w -buildid=
XRAY_GO_FLAGS := -trimpath

GO_VERSION := $(shell go version 2>/dev/null | awk '{print $$3}' | $(SED_READ) 's/go//' | cut -d. -f1,2)
GO_MAJOR := $(word 1,$(subst ., ,$(GO_VERSION)))
GO_MINOR := $(word 2,$(subst ., ,$(GO_VERSION)))
ifeq ($(shell test -n "$(GO_VERSION)" && test $(GO_MAJOR) -ge 1 && test $(GO_MINOR) -ge 18 && echo yes),yes)
    XRAY_GO_FLAGS += -buildvcs=false
endif

# XRAY_CGO_CFLAGS := -O2 -march=mips32r2
# XRAY_GO_FLAGS += -x

define Build/Configure
endef

define Build/Compile
	@echo ">>> Building $(PKG_NAME) v$(PKG_VERSION) for mipsle..."
	@echo ">>> Go version: $(shell go version)"
	@echo ">>> CGO_ENABLED: 1 (required for Xray full features)"
	(cd $(PKG_BUILD_DIR); \
		$(XRAY_GO_ENV) \
		CGO_CFLAGS="$(XRAY_CGO_CFLAGS)" \
		go build -v -o $(PKG_NAME) \
		$(XRAY_GO_FLAGS) \
		-ldflags="$(XRAY_LDFLAGS)" \
		./main \
	)
	@echo ">>> $(PKG_NAME) built successfully"
	@ls -lh $(PKG_BUILD_DIR)/$(PKG_NAME) 2>/dev/null || true
endef

define Build/Clean
	rm -f $(PKG_BUILD_DIR)/$(PKG_NAME)
	rm -f $(PKG_BUILD_DIR)/xray
	@echo ">>> Cleaned $(PKG_NAME)"
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(ROMFSDIR)/usr/bin/$(PKG_NAME)
