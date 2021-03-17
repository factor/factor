namespace factor {

#define FACTOR_CPU_STRING "arm.64"

// register cell ds asm("r5");
// register cell rs asm("r6");
inline static void flush_icache(cell start, cell len) {
  //__asm("ic ialluis");
  //__asm volatile ("dmb sy" ::: "memory");

  //dsb(nsh);
  //isb();
}

}
