# SPDX-License-Identifier: GPL-2.0-only
#
# Makefile for the Shortcut Forwarding Engine.
#

ccflags-y += -DSFE_SUPPORT_IPV6

# Core SFE engine, built-in to vmlinux.
obj-$(CONFIG_SHORTCUT_FE) += shortcut-fe.o
shortcut-fe-objs := sfe_ipv4.o sfe_ipv6.o

# Fast classifier netlink control plane (module: fast_classifier.ko).
# Source keeps upstream name fast-classifier.c; kbuild object name is
# remapped so the produced module is fast_classifier.ko (rc scripts
# modprobe fast_classifier).
obj-$(CONFIG_SHORTCUT_FE_FAST_CLASSIFIER) += fast_classifier.o
fast_classifier-y := fast-classifier.o
