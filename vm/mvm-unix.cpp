#include "master.hpp"

namespace factor {

static pthread_key_t current_vm_tls_key;

void init_mvm() {
  if (pthread_key_create(&current_vm_tls_key, nullptr) != 0)
    fatal_error("pthread_key_create() failed", 0);
}

void register_vm_with_thread(factor_vm* vm) {
  pthread_setspecific(current_vm_tls_key, vm);
}

factor_vm* current_vm_p() {
  return (factor_vm*)pthread_getspecific(current_vm_tls_key);
}

}
