// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
.text
#if __powerpc64__ && (!defined(_CALL_ELF) || _CALL_ELF == 1)
.section ".opd","aw"
.align 3
.globl ppc_boundary_invoke
ppc_boundary_invoke:
.quad .ppc_boundary_invoke,.TOC.@tocbase,0
.text
.ppc_boundary_invoke:
#else
.globl ppc_boundary_invoke
ppc_boundary_invoke:
#endif
mflr 0
#if __powerpc64__
std 0,16(1)
stdu 1,-256(1)
std 30,112(1)
std 1,0(4)
#else
stw 0,4(1)
stwu 1,-256(1)
stw 30,112(1)
stw 1,0(4)
#endif
mr 12,3
mtctr 12
bctrl
.globl ppc_boundary_after_call
ppc_boundary_after_call:
#if __powerpc64__
ld 30,112(1)
addi 1,1,256
ld 0,16(1)
#else
lwz 30,112(1)
addi 1,1,256
lwz 0,4(1)
#endif
mtlr 0
blr
.globl ppc_boundary_return_stub
ppc_boundary_return_stub:
blr

// A 112-byte caller deliberately differs from the historical 128-byte PIC
// header. Preserve Factor's data-stack register while exercising the PIC.
#if __powerpc64__ && (!defined(_CALL_ELF) || _CALL_ELF == 1)
.section ".opd","aw"
.align 3
.globl ppc_pic_boundary_invoke
ppc_pic_boundary_invoke:
.quad .ppc_pic_boundary_invoke,.TOC.@tocbase,0
.text
.ppc_pic_boundary_invoke:
#else
.globl ppc_pic_boundary_invoke
ppc_pic_boundary_invoke:
#endif
mflr 0
#if __powerpc64__
std 0,16(1)
stdu 1,-112(1)
std 14,96(1)
std 1,0(4)
#else
stw 0,4(1)
stwu 1,-112(1)
stw 14,96(1)
stw 1,0(4)
#endif
mr 14,5
mr 12,3
mtctr 12
bctrl
.globl ppc_pic_boundary_after_call
ppc_pic_boundary_after_call:
#if __powerpc64__
ld 14,96(1)
addi 1,1,112
ld 0,16(1)
#else
lwz 14,96(1)
addi 1,1,112
lwz 0,4(1)
#endif
mtlr 0
blr
.section .note.GNU-stack,"",@progbits
