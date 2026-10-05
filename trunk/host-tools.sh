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

    # Ensure Homebrew bin is in PATH so gsed/gtar/gpatch/grep are resolvable
    # even when this script is sourced outside the Makefile environment.
    if command -v brew >/dev/null 2>&1; then
        BREW_PREFIX="$(brew --prefix)"
        case ":$PATH:" in
            *":$BREW_PREFIX/bin:"*) ;;
            *) export PATH="$BREW_PREFIX/bin:$PATH" ;;
        esac
    fi

    SED="gsed"
    SED_READ="gsed"
    TAR="gtar"
    PATCH="gpatch"
    XARGS="gxargs -r"
    FIND="find"
    GREP="grep"
else
    IS_DARWIN=0
    HOST_OS="$(uname)"
    SED="sed"
    SED_READ="sed"
    TAR="tar"
    PATCH="patch"
    XARGS="xargs -r"
    FIND="find"
    GREP="grep"
fi
