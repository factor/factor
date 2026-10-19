#include <assert.h>
#include <stdio.h>
extern int runtime_narrow7(unsigned char),runtime_umulo(unsigned,unsigned,unsigned*),runtime_smulo(int,int,int*);
extern unsigned runtime_bits(unsigned);
int main(void) { unsigned i,a=0x80000000U,b=0xffffffffU,low; int slo; unsigned long long up; long long sp;
 for(i=0;i<256;i++) {assert(runtime_narrow7(i)==((i&127)>=64?(int)(i&127)-128:(int)(i&127)));assert(runtime_bits(i<<8)==(i&15));}
 for(i=0;i<512;i++){up=(unsigned long long)a*b; assert(runtime_umulo(a,b,&low)==(up>0xffffffffULL)); assert(low==(unsigned)up);sp=(long long)(int)a*(int)b;assert(runtime_smulo((int)a,(int)b,&slo)==(sp>2147483647LL||sp<(-2147483647LL-1)));assert((unsigned)slo==(unsigned)sp);a=a*1664525U+1013904223U;b=b*1103515245U+12345U;}
 puts("m88k runtime arithmetic PASS: 256 narrow/bitfield and 512 signed/unsigned multiply-overflow vectors");return 0; }
