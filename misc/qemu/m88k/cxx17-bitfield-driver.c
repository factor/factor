#include <assert.h>
#include <stdio.h>
extern unsigned long long m88k_extract_low1(unsigned long long);
extern unsigned long long m88k_extract_low32(unsigned long long);
extern unsigned long long m88k_extract_high32(unsigned long long);
extern unsigned long long m88k_extract_cross(unsigned long long);
extern long long m88k_extract_signed_cross(unsigned long long);
extern long long m88k_extract_signed_high(unsigned long long);
int main(void) {
  unsigned i; unsigned long long value=0x123456789abcdef0ull;
  for(i=0;i<260;i++) {
    unsigned long long x=i<4 ? (i==0 ? 0 : i==1 ? ~0ull : i==2 ? 1ull<<63 : 1ull<<31) : value;
    long long signedcross=(long long)((x>>28)&0xfff);
    if(signedcross&0x800) signedcross-=0x1000;
    assert(m88k_extract_low1(x)==(x&1));
    assert(m88k_extract_low32(x)==(x&0xffffffffull));
    assert(m88k_extract_high32(x)==(x>>32));
    assert(m88k_extract_cross(x)==((x>>28)&0xfff));
    assert(m88k_extract_signed_cross(x)==signedcross);
    assert(m88k_extract_signed_high(x)==(long long)x>>32);
    value=value*6364136223846793005ull+1442695040888963407ull;
  }
  puts("m88k bitfield gate PASS: 260 signed unsigned cross-word boundaries");
  return 0;
}
