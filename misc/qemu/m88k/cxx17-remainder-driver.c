#include <assert.h>
#include <stdio.h>
extern unsigned m88k_urem8(unsigned,unsigned),m88k_urem16(unsigned,unsigned);
extern int m88k_srem8(int,int),m88k_srem16(int,int);
int main(void) {
 unsigned values[]={0,1,2,127,128,255,256,32767,32768,65535,0xffffffff};
 unsigned divisors[]={1,2,3,7,127};
 unsigned i,j;
 for(i=0;i<sizeof(values)/sizeof(values[0]);++i)
  for(j=0;j<sizeof(divisors)/sizeof(divisors[0]);++j) {
   unsigned a=values[i],b=divisors[j];
   int s8=(a&255)>=128?(int)(a&255)-256:(int)(a&255);
   int s16=(a&65535)>=32768?(int)(a&65535)-65536:(int)(a&65535);
   assert(m88k_urem8(a,b)==((a&255)%b));
   assert(m88k_urem16(a,b)==((a&65535)%b));
   assert(m88k_srem8(a,b)==s8%(int)b);
   assert(m88k_srem16(a,b)==s16%(int)b);
  }
 puts("m88k remainder gate PASS: unsigned and signed byte halfword boundaries");
 return 0;
}
