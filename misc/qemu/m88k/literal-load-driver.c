#include <assert.h>
#include <stdio.h>
extern unsigned literal_load_o2(const unsigned*);
extern unsigned literal_load_o0(const unsigned*);
static unsigned oracle(const unsigned* words) {
 const volatile unsigned char *p=(const volatile unsigned char *)words;
 return (unsigned)p[2]<<24|(unsigned)p[3]<<16|(unsigned)p[6]<<8|p[7];
}
int main(void) {
 unsigned pairs[][2]={{0x5c801615,0x5884486c},{0x5c801234,0x5884abcd},
 {0x5c800000,0x58840000},{0x5c80ffff,0x5884ffff}};
 unsigned i,wrong=0,wrong_o0=0;
 for(i=0;i<4;i++) {
  unsigned expected=oracle(pairs[i]);
  unsigned a=literal_load_o2(pairs[i]),b=literal_load_o0(pairs[i]);
  printf("pair=%08x/%08x oracle=%08x O2=%08x O0=%08x\n",pairs[i][0],pairs[i][1],expected,a,b);
  wrong+=a!=expected; wrong_o0+=b!=expected;
 }
 printf("production literal-load microprobe: O2 mismatches=%u/4 O0 mismatches=%u/4\n",wrong,wrong_o0);
 return (wrong||wrong_o0)?2:0;
}
