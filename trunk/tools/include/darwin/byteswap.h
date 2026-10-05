/* macOS-compatible replacement for glibc <byteswap.h> (clang builtins) */
#ifndef _BYTESWAP_H_MACOS_COMPAT
#define _BYTESWAP_H_MACOS_COMPAT

#define bswap_16(x) __builtin_bswap16(x)
#define bswap_32(x) __builtin_bswap32(x)
#define bswap_64(x) __builtin_bswap64(x)

#endif
