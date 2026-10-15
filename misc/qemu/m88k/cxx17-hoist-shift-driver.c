#include <stdio.h>
extern unsigned m88k_hoist_shift(unsigned);
extern unsigned m88k_hoist_variable(unsigned,unsigned);
int main(void) {
  unsigned xs[] = {0,1,2,42,0xffffffffU,0x80000000U,0x7fffffffU,0x12345678U};
  unsigned i,j;
  for(i=0;i<sizeof(xs)/sizeof(xs[0]);++i) {
    if(m88k_hoist_shift(xs[i]) != ((xs[i]|1U)<<2)) return 1;
    for(j=0;j<sizeof(xs)/sizeof(xs[0]);++j)
      if(m88k_hoist_variable(xs[i],xs[j]) != ((xs[i]|xs[j])<<2)) return 2;
  }
  puts("m88k hoist shift PASS"); return 0;
}
