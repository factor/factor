#include "master.hpp"

namespace factor {

HANDLE boot_thread;

DWORD current_vm_tls_key;

void init_mvm() {
  if ((current_vm_tls_key = TlsAlloc()) == TLS_OUT_OF_INDEXES)
    fatal_error("TlsAlloc() failed", 0);
}

void register_vm_with_thread(factor_vm* vm) {
  if (!TlsSetValue(current_vm_tls_key, vm))
    fatal_error("TlsSetValue() failed", 0);
}

factor_vm* current_vm_p() {
  return static_cast<factor_vm*>(TlsGetValue(current_vm_tls_key));
}

}
