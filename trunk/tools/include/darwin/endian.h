/* macOS-compatible replacement for glibc <endian.h> (clang/gcc builtins) */
#ifndef _ENDIAN_H_MACOS_COMPAT
#define _ENDIAN_H_MACOS_COMPAT

#include <stdint.h>

/* Byte-order constants (glibc-compatible values). */
#define __LITTLE_ENDIAN 1234
#define __BIG_ENDIAN    4321
#define __PDP_ENDIAN    3412

#define LITTLE_ENDIAN __LITTLE_ENDIAN
#define BIG_ENDIAN    __BIG_ENDIAN
#define PDP_ENDIAN    __PDP_ENDIAN

/* Detect host byte order from compiler predefined macros (clang & gcc). */
#if defined(__BYTE_ORDER__) && (__BYTE_ORDER__ == __ORDER_BIG_ENDIAN__)
# define __BYTE_ORDER __BIG_ENDIAN
#elif defined(__BYTE_ORDER__) && (__BYTE_ORDER__ == __ORDER_PDP_ENDIAN__)
# define __BYTE_ORDER __PDP_ENDIAN
#else
# define __BYTE_ORDER __LITTLE_ENDIAN
#endif

#define BYTE_ORDER __BYTE_ORDER

/* Host <-> big-endian conversion. */
#if __BYTE_ORDER == __BIG_ENDIAN
# define htobe16(x) ((uint16_t)(x))
# define htobe32(x) ((uint32_t)(x))
# define htobe64(x) ((uint64_t)(x))
# define be16toh(x) ((uint16_t)(x))
# define be32toh(x) ((uint32_t)(x))
# define be64toh(x) ((uint64_t)(x))
#else
# define htobe16(x) __builtin_bswap16(x)
# define htobe32(x) __builtin_bswap32(x)
# define htobe64(x) __builtin_bswap64(x)
# define be16toh(x) __builtin_bswap16(x)
# define be32toh(x) __builtin_bswap32(x)
# define be64toh(x) __builtin_bswap64(x)
#endif

/* Host <-> little-endian conversion. */
#if __BYTE_ORDER == __LITTLE_ENDIAN
# define htole16(x) ((uint16_t)(x))
# define htole32(x) ((uint32_t)(x))
# define htole64(x) ((uint64_t)(x))
# define le16toh(x) ((uint16_t)(x))
# define le32toh(x) ((uint32_t)(x))
# define le64toh(x) ((uint64_t)(x))
#else
# define htole16(x) __builtin_bswap16(x)
# define htole32(x) __builtin_bswap32(x)
# define htole64(x) __builtin_bswap64(x)
# define le16toh(x) __builtin_bswap16(x)
# define le32toh(x) __builtin_bswap32(x)
# define le64toh(x) __builtin_bswap64(x)
#endif

#endif /* _ENDIAN_H_MACOS_COMPAT */
