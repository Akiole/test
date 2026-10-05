/*
 * fopencookie_compat.c - fopencookie() compatibility for uClibc
 *
 * glibc provides fopencookie()/cookie_io_functions_t for custom FILE* streams.
 * uClibc lacks these.  This implementation uses a socketpair(2) plus two
 * pthreads to proxy between a standard FILE* (fdopen'd on one end) and the
 * cookie read/write/close callbacks.
 *
 * Only the subset needed by httpd (SSL I/O) is implemented:  "r+" mode,
 * no seek.
 */

#include "fopencookie_compat.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/socket.h>
#include <errno.h>

typedef struct {
	void *cookie;
	cookie_io_functions_t funcs;
	int sock;
	pthread_t read_thr;
	pthread_t write_thr;
} fcookie_t;

/* Read proxy: block on cookie->read (SSL_read), push into socketpair */
static void *read_proxy(void *arg)
{
	fcookie_t *fc = (fcookie_t *)arg;
	char buf[8192];
	for (;;) {
		ssize_t n = fc->funcs.read(fc->cookie, buf, sizeof(buf));
		if (n <= 0)
			break;
		ssize_t off = 0;
		while (off < n) {
			ssize_t w = write(fc->sock, buf + off, n - off);
			if (w <= 0)
				goto done;
			off += w;
		}
	}
done:
	shutdown(fc->sock, SHUT_WR);
	return NULL;
}

/* Write proxy: drain socketpair, push into cookie->write (SSL_write).
 * On EOF (fclose closed the other end), call cookie->close and clean up. */
static void *write_proxy(void *arg)
{
	fcookie_t *fc = (fcookie_t *)arg;
	char buf[8192];
	for (;;) {
		ssize_t n = read(fc->sock, buf, sizeof(buf));
		if (n <= 0)
			break;
		ssize_t off = 0;
		while (off < n) {
			ssize_t w = fc->funcs.write(fc->cookie, buf + off, n - off);
			if (w <= 0)
				goto done;
			off += w;
		}
	}
done:
	/* Signal read thread to stop by shutting down SSL via cookie->close */
	if (fc->funcs.close)
		fc->funcs.close(fc->cookie);
	pthread_join(fc->read_thr, NULL);
	close(fc->sock);
	free(fc);
	return NULL;
}

FILE *fopencookie(void *cookie, const char *mode, cookie_io_functions_t funcs)
{
	int sv[2];
	if (socketpair(AF_UNIX, SOCK_STREAM, 0, sv) < 0)
		return NULL;

	fcookie_t *fc = calloc(1, sizeof(*fc));
	if (!fc) {
		close(sv[0]);
		close(sv[1]);
		return NULL;
	}
	fc->cookie = cookie;
	fc->funcs  = funcs;
	fc->sock   = sv[1];

	pthread_create(&fc->read_thr, NULL, read_proxy, fc);
	pthread_create(&fc->write_thr, NULL, write_proxy, fc);

	FILE *fp = fdopen(sv[0], mode);
	if (!fp) {
		close(sv[0]);
		close(sv[1]);
		pthread_cancel(fc->read_thr);
		pthread_cancel(fc->write_thr);
		pthread_join(fc->read_thr, NULL);
		pthread_join(fc->write_thr, NULL);
		free(fc);
		return NULL;
	}
	return fp;
}
