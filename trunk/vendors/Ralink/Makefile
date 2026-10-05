# =============================================================================
# Padavan Firmware Image Generator (Ralink/MediaTek MIPS)
# Pipeline: romfs → squashfs → kernel objcopy+lzma → pad → append rootfs → TRX
# =============================================================================

# === Metadata ===
IMAGE_AUTHOR    = TurBoTse
IMAGE_DATE      ?= $(shell TZ=Asia/Shanghai date +%Y%m%d)
IMAGE_NAME      = $(CONFIG_FIRMWARE_PRODUCT_ID)-$(FIRMWARE_KERNEL_VER).$(FIRMWARE_ROOTFS_VER)-$(CONFIG_CROSS_COMPILE)-$(IMAGE_DATE).trx
IMAGE           = $(IMAGEDIR)/$(IMAGE_NAME)

# === Paths ===
KERNELZ         = $(IMAGEDIR)/zImage
RAMDISK         = $(IMAGEDIR)/ramdisk
# BOARD_NAME comes from the top-level Makefile (the build target name,
# e.g. XIAOMI-R2100). This decouples board directory lookup from
# CONFIG_FIRMWARE_PRODUCT_ID, allowing ProductID to differ from the
# board directory name (e.g. short ProductID for legacy compatibility).
BOARD_NAME      ?= $(CONFIG_FIRMWARE_PRODUCT_ID)
BOARD_DIR       = $(ROOTDIR)/configs/boards/$(BOARD_NAME)
SINGLESKU_DIR   = $(ROOTDIR)/vendors/Ralink

# === Compression / Alignment ===
COMP            = $(if $(filter y,$(CONFIG_KERNEL_NO_COMPRESS)),none,lzma)
# NAND: 128KB erase block; NOR: 16-byte
PART_ALIGN      = $(if $(filter y,$(CONFIG_MTD_NAND_MTK) $(CONFIG_MTD_NAND_RALINK)),131072,16)

# === Kernel Load Address ===
# MT7621: 0x81001000; others: 0x80000000
LOAD_ADDR       = $(if $(filter $(CONFIG_PRODUCT),MT7621),81001000,80000000)

# === Entry Point ===
# CONFIG_WITHOUT_KERNEL=y → from U-Boot header; else → from vmlinux ELF
ifeq ($(CONFIG_WITHOUT_KERNEL),y)
ENTRY_CMD = LANG=C LC_ALL=C $(MKIMAGE_TOOL) -l $(UBOOT_HEADER) 2>/dev/null | grep "Entry" | awk '{print $$3}'
else
ENTRY_CMD = $(CROSS_COMPILE)readelf -h $(ROOTDIR)/$(LINUXDIR)/vmlinux 2>/dev/null | awk '/Entry/{print $$4}'
endif

# === SquashFS Options (overridable) ===
MKSQUASHFS_OPTS ?= -all-root -no-exports -noappend -nopad -noI -no-xattrs -b 1M -comp xz -Xdict-size 100%

# === ROMFS Skeleton ===
ROMFS_DIRS = \
	bin dev dev/pts home etc etc_ro etc_ro/ppp/peers etc_ro/ppp/plugins etc_ro/ppp/3g \
	etc_ro/Wireless lib lib/modules mnt media opt proc sbin sys \
	usr usr/bin usr/sbin usr/lib/pppd usr/codepages tmp var

# Pad kernel to PART_ALIGN boundary with 0xFF fill. $(1)=image path.
define pad_kernel
	@SIZE=$$(wc -c < "$(1)") ; \
	SIZE=$$((SIZE + 64)) ; \
	DIV=$$((SIZE % $(PART_ALIGN))) ; \
	if [ $$DIV -gt 0 ]; then \
		PAD=$$(( $(PART_ALIGN) - DIV )) ; \
		head -c $$PAD /dev/zero | tr '\000' '\377' >> "$(1)" ; \
	fi
endef

# === Targets ===
.PHONY: clean romfs romfs.post image

clean:
	@echo "[*] Cleaning ramdisk and intermediate images..."
	@rm -f $(RAMDISK) $(KERNELZ) $(KERNELZ).* $(IMAGE)

