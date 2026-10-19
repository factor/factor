#include <assert.h>
#include <stdint.h>
#include <stdio.h>
extern unsigned m88k_trunc1(unsigned), m88k_trunc8(unsigned), m88k_trunc16(unsigned);
extern unsigned m88k_trunc32(uint64_t);
int main(void) {
    unsigned values[]={0,1,2,0x12345678,0xfffffffe,0xffffffff};
    unsigned i;
    for(i=0;i<sizeof(values)/sizeof(values[0]);++i) {
        unsigned v=values[i];
        assert(m88k_trunc1(v)==(v&1));
        assert(m88k_trunc8(v)==(v&255));
        assert(m88k_trunc16(v)==(v&65535));
        assert(m88k_trunc32(UINT64_C(0xabcdef0000000000)|v)==v);
    }
    puts("m88k truncation gate PASS: low1 low8 low16 low32 and int64 ABI");
    return 0;
}
