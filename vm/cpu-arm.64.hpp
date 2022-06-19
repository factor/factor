namespace factor {

#include <sys/syscall.h>
#include <unistd.h>

#define FACTOR_CPU_STRING "arm.64"

#define __ARM_NR_cacheflush 0x0f0002

inline static void flush_icache(cell start, cell len) {
  int result;
  cell end = start + len;

  // From compiler-rt, Apache-2.0 WITH LLVM-exception
  register int start_reg __asm("r0") = (int)(intptr_t)start;
  const register int end_reg __asm("r1") = (int)(intptr_t)end;
  const register int flags __asm("r2") = 0;
  const register int syscall_nr __asm("r7") = __ARM_NR_cacheflush;
  __asm __volatile("svc 0x0"
                   : "=r"(start_reg)
                   : "r"(syscall_nr), "r"(start_reg), "r"(end_reg), "r"(flags));
  //if (start_reg == 0)
    //critical_error("flush_icache() failed", result);

  uint64_t xstart = (uint64_t)(uintptr_t)start;
  uint64_t xend = (uint64_t)(uintptr_t)end;
  uint64_t addr;

  // Get Cache Type Info
  uint64_t ctr_el0;
  __asm __volatile("mrs %0, ctr_el0" : "=r"(ctr_el0));

  // dc & ic instructions must use 64bit registers so we don't use
  // uintptr_t in case this runs in an IPL32 environment.
  const size_t dcache_line_size = 4 << ((ctr_el0 >> 16) & 15);
  for (addr = xstart & ~(dcache_line_size - 1); addr < xend;
       addr += dcache_line_size)
    __asm __volatile("dc cvau, %0" ::"r"(addr));
  __asm __volatile("dsb ish");

  const size_t icache_line_size = 4 << ((ctr_el0 >> 0) & 15);
  for (addr = xstart & ~(icache_line_size - 1); addr < xend;
       addr += icache_line_size)
    __asm __volatile("ic ivau, %0" ::"r"(addr));
  __asm __volatile("isb sy");
}

}
