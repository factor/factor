#include "master.hpp"

namespace factor {
void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char*)start, (char*)(start + len));
}
}
