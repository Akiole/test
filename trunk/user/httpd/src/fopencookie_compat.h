#ifndef FOPENCOOKIE_COMPAT_H
#define FOPENCOOKIE_COMPAT_H

#include <stdio.h>
#include <sys/types.h>

/* musl and glibc provide fopencookie/cookie_io_functions_t natively.
   The build system defines HAVE_FOPENCOOKIE for such libcs. Only define
   compat shims for libcs that lack them (e.g. uClibc). */
#ifndef HAVE_FOPENCOOKIE
typedef struct {
	ssize_t (*read)(void *, char *, size_t);
	ssize_t (*write)(void *, const char *, size_t);
	int (*seek)(void *, off_t *, int);
	int (*close)(void *);
} cookie_io_functions_t;

FILE *fopencookie(void *cookie, const char *mode, cookie_io_functions_t funcs);
#endif /* !HAVE_FOPENCOOKIE */

#endif /* FOPENCOOKIE_COMPAT_H */
