#include "master.hpp"
#include <new>

namespace factor {

HANDLE boot_thread;

DWORD current_vm_tls_key;

static void allocation_failure() {
  // This can run before a VM exists. Avoid VM state, C++ streams, and
  // exception unwinding through generated code on this fatal path.
  static const char message[] =
      "fatal_error: Out of memory in C++ allocation\n";
  DWORD written;
  WriteFile(GetStdHandle(STD_ERROR_HANDLE), message, sizeof(message) - 1,
            &written, NULL);
  ::_exit(1);
}

void init_mvm() {
  std::set_new_handler(allocation_failure);
  if ((current_vm_tls_key = TlsAlloc()) == TLS_OUT_OF_INDEXES)
    fatal_error("TlsAlloc() failed", 0);
}

void register_vm_with_thread(factor_vm* vm) {
  if (!TlsSetValue(current_vm_tls_key, vm))
    fatal_error("TlsSetValue() failed", 0);
}

factor_vm* current_vm_p() {
  return (factor_vm*)TlsGetValue(current_vm_tls_key);
}

}