romfs:
	@echo "[*] Generating ROMFS structure..."
	@echo "[*] BOARD_NAME=$(BOARD_NAME)  BOARD_DIR=$(BOARD_DIR)"
	@mkdir -p $(ROMFSDIR)
	@for dir in $(ROMFS_DIRS); do mkdir -p $(ROMFSDIR)/$$dir; done
	@if [ ! -d "$(BOARD_DIR)" ]; then \
		echo "\033[1;33m[WARNING] Board directory not found: $(BOARD_DIR)\033[0m"; \
		echo "\033[1;33m  l1profile.dat will NOT be copied; WiFi driver may fail at runtime\033[0m"; \
	fi
	@if [ -f "$(BOARD_DIR)/l1profile.dat" ]; then \
		cp -f "$(BOARD_DIR)/l1profile.dat" "$(ROMFSDIR)/etc_ro/Wireless/" && \
		echo "[*] Copied l1profile.dat ($$(wc -c < "$(BOARD_DIR)/l1profile.dat") bytes)"; \
	else \
		echo "\033[1;33m[WARNING] $(BOARD_DIR)/l1profile.dat not found, skipping\033[0m"; \
	fi
	@for f in $(wildcard $(SINGLESKU_DIR)/SingleSKU*.dat); do \
		cp -f "$$f" "$(ROMFSDIR)/etc_ro/Wireless/" && \
		echo "[*] Copied $$(basename $$f)"; \
	done

romfs.post::
	@echo "[*] Compressing ROMFS into SquashFS..."
	@mkdir -p $(IMAGEDIR)
	@rm -f $(RAMDISK) $(KERNELZ).*
	@if [ ! -f "$(ROMFSDIR)/etc_ro/Wireless/l1profile.dat" ]; then \
		echo "\033[1;31m[ERROR] l1profile.dat missing from ROMFS before squashfs!\033[0m"; \
		echo "\033[1;31m  Expected: $(ROMFSDIR)/etc_ro/Wireless/l1profile.dat\033[0m"; \
		exit 1; \
	fi
	@echo "[*] Verified l1profile.dat present in ROMFS ($$(wc -c < "$(ROMFSDIR)/etc_ro/Wireless/l1profile.dat") bytes)"
	@$(MKSQUASHFS_TOOL) $(ROMFSDIR) $(RAMDISK) $(MKSQUASHFS_OPTS)

image:
	@echo "[*] Building firmware image..."
ifeq ($(CONFIG_WITHOUT_KERNEL),y)
	@echo "[*] Using external kernel image..."
	@mkdir -p $(IMAGEDIR)
	@( cd $(IMAGEDIR) && rm -f $(KERNELZ).* && \
	   cp -f $(MERGE_DIR)/$(CONFIG_FIRMWARE_PRODUCT_ID)/kernel.bin $(KERNELZ).$(COMP) )
else
	@$(CROSS_COMPILE)objcopy -O binary -R .note -R .comment -S \
		$(ROOTDIR)/$(LINUXDIR)/vmlinux $(KERNELZ)
ifeq ($(CONFIG_KERNEL_NO_COMPRESS),y)
	@( cd $(IMAGEDIR) && rm -f $(KERNELZ).* && mv -f $(KERNELZ) $(KERNELZ).$(COMP) )
else
	@( cd $(IMAGEDIR) && rm -f $(KERNELZ).* && \
	   $(LZMA_TOOL) e -a1 -d25 $(KERNELZ) $(KERNELZ).$(COMP) )
endif
endif
	@echo "[*] Padding kernel image and appending root filesystem..."
	$(call pad_kernel,$(KERNELZ).$(COMP))
	@cat $(RAMDISK) >> $(KERNELZ).$(COMP)
	@printf "    Combined size: " && wc -c < $(KERNELZ).$(COMP)
	@echo "[*] Packing final TRX image..."
	@( cd $(IMAGEDIR) && \
		ENTRY=$$(LANG=C LC_ALL=C $(ENTRY_CMD)) ; \
		[ -n "$$ENTRY" ] || { echo "Error: failed to get entry point" >&2; exit 1; } ; \
		ISIZE=$$(wc -c < $(KERNELZ).$(COMP)) ; \
		RSIZE=$$(wc -c < $(RAMDISK)) ; \
		KRN_SIZE=$$((ISIZE - RSIZE + 64)) ; \
		$(MKIMAGE_TOOL) -A mips -O linux -T kernel -C $(COMP) \
			-a $(LOAD_ADDR) -e $$ENTRY -k $$KRN_SIZE \
			-n $(CONFIG_FIRMWARE_PRODUCT_ID) \
			-V $(FIRMWARE_KERNEL_VER) $(FIRMWARE_ROOTFS_VER) \
			-d $(KERNELZ).$(COMP) $(IMAGE) )
	@echo "[*] Image created: $(IMAGE)"