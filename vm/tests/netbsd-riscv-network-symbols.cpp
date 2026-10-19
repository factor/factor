#include "../../src/netbsd-riscv-network-symbols.h"
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <type_traits>
#if defined(__NetBSD__)
#include <sys/bswap.h>
static_assert(std::is_same<decltype(&(bswap16)), uint16_t (*)(uint16_t)>::value, "native16 ABI");
static_assert(std::is_same<decltype(&(bswap32)), uint32_t (*)(uint32_t)>::value, "native32 ABI");
#endif

int main() {
  const char* names[] = {"htons", "ntohs", "htonl", "ntohl"};
  for (unsigned i = 0; i != 4; ++i) {
    assert(!strcmp(factor_netbsd_network_alias_for(1, 1, 1, names[i]), i < 2 ? "__bswap16" : "__bswap32"));
    assert(!factor_netbsd_network_alias_for(0, 1, 1, names[i]));
    assert(!factor_netbsd_network_alias_for(1, 0, 1, names[i]));
    assert(!factor_netbsd_network_alias_for(1, 1, 0, names[i]));
  }
  assert(!factor_netbsd_network_alias_for(1, 1, 1, "malloc"));
  void* handle = dlopen(NULL, RTLD_LAZY);
  assert(handle);
  void* original = dlsym(handle, "malloc");
  assert(original && factor_netbsd_network_symbol(original, handle, "malloc") == original);
  assert(factor_netbsd_network_symbol(original, handle, "htons") == original);
  if (factor_netbsd_network_alias("htons")) {
    const uint16_t shorts[] = {0, 1, 0x80, 0x8000, 0xffff, 0x1234};
    const uint32_t longs[] = {0, 1, 0x80, 0x80000000, 0xffffffff, 0x12345678};
    for (unsigned i = 0; i != 4; ++i) {
      void* native = dlsym(handle, names[i]);
      void* resolved = factor_netbsd_network_symbol(native, handle, names[i]);
      assert(resolved);
      assert(resolved == (native ? native : dlsym(handle, i < 2 ? "__bswap16" : "__bswap32")));
      if (i < 2) {
        auto convert = reinterpret_cast<uint16_t (*)(uint16_t)>(resolved);
        for (uint16_t x : shorts) assert(convert(x) == uint16_t((x >> 8) | (x << 8)));
      } else {
        auto convert = reinterpret_cast<uint32_t (*)(uint32_t)>(resolved);
        for (uint32_t x : longs) assert(convert(x) == ((x >> 24) | ((x >> 8) & 0xff00) | ((x << 8) & 0xff0000) | (x << 24)));
      }
    }
  } else {
    for (const char* name : names) assert(!factor_netbsd_network_alias(name));
  }
  assert(!factor_netbsd_network_symbol(NULL, handle, "factor-definitely-missing-symbol"));
  dlclose(handle);
  puts("NetBSD network alias guards, native precedence, ABI and16/32-bit bounds passed");
}
