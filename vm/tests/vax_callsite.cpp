#include "../vax.hpp"
#include <assert.h>
#include <stdio.h>

#if defined(__NetBSD__) && defined(__vax__)
#include <sys/mman.h>
#include <unistd.h>
#include "../assert.hpp"
#include "../layouts.hpp"
#include "../os-netbsd-vax.hpp"
#include "../cpu-vax.hpp"
#endif

int main() {
  unsigned char instruction[] = {0x16, 0x9f, 0x78, 0x56, 0x34, 0x12};
  void* return_address = instruction + 6;
  assert(factor::vax_call_site_p(return_address));
  assert(!factor::vax_tail_call_site_p(return_address));
  assert(factor::vax_call_target(return_address) == UINT32_C(0x12345678));
  factor::vax_store_call_target(return_address, UINT32_C(0xfedcba98));
  assert(factor::vax_call_target(return_address) == UINT32_C(0xfedcba98));
  instruction[0] = 0x17;
  assert(factor::vax_tail_call_site_p(return_address));
  instruction[1] = 0x8f;
  assert(!factor::vax_call_site_p(return_address));

#if defined(__NetBSD__) && defined(__vax__)
  static_assert(sizeof(void*) == 4, "VAX addresses are 32 bits");
  long page_size = sysconf(_SC_PAGESIZE);
  assert(page_size > 0);
  unsigned char* code = (unsigned char*)mmap(
      NULL, (size_t)page_size, PROT_READ | PROT_WRITE,
      MAP_PRIVATE | MAP_ANON, -1, 0);
  assert(code != MAP_FAILED);
  // A native CALLS entry calls an RSB leaf through JSB or a tail JMP stub.
  const unsigned char body[] = {
      0, 0, 0x16, 0x9f, 0, 0, 0, 0, 0x04,
      0xd0, 42, 0x50, 0x05,
      0xd0, 17, 0x50, 0x05,
      0x17, 0x9f, 0, 0, 0, 0};
  memcpy(code, body, sizeof(body));
  factor::vax_store_call_target(code + 8, (uint32_t)(uintptr_t)(code + 9));
  factor::vax_store_call_target(code + 23, (uint32_t)(uintptr_t)(code + 9));
  assert(mprotect(code, (size_t)page_size, PROT_READ | PROT_EXEC) == 0);
  typedef int (*native_entry)(void);
  native_entry entry = (native_entry)code;
  assert(factor::JIT_FRAME_SIZE == 16);
  assert(factor::SIGNAL_HANDLER_STACK_FRAME_SIZE == 64);
  assert(factor::get_call_target((uintptr_t)(code + 8)) == code + 9);
  assert(entry() == 42);

  assert(mprotect(code, (size_t)page_size, PROT_READ | PROT_WRITE) == 0);
  factor::set_call_target((uintptr_t)(code + 8), (uintptr_t)(code + 13));
  assert(mprotect(code, (size_t)page_size, PROT_READ | PROT_EXEC) == 0);
  assert(entry() == 17);

  assert(mprotect(code, (size_t)page_size, PROT_READ | PROT_WRITE) == 0);
  factor::set_call_target((uintptr_t)(code + 8), (uintptr_t)(code + 17));
  assert(factor::vax_tail_call_site_p(code + 23));
  assert(mprotect(code, (size_t)page_size, PROT_READ | PROT_EXEC) == 0);
  assert(entry() == 42);
  assert(munmap(code, (size_t)page_size) == 0);
#endif
  puts("VAX JSB/JMP callsite encoding passed");
}
