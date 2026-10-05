#!/bin/sh

depmod_bin="/sbin/depmod"

# check env
if [ -z "${ROOTDIR}" ]; then
	echo "ROOTDIR is not set!"
	exit 1
fi

if [ -z "${KERNELRELEASE}" ]; then
	echo "KERNELRELEASE is not set!"
	exit 1
fi

if [ -z "${INSTALL_MOD_PATH}" ]; then
	echo "INSTALL_MOD_PATH is not set!"
	exit 1
fi

# Locate ipset kernel modules (version-agnostic)
ipset_dir=$(ls -d "${ROOTDIR}"/build/ipset-*/kernel/net/netfilter 2>/dev/null | head -1)
if [ -n "$ipset_dir" ]; then
	mkdir -p "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/kernel/net/netfilter/ipset"
	[ -f "$ipset_dir/xt_set.ko" ] && cp -f "$ipset_dir/xt_set.ko" "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/kernel/net/netfilter"
	cp -f "$ipset_dir/ipset/"*.ko "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/kernel/net/netfilter/ipset" 2>/dev/null || true
fi

if [ "$CONFIG_FIRMWARE_INCLUDE_ANTFS" = "y" ] ; then
	antfs_dir=$(ls -d "${ROOTDIR}"/build/antfs-* 2>/dev/null | head -1)
	if [ -n "$antfs_dir" ] && [ -f "$antfs_dir/antfs.ko" ]; then
		mkdir -p "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/kernel/antfs"
		cp -f "$antfs_dir/antfs.ko" "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/kernel/antfs"
	fi
fi

# Newer kmod probes this metadata file, while Linux 4.4 does not generate it.
# An empty file is sufficient and avoids a misleading warning.
: > "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/modules.builtin.modinfo"

# call depmod.  -b already selects the target root; the old -r option was
# removed from modern kmod and made this command fail without generating
# modules.dep.
if [ -x "$depmod_bin" ]; then
	if ! "$depmod_bin" -ae -F System.map -b "${INSTALL_MOD_PATH}" "${KERNELRELEASE}"; then
		echo "depmod failed for ${KERNELRELEASE}"
		exit 1
	fi
else
	# No host depmod (e.g. macOS): resolve module deps with the cross nm.
	DEPMOD_NM="${CROSS_COMPILE}nm" python3 "$(dirname "$0")/depmod.py" "${KERNELRELEASE}" || exit 1
fi

# clear unneeded depmod files
rm -f "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/modules.alias"
rm -f "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/modules.alias.bin"
rm -f "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/modules.dep.bin"
rm -f "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/modules.devname"
rm -f "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/modules.softdep"
rm -f "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/modules.symbols"
rm -f "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/modules.symbols.bin"
rm -f "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/modules.builtin"
rm -f "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/modules.builtin.bin"
rm -f "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/modules.builtin.alias.bin"
rm -f "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/modules.builtin.modinfo"
rm -f "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/modules.order"
rm -f "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/build"
rm -f "${INSTALL_MOD_PATH}/lib/modules/${KERNELRELEASE}/source"
