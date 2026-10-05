include $(ROOTDIR)/rules.mk

PKG_NAME:=boost
PKG_VERSION:=1.92.0

PKG_SOURCE:=boost_$(subst .,_,$(PKG_VERSION)).tar.gz
PKG_SOURCE_URL:=https://archives.boost.io/release/1.92.0/source/
PKG_HASH:=c4a3b310ddd2472416e091067166b0713be97c63f38c212c484ada022fd296ce

PKG_BUILD_DIR:=$(BUILD_DIR)/boost_1_92_0

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL:=1

BOOST_BUILD_LIBS := --with-program_options

BOOST_CXX := $(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)g++

TARGET_CFLAGS  += -fPIC
TARGET_CXXFLAGS += -fPIC

# Filter C-only warning flags from cflags: b2 applies cflags to both C
# and C++ compilations, and C-only options trigger cc1plus warnings.
BOOST_CFLAGS := $(filter-out $(C_ONLY_WARNING_FLAGS),$(TARGET_CFLAGS))

BOOST_B2_OPTS := \
	--prefix=$(PKG_INSTALL_DIR) \
	--includedir=$(PKG_INSTALL_DIR)/include \
	--libdir=$(PKG_INSTALL_DIR)/lib \
	--build-dir=$(PKG_BUILD_DIR)/build \
	--layout=system \
	--user-config=$(PKG_BUILD_DIR)/user-config.jam \
	--toolset=gcc-mipsel \
	link=shared \
	runtime-link=shared \
	threading=multi \
	variant=release \
	debug-symbols=off \
	profiling=off \
	address-model=32 \
	architecture=mips \
	cflags="$(BOOST_CFLAGS)" \
	cxxflags="$(TARGET_CXXFLAGS)" \
	linkflags="$(TARGET_LDFLAGS)"

define Build/Configure
	@echo ">>> Configuring Boost $(PKG_VERSION)..."
	@printf 'using gcc : mipsel : %s :\n    <compileflags>%s\n    <compileflags>-I%s/include\n    <linkflags>-L%s/lib\n    <linkflags>-Wl,--gc-sections\n    ;\n' \
		"$(BOOST_CXX)" "$(TARGET_CXXFLAGS)" "$(STAGING_DIR)" "$(STAGING_DIR)" \
		> $(PKG_BUILD_DIR)/user-config.jam
	@cd $(PKG_BUILD_DIR) && ./bootstrap.sh --with-toolset=gcc
	@echo ">>> Boost configuration complete"
endef

define Build/Compile
	@echo ">>> Building Boost $(PKG_VERSION) shared libs..."
	# b2 may fail to link due to container lib check on musl/uclibc,
	# but .o files are still produced; program_options is linked manually below.
	@cd $(PKG_BUILD_DIR) && PATH="$(TOOLCHAIN_DIR)/bin:$$PATH" ./b2 \
		$(BOOST_B2_OPTS) \
		$(BOOST_BUILD_LIBS) \
		$(PKG_JOBS) \
		stage
	# Manual link: program_options does not actually depend on container
	@echo ">>> Linking libboost_program_options.so..."
	@PO_OBJ_DIR=$$(find $(PKG_BUILD_DIR)/bin.v2 -path '*program_options*' -name '*.o' -type f 2>/dev/null | head -1 | xargs dirname 2>/dev/null); \
	if [ -n "$$PO_OBJ_DIR" ] && [ -d "$$PO_OBJ_DIR" ]; then \
		$(INSTALL_DIR) $(PKG_BUILD_DIR)/stage/lib; \
		$(BOOST_CXX) -shared \
			-o $(PKG_BUILD_DIR)/stage/lib/libboost_program_options.so.$(PKG_VERSION) \
			-Wl,-soname,libboost_program_options.so.$(PKG_VERSION) \
			$(TARGET_CXXFLAGS) \
			$$PO_OBJ_DIR/*.o \
			$(TARGET_LDFLAGS) && \
		ln -sf libboost_program_options.so.$(PKG_VERSION) \
			$(PKG_BUILD_DIR)/stage/lib/libboost_program_options.so && \
		echo ">>> libboost_program_options.so linked successfully"; \
	else \
		echo ">>> WARNING: program_options object files not found"; \
	fi
	# boost_system is header-only in Boost 1.92+, but CMake FindBoost
	# requires a library file to satisfy COMPONENTS system. Create an empty
	# placeholder shared library so trojan's cmake configure can find it.
	@echo ">>> Creating libboost_system.so placeholder (header-only lib)..."
	@$(INSTALL_DIR) $(PKG_BUILD_DIR)/stage/lib
	@echo '/* header-only placeholder */' > $(PKG_BUILD_DIR)/boost_system_placeholder.c
	@$(BOOST_CXX) -shared -fPIC \
		-o $(PKG_BUILD_DIR)/stage/lib/libboost_system.so.$(PKG_VERSION) \
		-Wl,-soname,libboost_system.so.$(PKG_VERSION) \
		$(PKG_BUILD_DIR)/boost_system_placeholder.c \
		$(TARGET_LDFLAGS) && \
	ln -sf libboost_system.so.$(PKG_VERSION) \
		$(PKG_BUILD_DIR)/stage/lib/libboost_system.so && \
	echo ">>> libboost_system.so placeholder created" || \
	echo ">>> WARNING: failed to create libboost_system.so placeholder"
	@echo ">>> Boost build complete"
endef

define Build/Install
	@echo ">>> Installing Boost $(PKG_VERSION)..."
	@$(INSTALL_DIR) $(PKG_INSTALL_DIR)/include $(PKG_INSTALL_DIR)/lib
	@cp -rf $(PKG_BUILD_DIR)/boost $(PKG_INSTALL_DIR)/include/
	@if [ -d $(PKG_BUILD_DIR)/stage/lib ]; then \
		$(CP) $(PKG_BUILD_DIR)/stage/lib/libboost_*.so* $(PKG_INSTALL_DIR)/lib/ 2>/dev/null || true; \
	fi
	@echo ">>> Boost installation complete"
	@ls -lh $(PKG_INSTALL_DIR)/lib/libboost_*.so* 2>/dev/null || echo "  (no shared libs)"
endef


$(eval $(call BuildPackage,$(PKG_NAME)))

romfs:
	$(INSTALL_DIR) $(ROMFSDIR)/lib
	-$(CP) $(PKG_INSTALL_DIR)/lib/libboost_*.so* $(ROMFSDIR)/lib/
