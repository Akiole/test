#!/bin/bash
# ============================================================
# 宿主机 OS 检测 + 跨平台 GNU 工具选择（shell 脚本版）
# 被 configure 等 shell 脚本 source，与 host-tools.mk 保持一致
#
# 用法：source "$ROOTDIR/host-tools.sh"
# ============================================================

if [ "$(uname)" = "Darwin" ]; then
    IS_DARWIN=1
    HOST_OS="Darwin"
    SED="gsed"
    SED_READ="gsed"
    TAR="gtar"
    PATCH="gpatch"
    XARGS="gxargs -r"
    FIND="find"
else
    IS_DARWIN=0
    HOST_OS="$(uname)"
    SED="sed"
    SED_READ="sed"
    TAR="tar"
    PATCH="patch"
    XARGS="xargs -r"
    FIND="find"
fi
