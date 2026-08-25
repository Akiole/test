#ifndef _UTIME_H
#define _UTIME_H

#include <linux/utime.h>   /* provides struct utimbuf */
#include <sys/time.h>      /* provides struct timeval, utimes() */
#include <time.h>

__BEGIN_DECLS

/* uClibc/musl may lack utime(); implement via utimes() as static inline. */
static inline int utime(const char *filename, const struct utimbuf *times)
{
	struct timeval tv[2];
	if (times == NULL) {
		return utimes(filename, NULL);
	}
	tv[0].tv_sec  = times->actime;
	tv[0].tv_usec = 0;
	tv[1].tv_sec  = times->modtime;
	tv[1].tv_usec = 0;
	return utimes(filename, tv);
}

__END_DECLS

#endif /* _UTIME_H */
