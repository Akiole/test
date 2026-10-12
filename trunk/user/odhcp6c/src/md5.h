/*
 * Minimal MD5 implementation compatible with libubox md5 API.
 * Used by odhcp6c for DUID generation and reconfigure authentication.
 */

#ifndef _MD5_H_
#define _MD5_H_

#include <stdint.h>
#include <stddef.h>

#define MD5_DIGEST_SIZE	16
#define MD5_BLOCK_SIZE		64

typedef struct md5_ctx {
	uint32_t A, B, C, D;
	uint64_t total;
	uint8_t buffer[MD5_BLOCK_SIZE];
} md5_ctx_t;

void md5_begin(md5_ctx_t *ctx);
void md5_hash(const void *data, size_t len, md5_ctx_t *ctx);
void md5_end(void *resbuf, md5_ctx_t *ctx);

#endif /* _MD5_H_ */
