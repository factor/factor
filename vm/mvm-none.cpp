#include "master.hpp"

namespace factor {

factor_vm* global_vm;

void init_mvm() { global_vm = NULL; }

void register_vm_with_thread(factor_vm* vm) {
  FACTOR_ASSERT(!global_vm);
  global_vm = vm;
}

factor_vm* current_vm_p() { return global_vm; }

}
