LINUX_VERSION := $(shell grep -m1 "^VERSION =" $(CONFIG_LINUXDIR)/Makefile | awk '{print $$3}')
LINUX_PATCHLEVEL := $(shell grep -m1 "^PATCHLEVEL =" $(CONFIG_LINUXDIR)/Makefile | awk '{print $$3}')
LINUX_SUBLEVEL := $(shell grep -m1 "^SUBLEVEL =" $(CONFIG_LINUXDIR)/Makefile | awk '{print $$3}')

FIRMWARE_KERNEL_VER=$(LINUX_VERSION).$(LINUX_PATCHLEVEL)
FIRMWARE_ROOTFS_VER=$(LINUX_SUBLEVEL)
FIRMWARE_BUILDS_VER=100
FIRMWARE_BUILDS_REV := $(shell git rev-parse --short=7 HEAD 2>/dev/null)
