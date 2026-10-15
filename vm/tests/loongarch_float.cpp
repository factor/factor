#ifdef NDEBUG
#undef NDEBUG
#endif
// Execute the comparison encodings used by the Factor backend on LoongArch Linux.
#include <cassert>
#include <cstdint>
#include <initializer_list>
#include <cstring>
#include <sys/mman.h>
#include <unistd.h>
int main() {
  const auto size = getpagesize();
  auto* code = (uint32_t*)mmap(nullptr,size,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  assert(code != MAP_FAILED);
  code[1] = 0x0114c804; // movfcsr2gr a0,fcsr0
  code[2] = 0x4c000020; // jirl zero,ra,0
  auto compare = (uint32_t(*)(double,double))code;
  for (uint64_t bits : {UINT64_C(0x7ff8000000000001), UINT64_C(0x7ff0000000000001)}) {
    double nan; memcpy(&nan,&bits,sizeof(nan));
    for (unsigned opcode : {0x0c210400u,0x0c218400u,0x0c230400u,0x0c238400u}) {
      code[0] = opcode;
      __builtin___clear_cache((char*)code,(char*)(code+3));
      asm volatile("movgr2fcsr $fcsr0,$zero" ::: "memory");
      unsigned status = compare(nan,1.0);
      assert(bool(status & 0x100000) == (bool(opcode & 0x8000) || !(bits & (UINT64_C(1) << 51))));
    }
  }
  munmap(code,size);
}
