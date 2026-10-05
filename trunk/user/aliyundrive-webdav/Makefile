# aliyundrive-webdav - build from source (Rust)

include $(ROOTDIR)/rules.mk

PKG_NAME:=aliyundrive-webdav
PKG_VERSION:=2.0.0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/messense/aliyundrive-webdav/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=36d0af0b0900a03114bbd8b1f9fe46ec6846130b61667932e76438d01626f730

include $(INCLUDE_DIR)/package.mk

RUST_TARGET:=mipsel-unknown-linux-musl
RUSTUP_HOME:=$(HOME)/.rustup
CARGO_HOME:=$(HOME)/.cargo

define Build/Configure
	# Ensure Rust nightly with rust-src is available
	@if [ ! -d "$(RUSTUP_HOME)/toolchains/nightly-aarch64-apple-darwin" ]; then \
		echo "Installing Rust nightly..."; \
		rustup toolchain install nightly --component rust-src; \
	fi
	@mkdir -p $(CARGO_HOME)
	@printf '[target.%s]\nlinker = "%s"\n' "$(RUST_TARGET)" "$(TARGET_CC)" > $(CARGO_HOME)/config.toml
endef

define Build/Compile
	(cd $(PKG_BUILD_DIR); \
		export PATH="$(CARGO_HOME)/bin:$(TOOLCHAIN_DIR)/bin:$$PATH"; \
		export RUSTUP_HOME="$(RUSTUP_HOME)"; \
		export CARGO_HOME="$(CARGO_HOME)"; \
		rm -f Cargo.lock; \
		cargo +nightly build \
			-Z build-std=std,panic_abort \
			--target $(RUST_TARGET) \
			--release \
			--no-default-features; \
		$(TARGET_CROSS)strip target/$(RUST_TARGET)/release/$(PKG_NAME); \
	)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUST_TARGET)/release/$(PKG_NAME) $(ROMFSDIR)/usr/bin/$(PKG_NAME)
	$(INSTALL_BIN) ./aliyundrive-webdav.sh $(ROMFSDIR)/usr/bin/aliyundrive-webdav.sh
