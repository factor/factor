#if defined(__powerpc64__) && __CALL_ELF == 1
.section ".opd","aw"
.globl varcapture
.type varcapture,@function
varcapture:
.quad .Lvarcapture,.TOC.@tocbase,0
.text
.Lvarcapture:
#else
.text
.globl varcapture
.type varcapture,@function
varcapture:
#endif
 mfcr 0
 stw 0,0(3)
 stfd 1,8(3)
#if defined(__powerpc64__)
 std 4,16(3)
#endif
 blr
.section .note.GNU-stack,"",@progbits
