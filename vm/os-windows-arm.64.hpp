#include "atomic-cl-64.hpp"

namespace factor {

#define ESP Sp
#define EIP Pc

inline static void flush_icache(cell start, cell len) {
  HANDLE proc = GetCurrentProcess();
  FlushInstructionCache(proc, (LPCVOID)start, len);
}

}
