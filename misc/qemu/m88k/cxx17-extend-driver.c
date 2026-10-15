#include <assert.h>
#include <stdio.h>
extern int m88k_sext1(unsigned),m88k_sext8(unsigned),m88k_sext16(unsigned);
extern unsigned m88k_phi8(unsigned);
int main(void) {
    unsigned values[]={0,1,2,127,128,255,32767,32768,65535,0x12345678,0xffffffff};
    unsigned i;
    for(i=0;i<sizeof(values)/sizeof(values[0]);++i) {
        unsigned v=values[i];
        int low8=v&255,low16=v&65535;
        assert(m88k_sext1(v)==-(int)(v&1));
        assert(m88k_sext8(v)==(low8>=128?low8-256:low8));
        assert(m88k_sext16(v)==(low16>=32768?low16-65536:low16));
        assert(m88k_phi8(v)==((v&255)*((v&255)-1)/2));
    }
    puts("m88k extension gate PASS: signed low1 low8 low16 byte-PHI loop");
    return 0;
}
