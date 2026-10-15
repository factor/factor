#pragma once

namespace factor::platform {
inline void dispatch_signal(factor_vm& vm, void* uap, void(handler)()) {
  vm.dispatch_sparc_signal(uap, (cell)FUNCTION_CODE_POINTER(handler));
}
}
