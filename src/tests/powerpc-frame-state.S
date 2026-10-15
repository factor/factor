// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
.text
.macro absolute reg
lis \reg,0x1234
ori \reg,\reg,0x5678
#if __powerpc64__
sldi \reg,\reg,32
oris \reg,\reg,0x9abc
ori \reg,\reg,0xdef0
#endif
.endm
.globl fixture_start, fixture_allocation, fixture_body, fixture_restore, fixture_restored, fixture_end
fixture_start:
absolute 30
stw 30,0(30)
mflr 0
#if __powerpc64__
std 0,16(1)
absolute 11
std 11,-16(1)
li 11,48
std 11,-8(1)
fixture_allocation:
stdu 1,-48(1)
#else
stw 0,4(1)
absolute 11
stw 11,-8(1)
li 11,48
stw 11,-4(1)
fixture_allocation:
stwu 1,-48(1)
#endif
fixture_body:
nop
nop
fixture_restore:
addi 1,1,48
fixture_restored:
#if __powerpc64__
ld 0,16(1)
#else
lwz 0,4(1)
#endif
mtlr 0
blr
fixture_end:
.section .note.GNU-stack,"",@progbits
.text
.macro fixture name,size,optimized,tail,temporary=0,bodycall=0,prefix=0
.globl \name\()_start,\name\()_body,\name\()_restore,\name\()_restored,\name\()_end
\name\()_start:
.if \prefix
li 5,1
cmpw 1,5,5
cmpwi 5,0
bne \name\()_prologue
blr
.endif
.globl \name\()_prologue
\name\()_prologue:
 .if \optimized == 1
absolute 30
stw 30,0(30)
.elseif \optimized == 2
absolute 12
stw 0,0(12)
.endif
mflr 0
#if __powerpc64__
std 0,16(1)
#else
stw 0,4(1)
#endif
.if \optimized == 1
absolute 11
#if __powerpc64__
std 11,-16(1)
#else
stw 11,-8(1)
#endif
.if \size < 32768
li 11,\size
.else
lis 11,0
#if __powerpc64__
ori 11,11,0
sldi 11,11,32
oris 11,11,0
ori 11,11,\size
#else
ori 11,11,\size
#endif
.endif
#if __powerpc64__
std 11,-8(1)
#else
stw 11,-4(1)
#endif
.else
absolute 0
#if __powerpc64__
std 0,-16(1)
#else
stw 0,-8(1)
#endif
li 0,\size
#if __powerpc64__
std 0,-8(1)
#else
stw 0,-4(1)
#endif
.endif
.if \size <= 32768
#if __powerpc64__
stdu 1,-\size(1)
#else
stwu 1,-\size(1)
#endif
.else
neg 11,11
#if __powerpc64__
stdux 1,1,11
#else
stwux 1,1,11
#endif
.endif
\name\()_body:
.if \bodycall == 2
.globl \name\()_counterload
\name\()_counterload:
absolute 5
lwz 6,0(5)
cmpwi 6,0
beq \name\()_skipcall
li 6,0
stw 6,0(5)
.endif
.if \bodycall
.globl \name\()_callload,\name\()_link,\name\()_lr_restored
\name\()_callload:
absolute 12
mtctr 12
bctrl
\name\()_link:
.if \bodycall == 2
\name\()_skipcall:
.endif
.endif
.if \temporary
li 3,0
.globl \name\()_temporary,\name\()_temporary_restored
#if __powerpc64__
stdu 1,-32(1)
#else
stwu 1,-32(1)
#endif
\name\()_temporary:
.if \temporary == 1
mffs 0
stfd 0,16(1)
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
lwz 3,16(1)
#else
lwz 3,20(1)
#endif
.endif
#if __powerpc64__
lis 4,0
ori 4,4,0
sldi 4,4,32
oris 4,4,7
#else
lis 4,7
#endif
ori 4,4,0xf8ff
and 4,3,4
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
stw 4,16(1)
#else
stw 4,20(1)
#endif
.if \temporary == 2
li 5,0
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
stw 5,20(1)
#else
stw 5,16(1)
#endif
.endif
lfd 0,16(1)
mtfsf 255,0
addi 1,1,32
\name\()_temporary_restored:
.else
nop
nop
.endif
\name\()_restore:
.if \size < 32768
addi 1,1,\size
.else
lis 0,0
#if __powerpc64__
ori 0,0,0
sldi 0,0,32
oris 0,0,0
ori 0,0,\size
#else
ori 0,0,\size
#endif
add 1,1,0
.endif
\name\()_restored:
#if __powerpc64__
ld 0,16(1)
#else
lwz 0,4(1)
#endif
mtlr 0
.if \bodycall
\name\()_lr_restored:
.endif
.if \tail
absolute 6
absolute 12
mtctr 12
bctr
.else
blr
.endif
\name\()_end:
.endm
fixture quotation,80,0,0
fixture boundary,32768,1,1
fixture large,32784,1,1

