namespace factor {

#define FACTOR_CPU_STRING "arm.64"

inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char *)start, (char *)(start + len));
}

}
