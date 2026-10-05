#!/bin/bash
# Build a single package (user or libs) with proper cross-compile environment
# Usage: ./build-pkg.sh <package-name> [clean]
# Example: ./build-pkg.sh htop
#          ./build-pkg.sh zlib clean

PKG="$1"
ACTION="${2:-build}"
TRUNK="/Volumes/Padavan/GitHub/test/trunk"
TOOLCHAIN="mipsel-linux-musl"

if [ -z "$PKG" ]; then
    echo "Usage: $0 <package-name> [clean]"
    echo "Example: $0 htop"
    echo "         $0 zlib clean"
    exit 1
fi

# Determine if package is in user/ or libs/
if [ -d "$TRUNK/user/$PKG" ]; then
    CATEGORY="user"
elif [ -d "$TRUNK/libs/$PKG" ]; then
    CATEGORY="libs"
else
    echo "Error: Package '$PKG' not found in user/ or libs/"
    exit 1
fi

# Export required environment variables (CROSS_COMPILE must have trailing hyphen!)
export ROOTDIR="$TRUNK"
export STAGING_DIR="$TRUNK/stage"
export STAGEDIR="$TRUNK/stage"
export CROSS_COMPILE="${TOOLCHAIN}-"
export PATH="$TRUNK/../toolchain/${TOOLCHAIN}/bin:$PATH"
export CONFIG_CROSS_COMPILE="$TOOLCHAIN"
export CONFIG_CROSS_COMPILER_ROOT="$TRUNK/../toolchain/${TOOLCHAIN}"
export ARCH_CONFIG="$TRUNK/config.arch"

# Export all CONFIG_ variables from .config (needed for packages that check config options)
if [ -f "$TRUNK/.config" ]; then
    set -a
    . "$TRUNK/.config"
    set +a
fi

cd "$TRUNK"

if [ "$ACTION" = "clean" ]; then
    echo "=== Cleaning $PKG ==="
    rm -rf "$TRUNK/build/${PKG}-"* 2>/dev/null
    echo "Cleaned. Now building..."
fi

echo "=== Building $PKG ($CATEGORY) ==="
gmake -C "$CATEGORY" "${PKG}_only"

if [ $? -eq 0 ]; then
    echo "✅ $PKG build succeeded"
else
    echo "❌ $PKG build failed"
    exit 1
fi
