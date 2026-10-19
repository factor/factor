// Exhaust process RAS slots before the VM primitive initializes. These ranges
// are never executed; the check exercises the real kernel registration failure.
#include <sys/types.h>
#include <sys/ras.h>
#include <stdio.h>
#include "../../../vm/atomic-netbsd-sparc.hpp"
asm(".text\n.align 4\n.global factor_probe_ranges\n"
    "factor_probe_ranges:\n.skip 256\n");
extern "C" char factor_probe_ranges[];
static unsigned installed;
__attribute__((constructor(101))) static void exhaust_slots() {
  for (unsigned i = 0; i < 32; ++i)
    if (!rasctl(factor_probe_ranges + 8 * i, 4, RAS_INSTALL)) ++installed;
}
int main() {
  bool unavailable = !factor::atomic::ras::initialize() &&
                     !factor::atomic::ras::available();
  printf("RAS exhausted=%u unsupported=%u\n", installed, unavailable);
  return !installed || !unavailable;
}
