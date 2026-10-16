// Select CPU frames and call-site operations after OS cache services.
#pragma once

#if defined(FACTOR_ALPHA)
  #include "cpu-alpha.hpp"
#elif defined(FACTOR_HPPA)
  #include "cpu-hppa.hpp"
#elif defined(FACTOR_SH)
  #include "cpu-sh.hpp"
#elif defined(FACTOR_M68K)
  #include "cpu-m68k.hpp"
#elif defined(FACTOR_MIPS)
  #include "cpu-mips.hpp"
#elif defined(FACTOR_X86)
  #include "cpu-x86.32.hpp"
  #include "cpu-x86.hpp"
#elif defined(FACTOR_AMD64)
  #include "cpu-x86.64.hpp"
  #include "cpu-x86.hpp"
#elif defined(FACTOR_PPC)
  #include "cpu-ppc.hpp"
#elif defined(FACTOR_ARM32)
  #include "cpu-arm.32.hpp"
#elif defined(FACTOR_ARM64)
  #include "cpu-arm.64.hpp"
#elif defined(FACTOR_SPARC)
  #include "cpu-sparc.hpp"
#elif defined(FACTOR_RISCV32)
  #include "cpu-riscv.32.hpp"
#elif defined(FACTOR_OPENRISC32)
  #include "cpu-openrisc.32.hpp"
#elif defined(FACTOR_RISCV64)
  #include "cpu-riscv.64.hpp"
#elif defined(FACTOR_LOONGARCH64)
  #include "cpu-loongarch.64.hpp"
#elif defined(FACTOR_S390X)
  #include "cpu-s390x.hpp"
#elif defined(FACTOR_M88K)
  #include "cpu-m88k.hpp"
#else
  #error "Unsupported CPU"
#endif
