// Select the native relocation implementation; operand classes stay runtime data.
#pragma once

#if defined(FACTOR_M88K)
#include "cpu-m88k-relocations.hpp"
#elif defined(FACTOR_LOONGARCH64)
#include "cpu-loongarch.64-relocations.hpp"
#elif defined(FACTOR_ALPHA)
#include "cpu-alpha-relocations.hpp"
#elif defined(FACTOR_HPPA)
#include "cpu-hppa-relocations.hpp"
#elif defined(FACTOR_MIPS)
#include "cpu-mips-relocations.hpp"
#elif defined(FACTOR_OPENRISC32)
#include "cpu-openrisc-relocations.hpp"
#elif defined(FACTOR_PPC)
#include "cpu-ppc-relocations.hpp"
#elif defined(FACTOR_SPARC) || defined(FACTOR_SPARC32) || defined(FACTOR_SPARC64)
#include "cpu-sparc-relocations.hpp"
#elif defined(FACTOR_S390X)
#include "cpu-s390x-relocations.hpp"
#else
#include "cpu-generic-relocations.hpp"
#endif
