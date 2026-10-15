// OS cache declarations precede CPU inline call-site patching.
#pragma once

// Instruction encodings are independent of OS headers.
#if defined(FACTOR_HPPA)
#include "hppa.hpp"
#elif defined(FACTOR_SH)
#include "sh.hpp"
#elif defined(FACTOR_RISCV32) || defined(FACTOR_RISCV64)
#include "riscv.hpp"
#elif defined(FACTOR_S390X)
#include "s390x.hpp"
#elif defined(FACTOR_M68K)
#include "m68k.hpp"
#elif defined(FACTOR_SPARC)
#include "sparc.hpp"
#elif defined(FACTOR_M88K)
#include "m88k.hpp"
#endif

#include "os.hpp"
#include "cpu.hpp"
