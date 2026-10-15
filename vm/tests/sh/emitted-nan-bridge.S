.text
.align 2
.global sh_call_emitted_double
.type sh_call_emitted_double,@function
sh_call_emitted_double:
    mov.l r12,@-r15
    sts.l pr,@-r15
    fmov.s fr12,@-r15
    fmov.s fr13,@-r15
    fmov.s fr14,@-r15
    fmov.s fr15,@-r15
    add #-32,r15
    jsr @r4
    nop
    add #32,r15
    fmov.s @r15+,fr15
    fmov.s @r15+,fr14
    fmov.s @r15+,fr13
    fmov.s @r15+,fr12
    lds.l @r15+,pr
    mov.l @r15+,r12
    rts
    nop
.size sh_call_emitted_double,.-sh_call_emitted_double
.global sh_call_emitted_float
.set sh_call_emitted_float,sh_call_emitted_double

.global sh_call_emitted_compare
.set sh_call_emitted_compare,sh_call_emitted_double

.global sh_call_emitted_widen
.set sh_call_emitted_widen,sh_call_emitted_double
.global sh_call_emitted_narrow
.set sh_call_emitted_narrow,sh_call_emitted_double

.global sh_call_emitted_memory_double
.set sh_call_emitted_memory_double,sh_call_emitted_double
.global sh_call_emitted_memory_float
.set sh_call_emitted_memory_float,sh_call_emitted_double
