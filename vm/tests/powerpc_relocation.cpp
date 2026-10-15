#include <stdint.h>
#include <cstring>
#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <stdexcept>
namespace factor {
using cell = uintptr_t;
using fixnum = intptr_t;
void critical_error(const char* reason, cell) { throw std::runtime_error(reason); }
}
#include "../powerpc.hpp"
using namespace factor;
int main() {
  uint32_t load[] = {0x3d800000,0x618c0000,0x798c07c6,0x658c0000,0x618c0000};
  if (sizeof(cell)==4) { load[0]=0x3d800000; load[1]=0x618c0000; }
  cell end=(cell)(load+(sizeof(cell)==8 ? 5 : 2));
  cell value=(cell)UINT64_C(0xfedcba9876543210);
  ppc_store_absolute(end,(fixnum)value);
  assert((cell)ppc_load_absolute(end)==value);
  uint32_t branch=0x48000001;
  end=(cell)(&branch+1);
  for (fixnum delta : {-33554432,-4,0,4,33554428}) {
    cell target=end-4+(cell)delta;
    ppc_store_relative(end,(fixnum)target);
    assert((cell)ppc_load_relative(end,end)==target);
    assert((branch&3)==1);
  }
  branch=0x41820000;
  for (fixnum delta : {-32768,-4,0,4,32764}) {
    cell target=end-4+(cell)delta;
    ppc_store_relative(end,(fixnum)target);
    assert((cell)ppc_load_relative(end,end)==target);
  }
  uint32_t ds=0xe86c0001;
  end=(cell)(&ds+1); ppc_store_absolute(end,-32768);
  assert(ppc_load_absolute(end)==-32768); assert((ds&3)==1);
  bool rejected=false; try {ppc_store_absolute(end,3);} catch(const std::runtime_error&){rejected=true;}
  assert(rejected);
  branch=0x48000003;end=(cell)(&branch+1); rejected=false;
  try {ppc_load_relative(end,end);} catch(const std::runtime_error&){rejected=true;} assert(rejected);
  puts("PowerPC relocation decode/store PASS");
}
