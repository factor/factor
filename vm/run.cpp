#include "master.hpp"

namespace factor {

void factor_vm::primitive_exit() { exit((int)to_fixnum(ctx->pop())); }

void exit(int status) {
  close_console();
  ::exit(status);
}

void factor_vm::primitive_nano_count() {
  uint64_t nanos = nano_count();
  if (nanos < last_nano_count) {
    std::cout << "Monotonic counter decreased from 0x";
    std::cout << std::hex << last_nano_count;
    std::cout << " to 0x" << nanos << "." << std::dec << "\n";
    std::cout << "Please report this error.\n";
    current_vm()->factorbug();
  }
  last_nano_count = nanos;
  ctx->push(from_unsigned_8(nanos));
}

void factor_vm::primitive_sleep() { sleep_nanos(to_unsigned_8(ctx->pop())); }

}
