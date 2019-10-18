#include "master.hpp"

namespace factor {

void factor_vm::c_to_factor_toplevel(cell quot) {
  // 32-bit Windows SEH set up in basis/bootstrap/assembler/x86.32.windows.factor
  c_to_factor(quot);
}

}
