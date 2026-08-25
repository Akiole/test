include $(ROOTDIR)/rules.mk

PKG_NAME:=v2ray
PKG_VERSION:=5.24.0
SRC_DIR:=./$(PKG_NAME)-core-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

V2RAY_GO_ENV := GOOS=linux GOARCH=mipsle CGO_ENABLED=0
V2RAY_LDFLAGS := -s -w -buildid=
V2RAY_GO_FLAGS := -trimpath

GO_VERSION := $(shell go version 2>/dev/null | awk '{print $$3}' | $(SED_READ) 's/go//' | cut -d. -f1,2)
GO_MAJOR := $(word 1,$(subst ., ,$(GO_VERSION)))
GO_MINOR := $(word 2,$(subst ., ,$(GO_VERSION)))
ifeq ($(shell test -n "$(GO_VERSION)" && test $(GO_MAJOR) -ge 1 && test $(GO_MINOR) -ge 18 && echo yes),yes)
    V2RAY_GO_FLAGS += -buildvcs=false
endif

# V2RAY_GO_FLAGS += -x

define Build/Configure
endef

define Build/Compile
	@echo ">>> Building $(PKG_NAME) v$(PKG_VERSION) for mipsle..."
	@echo ">>> Go version: $(shell go version)"
	(cd $(PKG_BUILD_DIR); \
		$(V2RAY_GO_ENV) \
		go build -v -o $(PKG_NAME) \
		$(V2RAY_GO_FLAGS) \
		-ldflags="$(V2RAY_LDFLAGS)" \
		./main \
	)
	@echo ">>> $(PKG_NAME) built successfully"
	@ls -lh $(PKG_BUILD_DIR)/$(PKG_NAME) 2>/dev/null || true
endef

define Build/Clean
	rm -f $(PKG_BUILD_DIR)/$(PKG_NAME)
	rm -f $(PKG_BUILD_DIR)/v2ray
	@echo ">>> Cleaned $(PKG_NAME)"
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(ROMFSDIR)/usr/bin/$(PKG_NAME)
