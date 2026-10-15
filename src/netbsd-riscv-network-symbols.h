/* NetBSD RV64 exposes its little-endian network conversions as bswap symbols.
 * Keep the real native call and only alias names that dlsym could not resolve. */
#ifndef FACTOR_NETBSD_RISCV_NETWORK_SYMBOLS_H
#define FACTOR_NETBSD_RISCV_NETWORK_SYMBOLS_H
#include <string.h>
#include <dlfcn.h>

static inline const char* factor_netbsd_network_alias_for(
    int netbsd, int riscv64, int little_endian, const char* name) {
  if (!netbsd || !riscv64 || !little_endian) return NULL;
  if (!strcmp(name, "htons") || !strcmp(name, "ntohs")) return "__bswap16";
  if (!strcmp(name, "htonl") || !strcmp(name, "ntohl")) return "__bswap32";
  return NULL;
}

static inline const char* factor_netbsd_network_alias(const char* name) {
#if defined(__NetBSD__) && defined(__riscv) && __riscv_xlen == 64 && \
    defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
  return factor_netbsd_network_alias_for(1, 1, 1, name);
#else
  return factor_netbsd_network_alias_for(0, 0, 0, name);
#endif
}

static inline void* factor_netbsd_network_symbol(
    void* original, void* handle, const char* name) {
  if (original) return original;
  const char* alias = factor_netbsd_network_alias(name);
  return alias ? dlsym(handle, alias) : NULL;
}
#endif
