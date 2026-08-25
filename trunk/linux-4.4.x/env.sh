#!/usr/bin/env bash
# Auto-detect MIPS cross toolchain for manual kernel builds.
#
# Priority:
#   1. TOOLCHAIN env var (e.g. TOOLCHAIN=mipsel-linux-musl)
#   2. Local toolchain/ directory (musl preferred, then uclibc)
#   3. System PATH (musl preferred, then uclibc)
#
# Usage:  source env.sh   then   make menuconfig / make -j10

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Project root is two levels up from linux-4.4.x/
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TOOLCHAIN_DIR="$PROJECT_ROOT/toolchain"

# Supported toolchain triplets (order = preference)
TRIPLETS=(mipsel-linux-musl mipsel-linux-uclibc)

# --- 1. Explicit TOOLCHAIN override ---
if [ -n "$TOOLCHAIN" ]; then
    SELECTED="$TOOLCHAIN"
else
    SELECTED=""
    # --- 2. Local toolchain/ directory ---
    for t in "${TRIPLETS[@]}"; do
        if [ -x "$TOOLCHAIN_DIR/$t/bin/$t-gcc" ]; then
            SELECTED="$t"
            break
        fi
    done
    # --- 3. System PATH ---
    if [ -z "$SELECTED" ]; then
        for t in "${TRIPLETS[@]}"; do
            if command -v "$t-gcc" >/dev/null 2>&1; then
                SELECTED="$t"
                break
            fi
        done
    fi
fi

if [ -z "$SELECTED" ]; then
    echo "Error: No MIPS toolchain found." >&2
    echo "  Looked in: $TOOLCHAIN_DIR" >&2
    echo "  And PATH for: ${TRIPLETS[*]}" >&2
    echo "  Set TOOLCHAIN=<triplet> to override." >&2
    return 1 2>/dev/null || exit 1
fi

export ARCH=mips
export CROSS_COMPILE="${SELECTED}-"
export CONFIG_CROSS_COMPILE="${SELECTED}-"

# Add local toolchain bin to PATH if not already there
if [ -d "$TOOLCHAIN_DIR/$SELECTED/bin" ]; then
    case ":$PATH:" in
        *":$TOOLCHAIN_DIR/$SELECTED/bin:"*) ;;
        *) export PATH="$TOOLCHAIN_DIR/$SELECTED/bin:$PATH" ;;
    esac
fi

echo "==> Toolchain: $SELECTED"
echo "    ARCH=$ARCH  CROSS_COMPILE=$CROSS_COMPILE"
