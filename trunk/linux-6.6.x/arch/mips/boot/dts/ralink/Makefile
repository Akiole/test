# SPDX-License-Identifier: GPL-2.0
dtb-$(CONFIG_DTB_RT2880_EVAL)	+= rt2880_eval.dtb
dtb-$(CONFIG_DTB_RT305X_EVAL)	+= rt3052_eval.dtb
dtb-$(CONFIG_DTB_RT3883_EVAL)	+= rt3883_eval.dtb
dtb-$(CONFIG_DTB_MT7620A_EVAL)	+= mt7620a_eval.dtb
dtb-$(CONFIG_DTB_OMEGA2P)	+= omega2p.dtb
dtb-$(CONFIG_DTB_VOCORE2)	+= vocore2.dtb

# NOTE: pre-existing upstream boards (gnubee gb-pc1/gb-pc2, tplink hc220)
# reference an &mmc label not present in this tree's mt7621.dtsi and fail dtc.
# MT7621 dtbs are selected per board via the Kconfig choice
# (DTB_FCJ_GAX1800W / DTB_XIAOMI_REDMI_ROUTER_AC2100).
dtb-$(CONFIG_DTB_FCJ_GAX1800W) += mt7621_fcj-g-ax1800-w.dtb
dtb-$(CONFIG_DTB_XIAOMI_REDMI_ROUTER_AC2100) += mt7621_xiaomi_redmi-router-ac2100.dtb

obj-$(CONFIG_BUILTIN_DTB)	+= $(addsuffix .o, $(dtb-y))
