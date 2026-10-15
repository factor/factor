#pragma once
#include <stdint.h>
namespace factor {
// PA-RISC instruction and data caches are separate. GCC's PA clear-cache
// builtin can be empty; explicitly write back data before invalidating code.
inline void hppa_flush_icache(uintptr_t start, uintptr_t length) {
  if (!length) return;
  uintptr_t first=start & ~uintptr_t(15), last=(start+length-1)&~uintptr_t(15);
  for(uintptr_t p=first;;p+=16) {
    __asm__ volatile("fdc 0(%0)" : : "r"(p) : "memory");
    if(p==last) break;
  }
  __asm__ volatile("sync" : : : "memory");
  uintptr_t old_space, space;
  __asm__ volatile("mfsp %%sr0,%0\n\tldsid (%2),%1\n\tmtsp %1,%%sr0"
                   : "=&r"(old_space), "=&r"(space) : "r"(start) : "memory");
  for(uintptr_t p=first;;p+=16) {
    __asm__ volatile("fic 0(%%sr0,%0)" : : "r"(p) : "memory");
    if(p==last) break;
  }
  __asm__ volatile("sync\n\tnop\n\tnop\n\tnop\n\tnop\n\tnop\n\tnop\n\tnop\n\tmtsp %0,%%sr0"
                   : : "r"(old_space) : "memory");
}
}