.text
.globl leaf_start,leaf_body,leaf_restored,leaf_end
leaf_start:
leaf_body:
leaf_restored:
nop
blr
leaf_end:

fixture getter,80,0,0,1
fixture setter,80,0,0,2

fixture caller,80,0,0,0,1

fixture collision,256,0,0

fixture recursive,80,0,0,0,2

fixture quotation_poll,128,2,0

.macro leaf_fpscr name,getter
.globl \name\()_start,\name\()_body,\name\()_restored,\name\()_end
\name\()_start:
\name\()_body:
\name\()_restored:
li 3,0
.globl \name\()_temporary,\name\()_temporary_restored
#if __powerpc64__
stdu 1,-32(1)
#else
stwu 1,-32(1)
#endif
\name\()_temporary:
.if \getter
mffs 0
stfd 0,16(1)
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
lwz 3,16(1)
#else
lwz 3,20(1)
#endif
.endif
#if __powerpc64__
lis 4,0
ori 4,4,0
sldi 4,4,32
oris 4,4,7
#else
lis 4,7
#endif
ori 4,4,0xf8ff
and 4,3,4
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
stw 4,16(1)
#else
stw 4,20(1)
#endif
.if \getter == 0
li 5,0
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
stw 5,20(1)
#else
stw 5,16(1)
#endif
.endif
lfd 0,16(1)
mtfsf 255,0
addi 1,1,32
\name\()_temporary_restored:
blr
\name\()_end:
.endm
leaf_fpscr leaf_getter,1
leaf_fpscr leaf_setter,0

fixture conditional,128,0,0,0,0,1

// The PIC tag/hit/miss templates transfer without allocating an R1 frame.
.globl pic_start,pic_branch,pic_hitload,pic_hit_end,pic_miss,pic_missload,pic_end
pic_start:
#if __powerpc64__
ld 4,0(14)
#else
lwz 4,0(14)
#endif
andi. 4,4,15
#if __powerpc64__
cmpdi 1,4,11
#else
cmpwi 1,4,11
#endif
pic_branch:
bne 1,pic_miss
pic_hitload:
absolute 12
mtctr 12
bctr
pic_hit_end:
pic_miss:
.rept 4
absolute 3
#if __powerpc64__
stdu 3,8(14)
#else
stwu 3,4(14)
#endif
.endr
mflr 6
pic_missload:
absolute 12
mtctr 12
bctr
pic_end:

// Raw set-callstack/context operations have stack state outside a leaf header.
.globl unsupported_start,unsupported_allocated,unsupported_restored,unsupported_end
unsupported_start:
#if __powerpc64__
stdu 1,-128(1)
#else
stwu 1,-64(1)
#endif
unsupported_allocated:
nop
nop
#if __powerpc64__
addi 1,1,128
#else
addi 1,1,64
#endif
unsupported_restored:
blr
unsupported_end:
