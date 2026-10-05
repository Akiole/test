#
# Makefile for linux/drivers/scsi
#
# Core SCSI subsystem only (hardware drivers removed)
#

obj-$(CONFIG_SCSI)		+= scsi_mod.o

obj-$(CONFIG_RAID_ATTRS)	+= raid_class.o

obj-$(CONFIG_SCSI_DH)		+= scsi_dh.o

obj-$(CONFIG_BLK_DEV_SD)	+= sd_mod.o
obj-$(CONFIG_BLK_DEV_SR)	+= sr_mod.o
obj-$(CONFIG_CHR_DEV_SG)	+= sg.o
obj-$(CONFIG_CHR_DEV_SCH)	+= ch.o

scsi_mod-y			+= scsi.o hosts.o scsi_ioctl.o \
				   scsicam.o scsi_error.o scsi_lib.o
scsi_mod-y			+= scsi_common.o
scsi_mod-$(CONFIG_SCSI_CONSTANTS) += constants.o
scsi_mod-$(CONFIG_SCSI_DMA)	+= scsi_lib_dma.o
scsi_mod-y			+= scsi_scan.o scsi_sysfs.o scsi_devinfo.o
scsi_mod-$(CONFIG_SCSI_NETLINK)	+= scsi_netlink.o
scsi_mod-$(CONFIG_SYSCTL)	+= scsi_sysctl.o
scsi_mod-$(CONFIG_SCSI_PROC_FS)	+= scsi_proc.o
scsi_mod-y			+= scsi_trace.o scsi_logging.o
scsi_mod-$(CONFIG_PM)		+= scsi_pm.o

sd_mod-objs	:= sd.o
sd_mod-$(CONFIG_BLK_DEV_INTEGRITY) += sd_dif.o

sr_mod-objs	:= sr.o sr_ioctl.o sr_vendor.o
