#if defined(__powerpc64__) && _CALL_ELF == 1
.section ".opd","aw"
.align 3
.globl factor_powerpc_clobber_signal_homes
factor_powerpc_clobber_signal_homes:
.quad .factor_powerpc_clobber_signal_homes, .TOC.@tocbase, 0
.text
.factor_powerpc_clobber_signal_homes:
#else
.text
.globl factor_powerpc_clobber_signal_homes
.type factor_powerpc_clobber_signal_homes,@function
factor_powerpc_clobber_signal_homes:
#if defined(__powerpc64__)
.localentry factor_powerpc_clobber_signal_homes,0
#endif
#endif
/* PPC64 variadic callees may overwrite all eight register argument homes. */
#ifdef __powerpc64__
stdu 1,-128(1)
ld 11,0(1)
li 0,0x3333
#if _CALL_ELF == 1
#define HOME 48
#else
#define HOME 32
#endif
std 0,HOME+0(11)
std 0,HOME+8(11)
std 0,HOME+16(11)
std 0,HOME+24(11)
std 0,HOME+32(11)
std 0,HOME+40(11)
std 0,HOME+48(11)
std 0,HOME+56(11)
fsub 1,1,1
ld 1,0(1)
#else
stwu 1,-80(1)
lwz 11,0(1)
/* GNU32 SysV has no caller register homes. The LR header belongs to
   the callee; its argument register saves belong to its own frame. */
mflr 0
stw 0,4(11)
fsub 1,1,1
lwz 1,0(1)
#endif
blr
.section .note.GNU-stack,"",@progbits
