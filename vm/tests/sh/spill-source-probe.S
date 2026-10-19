 .text
.align 2
.global sh_spill_double
.type sh_spill_double,@function
sh_spill_double:
 sts.l pr,@-r15
 add #-16,r15
 mov.l @r5,r0
 mov.l r0,@r15
 mov.l @(4,r5),r0
 mov.l r0,@(4,r15)
 mov #1,r2
 jsr @r4
 mov #1,r1
 flds fr1,fpul
 sts fpul,r0
 flds fr0,fpul
 sts fpul,r1
 add #16,r15
 lds.l @r15+,pr
 rts
 nop
.global sh_spill_float
.type sh_spill_float,@function
sh_spill_float:
 sts.l pr,@-r15
 add #-16,r15
 mov.l @r5,r0
 mov.l r0,@r15
 mov #1,r2
 jsr @r4
 mov #1,r1
 flds fr0,fpul
 sts fpul,r0
 add #16,r15
 lds.l @r15+,pr
 rts
 nop
