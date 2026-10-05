#!/bin/sh
[ -z "$UNSQSHFS_TOOL" ] && echo "UNSQSHFS_TOOL is not set" >&2 && exit 1
[ -z "$ROOTDIR" ] && echo "ROOTDIR is not set" >&2 && exit 1

. "$ROOTDIR/.config"

UNPACK_TRX_DIR="$MERGE_DIR/${CONFIG_FIRMWARE_PRODUCT_ID}"
[ -d "$UNPACK_TRX_DIR" ] && exit 0

mkdir -p "$UNPACK_TRX_DIR"

TARGET="$MERGE_DIR/${CONFIG_FIRMWARE_PRODUCT_ID}.trx"
ROOTFS="$UNPACK_TRX_DIR/rootfs"

# Find squashfs magic offset (portable: no grep -P)
offset1=$(grep -oba hsqs "$TARGET" | head -1 | cut -d: -f1)
offset2=$(wc -c < "$TARGET" | tr -d ' ')
size2=$((offset2 - offset1))

#dd if="$TARGET" of="$UNPACK_TRX_DIR/uboot_header.bin" bs=1 ibs=1 count=64
dd if="$TARGET" of="$UNPACK_TRX_DIR/kernel.bin" bs=1 ibs=1 skip=64 count=$((offset1 - 64)) 2>/dev/null
dd if="$TARGET" of="$UNPACK_TRX_DIR/secondchunk.bin" bs=1 ibs=1 count="$size2" skip="$offset1" 2>/dev/null

"$UNSQSHFS_TOOL" -d "$ROOTFS" "$UNPACK_TRX_DIR/secondchunk.bin"
rm -f "$UNPACK_TRX_DIR/secondchunk.bin"
