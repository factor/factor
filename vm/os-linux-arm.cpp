#include "master.hpp"

namespace factor {

void flush_icache(cell start, cell len) {
//   int result;

//   // XXX: why doesn't this work on Nokia n800? It should behave
//   //      identically to the below assembly.
//   // result = syscall(__ARM_NR_cacheflush,start,start + len,0);

//   // Assembly swiped from
//   // http://lists.arm.linux.org.uk/pipermail/linux-arm/2002-July/003931.html
//   __asm__ __volatile__("mov     r0, %1\n"
//                        "sub     r1, %2, #1\n"
//                        "mov     r2, #0\n"
//                        "swi     " __sys1(__ARM_NR_cacheflush) "\n"
//                                                               "mov     %0, r0\n"
//                        : "=r"(result)
//                        : "r"(start), "r"(start + len)
//                        : "r0", "r1", "r2");

//   if (result < 0)
//     critical_error("flush_icache() failed", result);
}

}
