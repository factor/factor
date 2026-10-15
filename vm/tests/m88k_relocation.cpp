#include <cassert>
#include <stdint.h>
#define FACTOR_ASSERT assert
#include "../m88k.hpp"
int main() {
  const uint32_t values[] = {0,1,0xffff,0x10000,0x12345678,0x80000000,0xffffffff};
  for(unsigned i=0;i<sizeof(values)/sizeof(values[0]);++i) {
    uint32_t words[] = {0x5ea00000,0x5ab50000};
    factor::m88k_store_literal32(words,values[i]);
    assert(factor::m88k_load_literal32(words)==values[i]);
    assert((words[0]&0xffff0000)==0x5ea00000);
    assert((words[1]&0xffff0000)==0x5ab50000);
  }
  const int32_t offsets[] = {-0x08000000,-4,0,4,0x07fffffc};
  for(unsigned i=0;i<sizeof(offsets)/sizeof(offsets[0]);++i) {
    uint32_t word=0xc8000000;
    factor::m88k_store_branch(&word,offsets[i]);
    assert((word&0xfc000000)==0xc8000000);
    assert(factor::m88k_branch_displacement(word)==offsets[i]);
  }
  return 0;
}
