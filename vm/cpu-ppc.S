#if defined(__APPLE__)
    #define MANGLE(sym) _##sym
    #define XX @
#else
    #define MANGLE(sym) sym
    #define XX ;
#endif

/* The returns and args are just for documentation */
#define DEF(returns,symbol,args) .globl MANGLE(symbol) XX \
MANGLE(symbol)

/* Thanks to Joshua Grams for this code.

On PowerPC processors, we must flush the instruction cache manually
after writing to the code heap. */

DEF(void,flush_icache,(void*, int)):
    /* compute number of cache lines to flush */
    add r4,r4,r3
    /* align addr to next lower cache line boundary */
    clrrwi r3,r3,5
    /* then n_lines = (len + 0x1f) / 0x20 */
    sub r4,r4,r3
    addi r4,r4,0x1f
    /* note '.' suffix */
    srwi. r4,r4,5
    /* if n_lines == 0, just return. */
    beqlr
    /* flush cache lines */
    mtctr r4
    /* for each line... */
0:  dcbf 0,r3
    sync
    icbi 0,r3
    addi r3,r3,0x20
    bdnz 0b
    /* finish up */
    sync
    isync
    blr

DEF(void,get_ppc_fpu_env,(void*)):
    mffs f0
    stfd f0,0(r3)
    blr

DEF(void,set_ppc_fpu_env,(const void*)):
    lfd f0,0(r3)
    mtfsf 0xff,f0
    blr

DEF(void,get_ppc_vmx_env,(void*)):
    mfvscr v0
    subi r4,r1,16
    li r5,0xf
    andc r4,r4,r5
    stvxl v0,0,r4
    li r5,0xc
    lwzx r6,r5,r4
    stw r6,0(r3)
    blr

DEF(void,set_ppc_vmx_env,(const void*)):
    subi r4,r1,16
    li r5,0xf
    andc r4,r4,r5
    li r5,0xc
    lwz r6,0(r3)
    stwx r6,r5,r4
    lvxl v0,0,r4
    mtvscr v0
    blr
