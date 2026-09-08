#include "../master.hpp"
#include <new>

// An impossible request exercises the failure path without exhausting RAM.
// Catch the old behavior so the negative control does not open a crash dialog.
int main() {
  factor::init_mvm();
  try {
    void* memory = ::operator new(std::numeric_limits<size_t>::max());
    ::operator delete(memory);
  } catch (const std::bad_alloc&) {
    fputs("Allocation failure escaped without a Factor diagnostic\n", stderr);
    return 2;
  }
  return 3;
}
