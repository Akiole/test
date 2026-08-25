#
# CMake Toolchain file for MIPS (mipsel) cross-compilation
#
# This can be used when running cmake in the following way:
#  cd build/
#  cmake .. -DCMAKE_TOOLCHAIN_FILE=$(CONFIG_CMAKE_TOOLCHAIN_FILE)

# Basic environment extraction
set(CROSS_COMPILE $ENV{CROSS_COMPILE})
set(STAGEDIR $ENV{STAGEDIR})
set(ARCH $ENV{ARCH})
set(CONFIG_CROSS_COMPILER_ROOT $ENV{CONFIG_CROSS_COMPILER_ROOT})
set(CPUFLAGS $ENV{CPUFLAGS})
set(CFLAGS $ENV{CFLAGS})
set(CXXFLAGS $ENV{CXXFLAGS})
set(LDFLAGS $ENV{LDFLAGS})

# Toolchain prefix
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR "${ARCH}")

# Compiler tools (gcc-ar/gcc-ranlib/gcc-nm for LTO compatibility)
set(CMAKE_C_COMPILER "${CROSS_COMPILE}gcc")
set(CMAKE_CXX_COMPILER "${CROSS_COMPILE}g++")
set(CMAKE_AR "${CROSS_COMPILE}gcc-ar")
set(CMAKE_NM "${CROSS_COMPILE}gcc-nm")
set(CMAKE_RANLIB "${CROSS_COMPILE}gcc-ranlib")
set(CMAKE_LINKER "${CROSS_COMPILE}ld.bfd")
set(CMAKE_C_COMPILER_AR "${CROSS_COMPILE}gcc-ar")
set(CMAKE_CXX_COMPILER_AR "${CROSS_COMPILE}gcc-ar")
set(CMAKE_C_COMPILER_RANLIB "${CROSS_COMPILE}gcc-ranlib")
set(CMAKE_CXX_COMPILER_RANLIB "${CROSS_COMPILE}gcc-ranlib")

# Compilation flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CFLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CXXFLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${LDFLAGS}")

# Target environment paths
set(CMAKE_FIND_ROOT_PATH "${CONFIG_CROSS_COMPILER_ROOT}" "${STAGEDIR}")

# Find modes
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# pkg-config support: LIBDIR restricts search to staging (no host .pc files),
# SYSROOT_DIR rewrites -L/-I paths from the empty-prefix .pc files to staging.
set(ENV{PKG_CONFIG_LIBDIR} "${STAGEDIR}/lib/pkgconfig:${STAGEDIR}/share/pkgconfig")
set(ENV{PKG_CONFIG_SYSROOT_DIR} "${STAGEDIR}")

# Architecture-specific flags (append to compiler flags, not definitions)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CPUFLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CPUFLAGS}")
