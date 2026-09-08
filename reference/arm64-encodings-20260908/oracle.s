.text
adc W0, W1, W2
adcs W0, W1, W2
sbc W0, W1, W2
sbcs W0, W1, W2
udiv W0, W1, W2
sdiv W0, W1, W2
add W0, W1, W2
adds W0, W1, W2
sub W0, W1, W2
subs W0, W1, W2
and W0, W1, W2
bic W0, W1, W2
orr W0, W1, W2
orn W0, W1, W2
eor W0, W1, W2
eon W0, W1, W2
ands W0, W1, W2
bics W0, W1, W2
ngc W0, W1
ngcs W0, W1
neg W0, W1
negs W0, W1
mvn W0, W1
rbit W0, W1
rev16 W0, W1
rev W0, W1
clz W0, W1
cls W0, W1
madd W0, W1, W2, W3
msub W0, W1, W2, W3
mul W0, W1, W2
mneg W0, W1, W2
lsl W0, W1, W2
lsl W0, W1, #0
lsl W0, W1, #1
lsl W0, W1, #31
lsr W0, W1, W2
lsr W0, W1, #0
lsr W0, W1, #1
lsr W0, W1, #31
asr W0, W1, W2
asr W0, W1, #0
asr W0, W1, #1
asr W0, W1, #31
ror W0, W1, W2
ror W0, W1, #0
ror W0, W1, #1
ror W0, W1, #31
extr W0, W1, W2, #0
extr W0, W1, W2, #1
extr W0, W1, W2, #31
sbfm W0, W1, #0, #0
sbfm W0, W1, #0, #1
sbfm W0, W1, #0, #31
sbfm W0, W1, #1, #0
sbfm W0, W1, #1, #1
sbfm W0, W1, #1, #31
sbfm W0, W1, #31, #0
sbfm W0, W1, #31, #1
sbfm W0, W1, #31, #31
bfm W0, W1, #0, #0
bfm W0, W1, #0, #1
bfm W0, W1, #0, #31
bfm W0, W1, #1, #0
bfm W0, W1, #1, #1
bfm W0, W1, #1, #31
bfm W0, W1, #31, #0
bfm W0, W1, #31, #1
bfm W0, W1, #31, #31
ubfm W0, W1, #0, #0
ubfm W0, W1, #0, #1
ubfm W0, W1, #0, #31
ubfm W0, W1, #1, #0
ubfm W0, W1, #1, #1
ubfm W0, W1, #1, #31
ubfm W0, W1, #31, #0
ubfm W0, W1, #31, #1
ubfm W0, W1, #31, #31
sbfx W0, W1, #0, #32
sbfx W0, W1, #0, #1
sbfx W0, W1, #1, #31
sbfx W0, W1, #31, #1
ubfx W0, W1, #0, #32
ubfx W0, W1, #0, #1
ubfx W0, W1, #1, #31
ubfx W0, W1, #31, #1
bfxil W0, W1, #0, #32
bfxil W0, W1, #0, #1
bfxil W0, W1, #1, #31
bfxil W0, W1, #31, #1
sbfiz W0, W1, #0, #32
sbfiz W0, W1, #0, #1
sbfiz W0, W1, #1, #31
sbfiz W0, W1, #31, #1
ubfiz W0, W1, #0, #32
ubfiz W0, W1, #0, #1
ubfiz W0, W1, #1, #31
ubfiz W0, W1, #31, #1
bfi W0, W1, #0, #32
bfi W0, W1, #0, #1
bfi W0, W1, #1, #31
bfi W0, W1, #31, #1
csel W0, W1, W2, EQ
csel W0, W1, W2, NE
csel W0, W1, W2, LT
csel W0, W1, W2, GT
csel W0, W1, W2, AL
csel W0, W1, W2, NV
csinc W0, W1, W2, EQ
csinc W0, W1, W2, NE
csinc W0, W1, W2, LT
csinc W0, W1, W2, GT
csinc W0, W1, W2, AL
csinc W0, W1, W2, NV
csinv W0, W1, W2, EQ
csinv W0, W1, W2, NE
csinv W0, W1, W2, LT
csinv W0, W1, W2, GT
csinv W0, W1, W2, AL
csinv W0, W1, W2, NV
csneg W0, W1, W2, EQ
csneg W0, W1, W2, NE
csneg W0, W1, W2, LT
csneg W0, W1, W2, GT
csneg W0, W1, W2, AL
csneg W0, W1, W2, NV
ccmn W1, W2, #0, EQ
ccmn W1, #0, #0, EQ
ccmn W1, #1, #0, EQ
ccmn W1, #31, #0, EQ
ccmn W1, W2, #5, EQ
ccmn W1, #0, #5, EQ
ccmn W1, #1, #5, EQ
ccmn W1, #31, #5, EQ
ccmn W1, W2, #15, EQ
ccmn W1, #0, #15, EQ
ccmn W1, #1, #15, EQ
ccmn W1, #31, #15, EQ
ccmn W1, W2, #0, NE
ccmn W1, #0, #0, NE
ccmn W1, #1, #0, NE
ccmn W1, #31, #0, NE
ccmn W1, W2, #5, NE
ccmn W1, #0, #5, NE
ccmn W1, #1, #5, NE
ccmn W1, #31, #5, NE
ccmn W1, W2, #15, NE
ccmn W1, #0, #15, NE
ccmn W1, #1, #15, NE
ccmn W1, #31, #15, NE
ccmn W1, W2, #0, LT
ccmn W1, #0, #0, LT
ccmn W1, #1, #0, LT
ccmn W1, #31, #0, LT
ccmn W1, W2, #5, LT
ccmn W1, #0, #5, LT
ccmn W1, #1, #5, LT
ccmn W1, #31, #5, LT
ccmn W1, W2, #15, LT
ccmn W1, #0, #15, LT
ccmn W1, #1, #15, LT
ccmn W1, #31, #15, LT
ccmn W1, W2, #0, GT
ccmn W1, #0, #0, GT
ccmn W1, #1, #0, GT
ccmn W1, #31, #0, GT
ccmn W1, W2, #5, GT
ccmn W1, #0, #5, GT
ccmn W1, #1, #5, GT
ccmn W1, #31, #5, GT
ccmn W1, W2, #15, GT
ccmn W1, #0, #15, GT
ccmn W1, #1, #15, GT
ccmn W1, #31, #15, GT
ccmn W1, W2, #0, AL
ccmn W1, #0, #0, AL
ccmn W1, #1, #0, AL
ccmn W1, #31, #0, AL
ccmn W1, W2, #5, AL
ccmn W1, #0, #5, AL
ccmn W1, #1, #5, AL
ccmn W1, #31, #5, AL
ccmn W1, W2, #15, AL
ccmn W1, #0, #15, AL
ccmn W1, #1, #15, AL
ccmn W1, #31, #15, AL
ccmn W1, W2, #0, NV
ccmn W1, #0, #0, NV
ccmn W1, #1, #0, NV
ccmn W1, #31, #0, NV
ccmn W1, W2, #5, NV
ccmn W1, #0, #5, NV
ccmn W1, #1, #5, NV
ccmn W1, #31, #5, NV
ccmn W1, W2, #15, NV
ccmn W1, #0, #15, NV
ccmn W1, #1, #15, NV
ccmn W1, #31, #15, NV
ccmp W1, W2, #0, EQ
ccmp W1, #0, #0, EQ
ccmp W1, #1, #0, EQ
ccmp W1, #31, #0, EQ
ccmp W1, W2, #5, EQ
ccmp W1, #0, #5, EQ
ccmp W1, #1, #5, EQ
ccmp W1, #31, #5, EQ
ccmp W1, W2, #15, EQ
ccmp W1, #0, #15, EQ
ccmp W1, #1, #15, EQ
ccmp W1, #31, #15, EQ
ccmp W1, W2, #0, NE
ccmp W1, #0, #0, NE
ccmp W1, #1, #0, NE
ccmp W1, #31, #0, NE
ccmp W1, W2, #5, NE
ccmp W1, #0, #5, NE
ccmp W1, #1, #5, NE
ccmp W1, #31, #5, NE
ccmp W1, W2, #15, NE
ccmp W1, #0, #15, NE
ccmp W1, #1, #15, NE
ccmp W1, #31, #15, NE
ccmp W1, W2, #0, LT
ccmp W1, #0, #0, LT
ccmp W1, #1, #0, LT
ccmp W1, #31, #0, LT
ccmp W1, W2, #5, LT
ccmp W1, #0, #5, LT
ccmp W1, #1, #5, LT
ccmp W1, #31, #5, LT
ccmp W1, W2, #15, LT
ccmp W1, #0, #15, LT
ccmp W1, #1, #15, LT
ccmp W1, #31, #15, LT
ccmp W1, W2, #0, GT
ccmp W1, #0, #0, GT
ccmp W1, #1, #0, GT
ccmp W1, #31, #0, GT
ccmp W1, W2, #5, GT
ccmp W1, #0, #5, GT
ccmp W1, #1, #5, GT
ccmp W1, #31, #5, GT
ccmp W1, W2, #15, GT
ccmp W1, #0, #15, GT
ccmp W1, #1, #15, GT
ccmp W1, #31, #15, GT
ccmp W1, W2, #0, AL
ccmp W1, #0, #0, AL
ccmp W1, #1, #0, AL
ccmp W1, #31, #0, AL
ccmp W1, W2, #5, AL
ccmp W1, #0, #5, AL
ccmp W1, #1, #5, AL
ccmp W1, #31, #5, AL
ccmp W1, W2, #15, AL
ccmp W1, #0, #15, AL
ccmp W1, #1, #15, AL
ccmp W1, #31, #15, AL
ccmp W1, W2, #0, NV
ccmp W1, #0, #0, NV
ccmp W1, #1, #0, NV
ccmp W1, #31, #0, NV
ccmp W1, W2, #5, NV
ccmp W1, #0, #5, NV
ccmp W1, #1, #5, NV
ccmp W1, #31, #5, NV
ccmp W1, W2, #15, NV
ccmp W1, #0, #15, NV
ccmp W1, #1, #15, NV
ccmp W1, #31, #15, NV
movn W0, #0, lsl #0
movn W0, #1, lsl #0
movn W0, #65535, lsl #0
movn W0, #0, lsl #16
movn W0, #1, lsl #16
movn W0, #65535, lsl #16
movz W0, #0, lsl #0
movz W0, #1, lsl #0
movz W0, #65535, lsl #0
movz W0, #0, lsl #16
movz W0, #1, lsl #16
movz W0, #65535, lsl #16
movk W0, #0, lsl #0
movk W0, #1, lsl #0
movk W0, #65535, lsl #0
movk W0, #0, lsl #16
movk W0, #1, lsl #16
movk W0, #65535, lsl #16
and W0, W1, #1
and W0, W1, #255
and W0, W1, #4278255360
and W0, W1, #4294967294
and W0, W1, #4294967280
orr W0, W1, #1
orr W0, W1, #255
orr W0, W1, #4278255360
orr W0, W1, #4294967294
orr W0, W1, #4294967280
eor W0, W1, #1
eor W0, W1, #255
eor W0, W1, #4278255360
eor W0, W1, #4294967294
eor W0, W1, #4294967280
ands W0, W1, #1
ands W0, W1, #255
ands W0, W1, #4278255360
ands W0, W1, #4294967294
ands W0, W1, #4294967280
add W0, W1, W2, LSL #0
add W0, W1, W2, LSL #1
add W0, W1, W2, LSL #31
add W0, W1, W2, LSR #0
add W0, W1, W2, LSR #1
add W0, W1, W2, LSR #31
add W0, W1, W2, ASR #0
add W0, W1, W2, ASR #1
add W0, W1, W2, ASR #31
adds W0, W1, W2, LSL #0
adds W0, W1, W2, LSL #1
adds W0, W1, W2, LSL #31
adds W0, W1, W2, LSR #0
adds W0, W1, W2, LSR #1
adds W0, W1, W2, LSR #31
adds W0, W1, W2, ASR #0
adds W0, W1, W2, ASR #1
adds W0, W1, W2, ASR #31
sub W0, W1, W2, LSL #0
sub W0, W1, W2, LSL #1
sub W0, W1, W2, LSL #31
sub W0, W1, W2, LSR #0
sub W0, W1, W2, LSR #1
sub W0, W1, W2, LSR #31
sub W0, W1, W2, ASR #0
sub W0, W1, W2, ASR #1
sub W0, W1, W2, ASR #31
subs W0, W1, W2, LSL #0
subs W0, W1, W2, LSL #1
subs W0, W1, W2, LSL #31
subs W0, W1, W2, LSR #0
subs W0, W1, W2, LSR #1
subs W0, W1, W2, LSR #31
subs W0, W1, W2, ASR #0
subs W0, W1, W2, ASR #1
subs W0, W1, W2, ASR #31
and W0, W1, W2, LSL #0
and W0, W1, W2, LSL #1
and W0, W1, W2, LSL #31
and W0, W1, W2, LSR #0
and W0, W1, W2, LSR #1
and W0, W1, W2, LSR #31
and W0, W1, W2, ASR #0
and W0, W1, W2, ASR #1
and W0, W1, W2, ASR #31
and W0, W1, W2, ROR #0
and W0, W1, W2, ROR #1
and W0, W1, W2, ROR #31
bic W0, W1, W2, LSL #0
bic W0, W1, W2, LSL #1
bic W0, W1, W2, LSL #31
bic W0, W1, W2, LSR #0
bic W0, W1, W2, LSR #1
bic W0, W1, W2, LSR #31
bic W0, W1, W2, ASR #0
bic W0, W1, W2, ASR #1
bic W0, W1, W2, ASR #31
bic W0, W1, W2, ROR #0
bic W0, W1, W2, ROR #1
bic W0, W1, W2, ROR #31
orr W0, W1, W2, LSL #0
orr W0, W1, W2, LSL #1
orr W0, W1, W2, LSL #31
orr W0, W1, W2, LSR #0
orr W0, W1, W2, LSR #1
orr W0, W1, W2, LSR #31
orr W0, W1, W2, ASR #0
orr W0, W1, W2, ASR #1
orr W0, W1, W2, ASR #31
orr W0, W1, W2, ROR #0
orr W0, W1, W2, ROR #1
orr W0, W1, W2, ROR #31
orn W0, W1, W2, LSL #0
orn W0, W1, W2, LSL #1
orn W0, W1, W2, LSL #31
orn W0, W1, W2, LSR #0
orn W0, W1, W2, LSR #1
orn W0, W1, W2, LSR #31
orn W0, W1, W2, ASR #0
orn W0, W1, W2, ASR #1
orn W0, W1, W2, ASR #31
orn W0, W1, W2, ROR #0
orn W0, W1, W2, ROR #1
orn W0, W1, W2, ROR #31
eor W0, W1, W2, LSL #0
eor W0, W1, W2, LSL #1
eor W0, W1, W2, LSL #31
eor W0, W1, W2, LSR #0
eor W0, W1, W2, LSR #1
eor W0, W1, W2, LSR #31
eor W0, W1, W2, ASR #0
eor W0, W1, W2, ASR #1
eor W0, W1, W2, ASR #31
eor W0, W1, W2, ROR #0
eor W0, W1, W2, ROR #1
eor W0, W1, W2, ROR #31
eon W0, W1, W2, LSL #0
eon W0, W1, W2, LSL #1
eon W0, W1, W2, LSL #31
eon W0, W1, W2, LSR #0
eon W0, W1, W2, LSR #1
eon W0, W1, W2, LSR #31
eon W0, W1, W2, ASR #0
eon W0, W1, W2, ASR #1
eon W0, W1, W2, ASR #31
eon W0, W1, W2, ROR #0
eon W0, W1, W2, ROR #1
eon W0, W1, W2, ROR #31
ands W0, W1, W2, LSL #0
ands W0, W1, W2, LSL #1
ands W0, W1, W2, LSL #31
ands W0, W1, W2, LSR #0
ands W0, W1, W2, LSR #1
ands W0, W1, W2, LSR #31
ands W0, W1, W2, ASR #0
ands W0, W1, W2, ASR #1
ands W0, W1, W2, ASR #31
ands W0, W1, W2, ROR #0
ands W0, W1, W2, ROR #1
ands W0, W1, W2, ROR #31
bics W0, W1, W2, LSL #0
bics W0, W1, W2, LSL #1
bics W0, W1, W2, LSL #31
bics W0, W1, W2, LSR #0
bics W0, W1, W2, LSR #1
bics W0, W1, W2, LSR #31
bics W0, W1, W2, ASR #0
bics W0, W1, W2, ASR #1
bics W0, W1, W2, ASR #31
bics W0, W1, W2, ROR #0
bics W0, W1, W2, ROR #1
bics W0, W1, W2, ROR #31
adc W30, W17, W29
adcs W30, W17, W29
sbc W30, W17, W29
sbcs W30, W17, W29
udiv W30, W17, W29
sdiv W30, W17, W29
add W30, W17, W29
adds W30, W17, W29
sub W30, W17, W29
subs W30, W17, W29
and W30, W17, W29
bic W30, W17, W29
orr W30, W17, W29
orn W30, W17, W29
eor W30, W17, W29
eon W30, W17, W29
ands W30, W17, W29
bics W30, W17, W29
ngc W30, W17
ngcs W30, W17
neg W30, W17
negs W30, W17
mvn W30, W17
rbit W30, W17
rev16 W30, W17
rev W30, W17
clz W30, W17
cls W30, W17
madd W30, W17, W29, W11
msub W30, W17, W29, W11
mul W30, W17, W29
mneg W30, W17, W29
lsl W30, W17, W29
lsl W30, W17, #0
lsl W30, W17, #1
lsl W30, W17, #31
lsr W30, W17, W29
lsr W30, W17, #0
lsr W30, W17, #1
lsr W30, W17, #31
asr W30, W17, W29
asr W30, W17, #0
asr W30, W17, #1
asr W30, W17, #31
ror W30, W17, W29
ror W30, W17, #0
ror W30, W17, #1
ror W30, W17, #31
extr W30, W17, W29, #0
extr W30, W17, W29, #1
extr W30, W17, W29, #31
sbfm W30, W17, #0, #0
sbfm W30, W17, #0, #1
sbfm W30, W17, #0, #31
sbfm W30, W17, #1, #0
sbfm W30, W17, #1, #1
sbfm W30, W17, #1, #31
sbfm W30, W17, #31, #0
sbfm W30, W17, #31, #1
sbfm W30, W17, #31, #31
bfm W30, W17, #0, #0
bfm W30, W17, #0, #1
bfm W30, W17, #0, #31
bfm W30, W17, #1, #0
bfm W30, W17, #1, #1
bfm W30, W17, #1, #31
bfm W30, W17, #31, #0
bfm W30, W17, #31, #1
bfm W30, W17, #31, #31
ubfm W30, W17, #0, #0
ubfm W30, W17, #0, #1
ubfm W30, W17, #0, #31
ubfm W30, W17, #1, #0
ubfm W30, W17, #1, #1
ubfm W30, W17, #1, #31
ubfm W30, W17, #31, #0
ubfm W30, W17, #31, #1
ubfm W30, W17, #31, #31
sbfx W30, W17, #0, #32
sbfx W30, W17, #0, #1
sbfx W30, W17, #1, #31
sbfx W30, W17, #31, #1
ubfx W30, W17, #0, #32
ubfx W30, W17, #0, #1
ubfx W30, W17, #1, #31
ubfx W30, W17, #31, #1
bfxil W30, W17, #0, #32
bfxil W30, W17, #0, #1
bfxil W30, W17, #1, #31
bfxil W30, W17, #31, #1
sbfiz W30, W17, #0, #32
sbfiz W30, W17, #0, #1
sbfiz W30, W17, #1, #31
sbfiz W30, W17, #31, #1
ubfiz W30, W17, #0, #32
ubfiz W30, W17, #0, #1
ubfiz W30, W17, #1, #31
ubfiz W30, W17, #31, #1
bfi W30, W17, #0, #32
bfi W30, W17, #0, #1
bfi W30, W17, #1, #31
bfi W30, W17, #31, #1
csel W30, W17, W29, EQ
csel W30, W17, W29, NE
csel W30, W17, W29, LT
csel W30, W17, W29, GT
csel W30, W17, W29, AL
csel W30, W17, W29, NV
csinc W30, W17, W29, EQ
csinc W30, W17, W29, NE
csinc W30, W17, W29, LT
csinc W30, W17, W29, GT
csinc W30, W17, W29, AL
csinc W30, W17, W29, NV
csinv W30, W17, W29, EQ
csinv W30, W17, W29, NE
csinv W30, W17, W29, LT
csinv W30, W17, W29, GT
csinv W30, W17, W29, AL
csinv W30, W17, W29, NV
csneg W30, W17, W29, EQ
csneg W30, W17, W29, NE
csneg W30, W17, W29, LT
csneg W30, W17, W29, GT
csneg W30, W17, W29, AL
csneg W30, W17, W29, NV
ccmn W17, W29, #0, EQ
ccmn W17, #0, #0, EQ
ccmn W17, #1, #0, EQ
ccmn W17, #31, #0, EQ
ccmn W17, W29, #5, EQ
ccmn W17, #0, #5, EQ
ccmn W17, #1, #5, EQ
ccmn W17, #31, #5, EQ
ccmn W17, W29, #15, EQ
ccmn W17, #0, #15, EQ
ccmn W17, #1, #15, EQ
ccmn W17, #31, #15, EQ
ccmn W17, W29, #0, NE
ccmn W17, #0, #0, NE
ccmn W17, #1, #0, NE
ccmn W17, #31, #0, NE
ccmn W17, W29, #5, NE
ccmn W17, #0, #5, NE
ccmn W17, #1, #5, NE
ccmn W17, #31, #5, NE
ccmn W17, W29, #15, NE
ccmn W17, #0, #15, NE
ccmn W17, #1, #15, NE
ccmn W17, #31, #15, NE
ccmn W17, W29, #0, LT
ccmn W17, #0, #0, LT
ccmn W17, #1, #0, LT
ccmn W17, #31, #0, LT
ccmn W17, W29, #5, LT
ccmn W17, #0, #5, LT
ccmn W17, #1, #5, LT
ccmn W17, #31, #5, LT
ccmn W17, W29, #15, LT
ccmn W17, #0, #15, LT
ccmn W17, #1, #15, LT
ccmn W17, #31, #15, LT
ccmn W17, W29, #0, GT
ccmn W17, #0, #0, GT
ccmn W17, #1, #0, GT
ccmn W17, #31, #0, GT
ccmn W17, W29, #5, GT
ccmn W17, #0, #5, GT
ccmn W17, #1, #5, GT
ccmn W17, #31, #5, GT
ccmn W17, W29, #15, GT
ccmn W17, #0, #15, GT
ccmn W17, #1, #15, GT
ccmn W17, #31, #15, GT
ccmn W17, W29, #0, AL
ccmn W17, #0, #0, AL
ccmn W17, #1, #0, AL
ccmn W17, #31, #0, AL
ccmn W17, W29, #5, AL
ccmn W17, #0, #5, AL
ccmn W17, #1, #5, AL
ccmn W17, #31, #5, AL
ccmn W17, W29, #15, AL
ccmn W17, #0, #15, AL
ccmn W17, #1, #15, AL
ccmn W17, #31, #15, AL
ccmn W17, W29, #0, NV
ccmn W17, #0, #0, NV
ccmn W17, #1, #0, NV
ccmn W17, #31, #0, NV
ccmn W17, W29, #5, NV
ccmn W17, #0, #5, NV
ccmn W17, #1, #5, NV
ccmn W17, #31, #5, NV
ccmn W17, W29, #15, NV
ccmn W17, #0, #15, NV
ccmn W17, #1, #15, NV
ccmn W17, #31, #15, NV
ccmp W17, W29, #0, EQ
ccmp W17, #0, #0, EQ
ccmp W17, #1, #0, EQ
ccmp W17, #31, #0, EQ
ccmp W17, W29, #5, EQ
ccmp W17, #0, #5, EQ
ccmp W17, #1, #5, EQ
ccmp W17, #31, #5, EQ
ccmp W17, W29, #15, EQ
ccmp W17, #0, #15, EQ
ccmp W17, #1, #15, EQ
ccmp W17, #31, #15, EQ
ccmp W17, W29, #0, NE
ccmp W17, #0, #0, NE
ccmp W17, #1, #0, NE
ccmp W17, #31, #0, NE
ccmp W17, W29, #5, NE
ccmp W17, #0, #5, NE
ccmp W17, #1, #5, NE
ccmp W17, #31, #5, NE
ccmp W17, W29, #15, NE
ccmp W17, #0, #15, NE
ccmp W17, #1, #15, NE
ccmp W17, #31, #15, NE
ccmp W17, W29, #0, LT
ccmp W17, #0, #0, LT
ccmp W17, #1, #0, LT
ccmp W17, #31, #0, LT
ccmp W17, W29, #5, LT
ccmp W17, #0, #5, LT
ccmp W17, #1, #5, LT
ccmp W17, #31, #5, LT
ccmp W17, W29, #15, LT
ccmp W17, #0, #15, LT
ccmp W17, #1, #15, LT
ccmp W17, #31, #15, LT
ccmp W17, W29, #0, GT
ccmp W17, #0, #0, GT
ccmp W17, #1, #0, GT
ccmp W17, #31, #0, GT
ccmp W17, W29, #5, GT
ccmp W17, #0, #5, GT
ccmp W17, #1, #5, GT
ccmp W17, #31, #5, GT
ccmp W17, W29, #15, GT
ccmp W17, #0, #15, GT
ccmp W17, #1, #15, GT
ccmp W17, #31, #15, GT
ccmp W17, W29, #0, AL
ccmp W17, #0, #0, AL
ccmp W17, #1, #0, AL
ccmp W17, #31, #0, AL
ccmp W17, W29, #5, AL
ccmp W17, #0, #5, AL
ccmp W17, #1, #5, AL
ccmp W17, #31, #5, AL
ccmp W17, W29, #15, AL
ccmp W17, #0, #15, AL
ccmp W17, #1, #15, AL
ccmp W17, #31, #15, AL
ccmp W17, W29, #0, NV
ccmp W17, #0, #0, NV
ccmp W17, #1, #0, NV
ccmp W17, #31, #0, NV
ccmp W17, W29, #5, NV
ccmp W17, #0, #5, NV
ccmp W17, #1, #5, NV
ccmp W17, #31, #5, NV
ccmp W17, W29, #15, NV
ccmp W17, #0, #15, NV
ccmp W17, #1, #15, NV
ccmp W17, #31, #15, NV
movn W30, #0, lsl #0
movn W30, #1, lsl #0
movn W30, #65535, lsl #0
movn W30, #0, lsl #16
movn W30, #1, lsl #16
movn W30, #65535, lsl #16
movz W30, #0, lsl #0
movz W30, #1, lsl #0
movz W30, #65535, lsl #0
movz W30, #0, lsl #16
movz W30, #1, lsl #16
movz W30, #65535, lsl #16
movk W30, #0, lsl #0
movk W30, #1, lsl #0
movk W30, #65535, lsl #0
movk W30, #0, lsl #16
movk W30, #1, lsl #16
movk W30, #65535, lsl #16
and W30, W17, #1
and W30, W17, #255
and W30, W17, #4278255360
and W30, W17, #4294967294
and W30, W17, #4294967280
orr W30, W17, #1
orr W30, W17, #255
orr W30, W17, #4278255360
orr W30, W17, #4294967294
orr W30, W17, #4294967280
eor W30, W17, #1
eor W30, W17, #255
eor W30, W17, #4278255360
eor W30, W17, #4294967294
eor W30, W17, #4294967280
ands W30, W17, #1
ands W30, W17, #255
ands W30, W17, #4278255360
ands W30, W17, #4294967294
ands W30, W17, #4294967280
add W30, W17, W29, LSL #0
add W30, W17, W29, LSL #1
add W30, W17, W29, LSL #31
add W30, W17, W29, LSR #0
add W30, W17, W29, LSR #1
add W30, W17, W29, LSR #31
add W30, W17, W29, ASR #0
add W30, W17, W29, ASR #1
add W30, W17, W29, ASR #31
adds W30, W17, W29, LSL #0
adds W30, W17, W29, LSL #1
adds W30, W17, W29, LSL #31
adds W30, W17, W29, LSR #0
adds W30, W17, W29, LSR #1
adds W30, W17, W29, LSR #31
adds W30, W17, W29, ASR #0
adds W30, W17, W29, ASR #1
adds W30, W17, W29, ASR #31
sub W30, W17, W29, LSL #0
sub W30, W17, W29, LSL #1
sub W30, W17, W29, LSL #31
sub W30, W17, W29, LSR #0
sub W30, W17, W29, LSR #1
sub W30, W17, W29, LSR #31
sub W30, W17, W29, ASR #0
sub W30, W17, W29, ASR #1
sub W30, W17, W29, ASR #31
subs W30, W17, W29, LSL #0
subs W30, W17, W29, LSL #1
subs W30, W17, W29, LSL #31
subs W30, W17, W29, LSR #0
subs W30, W17, W29, LSR #1
subs W30, W17, W29, LSR #31
subs W30, W17, W29, ASR #0
subs W30, W17, W29, ASR #1
subs W30, W17, W29, ASR #31
and W30, W17, W29, LSL #0
and W30, W17, W29, LSL #1
and W30, W17, W29, LSL #31
and W30, W17, W29, LSR #0
and W30, W17, W29, LSR #1
and W30, W17, W29, LSR #31
and W30, W17, W29, ASR #0
and W30, W17, W29, ASR #1
and W30, W17, W29, ASR #31
and W30, W17, W29, ROR #0
and W30, W17, W29, ROR #1
and W30, W17, W29, ROR #31
bic W30, W17, W29, LSL #0
bic W30, W17, W29, LSL #1
bic W30, W17, W29, LSL #31
bic W30, W17, W29, LSR #0
bic W30, W17, W29, LSR #1
bic W30, W17, W29, LSR #31
bic W30, W17, W29, ASR #0
bic W30, W17, W29, ASR #1
bic W30, W17, W29, ASR #31
bic W30, W17, W29, ROR #0
bic W30, W17, W29, ROR #1
bic W30, W17, W29, ROR #31
orr W30, W17, W29, LSL #0
orr W30, W17, W29, LSL #1
orr W30, W17, W29, LSL #31
orr W30, W17, W29, LSR #0
orr W30, W17, W29, LSR #1
orr W30, W17, W29, LSR #31
orr W30, W17, W29, ASR #0
orr W30, W17, W29, ASR #1
orr W30, W17, W29, ASR #31
orr W30, W17, W29, ROR #0
orr W30, W17, W29, ROR #1
orr W30, W17, W29, ROR #31
orn W30, W17, W29, LSL #0
orn W30, W17, W29, LSL #1
orn W30, W17, W29, LSL #31
orn W30, W17, W29, LSR #0
orn W30, W17, W29, LSR #1
orn W30, W17, W29, LSR #31
orn W30, W17, W29, ASR #0
orn W30, W17, W29, ASR #1
orn W30, W17, W29, ASR #31
orn W30, W17, W29, ROR #0
orn W30, W17, W29, ROR #1
orn W30, W17, W29, ROR #31
eor W30, W17, W29, LSL #0
eor W30, W17, W29, LSL #1
eor W30, W17, W29, LSL #31
eor W30, W17, W29, LSR #0
eor W30, W17, W29, LSR #1
eor W30, W17, W29, LSR #31
eor W30, W17, W29, ASR #0
eor W30, W17, W29, ASR #1
eor W30, W17, W29, ASR #31
eor W30, W17, W29, ROR #0
eor W30, W17, W29, ROR #1
eor W30, W17, W29, ROR #31
eon W30, W17, W29, LSL #0
eon W30, W17, W29, LSL #1
eon W30, W17, W29, LSL #31
eon W30, W17, W29, LSR #0
eon W30, W17, W29, LSR #1
eon W30, W17, W29, LSR #31
eon W30, W17, W29, ASR #0
eon W30, W17, W29, ASR #1
eon W30, W17, W29, ASR #31
eon W30, W17, W29, ROR #0
eon W30, W17, W29, ROR #1
eon W30, W17, W29, ROR #31
ands W30, W17, W29, LSL #0
ands W30, W17, W29, LSL #1
ands W30, W17, W29, LSL #31
ands W30, W17, W29, LSR #0
ands W30, W17, W29, LSR #1
ands W30, W17, W29, LSR #31
ands W30, W17, W29, ASR #0
ands W30, W17, W29, ASR #1
ands W30, W17, W29, ASR #31
ands W30, W17, W29, ROR #0
ands W30, W17, W29, ROR #1
ands W30, W17, W29, ROR #31
bics W30, W17, W29, LSL #0
bics W30, W17, W29, LSL #1
bics W30, W17, W29, LSL #31
bics W30, W17, W29, LSR #0
bics W30, W17, W29, LSR #1
bics W30, W17, W29, LSR #31
bics W30, W17, W29, ASR #0
bics W30, W17, W29, ASR #1
bics W30, W17, W29, ASR #31
bics W30, W17, W29, ROR #0
bics W30, W17, W29, ROR #1
bics W30, W17, W29, ROR #31
adc WZR, WZR, WZR
adcs WZR, WZR, WZR
sbc WZR, WZR, WZR
sbcs WZR, WZR, WZR
udiv WZR, WZR, WZR
sdiv WZR, WZR, WZR
add WZR, WZR, WZR
adds WZR, WZR, WZR
sub WZR, WZR, WZR
subs WZR, WZR, WZR
and WZR, WZR, WZR
bic WZR, WZR, WZR
orr WZR, WZR, WZR
orn WZR, WZR, WZR
eor WZR, WZR, WZR
eon WZR, WZR, WZR
ands WZR, WZR, WZR
bics WZR, WZR, WZR
ngc WZR, WZR
ngcs WZR, WZR
neg WZR, WZR
negs WZR, WZR
mvn WZR, WZR
rbit WZR, WZR
rev16 WZR, WZR
rev WZR, WZR
clz WZR, WZR
cls WZR, WZR
madd WZR, WZR, WZR, WZR
msub WZR, WZR, WZR, WZR
mul WZR, WZR, WZR
mneg WZR, WZR, WZR
lsl WZR, WZR, WZR
lsl WZR, WZR, #0
lsl WZR, WZR, #1
lsl WZR, WZR, #31
lsr WZR, WZR, WZR
lsr WZR, WZR, #0
lsr WZR, WZR, #1
lsr WZR, WZR, #31
asr WZR, WZR, WZR
asr WZR, WZR, #0
asr WZR, WZR, #1
asr WZR, WZR, #31
ror WZR, WZR, WZR
ror WZR, WZR, #0
ror WZR, WZR, #1
ror WZR, WZR, #31
extr WZR, WZR, WZR, #0
extr WZR, WZR, WZR, #1
extr WZR, WZR, WZR, #31
sbfm WZR, WZR, #0, #0
sbfm WZR, WZR, #0, #1
sbfm WZR, WZR, #0, #31
sbfm WZR, WZR, #1, #0
sbfm WZR, WZR, #1, #1
sbfm WZR, WZR, #1, #31
sbfm WZR, WZR, #31, #0
sbfm WZR, WZR, #31, #1
sbfm WZR, WZR, #31, #31
bfm WZR, WZR, #0, #0
bfm WZR, WZR, #0, #1
bfm WZR, WZR, #0, #31
bfm WZR, WZR, #1, #0
bfm WZR, WZR, #1, #1
bfm WZR, WZR, #1, #31
bfm WZR, WZR, #31, #0
bfm WZR, WZR, #31, #1
bfm WZR, WZR, #31, #31
ubfm WZR, WZR, #0, #0
ubfm WZR, WZR, #0, #1
ubfm WZR, WZR, #0, #31
ubfm WZR, WZR, #1, #0
ubfm WZR, WZR, #1, #1
ubfm WZR, WZR, #1, #31
ubfm WZR, WZR, #31, #0
ubfm WZR, WZR, #31, #1
ubfm WZR, WZR, #31, #31
sbfx WZR, WZR, #0, #32
sbfx WZR, WZR, #0, #1
sbfx WZR, WZR, #1, #31
sbfx WZR, WZR, #31, #1
ubfx WZR, WZR, #0, #32
ubfx WZR, WZR, #0, #1
ubfx WZR, WZR, #1, #31
ubfx WZR, WZR, #31, #1
bfxil WZR, WZR, #0, #32
bfxil WZR, WZR, #0, #1
bfxil WZR, WZR, #1, #31
bfxil WZR, WZR, #31, #1
sbfiz WZR, WZR, #0, #32
sbfiz WZR, WZR, #0, #1
sbfiz WZR, WZR, #1, #31
sbfiz WZR, WZR, #31, #1
ubfiz WZR, WZR, #0, #32
ubfiz WZR, WZR, #0, #1
ubfiz WZR, WZR, #1, #31
ubfiz WZR, WZR, #31, #1
bfi WZR, WZR, #0, #32
bfi WZR, WZR, #0, #1
bfi WZR, WZR, #1, #31
bfi WZR, WZR, #31, #1
csel WZR, WZR, WZR, EQ
csel WZR, WZR, WZR, NE
csel WZR, WZR, WZR, LT
csel WZR, WZR, WZR, GT
csel WZR, WZR, WZR, AL
csel WZR, WZR, WZR, NV
csinc WZR, WZR, WZR, EQ
csinc WZR, WZR, WZR, NE
csinc WZR, WZR, WZR, LT
csinc WZR, WZR, WZR, GT
csinc WZR, WZR, WZR, AL
csinc WZR, WZR, WZR, NV
csinv WZR, WZR, WZR, EQ
csinv WZR, WZR, WZR, NE
csinv WZR, WZR, WZR, LT
csinv WZR, WZR, WZR, GT
csinv WZR, WZR, WZR, AL
csinv WZR, WZR, WZR, NV
csneg WZR, WZR, WZR, EQ
csneg WZR, WZR, WZR, NE
csneg WZR, WZR, WZR, LT
csneg WZR, WZR, WZR, GT
csneg WZR, WZR, WZR, AL
csneg WZR, WZR, WZR, NV
ccmn WZR, WZR, #0, EQ
ccmn WZR, #0, #0, EQ
ccmn WZR, #1, #0, EQ
ccmn WZR, #31, #0, EQ
ccmn WZR, WZR, #5, EQ
ccmn WZR, #0, #5, EQ
ccmn WZR, #1, #5, EQ
ccmn WZR, #31, #5, EQ
ccmn WZR, WZR, #15, EQ
ccmn WZR, #0, #15, EQ
ccmn WZR, #1, #15, EQ
ccmn WZR, #31, #15, EQ
ccmn WZR, WZR, #0, NE
ccmn WZR, #0, #0, NE
ccmn WZR, #1, #0, NE
ccmn WZR, #31, #0, NE
ccmn WZR, WZR, #5, NE
ccmn WZR, #0, #5, NE
ccmn WZR, #1, #5, NE
ccmn WZR, #31, #5, NE
ccmn WZR, WZR, #15, NE
ccmn WZR, #0, #15, NE
ccmn WZR, #1, #15, NE
ccmn WZR, #31, #15, NE
ccmn WZR, WZR, #0, LT
ccmn WZR, #0, #0, LT
ccmn WZR, #1, #0, LT
ccmn WZR, #31, #0, LT
ccmn WZR, WZR, #5, LT
ccmn WZR, #0, #5, LT
ccmn WZR, #1, #5, LT
ccmn WZR, #31, #5, LT
ccmn WZR, WZR, #15, LT
ccmn WZR, #0, #15, LT
ccmn WZR, #1, #15, LT
ccmn WZR, #31, #15, LT
ccmn WZR, WZR, #0, GT
ccmn WZR, #0, #0, GT
ccmn WZR, #1, #0, GT
ccmn WZR, #31, #0, GT
ccmn WZR, WZR, #5, GT
ccmn WZR, #0, #5, GT
ccmn WZR, #1, #5, GT
ccmn WZR, #31, #5, GT
ccmn WZR, WZR, #15, GT
ccmn WZR, #0, #15, GT
ccmn WZR, #1, #15, GT
ccmn WZR, #31, #15, GT
ccmn WZR, WZR, #0, AL
ccmn WZR, #0, #0, AL
ccmn WZR, #1, #0, AL
ccmn WZR, #31, #0, AL
ccmn WZR, WZR, #5, AL
ccmn WZR, #0, #5, AL
ccmn WZR, #1, #5, AL
ccmn WZR, #31, #5, AL
ccmn WZR, WZR, #15, AL
ccmn WZR, #0, #15, AL
ccmn WZR, #1, #15, AL
ccmn WZR, #31, #15, AL
ccmn WZR, WZR, #0, NV
ccmn WZR, #0, #0, NV
ccmn WZR, #1, #0, NV
ccmn WZR, #31, #0, NV
ccmn WZR, WZR, #5, NV
ccmn WZR, #0, #5, NV
ccmn WZR, #1, #5, NV
ccmn WZR, #31, #5, NV
ccmn WZR, WZR, #15, NV
ccmn WZR, #0, #15, NV
ccmn WZR, #1, #15, NV
ccmn WZR, #31, #15, NV
ccmp WZR, WZR, #0, EQ
ccmp WZR, #0, #0, EQ
ccmp WZR, #1, #0, EQ
ccmp WZR, #31, #0, EQ
ccmp WZR, WZR, #5, EQ
ccmp WZR, #0, #5, EQ
ccmp WZR, #1, #5, EQ
ccmp WZR, #31, #5, EQ
ccmp WZR, WZR, #15, EQ
ccmp WZR, #0, #15, EQ
ccmp WZR, #1, #15, EQ
ccmp WZR, #31, #15, EQ
ccmp WZR, WZR, #0, NE
ccmp WZR, #0, #0, NE
ccmp WZR, #1, #0, NE
ccmp WZR, #31, #0, NE
ccmp WZR, WZR, #5, NE
ccmp WZR, #0, #5, NE
ccmp WZR, #1, #5, NE
ccmp WZR, #31, #5, NE
ccmp WZR, WZR, #15, NE
ccmp WZR, #0, #15, NE
ccmp WZR, #1, #15, NE
ccmp WZR, #31, #15, NE
ccmp WZR, WZR, #0, LT
ccmp WZR, #0, #0, LT
ccmp WZR, #1, #0, LT
ccmp WZR, #31, #0, LT
ccmp WZR, WZR, #5, LT
ccmp WZR, #0, #5, LT
ccmp WZR, #1, #5, LT
ccmp WZR, #31, #5, LT
ccmp WZR, WZR, #15, LT
ccmp WZR, #0, #15, LT
ccmp WZR, #1, #15, LT
ccmp WZR, #31, #15, LT
ccmp WZR, WZR, #0, GT
ccmp WZR, #0, #0, GT
ccmp WZR, #1, #0, GT
ccmp WZR, #31, #0, GT
ccmp WZR, WZR, #5, GT
ccmp WZR, #0, #5, GT
ccmp WZR, #1, #5, GT
ccmp WZR, #31, #5, GT
ccmp WZR, WZR, #15, GT
ccmp WZR, #0, #15, GT
ccmp WZR, #1, #15, GT
ccmp WZR, #31, #15, GT
ccmp WZR, WZR, #0, AL
ccmp WZR, #0, #0, AL
ccmp WZR, #1, #0, AL
ccmp WZR, #31, #0, AL
ccmp WZR, WZR, #5, AL
ccmp WZR, #0, #5, AL
ccmp WZR, #1, #5, AL
ccmp WZR, #31, #5, AL
ccmp WZR, WZR, #15, AL
ccmp WZR, #0, #15, AL
ccmp WZR, #1, #15, AL
ccmp WZR, #31, #15, AL
ccmp WZR, WZR, #0, NV
ccmp WZR, #0, #0, NV
ccmp WZR, #1, #0, NV
ccmp WZR, #31, #0, NV
ccmp WZR, WZR, #5, NV
ccmp WZR, #0, #5, NV
ccmp WZR, #1, #5, NV
ccmp WZR, #31, #5, NV
ccmp WZR, WZR, #15, NV
ccmp WZR, #0, #15, NV
ccmp WZR, #1, #15, NV
ccmp WZR, #31, #15, NV
movn WZR, #0, lsl #0
movn WZR, #1, lsl #0
movn WZR, #65535, lsl #0
movn WZR, #0, lsl #16
movn WZR, #1, lsl #16
movn WZR, #65535, lsl #16
movz WZR, #0, lsl #0
movz WZR, #1, lsl #0
movz WZR, #65535, lsl #0
movz WZR, #0, lsl #16
movz WZR, #1, lsl #16
movz WZR, #65535, lsl #16
movk WZR, #0, lsl #0
movk WZR, #1, lsl #0
movk WZR, #65535, lsl #0
movk WZR, #0, lsl #16
movk WZR, #1, lsl #16
movk WZR, #65535, lsl #16
and WSP, WZR, #1
and WSP, WZR, #255
and WSP, WZR, #4278255360
and WSP, WZR, #4294967294
and WSP, WZR, #4294967280
orr WSP, WZR, #1
orr WSP, WZR, #255
orr WSP, WZR, #4278255360
orr WSP, WZR, #4294967294
orr WSP, WZR, #4294967280
eor WSP, WZR, #1
eor WSP, WZR, #255
eor WSP, WZR, #4278255360
eor WSP, WZR, #4294967294
eor WSP, WZR, #4294967280
ands WZR, WZR, #1
ands WZR, WZR, #255
ands WZR, WZR, #4278255360
ands WZR, WZR, #4294967294
ands WZR, WZR, #4294967280
add WZR, WZR, WZR, LSL #0
add WZR, WZR, WZR, LSL #1
add WZR, WZR, WZR, LSL #31
add WZR, WZR, WZR, LSR #0
add WZR, WZR, WZR, LSR #1
add WZR, WZR, WZR, LSR #31
add WZR, WZR, WZR, ASR #0
add WZR, WZR, WZR, ASR #1
add WZR, WZR, WZR, ASR #31
adds WZR, WZR, WZR, LSL #0
adds WZR, WZR, WZR, LSL #1
adds WZR, WZR, WZR, LSL #31
adds WZR, WZR, WZR, LSR #0
adds WZR, WZR, WZR, LSR #1
adds WZR, WZR, WZR, LSR #31
adds WZR, WZR, WZR, ASR #0
adds WZR, WZR, WZR, ASR #1
adds WZR, WZR, WZR, ASR #31
sub WZR, WZR, WZR, LSL #0
sub WZR, WZR, WZR, LSL #1
sub WZR, WZR, WZR, LSL #31
sub WZR, WZR, WZR, LSR #0
sub WZR, WZR, WZR, LSR #1
sub WZR, WZR, WZR, LSR #31
sub WZR, WZR, WZR, ASR #0
sub WZR, WZR, WZR, ASR #1
sub WZR, WZR, WZR, ASR #31
subs WZR, WZR, WZR, LSL #0
subs WZR, WZR, WZR, LSL #1
subs WZR, WZR, WZR, LSL #31
subs WZR, WZR, WZR, LSR #0
subs WZR, WZR, WZR, LSR #1
subs WZR, WZR, WZR, LSR #31
subs WZR, WZR, WZR, ASR #0
subs WZR, WZR, WZR, ASR #1
subs WZR, WZR, WZR, ASR #31
and WZR, WZR, WZR, LSL #0
and WZR, WZR, WZR, LSL #1
and WZR, WZR, WZR, LSL #31
and WZR, WZR, WZR, LSR #0
and WZR, WZR, WZR, LSR #1
and WZR, WZR, WZR, LSR #31
and WZR, WZR, WZR, ASR #0
and WZR, WZR, WZR, ASR #1
and WZR, WZR, WZR, ASR #31
and WZR, WZR, WZR, ROR #0
and WZR, WZR, WZR, ROR #1
and WZR, WZR, WZR, ROR #31
bic WZR, WZR, WZR, LSL #0
bic WZR, WZR, WZR, LSL #1
bic WZR, WZR, WZR, LSL #31
bic WZR, WZR, WZR, LSR #0
bic WZR, WZR, WZR, LSR #1
bic WZR, WZR, WZR, LSR #31
bic WZR, WZR, WZR, ASR #0
bic WZR, WZR, WZR, ASR #1
bic WZR, WZR, WZR, ASR #31
bic WZR, WZR, WZR, ROR #0
bic WZR, WZR, WZR, ROR #1
bic WZR, WZR, WZR, ROR #31
orr WZR, WZR, WZR, LSL #0
orr WZR, WZR, WZR, LSL #1
orr WZR, WZR, WZR, LSL #31
orr WZR, WZR, WZR, LSR #0
orr WZR, WZR, WZR, LSR #1
orr WZR, WZR, WZR, LSR #31
orr WZR, WZR, WZR, ASR #0
orr WZR, WZR, WZR, ASR #1
orr WZR, WZR, WZR, ASR #31
orr WZR, WZR, WZR, ROR #0
orr WZR, WZR, WZR, ROR #1
orr WZR, WZR, WZR, ROR #31
orn WZR, WZR, WZR, LSL #0
orn WZR, WZR, WZR, LSL #1
orn WZR, WZR, WZR, LSL #31
orn WZR, WZR, WZR, LSR #0
orn WZR, WZR, WZR, LSR #1
orn WZR, WZR, WZR, LSR #31
orn WZR, WZR, WZR, ASR #0
orn WZR, WZR, WZR, ASR #1
orn WZR, WZR, WZR, ASR #31
orn WZR, WZR, WZR, ROR #0
orn WZR, WZR, WZR, ROR #1
orn WZR, WZR, WZR, ROR #31
eor WZR, WZR, WZR, LSL #0
eor WZR, WZR, WZR, LSL #1
eor WZR, WZR, WZR, LSL #31
eor WZR, WZR, WZR, LSR #0
eor WZR, WZR, WZR, LSR #1
eor WZR, WZR, WZR, LSR #31
eor WZR, WZR, WZR, ASR #0
eor WZR, WZR, WZR, ASR #1
eor WZR, WZR, WZR, ASR #31
eor WZR, WZR, WZR, ROR #0
eor WZR, WZR, WZR, ROR #1
eor WZR, WZR, WZR, ROR #31
eon WZR, WZR, WZR, LSL #0
eon WZR, WZR, WZR, LSL #1
eon WZR, WZR, WZR, LSL #31
eon WZR, WZR, WZR, LSR #0
eon WZR, WZR, WZR, LSR #1
eon WZR, WZR, WZR, LSR #31
eon WZR, WZR, WZR, ASR #0
eon WZR, WZR, WZR, ASR #1
eon WZR, WZR, WZR, ASR #31
eon WZR, WZR, WZR, ROR #0
eon WZR, WZR, WZR, ROR #1
eon WZR, WZR, WZR, ROR #31
ands WZR, WZR, WZR, LSL #0
ands WZR, WZR, WZR, LSL #1
ands WZR, WZR, WZR, LSL #31
ands WZR, WZR, WZR, LSR #0
ands WZR, WZR, WZR, LSR #1
ands WZR, WZR, WZR, LSR #31
ands WZR, WZR, WZR, ASR #0
ands WZR, WZR, WZR, ASR #1
ands WZR, WZR, WZR, ASR #31
ands WZR, WZR, WZR, ROR #0
ands WZR, WZR, WZR, ROR #1
ands WZR, WZR, WZR, ROR #31
bics WZR, WZR, WZR, LSL #0
bics WZR, WZR, WZR, LSL #1
bics WZR, WZR, WZR, LSL #31
bics WZR, WZR, WZR, LSR #0
bics WZR, WZR, WZR, LSR #1
bics WZR, WZR, WZR, LSR #31
bics WZR, WZR, WZR, ASR #0
bics WZR, WZR, WZR, ASR #1
bics WZR, WZR, WZR, ASR #31
bics WZR, WZR, WZR, ROR #0
bics WZR, WZR, WZR, ROR #1
bics WZR, WZR, WZR, ROR #31
add W0, WSP, W2, UXTB #0
add WSP, WSP, W2, UXTB #0
add W0, WSP, W2, UXTB #4
add WSP, WSP, W2, UXTB #4
add W0, WSP, W2, UXTH #0
add WSP, WSP, W2, UXTH #0
add W0, WSP, W2, UXTH #4
add WSP, WSP, W2, UXTH #4
add W0, WSP, W2, UXTW #0
add WSP, WSP, W2, UXTW #0
add W0, WSP, W2, UXTW #4
add WSP, WSP, W2, UXTW #4
add W0, WSP, W2, SXTB #0
add WSP, WSP, W2, SXTB #0
add W0, WSP, W2, SXTB #4
add WSP, WSP, W2, SXTB #4
add W0, WSP, W2, SXTH #0
add WSP, WSP, W2, SXTH #0
add W0, WSP, W2, SXTH #4
add WSP, WSP, W2, SXTH #4
add W0, WSP, W2, SXTW #0
add WSP, WSP, W2, SXTW #0
add W0, WSP, W2, SXTW #4
add WSP, WSP, W2, SXTW #4
adds W0, WSP, W2, UXTB #0
adds WZR, WSP, W2, UXTB #0
adds W0, WSP, W2, UXTB #4
adds WZR, WSP, W2, UXTB #4
adds W0, WSP, W2, UXTH #0
adds WZR, WSP, W2, UXTH #0
adds W0, WSP, W2, UXTH #4
adds WZR, WSP, W2, UXTH #4
adds W0, WSP, W2, UXTW #0
adds WZR, WSP, W2, UXTW #0
adds W0, WSP, W2, UXTW #4
adds WZR, WSP, W2, UXTW #4
adds W0, WSP, W2, SXTB #0
adds WZR, WSP, W2, SXTB #0
adds W0, WSP, W2, SXTB #4
adds WZR, WSP, W2, SXTB #4
adds W0, WSP, W2, SXTH #0
adds WZR, WSP, W2, SXTH #0
adds W0, WSP, W2, SXTH #4
adds WZR, WSP, W2, SXTH #4
adds W0, WSP, W2, SXTW #0
adds WZR, WSP, W2, SXTW #0
adds W0, WSP, W2, SXTW #4
adds WZR, WSP, W2, SXTW #4
sub W0, WSP, W2, UXTB #0
sub WSP, WSP, W2, UXTB #0
sub W0, WSP, W2, UXTB #4
sub WSP, WSP, W2, UXTB #4
sub W0, WSP, W2, UXTH #0
sub WSP, WSP, W2, UXTH #0
sub W0, WSP, W2, UXTH #4
sub WSP, WSP, W2, UXTH #4
sub W0, WSP, W2, UXTW #0
sub WSP, WSP, W2, UXTW #0
sub W0, WSP, W2, UXTW #4
sub WSP, WSP, W2, UXTW #4
sub W0, WSP, W2, SXTB #0
sub WSP, WSP, W2, SXTB #0
sub W0, WSP, W2, SXTB #4
sub WSP, WSP, W2, SXTB #4
sub W0, WSP, W2, SXTH #0
sub WSP, WSP, W2, SXTH #0
sub W0, WSP, W2, SXTH #4
sub WSP, WSP, W2, SXTH #4
sub W0, WSP, W2, SXTW #0
sub WSP, WSP, W2, SXTW #0
sub W0, WSP, W2, SXTW #4
sub WSP, WSP, W2, SXTW #4
subs W0, WSP, W2, UXTB #0
subs WZR, WSP, W2, UXTB #0
subs W0, WSP, W2, UXTB #4
subs WZR, WSP, W2, UXTB #4
subs W0, WSP, W2, UXTH #0
subs WZR, WSP, W2, UXTH #0
subs W0, WSP, W2, UXTH #4
subs WZR, WSP, W2, UXTH #4
subs W0, WSP, W2, UXTW #0
subs WZR, WSP, W2, UXTW #0
subs W0, WSP, W2, UXTW #4
subs WZR, WSP, W2, UXTW #4
subs W0, WSP, W2, SXTB #0
subs WZR, WSP, W2, SXTB #0
subs W0, WSP, W2, SXTB #4
subs WZR, WSP, W2, SXTB #4
subs W0, WSP, W2, SXTH #0
subs WZR, WSP, W2, SXTH #0
subs W0, WSP, W2, SXTH #4
subs WZR, WSP, W2, SXTH #4
subs W0, WSP, W2, SXTW #0
subs WZR, WSP, W2, SXTW #0
subs W0, WSP, W2, SXTW #4
subs WZR, WSP, W2, SXTW #4
adc X0, X1, X2
adcs X0, X1, X2
sbc X0, X1, X2
sbcs X0, X1, X2
udiv X0, X1, X2
sdiv X0, X1, X2
add X0, X1, X2
adds X0, X1, X2
sub X0, X1, X2
subs X0, X1, X2
and X0, X1, X2
bic X0, X1, X2
orr X0, X1, X2
orn X0, X1, X2
eor X0, X1, X2
eon X0, X1, X2
ands X0, X1, X2
bics X0, X1, X2
ngc X0, X1
ngcs X0, X1
neg X0, X1
negs X0, X1
mvn X0, X1
rbit X0, X1
rev16 X0, X1
rev X0, X1
clz X0, X1
cls X0, X1
rev32 X0, X1
madd X0, X1, X2, X3
msub X0, X1, X2, X3
mul X0, X1, X2
mneg X0, X1, X2
lsl X0, X1, X2
lsl X0, X1, #0
lsl X0, X1, #1
lsl X0, X1, #63
lsr X0, X1, X2
lsr X0, X1, #0
lsr X0, X1, #1
lsr X0, X1, #63
asr X0, X1, X2
asr X0, X1, #0
asr X0, X1, #1
asr X0, X1, #63
ror X0, X1, X2
ror X0, X1, #0
ror X0, X1, #1
ror X0, X1, #63
extr X0, X1, X2, #0
extr X0, X1, X2, #1
extr X0, X1, X2, #63
sbfm X0, X1, #0, #0
sbfm X0, X1, #0, #1
sbfm X0, X1, #0, #63
sbfm X0, X1, #1, #0
sbfm X0, X1, #1, #1
sbfm X0, X1, #1, #63
sbfm X0, X1, #63, #0
sbfm X0, X1, #63, #1
sbfm X0, X1, #63, #63
bfm X0, X1, #0, #0
bfm X0, X1, #0, #1
bfm X0, X1, #0, #63
bfm X0, X1, #1, #0
bfm X0, X1, #1, #1
bfm X0, X1, #1, #63
bfm X0, X1, #63, #0
bfm X0, X1, #63, #1
bfm X0, X1, #63, #63
ubfm X0, X1, #0, #0
ubfm X0, X1, #0, #1
ubfm X0, X1, #0, #63
ubfm X0, X1, #1, #0
ubfm X0, X1, #1, #1
ubfm X0, X1, #1, #63
ubfm X0, X1, #63, #0
ubfm X0, X1, #63, #1
ubfm X0, X1, #63, #63
sbfx X0, X1, #0, #64
sbfx X0, X1, #0, #1
sbfx X0, X1, #1, #63
sbfx X0, X1, #63, #1
ubfx X0, X1, #0, #64
ubfx X0, X1, #0, #1
ubfx X0, X1, #1, #63
ubfx X0, X1, #63, #1
bfxil X0, X1, #0, #64
bfxil X0, X1, #0, #1
bfxil X0, X1, #1, #63
bfxil X0, X1, #63, #1
sbfiz X0, X1, #0, #64
sbfiz X0, X1, #0, #1
sbfiz X0, X1, #1, #63
sbfiz X0, X1, #63, #1
ubfiz X0, X1, #0, #64
ubfiz X0, X1, #0, #1
ubfiz X0, X1, #1, #63
ubfiz X0, X1, #63, #1
bfi X0, X1, #0, #64
bfi X0, X1, #0, #1
bfi X0, X1, #1, #63
bfi X0, X1, #63, #1
csel X0, X1, X2, EQ
csel X0, X1, X2, NE
csel X0, X1, X2, LT
csel X0, X1, X2, GT
csel X0, X1, X2, AL
csel X0, X1, X2, NV
csinc X0, X1, X2, EQ
csinc X0, X1, X2, NE
csinc X0, X1, X2, LT
csinc X0, X1, X2, GT
csinc X0, X1, X2, AL
csinc X0, X1, X2, NV
csinv X0, X1, X2, EQ
csinv X0, X1, X2, NE
csinv X0, X1, X2, LT
csinv X0, X1, X2, GT
csinv X0, X1, X2, AL
csinv X0, X1, X2, NV
csneg X0, X1, X2, EQ
csneg X0, X1, X2, NE
csneg X0, X1, X2, LT
csneg X0, X1, X2, GT
csneg X0, X1, X2, AL
csneg X0, X1, X2, NV
ccmn X1, X2, #0, EQ
ccmn X1, #0, #0, EQ
ccmn X1, #1, #0, EQ
ccmn X1, #31, #0, EQ
ccmn X1, X2, #5, EQ
ccmn X1, #0, #5, EQ
ccmn X1, #1, #5, EQ
ccmn X1, #31, #5, EQ
ccmn X1, X2, #15, EQ
ccmn X1, #0, #15, EQ
ccmn X1, #1, #15, EQ
ccmn X1, #31, #15, EQ
ccmn X1, X2, #0, NE
ccmn X1, #0, #0, NE
ccmn X1, #1, #0, NE
ccmn X1, #31, #0, NE
ccmn X1, X2, #5, NE
ccmn X1, #0, #5, NE
ccmn X1, #1, #5, NE
ccmn X1, #31, #5, NE
ccmn X1, X2, #15, NE
ccmn X1, #0, #15, NE
ccmn X1, #1, #15, NE
ccmn X1, #31, #15, NE
ccmn X1, X2, #0, LT
ccmn X1, #0, #0, LT
ccmn X1, #1, #0, LT
ccmn X1, #31, #0, LT
ccmn X1, X2, #5, LT
ccmn X1, #0, #5, LT
ccmn X1, #1, #5, LT
ccmn X1, #31, #5, LT
ccmn X1, X2, #15, LT
ccmn X1, #0, #15, LT
ccmn X1, #1, #15, LT
ccmn X1, #31, #15, LT
ccmn X1, X2, #0, GT
ccmn X1, #0, #0, GT
ccmn X1, #1, #0, GT
ccmn X1, #31, #0, GT
ccmn X1, X2, #5, GT
ccmn X1, #0, #5, GT
ccmn X1, #1, #5, GT
ccmn X1, #31, #5, GT
ccmn X1, X2, #15, GT
ccmn X1, #0, #15, GT
ccmn X1, #1, #15, GT
ccmn X1, #31, #15, GT
ccmn X1, X2, #0, AL
ccmn X1, #0, #0, AL
ccmn X1, #1, #0, AL
ccmn X1, #31, #0, AL
ccmn X1, X2, #5, AL
ccmn X1, #0, #5, AL
ccmn X1, #1, #5, AL
ccmn X1, #31, #5, AL
ccmn X1, X2, #15, AL
ccmn X1, #0, #15, AL
ccmn X1, #1, #15, AL
ccmn X1, #31, #15, AL
ccmn X1, X2, #0, NV
ccmn X1, #0, #0, NV
ccmn X1, #1, #0, NV
ccmn X1, #31, #0, NV
ccmn X1, X2, #5, NV
ccmn X1, #0, #5, NV
ccmn X1, #1, #5, NV
ccmn X1, #31, #5, NV
ccmn X1, X2, #15, NV
ccmn X1, #0, #15, NV
ccmn X1, #1, #15, NV
ccmn X1, #31, #15, NV
ccmp X1, X2, #0, EQ
ccmp X1, #0, #0, EQ
ccmp X1, #1, #0, EQ
ccmp X1, #31, #0, EQ
ccmp X1, X2, #5, EQ
ccmp X1, #0, #5, EQ
ccmp X1, #1, #5, EQ
ccmp X1, #31, #5, EQ
ccmp X1, X2, #15, EQ
ccmp X1, #0, #15, EQ
ccmp X1, #1, #15, EQ
ccmp X1, #31, #15, EQ
ccmp X1, X2, #0, NE
ccmp X1, #0, #0, NE
ccmp X1, #1, #0, NE
ccmp X1, #31, #0, NE
ccmp X1, X2, #5, NE
ccmp X1, #0, #5, NE
ccmp X1, #1, #5, NE
ccmp X1, #31, #5, NE
ccmp X1, X2, #15, NE
ccmp X1, #0, #15, NE
ccmp X1, #1, #15, NE
ccmp X1, #31, #15, NE
ccmp X1, X2, #0, LT
ccmp X1, #0, #0, LT
ccmp X1, #1, #0, LT
ccmp X1, #31, #0, LT
ccmp X1, X2, #5, LT
ccmp X1, #0, #5, LT
ccmp X1, #1, #5, LT
ccmp X1, #31, #5, LT
ccmp X1, X2, #15, LT
ccmp X1, #0, #15, LT
ccmp X1, #1, #15, LT
ccmp X1, #31, #15, LT
ccmp X1, X2, #0, GT
ccmp X1, #0, #0, GT
ccmp X1, #1, #0, GT
ccmp X1, #31, #0, GT
ccmp X1, X2, #5, GT
ccmp X1, #0, #5, GT
ccmp X1, #1, #5, GT
ccmp X1, #31, #5, GT
ccmp X1, X2, #15, GT
ccmp X1, #0, #15, GT
ccmp X1, #1, #15, GT
ccmp X1, #31, #15, GT
ccmp X1, X2, #0, AL
ccmp X1, #0, #0, AL
ccmp X1, #1, #0, AL
ccmp X1, #31, #0, AL
ccmp X1, X2, #5, AL
ccmp X1, #0, #5, AL
ccmp X1, #1, #5, AL
ccmp X1, #31, #5, AL
ccmp X1, X2, #15, AL
ccmp X1, #0, #15, AL
ccmp X1, #1, #15, AL
ccmp X1, #31, #15, AL
ccmp X1, X2, #0, NV
ccmp X1, #0, #0, NV
ccmp X1, #1, #0, NV
ccmp X1, #31, #0, NV
ccmp X1, X2, #5, NV
ccmp X1, #0, #5, NV
ccmp X1, #1, #5, NV
ccmp X1, #31, #5, NV
ccmp X1, X2, #15, NV
ccmp X1, #0, #15, NV
ccmp X1, #1, #15, NV
ccmp X1, #31, #15, NV
movn X0, #0, lsl #0
movn X0, #1, lsl #0
movn X0, #65535, lsl #0
movn X0, #0, lsl #16
movn X0, #1, lsl #16
movn X0, #65535, lsl #16
movn X0, #0, lsl #32
movn X0, #1, lsl #32
movn X0, #65535, lsl #32
movn X0, #0, lsl #48
movn X0, #1, lsl #48
movn X0, #65535, lsl #48
movz X0, #0, lsl #0
movz X0, #1, lsl #0
movz X0, #65535, lsl #0
movz X0, #0, lsl #16
movz X0, #1, lsl #16
movz X0, #65535, lsl #16
movz X0, #0, lsl #32
movz X0, #1, lsl #32
movz X0, #65535, lsl #32
movz X0, #0, lsl #48
movz X0, #1, lsl #48
movz X0, #65535, lsl #48
movk X0, #0, lsl #0
movk X0, #1, lsl #0
movk X0, #65535, lsl #0
movk X0, #0, lsl #16
movk X0, #1, lsl #16
movk X0, #65535, lsl #16
movk X0, #0, lsl #32
movk X0, #1, lsl #32
movk X0, #65535, lsl #32
movk X0, #0, lsl #48
movk X0, #1, lsl #48
movk X0, #65535, lsl #48
and X0, X1, #1
and X0, X1, #255
and X0, X1, #18374966859414961920
and X0, X1, #18446744073709551614
and X0, X1, #18446744073709551600
orr X0, X1, #1
orr X0, X1, #255
orr X0, X1, #18374966859414961920
orr X0, X1, #18446744073709551614
orr X0, X1, #18446744073709551600
eor X0, X1, #1
eor X0, X1, #255
eor X0, X1, #18374966859414961920
eor X0, X1, #18446744073709551614
eor X0, X1, #18446744073709551600
ands X0, X1, #1
ands X0, X1, #255
ands X0, X1, #18374966859414961920
ands X0, X1, #18446744073709551614
ands X0, X1, #18446744073709551600
add X0, X1, X2, LSL #0
add X0, X1, X2, LSL #1
add X0, X1, X2, LSL #63
add X0, X1, X2, LSR #0
add X0, X1, X2, LSR #1
add X0, X1, X2, LSR #63
add X0, X1, X2, ASR #0
add X0, X1, X2, ASR #1
add X0, X1, X2, ASR #63
adds X0, X1, X2, LSL #0
adds X0, X1, X2, LSL #1
adds X0, X1, X2, LSL #63
adds X0, X1, X2, LSR #0
adds X0, X1, X2, LSR #1
adds X0, X1, X2, LSR #63
adds X0, X1, X2, ASR #0
adds X0, X1, X2, ASR #1
adds X0, X1, X2, ASR #63
sub X0, X1, X2, LSL #0
sub X0, X1, X2, LSL #1
sub X0, X1, X2, LSL #63
sub X0, X1, X2, LSR #0
sub X0, X1, X2, LSR #1
sub X0, X1, X2, LSR #63
sub X0, X1, X2, ASR #0
sub X0, X1, X2, ASR #1
sub X0, X1, X2, ASR #63
subs X0, X1, X2, LSL #0
subs X0, X1, X2, LSL #1
subs X0, X1, X2, LSL #63
subs X0, X1, X2, LSR #0
subs X0, X1, X2, LSR #1
subs X0, X1, X2, LSR #63
subs X0, X1, X2, ASR #0
subs X0, X1, X2, ASR #1
subs X0, X1, X2, ASR #63
and X0, X1, X2, LSL #0
and X0, X1, X2, LSL #1
and X0, X1, X2, LSL #63
and X0, X1, X2, LSR #0
and X0, X1, X2, LSR #1
and X0, X1, X2, LSR #63
and X0, X1, X2, ASR #0
and X0, X1, X2, ASR #1
and X0, X1, X2, ASR #63
and X0, X1, X2, ROR #0
and X0, X1, X2, ROR #1
and X0, X1, X2, ROR #63
bic X0, X1, X2, LSL #0
bic X0, X1, X2, LSL #1
bic X0, X1, X2, LSL #63
bic X0, X1, X2, LSR #0
bic X0, X1, X2, LSR #1
bic X0, X1, X2, LSR #63
bic X0, X1, X2, ASR #0
bic X0, X1, X2, ASR #1
bic X0, X1, X2, ASR #63
bic X0, X1, X2, ROR #0
bic X0, X1, X2, ROR #1
bic X0, X1, X2, ROR #63
orr X0, X1, X2, LSL #0
orr X0, X1, X2, LSL #1
orr X0, X1, X2, LSL #63
orr X0, X1, X2, LSR #0
orr X0, X1, X2, LSR #1
orr X0, X1, X2, LSR #63
orr X0, X1, X2, ASR #0
orr X0, X1, X2, ASR #1
orr X0, X1, X2, ASR #63
orr X0, X1, X2, ROR #0
orr X0, X1, X2, ROR #1
orr X0, X1, X2, ROR #63
orn X0, X1, X2, LSL #0
orn X0, X1, X2, LSL #1
orn X0, X1, X2, LSL #63
orn X0, X1, X2, LSR #0
orn X0, X1, X2, LSR #1
orn X0, X1, X2, LSR #63
orn X0, X1, X2, ASR #0
orn X0, X1, X2, ASR #1
orn X0, X1, X2, ASR #63
orn X0, X1, X2, ROR #0
orn X0, X1, X2, ROR #1
orn X0, X1, X2, ROR #63
eor X0, X1, X2, LSL #0
eor X0, X1, X2, LSL #1
eor X0, X1, X2, LSL #63
eor X0, X1, X2, LSR #0
eor X0, X1, X2, LSR #1
eor X0, X1, X2, LSR #63
eor X0, X1, X2, ASR #0
eor X0, X1, X2, ASR #1
eor X0, X1, X2, ASR #63
eor X0, X1, X2, ROR #0
eor X0, X1, X2, ROR #1
eor X0, X1, X2, ROR #63
eon X0, X1, X2, LSL #0
eon X0, X1, X2, LSL #1
eon X0, X1, X2, LSL #63
eon X0, X1, X2, LSR #0
eon X0, X1, X2, LSR #1
eon X0, X1, X2, LSR #63
eon X0, X1, X2, ASR #0
eon X0, X1, X2, ASR #1
eon X0, X1, X2, ASR #63
eon X0, X1, X2, ROR #0
eon X0, X1, X2, ROR #1
eon X0, X1, X2, ROR #63
ands X0, X1, X2, LSL #0
ands X0, X1, X2, LSL #1
ands X0, X1, X2, LSL #63
ands X0, X1, X2, LSR #0
ands X0, X1, X2, LSR #1
ands X0, X1, X2, LSR #63
ands X0, X1, X2, ASR #0
ands X0, X1, X2, ASR #1
ands X0, X1, X2, ASR #63
ands X0, X1, X2, ROR #0
ands X0, X1, X2, ROR #1
ands X0, X1, X2, ROR #63
bics X0, X1, X2, LSL #0
bics X0, X1, X2, LSL #1
bics X0, X1, X2, LSL #63
bics X0, X1, X2, LSR #0
bics X0, X1, X2, LSR #1
bics X0, X1, X2, LSR #63
bics X0, X1, X2, ASR #0
bics X0, X1, X2, ASR #1
bics X0, X1, X2, ASR #63
bics X0, X1, X2, ROR #0
bics X0, X1, X2, ROR #1
bics X0, X1, X2, ROR #63
adc X30, X17, X29
adcs X30, X17, X29
sbc X30, X17, X29
sbcs X30, X17, X29
udiv X30, X17, X29
sdiv X30, X17, X29
add X30, X17, X29
adds X30, X17, X29
sub X30, X17, X29
subs X30, X17, X29
and X30, X17, X29
bic X30, X17, X29
orr X30, X17, X29
orn X30, X17, X29
eor X30, X17, X29
eon X30, X17, X29
ands X30, X17, X29
bics X30, X17, X29
ngc X30, X17
ngcs X30, X17
neg X30, X17
negs X30, X17
mvn X30, X17
rbit X30, X17
rev16 X30, X17
rev X30, X17
clz X30, X17
cls X30, X17
rev32 X30, X17
madd X30, X17, X29, X11
msub X30, X17, X29, X11
mul X30, X17, X29
mneg X30, X17, X29
lsl X30, X17, X29
lsl X30, X17, #0
lsl X30, X17, #1
lsl X30, X17, #63
lsr X30, X17, X29
lsr X30, X17, #0
lsr X30, X17, #1
lsr X30, X17, #63
asr X30, X17, X29
asr X30, X17, #0
asr X30, X17, #1
asr X30, X17, #63
ror X30, X17, X29
ror X30, X17, #0
ror X30, X17, #1
ror X30, X17, #63
extr X30, X17, X29, #0
extr X30, X17, X29, #1
extr X30, X17, X29, #63
sbfm X30, X17, #0, #0
sbfm X30, X17, #0, #1
sbfm X30, X17, #0, #63
sbfm X30, X17, #1, #0
sbfm X30, X17, #1, #1
sbfm X30, X17, #1, #63
sbfm X30, X17, #63, #0
sbfm X30, X17, #63, #1
sbfm X30, X17, #63, #63
bfm X30, X17, #0, #0
bfm X30, X17, #0, #1
bfm X30, X17, #0, #63
bfm X30, X17, #1, #0
bfm X30, X17, #1, #1
bfm X30, X17, #1, #63
bfm X30, X17, #63, #0
bfm X30, X17, #63, #1
bfm X30, X17, #63, #63
ubfm X30, X17, #0, #0
ubfm X30, X17, #0, #1
ubfm X30, X17, #0, #63
ubfm X30, X17, #1, #0
ubfm X30, X17, #1, #1
ubfm X30, X17, #1, #63
ubfm X30, X17, #63, #0
ubfm X30, X17, #63, #1
ubfm X30, X17, #63, #63
sbfx X30, X17, #0, #64
sbfx X30, X17, #0, #1
sbfx X30, X17, #1, #63
sbfx X30, X17, #63, #1
ubfx X30, X17, #0, #64
ubfx X30, X17, #0, #1
ubfx X30, X17, #1, #63
ubfx X30, X17, #63, #1
bfxil X30, X17, #0, #64
bfxil X30, X17, #0, #1
bfxil X30, X17, #1, #63
bfxil X30, X17, #63, #1
sbfiz X30, X17, #0, #64
sbfiz X30, X17, #0, #1
sbfiz X30, X17, #1, #63
sbfiz X30, X17, #63, #1
ubfiz X30, X17, #0, #64
ubfiz X30, X17, #0, #1
ubfiz X30, X17, #1, #63
ubfiz X30, X17, #63, #1
bfi X30, X17, #0, #64
bfi X30, X17, #0, #1
bfi X30, X17, #1, #63
bfi X30, X17, #63, #1
csel X30, X17, X29, EQ
csel X30, X17, X29, NE
csel X30, X17, X29, LT
csel X30, X17, X29, GT
csel X30, X17, X29, AL
csel X30, X17, X29, NV
csinc X30, X17, X29, EQ
csinc X30, X17, X29, NE
csinc X30, X17, X29, LT
csinc X30, X17, X29, GT
csinc X30, X17, X29, AL
csinc X30, X17, X29, NV
csinv X30, X17, X29, EQ
csinv X30, X17, X29, NE
csinv X30, X17, X29, LT
csinv X30, X17, X29, GT
csinv X30, X17, X29, AL
csinv X30, X17, X29, NV
csneg X30, X17, X29, EQ
csneg X30, X17, X29, NE
csneg X30, X17, X29, LT
csneg X30, X17, X29, GT
csneg X30, X17, X29, AL
csneg X30, X17, X29, NV
ccmn X17, X29, #0, EQ
ccmn X17, #0, #0, EQ
ccmn X17, #1, #0, EQ
ccmn X17, #31, #0, EQ
ccmn X17, X29, #5, EQ
ccmn X17, #0, #5, EQ
ccmn X17, #1, #5, EQ
ccmn X17, #31, #5, EQ
ccmn X17, X29, #15, EQ
ccmn X17, #0, #15, EQ
ccmn X17, #1, #15, EQ
ccmn X17, #31, #15, EQ
ccmn X17, X29, #0, NE
ccmn X17, #0, #0, NE
ccmn X17, #1, #0, NE
ccmn X17, #31, #0, NE
ccmn X17, X29, #5, NE
ccmn X17, #0, #5, NE
ccmn X17, #1, #5, NE
ccmn X17, #31, #5, NE
ccmn X17, X29, #15, NE
ccmn X17, #0, #15, NE
ccmn X17, #1, #15, NE
ccmn X17, #31, #15, NE
ccmn X17, X29, #0, LT
ccmn X17, #0, #0, LT
ccmn X17, #1, #0, LT
ccmn X17, #31, #0, LT
ccmn X17, X29, #5, LT
ccmn X17, #0, #5, LT
ccmn X17, #1, #5, LT
ccmn X17, #31, #5, LT
ccmn X17, X29, #15, LT
ccmn X17, #0, #15, LT
ccmn X17, #1, #15, LT
ccmn X17, #31, #15, LT
ccmn X17, X29, #0, GT
ccmn X17, #0, #0, GT
ccmn X17, #1, #0, GT
ccmn X17, #31, #0, GT
ccmn X17, X29, #5, GT
ccmn X17, #0, #5, GT
ccmn X17, #1, #5, GT
ccmn X17, #31, #5, GT
ccmn X17, X29, #15, GT
ccmn X17, #0, #15, GT
ccmn X17, #1, #15, GT
ccmn X17, #31, #15, GT
ccmn X17, X29, #0, AL
ccmn X17, #0, #0, AL
ccmn X17, #1, #0, AL
ccmn X17, #31, #0, AL
ccmn X17, X29, #5, AL
ccmn X17, #0, #5, AL
ccmn X17, #1, #5, AL
ccmn X17, #31, #5, AL
ccmn X17, X29, #15, AL
ccmn X17, #0, #15, AL
ccmn X17, #1, #15, AL
ccmn X17, #31, #15, AL
ccmn X17, X29, #0, NV
ccmn X17, #0, #0, NV
ccmn X17, #1, #0, NV
ccmn X17, #31, #0, NV
ccmn X17, X29, #5, NV
ccmn X17, #0, #5, NV
ccmn X17, #1, #5, NV
ccmn X17, #31, #5, NV
ccmn X17, X29, #15, NV
ccmn X17, #0, #15, NV
ccmn X17, #1, #15, NV
ccmn X17, #31, #15, NV
ccmp X17, X29, #0, EQ
ccmp X17, #0, #0, EQ
ccmp X17, #1, #0, EQ
ccmp X17, #31, #0, EQ
ccmp X17, X29, #5, EQ
ccmp X17, #0, #5, EQ
ccmp X17, #1, #5, EQ
ccmp X17, #31, #5, EQ
ccmp X17, X29, #15, EQ
ccmp X17, #0, #15, EQ
ccmp X17, #1, #15, EQ
ccmp X17, #31, #15, EQ
ccmp X17, X29, #0, NE
ccmp X17, #0, #0, NE
ccmp X17, #1, #0, NE
ccmp X17, #31, #0, NE
ccmp X17, X29, #5, NE
ccmp X17, #0, #5, NE
ccmp X17, #1, #5, NE
ccmp X17, #31, #5, NE
ccmp X17, X29, #15, NE
ccmp X17, #0, #15, NE
ccmp X17, #1, #15, NE
ccmp X17, #31, #15, NE
ccmp X17, X29, #0, LT
ccmp X17, #0, #0, LT
ccmp X17, #1, #0, LT
ccmp X17, #31, #0, LT
ccmp X17, X29, #5, LT
ccmp X17, #0, #5, LT
ccmp X17, #1, #5, LT
ccmp X17, #31, #5, LT
ccmp X17, X29, #15, LT
ccmp X17, #0, #15, LT
ccmp X17, #1, #15, LT
ccmp X17, #31, #15, LT
ccmp X17, X29, #0, GT
ccmp X17, #0, #0, GT
ccmp X17, #1, #0, GT
ccmp X17, #31, #0, GT
ccmp X17, X29, #5, GT
ccmp X17, #0, #5, GT
ccmp X17, #1, #5, GT
ccmp X17, #31, #5, GT
ccmp X17, X29, #15, GT
ccmp X17, #0, #15, GT
ccmp X17, #1, #15, GT
ccmp X17, #31, #15, GT
ccmp X17, X29, #0, AL
ccmp X17, #0, #0, AL
ccmp X17, #1, #0, AL
ccmp X17, #31, #0, AL
ccmp X17, X29, #5, AL
ccmp X17, #0, #5, AL
ccmp X17, #1, #5, AL
ccmp X17, #31, #5, AL
ccmp X17, X29, #15, AL
ccmp X17, #0, #15, AL
ccmp X17, #1, #15, AL
ccmp X17, #31, #15, AL
ccmp X17, X29, #0, NV
ccmp X17, #0, #0, NV
ccmp X17, #1, #0, NV
ccmp X17, #31, #0, NV
ccmp X17, X29, #5, NV
ccmp X17, #0, #5, NV
ccmp X17, #1, #5, NV
ccmp X17, #31, #5, NV
ccmp X17, X29, #15, NV
ccmp X17, #0, #15, NV
ccmp X17, #1, #15, NV
ccmp X17, #31, #15, NV
movn X30, #0, lsl #0
movn X30, #1, lsl #0
movn X30, #65535, lsl #0
movn X30, #0, lsl #16
movn X30, #1, lsl #16
movn X30, #65535, lsl #16
movn X30, #0, lsl #32
movn X30, #1, lsl #32
movn X30, #65535, lsl #32
movn X30, #0, lsl #48
movn X30, #1, lsl #48
movn X30, #65535, lsl #48
movz X30, #0, lsl #0
movz X30, #1, lsl #0
movz X30, #65535, lsl #0
movz X30, #0, lsl #16
movz X30, #1, lsl #16
movz X30, #65535, lsl #16
movz X30, #0, lsl #32
movz X30, #1, lsl #32
movz X30, #65535, lsl #32
movz X30, #0, lsl #48
movz X30, #1, lsl #48
movz X30, #65535, lsl #48
movk X30, #0, lsl #0
movk X30, #1, lsl #0
movk X30, #65535, lsl #0
movk X30, #0, lsl #16
movk X30, #1, lsl #16
movk X30, #65535, lsl #16
movk X30, #0, lsl #32
movk X30, #1, lsl #32
movk X30, #65535, lsl #32
movk X30, #0, lsl #48
movk X30, #1, lsl #48
movk X30, #65535, lsl #48
and X30, X17, #1
and X30, X17, #255
and X30, X17, #18374966859414961920
and X30, X17, #18446744073709551614
and X30, X17, #18446744073709551600
orr X30, X17, #1
orr X30, X17, #255
orr X30, X17, #18374966859414961920
orr X30, X17, #18446744073709551614
orr X30, X17, #18446744073709551600
eor X30, X17, #1
eor X30, X17, #255
eor X30, X17, #18374966859414961920
eor X30, X17, #18446744073709551614
eor X30, X17, #18446744073709551600
ands X30, X17, #1
ands X30, X17, #255
ands X30, X17, #18374966859414961920
ands X30, X17, #18446744073709551614
ands X30, X17, #18446744073709551600
add X30, X17, X29, LSL #0
add X30, X17, X29, LSL #1
add X30, X17, X29, LSL #63
add X30, X17, X29, LSR #0
add X30, X17, X29, LSR #1
add X30, X17, X29, LSR #63
add X30, X17, X29, ASR #0
add X30, X17, X29, ASR #1
add X30, X17, X29, ASR #63
adds X30, X17, X29, LSL #0
adds X30, X17, X29, LSL #1
adds X30, X17, X29, LSL #63
adds X30, X17, X29, LSR #0
adds X30, X17, X29, LSR #1
adds X30, X17, X29, LSR #63
adds X30, X17, X29, ASR #0
adds X30, X17, X29, ASR #1
adds X30, X17, X29, ASR #63
sub X30, X17, X29, LSL #0
sub X30, X17, X29, LSL #1
sub X30, X17, X29, LSL #63
sub X30, X17, X29, LSR #0
sub X30, X17, X29, LSR #1
sub X30, X17, X29, LSR #63
sub X30, X17, X29, ASR #0
sub X30, X17, X29, ASR #1
sub X30, X17, X29, ASR #63
subs X30, X17, X29, LSL #0
subs X30, X17, X29, LSL #1
subs X30, X17, X29, LSL #63
subs X30, X17, X29, LSR #0
subs X30, X17, X29, LSR #1
subs X30, X17, X29, LSR #63
subs X30, X17, X29, ASR #0
subs X30, X17, X29, ASR #1
subs X30, X17, X29, ASR #63
and X30, X17, X29, LSL #0
and X30, X17, X29, LSL #1
and X30, X17, X29, LSL #63
and X30, X17, X29, LSR #0
and X30, X17, X29, LSR #1
and X30, X17, X29, LSR #63
and X30, X17, X29, ASR #0
and X30, X17, X29, ASR #1
and X30, X17, X29, ASR #63
and X30, X17, X29, ROR #0
and X30, X17, X29, ROR #1
and X30, X17, X29, ROR #63
bic X30, X17, X29, LSL #0
bic X30, X17, X29, LSL #1
bic X30, X17, X29, LSL #63
bic X30, X17, X29, LSR #0
bic X30, X17, X29, LSR #1
bic X30, X17, X29, LSR #63
bic X30, X17, X29, ASR #0
bic X30, X17, X29, ASR #1
bic X30, X17, X29, ASR #63
bic X30, X17, X29, ROR #0
bic X30, X17, X29, ROR #1
bic X30, X17, X29, ROR #63
orr X30, X17, X29, LSL #0
orr X30, X17, X29, LSL #1
orr X30, X17, X29, LSL #63
orr X30, X17, X29, LSR #0
orr X30, X17, X29, LSR #1
orr X30, X17, X29, LSR #63
orr X30, X17, X29, ASR #0
orr X30, X17, X29, ASR #1
orr X30, X17, X29, ASR #63
orr X30, X17, X29, ROR #0
orr X30, X17, X29, ROR #1
orr X30, X17, X29, ROR #63
orn X30, X17, X29, LSL #0
orn X30, X17, X29, LSL #1
orn X30, X17, X29, LSL #63
orn X30, X17, X29, LSR #0
orn X30, X17, X29, LSR #1
orn X30, X17, X29, LSR #63
orn X30, X17, X29, ASR #0
orn X30, X17, X29, ASR #1
orn X30, X17, X29, ASR #63
orn X30, X17, X29, ROR #0
orn X30, X17, X29, ROR #1
orn X30, X17, X29, ROR #63
eor X30, X17, X29, LSL #0
eor X30, X17, X29, LSL #1
eor X30, X17, X29, LSL #63
eor X30, X17, X29, LSR #0
eor X30, X17, X29, LSR #1
eor X30, X17, X29, LSR #63
eor X30, X17, X29, ASR #0
eor X30, X17, X29, ASR #1
eor X30, X17, X29, ASR #63
eor X30, X17, X29, ROR #0
eor X30, X17, X29, ROR #1
eor X30, X17, X29, ROR #63
eon X30, X17, X29, LSL #0
eon X30, X17, X29, LSL #1
eon X30, X17, X29, LSL #63
eon X30, X17, X29, LSR #0
eon X30, X17, X29, LSR #1
eon X30, X17, X29, LSR #63
eon X30, X17, X29, ASR #0
eon X30, X17, X29, ASR #1
eon X30, X17, X29, ASR #63
eon X30, X17, X29, ROR #0
eon X30, X17, X29, ROR #1
eon X30, X17, X29, ROR #63
ands X30, X17, X29, LSL #0
ands X30, X17, X29, LSL #1
ands X30, X17, X29, LSL #63
ands X30, X17, X29, LSR #0
ands X30, X17, X29, LSR #1
ands X30, X17, X29, LSR #63
ands X30, X17, X29, ASR #0
ands X30, X17, X29, ASR #1
ands X30, X17, X29, ASR #63
ands X30, X17, X29, ROR #0
ands X30, X17, X29, ROR #1
ands X30, X17, X29, ROR #63
bics X30, X17, X29, LSL #0
bics X30, X17, X29, LSL #1
bics X30, X17, X29, LSL #63
bics X30, X17, X29, LSR #0
bics X30, X17, X29, LSR #1
bics X30, X17, X29, LSR #63
bics X30, X17, X29, ASR #0
bics X30, X17, X29, ASR #1
bics X30, X17, X29, ASR #63
bics X30, X17, X29, ROR #0
bics X30, X17, X29, ROR #1
bics X30, X17, X29, ROR #63
adc XZR, XZR, XZR
adcs XZR, XZR, XZR
sbc XZR, XZR, XZR
sbcs XZR, XZR, XZR
udiv XZR, XZR, XZR
sdiv XZR, XZR, XZR
add XZR, XZR, XZR
adds XZR, XZR, XZR
sub XZR, XZR, XZR
subs XZR, XZR, XZR
and XZR, XZR, XZR
bic XZR, XZR, XZR
orr XZR, XZR, XZR
orn XZR, XZR, XZR
eor XZR, XZR, XZR
eon XZR, XZR, XZR
ands XZR, XZR, XZR
bics XZR, XZR, XZR
ngc XZR, XZR
ngcs XZR, XZR
neg XZR, XZR
negs XZR, XZR
mvn XZR, XZR
rbit XZR, XZR
rev16 XZR, XZR
rev XZR, XZR
clz XZR, XZR
cls XZR, XZR
rev32 XZR, XZR
madd XZR, XZR, XZR, XZR
msub XZR, XZR, XZR, XZR
mul XZR, XZR, XZR
mneg XZR, XZR, XZR
lsl XZR, XZR, XZR
lsl XZR, XZR, #0
lsl XZR, XZR, #1
lsl XZR, XZR, #63
lsr XZR, XZR, XZR
lsr XZR, XZR, #0
lsr XZR, XZR, #1
lsr XZR, XZR, #63
asr XZR, XZR, XZR
asr XZR, XZR, #0
asr XZR, XZR, #1
asr XZR, XZR, #63
ror XZR, XZR, XZR
ror XZR, XZR, #0
ror XZR, XZR, #1
ror XZR, XZR, #63
extr XZR, XZR, XZR, #0
extr XZR, XZR, XZR, #1
extr XZR, XZR, XZR, #63
sbfm XZR, XZR, #0, #0
sbfm XZR, XZR, #0, #1
sbfm XZR, XZR, #0, #63
sbfm XZR, XZR, #1, #0
sbfm XZR, XZR, #1, #1
sbfm XZR, XZR, #1, #63
sbfm XZR, XZR, #63, #0
sbfm XZR, XZR, #63, #1
sbfm XZR, XZR, #63, #63
bfm XZR, XZR, #0, #0
bfm XZR, XZR, #0, #1
bfm XZR, XZR, #0, #63
bfm XZR, XZR, #1, #0
bfm XZR, XZR, #1, #1
bfm XZR, XZR, #1, #63
bfm XZR, XZR, #63, #0
bfm XZR, XZR, #63, #1
bfm XZR, XZR, #63, #63
ubfm XZR, XZR, #0, #0
ubfm XZR, XZR, #0, #1
ubfm XZR, XZR, #0, #63
ubfm XZR, XZR, #1, #0
ubfm XZR, XZR, #1, #1
ubfm XZR, XZR, #1, #63
ubfm XZR, XZR, #63, #0
ubfm XZR, XZR, #63, #1
ubfm XZR, XZR, #63, #63
sbfx XZR, XZR, #0, #64
sbfx XZR, XZR, #0, #1
sbfx XZR, XZR, #1, #63
sbfx XZR, XZR, #63, #1
ubfx XZR, XZR, #0, #64
ubfx XZR, XZR, #0, #1
ubfx XZR, XZR, #1, #63
ubfx XZR, XZR, #63, #1
bfxil XZR, XZR, #0, #64
bfxil XZR, XZR, #0, #1
bfxil XZR, XZR, #1, #63
bfxil XZR, XZR, #63, #1
sbfiz XZR, XZR, #0, #64
sbfiz XZR, XZR, #0, #1
sbfiz XZR, XZR, #1, #63
sbfiz XZR, XZR, #63, #1
ubfiz XZR, XZR, #0, #64
ubfiz XZR, XZR, #0, #1
ubfiz XZR, XZR, #1, #63
ubfiz XZR, XZR, #63, #1
bfi XZR, XZR, #0, #64
bfi XZR, XZR, #0, #1
bfi XZR, XZR, #1, #63
bfi XZR, XZR, #63, #1
csel XZR, XZR, XZR, EQ
csel XZR, XZR, XZR, NE
csel XZR, XZR, XZR, LT
csel XZR, XZR, XZR, GT
csel XZR, XZR, XZR, AL
csel XZR, XZR, XZR, NV
csinc XZR, XZR, XZR, EQ
csinc XZR, XZR, XZR, NE
csinc XZR, XZR, XZR, LT
csinc XZR, XZR, XZR, GT
csinc XZR, XZR, XZR, AL
csinc XZR, XZR, XZR, NV
csinv XZR, XZR, XZR, EQ
csinv XZR, XZR, XZR, NE
csinv XZR, XZR, XZR, LT
csinv XZR, XZR, XZR, GT
csinv XZR, XZR, XZR, AL
csinv XZR, XZR, XZR, NV
csneg XZR, XZR, XZR, EQ
csneg XZR, XZR, XZR, NE
csneg XZR, XZR, XZR, LT
csneg XZR, XZR, XZR, GT
csneg XZR, XZR, XZR, AL
csneg XZR, XZR, XZR, NV
ccmn XZR, XZR, #0, EQ
ccmn XZR, #0, #0, EQ
ccmn XZR, #1, #0, EQ
ccmn XZR, #31, #0, EQ
ccmn XZR, XZR, #5, EQ
ccmn XZR, #0, #5, EQ
ccmn XZR, #1, #5, EQ
ccmn XZR, #31, #5, EQ
ccmn XZR, XZR, #15, EQ
ccmn XZR, #0, #15, EQ
ccmn XZR, #1, #15, EQ
ccmn XZR, #31, #15, EQ
ccmn XZR, XZR, #0, NE
ccmn XZR, #0, #0, NE
ccmn XZR, #1, #0, NE
ccmn XZR, #31, #0, NE
ccmn XZR, XZR, #5, NE
ccmn XZR, #0, #5, NE
ccmn XZR, #1, #5, NE
ccmn XZR, #31, #5, NE
ccmn XZR, XZR, #15, NE
ccmn XZR, #0, #15, NE
ccmn XZR, #1, #15, NE
ccmn XZR, #31, #15, NE
ccmn XZR, XZR, #0, LT
ccmn XZR, #0, #0, LT
ccmn XZR, #1, #0, LT
ccmn XZR, #31, #0, LT
ccmn XZR, XZR, #5, LT
ccmn XZR, #0, #5, LT
ccmn XZR, #1, #5, LT
ccmn XZR, #31, #5, LT
ccmn XZR, XZR, #15, LT
ccmn XZR, #0, #15, LT
ccmn XZR, #1, #15, LT
ccmn XZR, #31, #15, LT
ccmn XZR, XZR, #0, GT
ccmn XZR, #0, #0, GT
ccmn XZR, #1, #0, GT
ccmn XZR, #31, #0, GT
ccmn XZR, XZR, #5, GT
ccmn XZR, #0, #5, GT
ccmn XZR, #1, #5, GT
ccmn XZR, #31, #5, GT
ccmn XZR, XZR, #15, GT
ccmn XZR, #0, #15, GT
ccmn XZR, #1, #15, GT
ccmn XZR, #31, #15, GT
ccmn XZR, XZR, #0, AL
ccmn XZR, #0, #0, AL
ccmn XZR, #1, #0, AL
ccmn XZR, #31, #0, AL
ccmn XZR, XZR, #5, AL
ccmn XZR, #0, #5, AL
ccmn XZR, #1, #5, AL
ccmn XZR, #31, #5, AL
ccmn XZR, XZR, #15, AL
ccmn XZR, #0, #15, AL
ccmn XZR, #1, #15, AL
ccmn XZR, #31, #15, AL
ccmn XZR, XZR, #0, NV
ccmn XZR, #0, #0, NV
ccmn XZR, #1, #0, NV
ccmn XZR, #31, #0, NV
ccmn XZR, XZR, #5, NV
ccmn XZR, #0, #5, NV
ccmn XZR, #1, #5, NV
ccmn XZR, #31, #5, NV
ccmn XZR, XZR, #15, NV
ccmn XZR, #0, #15, NV
ccmn XZR, #1, #15, NV
ccmn XZR, #31, #15, NV
ccmp XZR, XZR, #0, EQ
ccmp XZR, #0, #0, EQ
ccmp XZR, #1, #0, EQ
ccmp XZR, #31, #0, EQ
ccmp XZR, XZR, #5, EQ
ccmp XZR, #0, #5, EQ
ccmp XZR, #1, #5, EQ
ccmp XZR, #31, #5, EQ
ccmp XZR, XZR, #15, EQ
ccmp XZR, #0, #15, EQ
ccmp XZR, #1, #15, EQ
ccmp XZR, #31, #15, EQ
ccmp XZR, XZR, #0, NE
ccmp XZR, #0, #0, NE
ccmp XZR, #1, #0, NE
ccmp XZR, #31, #0, NE
ccmp XZR, XZR, #5, NE
ccmp XZR, #0, #5, NE
ccmp XZR, #1, #5, NE
ccmp XZR, #31, #5, NE
ccmp XZR, XZR, #15, NE
ccmp XZR, #0, #15, NE
ccmp XZR, #1, #15, NE
ccmp XZR, #31, #15, NE
ccmp XZR, XZR, #0, LT
ccmp XZR, #0, #0, LT
ccmp XZR, #1, #0, LT
ccmp XZR, #31, #0, LT
ccmp XZR, XZR, #5, LT
ccmp XZR, #0, #5, LT
ccmp XZR, #1, #5, LT
ccmp XZR, #31, #5, LT
ccmp XZR, XZR, #15, LT
ccmp XZR, #0, #15, LT
ccmp XZR, #1, #15, LT
ccmp XZR, #31, #15, LT
ccmp XZR, XZR, #0, GT
ccmp XZR, #0, #0, GT
ccmp XZR, #1, #0, GT
ccmp XZR, #31, #0, GT
ccmp XZR, XZR, #5, GT
ccmp XZR, #0, #5, GT
ccmp XZR, #1, #5, GT
ccmp XZR, #31, #5, GT
ccmp XZR, XZR, #15, GT
ccmp XZR, #0, #15, GT
ccmp XZR, #1, #15, GT
ccmp XZR, #31, #15, GT
ccmp XZR, XZR, #0, AL
ccmp XZR, #0, #0, AL
ccmp XZR, #1, #0, AL
ccmp XZR, #31, #0, AL
ccmp XZR, XZR, #5, AL
ccmp XZR, #0, #5, AL
ccmp XZR, #1, #5, AL
ccmp XZR, #31, #5, AL
ccmp XZR, XZR, #15, AL
ccmp XZR, #0, #15, AL
ccmp XZR, #1, #15, AL
ccmp XZR, #31, #15, AL
ccmp XZR, XZR, #0, NV
ccmp XZR, #0, #0, NV
ccmp XZR, #1, #0, NV
ccmp XZR, #31, #0, NV
ccmp XZR, XZR, #5, NV
ccmp XZR, #0, #5, NV
ccmp XZR, #1, #5, NV
ccmp XZR, #31, #5, NV
ccmp XZR, XZR, #15, NV
ccmp XZR, #0, #15, NV
ccmp XZR, #1, #15, NV
ccmp XZR, #31, #15, NV
movn XZR, #0, lsl #0
movn XZR, #1, lsl #0
movn XZR, #65535, lsl #0
movn XZR, #0, lsl #16
movn XZR, #1, lsl #16
movn XZR, #65535, lsl #16
movn XZR, #0, lsl #32
movn XZR, #1, lsl #32
movn XZR, #65535, lsl #32
movn XZR, #0, lsl #48
movn XZR, #1, lsl #48
movn XZR, #65535, lsl #48
movz XZR, #0, lsl #0
movz XZR, #1, lsl #0
movz XZR, #65535, lsl #0
movz XZR, #0, lsl #16
movz XZR, #1, lsl #16
movz XZR, #65535, lsl #16
movz XZR, #0, lsl #32
movz XZR, #1, lsl #32
movz XZR, #65535, lsl #32
movz XZR, #0, lsl #48
movz XZR, #1, lsl #48
movz XZR, #65535, lsl #48
movk XZR, #0, lsl #0
movk XZR, #1, lsl #0
movk XZR, #65535, lsl #0
movk XZR, #0, lsl #16
movk XZR, #1, lsl #16
movk XZR, #65535, lsl #16
movk XZR, #0, lsl #32
movk XZR, #1, lsl #32
movk XZR, #65535, lsl #32
movk XZR, #0, lsl #48
movk XZR, #1, lsl #48
movk XZR, #65535, lsl #48
and SP, XZR, #1
and SP, XZR, #255
and SP, XZR, #18374966859414961920
and SP, XZR, #18446744073709551614
and SP, XZR, #18446744073709551600
orr SP, XZR, #1
orr SP, XZR, #255
orr SP, XZR, #18374966859414961920
orr SP, XZR, #18446744073709551614
orr SP, XZR, #18446744073709551600
eor SP, XZR, #1
eor SP, XZR, #255
eor SP, XZR, #18374966859414961920
eor SP, XZR, #18446744073709551614
eor SP, XZR, #18446744073709551600
ands XZR, XZR, #1
ands XZR, XZR, #255
ands XZR, XZR, #18374966859414961920
ands XZR, XZR, #18446744073709551614
ands XZR, XZR, #18446744073709551600
add XZR, XZR, XZR, LSL #0
add XZR, XZR, XZR, LSL #1
add XZR, XZR, XZR, LSL #63
add XZR, XZR, XZR, LSR #0
add XZR, XZR, XZR, LSR #1
add XZR, XZR, XZR, LSR #63
add XZR, XZR, XZR, ASR #0
add XZR, XZR, XZR, ASR #1
add XZR, XZR, XZR, ASR #63
adds XZR, XZR, XZR, LSL #0
adds XZR, XZR, XZR, LSL #1
adds XZR, XZR, XZR, LSL #63
adds XZR, XZR, XZR, LSR #0
adds XZR, XZR, XZR, LSR #1
adds XZR, XZR, XZR, LSR #63
adds XZR, XZR, XZR, ASR #0
adds XZR, XZR, XZR, ASR #1
adds XZR, XZR, XZR, ASR #63
sub XZR, XZR, XZR, LSL #0
sub XZR, XZR, XZR, LSL #1
sub XZR, XZR, XZR, LSL #63
sub XZR, XZR, XZR, LSR #0
sub XZR, XZR, XZR, LSR #1
sub XZR, XZR, XZR, LSR #63
sub XZR, XZR, XZR, ASR #0
sub XZR, XZR, XZR, ASR #1
sub XZR, XZR, XZR, ASR #63
subs XZR, XZR, XZR, LSL #0
subs XZR, XZR, XZR, LSL #1
subs XZR, XZR, XZR, LSL #63
subs XZR, XZR, XZR, LSR #0
subs XZR, XZR, XZR, LSR #1
subs XZR, XZR, XZR, LSR #63
subs XZR, XZR, XZR, ASR #0
subs XZR, XZR, XZR, ASR #1
subs XZR, XZR, XZR, ASR #63
and XZR, XZR, XZR, LSL #0
and XZR, XZR, XZR, LSL #1
and XZR, XZR, XZR, LSL #63
and XZR, XZR, XZR, LSR #0
and XZR, XZR, XZR, LSR #1
and XZR, XZR, XZR, LSR #63
and XZR, XZR, XZR, ASR #0
and XZR, XZR, XZR, ASR #1
and XZR, XZR, XZR, ASR #63
and XZR, XZR, XZR, ROR #0
and XZR, XZR, XZR, ROR #1
and XZR, XZR, XZR, ROR #63
bic XZR, XZR, XZR, LSL #0
bic XZR, XZR, XZR, LSL #1
bic XZR, XZR, XZR, LSL #63
bic XZR, XZR, XZR, LSR #0
bic XZR, XZR, XZR, LSR #1
bic XZR, XZR, XZR, LSR #63
bic XZR, XZR, XZR, ASR #0
bic XZR, XZR, XZR, ASR #1
bic XZR, XZR, XZR, ASR #63
bic XZR, XZR, XZR, ROR #0
bic XZR, XZR, XZR, ROR #1
bic XZR, XZR, XZR, ROR #63
orr XZR, XZR, XZR, LSL #0
orr XZR, XZR, XZR, LSL #1
orr XZR, XZR, XZR, LSL #63
orr XZR, XZR, XZR, LSR #0
orr XZR, XZR, XZR, LSR #1
orr XZR, XZR, XZR, LSR #63
orr XZR, XZR, XZR, ASR #0
orr XZR, XZR, XZR, ASR #1
orr XZR, XZR, XZR, ASR #63
orr XZR, XZR, XZR, ROR #0
orr XZR, XZR, XZR, ROR #1
orr XZR, XZR, XZR, ROR #63
orn XZR, XZR, XZR, LSL #0
orn XZR, XZR, XZR, LSL #1
orn XZR, XZR, XZR, LSL #63
orn XZR, XZR, XZR, LSR #0
orn XZR, XZR, XZR, LSR #1
orn XZR, XZR, XZR, LSR #63
orn XZR, XZR, XZR, ASR #0
orn XZR, XZR, XZR, ASR #1
orn XZR, XZR, XZR, ASR #63
orn XZR, XZR, XZR, ROR #0
orn XZR, XZR, XZR, ROR #1
orn XZR, XZR, XZR, ROR #63
eor XZR, XZR, XZR, LSL #0
eor XZR, XZR, XZR, LSL #1
eor XZR, XZR, XZR, LSL #63
eor XZR, XZR, XZR, LSR #0
eor XZR, XZR, XZR, LSR #1
eor XZR, XZR, XZR, LSR #63
eor XZR, XZR, XZR, ASR #0
eor XZR, XZR, XZR, ASR #1
eor XZR, XZR, XZR, ASR #63
eor XZR, XZR, XZR, ROR #0
eor XZR, XZR, XZR, ROR #1
eor XZR, XZR, XZR, ROR #63
eon XZR, XZR, XZR, LSL #0
eon XZR, XZR, XZR, LSL #1
eon XZR, XZR, XZR, LSL #63
eon XZR, XZR, XZR, LSR #0
eon XZR, XZR, XZR, LSR #1
eon XZR, XZR, XZR, LSR #63
eon XZR, XZR, XZR, ASR #0
eon XZR, XZR, XZR, ASR #1
eon XZR, XZR, XZR, ASR #63
eon XZR, XZR, XZR, ROR #0
eon XZR, XZR, XZR, ROR #1
eon XZR, XZR, XZR, ROR #63
ands XZR, XZR, XZR, LSL #0
ands XZR, XZR, XZR, LSL #1
ands XZR, XZR, XZR, LSL #63
ands XZR, XZR, XZR, LSR #0
ands XZR, XZR, XZR, LSR #1
ands XZR, XZR, XZR, LSR #63
ands XZR, XZR, XZR, ASR #0
ands XZR, XZR, XZR, ASR #1
ands XZR, XZR, XZR, ASR #63
ands XZR, XZR, XZR, ROR #0
ands XZR, XZR, XZR, ROR #1
ands XZR, XZR, XZR, ROR #63
bics XZR, XZR, XZR, LSL #0
bics XZR, XZR, XZR, LSL #1
bics XZR, XZR, XZR, LSL #63
bics XZR, XZR, XZR, LSR #0
bics XZR, XZR, XZR, LSR #1
bics XZR, XZR, XZR, LSR #63
bics XZR, XZR, XZR, ASR #0
bics XZR, XZR, XZR, ASR #1
bics XZR, XZR, XZR, ASR #63
bics XZR, XZR, XZR, ROR #0
bics XZR, XZR, XZR, ROR #1
bics XZR, XZR, XZR, ROR #63
add X0, SP, W2, UXTB #0
add SP, SP, W2, UXTB #0
add X0, SP, W2, UXTB #4
add SP, SP, W2, UXTB #4
add X0, SP, W2, UXTH #0
add SP, SP, W2, UXTH #0
add X0, SP, W2, UXTH #4
add SP, SP, W2, UXTH #4
add X0, SP, W2, UXTW #0
add SP, SP, W2, UXTW #0
add X0, SP, W2, UXTW #4
add SP, SP, W2, UXTW #4
add X0, SP, W2, SXTB #0
add SP, SP, W2, SXTB #0
add X0, SP, W2, SXTB #4
add SP, SP, W2, SXTB #4
add X0, SP, W2, SXTH #0
add SP, SP, W2, SXTH #0
add X0, SP, W2, SXTH #4
add SP, SP, W2, SXTH #4
add X0, SP, W2, SXTW #0
add SP, SP, W2, SXTW #0
add X0, SP, W2, SXTW #4
add SP, SP, W2, SXTW #4
add X0, SP, X2, UXTX #0
add SP, SP, X2, UXTX #0
add X0, SP, X2, UXTX #4
add SP, SP, X2, UXTX #4
add X0, SP, X2, SXTX #0
add SP, SP, X2, SXTX #0
add X0, SP, X2, SXTX #4
add SP, SP, X2, SXTX #4
adds X0, SP, W2, UXTB #0
adds XZR, SP, W2, UXTB #0
adds X0, SP, W2, UXTB #4
adds XZR, SP, W2, UXTB #4
adds X0, SP, W2, UXTH #0
adds XZR, SP, W2, UXTH #0
adds X0, SP, W2, UXTH #4
adds XZR, SP, W2, UXTH #4
adds X0, SP, W2, UXTW #0
adds XZR, SP, W2, UXTW #0
adds X0, SP, W2, UXTW #4
adds XZR, SP, W2, UXTW #4
adds X0, SP, W2, SXTB #0
adds XZR, SP, W2, SXTB #0
adds X0, SP, W2, SXTB #4
adds XZR, SP, W2, SXTB #4
adds X0, SP, W2, SXTH #0
adds XZR, SP, W2, SXTH #0
adds X0, SP, W2, SXTH #4
adds XZR, SP, W2, SXTH #4
adds X0, SP, W2, SXTW #0
adds XZR, SP, W2, SXTW #0
adds X0, SP, W2, SXTW #4
adds XZR, SP, W2, SXTW #4
adds X0, SP, X2, UXTX #0
adds XZR, SP, X2, UXTX #0
adds X0, SP, X2, UXTX #4
adds XZR, SP, X2, UXTX #4
adds X0, SP, X2, SXTX #0
adds XZR, SP, X2, SXTX #0
adds X0, SP, X2, SXTX #4
adds XZR, SP, X2, SXTX #4
sub X0, SP, W2, UXTB #0
sub SP, SP, W2, UXTB #0
sub X0, SP, W2, UXTB #4
sub SP, SP, W2, UXTB #4
sub X0, SP, W2, UXTH #0
sub SP, SP, W2, UXTH #0
sub X0, SP, W2, UXTH #4
sub SP, SP, W2, UXTH #4
sub X0, SP, W2, UXTW #0
sub SP, SP, W2, UXTW #0
sub X0, SP, W2, UXTW #4
sub SP, SP, W2, UXTW #4
sub X0, SP, W2, SXTB #0
sub SP, SP, W2, SXTB #0
sub X0, SP, W2, SXTB #4
sub SP, SP, W2, SXTB #4
sub X0, SP, W2, SXTH #0
sub SP, SP, W2, SXTH #0
sub X0, SP, W2, SXTH #4
sub SP, SP, W2, SXTH #4
sub X0, SP, W2, SXTW #0
sub SP, SP, W2, SXTW #0
sub X0, SP, W2, SXTW #4
sub SP, SP, W2, SXTW #4
sub X0, SP, X2, UXTX #0
sub SP, SP, X2, UXTX #0
sub X0, SP, X2, UXTX #4
sub SP, SP, X2, UXTX #4
sub X0, SP, X2, SXTX #0
sub SP, SP, X2, SXTX #0
sub X0, SP, X2, SXTX #4
sub SP, SP, X2, SXTX #4
subs X0, SP, W2, UXTB #0
subs XZR, SP, W2, UXTB #0
subs X0, SP, W2, UXTB #4
subs XZR, SP, W2, UXTB #4
subs X0, SP, W2, UXTH #0
subs XZR, SP, W2, UXTH #0
subs X0, SP, W2, UXTH #4
subs XZR, SP, W2, UXTH #4
subs X0, SP, W2, UXTW #0
subs XZR, SP, W2, UXTW #0
subs X0, SP, W2, UXTW #4
subs XZR, SP, W2, UXTW #4
subs X0, SP, W2, SXTB #0
subs XZR, SP, W2, SXTB #0
subs X0, SP, W2, SXTB #4
subs XZR, SP, W2, SXTB #4
subs X0, SP, W2, SXTH #0
subs XZR, SP, W2, SXTH #0
subs X0, SP, W2, SXTH #4
subs XZR, SP, W2, SXTH #4
subs X0, SP, W2, SXTW #0
subs XZR, SP, W2, SXTW #0
subs X0, SP, W2, SXTW #4
subs XZR, SP, W2, SXTW #4
subs X0, SP, X2, UXTX #0
subs XZR, SP, X2, UXTX #0
subs X0, SP, X2, UXTX #4
subs XZR, SP, X2, UXTX #4
subs X0, SP, X2, SXTX #0
subs XZR, SP, X2, SXTX #0
subs X0, SP, X2, SXTX #4
subs XZR, SP, X2, SXTX #4
smaddl X0, W1, W2, X3
smsubl X0, W1, W2, X3
umaddl X0, W1, W2, X3
umsubl X0, W1, W2, X3
smull X0, W1, W2
smnegl X0, W1, W2
umull X0, W1, W2
umnegl X0, W1, W2
smulh X0, X1, X2
umulh X0, X1, X2
smaddl X30, W17, W29, X11
smsubl X30, W17, W29, X11
umaddl X30, W17, W29, X11
umsubl X30, W17, W29, X11
smull X30, W17, W29
smnegl X30, W17, W29
umull X30, W17, W29
umnegl X30, W17, W29
smulh X30, X17, X29
umulh X30, X17, X29
smaddl XZR, WZR, WZR, XZR
smsubl XZR, WZR, WZR, XZR
umaddl XZR, WZR, WZR, XZR
umsubl XZR, WZR, WZR, XZR
smull XZR, WZR, WZR
smnegl XZR, WZR, WZR
umull XZR, WZR, WZR
umnegl XZR, WZR, WZR
smulh XZR, XZR, XZR
umulh XZR, XZR, XZR
and W13, W27, #1
and W13, W27, #2
and W13, W27, #3
and W13, W27, #4
and W13, W27, #6
and W13, W27, #7
and W13, W27, #8
and W13, W27, #12
and W13, W27, #14
and W13, W27, #15
and W13, W27, #16
and W13, W27, #24
and W13, W27, #28
and W13, W27, #30
and W13, W27, #31
and W13, W27, #32
and W13, W27, #48
and W13, W27, #56
and W13, W27, #60
and W13, W27, #62
and W13, W27, #63
and W13, W27, #64
and W13, W27, #96
and W13, W27, #112
and W13, W27, #120
and W13, W27, #124
and W13, W27, #126
and W13, W27, #127
and W13, W27, #128
and W13, W27, #192
and W13, W27, #224
and W13, W27, #240
and W13, W27, #248
and W13, W27, #252
and W13, W27, #254
and W13, W27, #255
and W13, W27, #256
and W13, W27, #384
and W13, W27, #448
and W13, W27, #480
and W13, W27, #496
and W13, W27, #504
and W13, W27, #508
and W13, W27, #510
and W13, W27, #511
and W13, W27, #512
and W13, W27, #768
and W13, W27, #896
and W13, W27, #960
and W13, W27, #992
and W13, W27, #1008
and W13, W27, #1016
and W13, W27, #1020
and W13, W27, #1022
and W13, W27, #1023
and W13, W27, #1024
and W13, W27, #1536
and W13, W27, #1792
and W13, W27, #1920
and W13, W27, #1984
and W13, W27, #2016
and W13, W27, #2032
and W13, W27, #2040
and W13, W27, #2044
and W13, W27, #2046
and W13, W27, #2047
and W13, W27, #2048
and W13, W27, #3072
and W13, W27, #3584
and W13, W27, #3840
and W13, W27, #3968
and W13, W27, #4032
and W13, W27, #4064
and W13, W27, #4080
and W13, W27, #4088
and W13, W27, #4092
and W13, W27, #4094
and W13, W27, #4095
and W13, W27, #4096
and W13, W27, #6144
and W13, W27, #7168
and W13, W27, #7680
and W13, W27, #7936
and W13, W27, #8064
and W13, W27, #8128
and W13, W27, #8160
and W13, W27, #8176
and W13, W27, #8184
and W13, W27, #8188
and W13, W27, #8190
and W13, W27, #8191
and W13, W27, #8192
and W13, W27, #12288
and W13, W27, #14336
and W13, W27, #15360
and W13, W27, #15872
and W13, W27, #16128
and W13, W27, #16256
and W13, W27, #16320
and W13, W27, #16352
and W13, W27, #16368
and W13, W27, #16376
and W13, W27, #16380
and W13, W27, #16382
and W13, W27, #16383
and W13, W27, #16384
and W13, W27, #24576
and W13, W27, #28672
and W13, W27, #30720
and W13, W27, #31744
and W13, W27, #32256
and W13, W27, #32512
and W13, W27, #32640
and W13, W27, #32704
and W13, W27, #32736
and W13, W27, #32752
and W13, W27, #32760
and W13, W27, #32764
and W13, W27, #32766
and W13, W27, #32767
and W13, W27, #32768
and W13, W27, #49152
and W13, W27, #57344
and W13, W27, #61440
and W13, W27, #63488
and W13, W27, #64512
and W13, W27, #65024
and W13, W27, #65280
and W13, W27, #65408
and W13, W27, #65472
and W13, W27, #65504
and W13, W27, #65520
and W13, W27, #65528
and W13, W27, #65532
and W13, W27, #65534
and W13, W27, #65535
and W13, W27, #65536
and W13, W27, #65537
and W13, W27, #98304
and W13, W27, #114688
and W13, W27, #122880
and W13, W27, #126976
and W13, W27, #129024
and W13, W27, #130048
and W13, W27, #130560
and W13, W27, #130816
and W13, W27, #130944
and W13, W27, #131008
and W13, W27, #131040
and W13, W27, #131056
and W13, W27, #131064
and W13, W27, #131068
and W13, W27, #131070
and W13, W27, #131071
and W13, W27, #131072
and W13, W27, #131074
and W13, W27, #196608
and W13, W27, #196611
and W13, W27, #229376
and W13, W27, #245760
and W13, W27, #253952
and W13, W27, #258048
and W13, W27, #260096
and W13, W27, #261120
and W13, W27, #261632
and W13, W27, #261888
and W13, W27, #262016
and W13, W27, #262080
and W13, W27, #262112
and W13, W27, #262128
and W13, W27, #262136
and W13, W27, #262140
and W13, W27, #262142
and W13, W27, #262143
and W13, W27, #262144
and W13, W27, #262148
and W13, W27, #393216
and W13, W27, #393222
and W13, W27, #458752
and W13, W27, #458759
and W13, W27, #491520
and W13, W27, #507904
and W13, W27, #516096
and W13, W27, #520192
and W13, W27, #522240
and W13, W27, #523264
and W13, W27, #523776
and W13, W27, #524032
and W13, W27, #524160
and W13, W27, #524224
and W13, W27, #524256
and W13, W27, #524272
and W13, W27, #524280
and W13, W27, #524284
and W13, W27, #524286
and W13, W27, #524287
and W13, W27, #524288
and W13, W27, #524296
and W13, W27, #786432
and W13, W27, #786444
and W13, W27, #917504
and W13, W27, #917518
and W13, W27, #983040
and W13, W27, #983055
and W13, W27, #1015808
and W13, W27, #1032192
and W13, W27, #1040384
and W13, W27, #1044480
and W13, W27, #1046528
and W13, W27, #1047552
and W13, W27, #1048064
and W13, W27, #1048320
and W13, W27, #1048448
and W13, W27, #1048512
and W13, W27, #1048544
and W13, W27, #1048560
and W13, W27, #1048568
and W13, W27, #1048572
and W13, W27, #1048574
and W13, W27, #1048575
and W13, W27, #1048576
and W13, W27, #1048592
and W13, W27, #1572864
and W13, W27, #1572888
and W13, W27, #1835008
and W13, W27, #1835036
and W13, W27, #1966080
and W13, W27, #1966110
and W13, W27, #2031616
and W13, W27, #2031647
and W13, W27, #2064384
and W13, W27, #2080768
and W13, W27, #2088960
and W13, W27, #2093056
and W13, W27, #2095104
and W13, W27, #2096128
and W13, W27, #2096640
and W13, W27, #2096896
and W13, W27, #2097024
and W13, W27, #2097088
and W13, W27, #2097120
and W13, W27, #2097136
and W13, W27, #2097144
and W13, W27, #2097148
and W13, W27, #2097150
and W13, W27, #2097151
and W13, W27, #2097152
and W13, W27, #2097184
and W13, W27, #3145728
and W13, W27, #3145776
and W13, W27, #3670016
and W13, W27, #3670072
and W13, W27, #3932160
and W13, W27, #3932220
and W13, W27, #4063232
and W13, W27, #4063294
and W13, W27, #4128768
and W13, W27, #4128831
and W13, W27, #4161536
and W13, W27, #4177920
and W13, W27, #4186112
and W13, W27, #4190208
and W13, W27, #4192256
and W13, W27, #4193280
and W13, W27, #4193792
and W13, W27, #4194048
and W13, W27, #4194176
and W13, W27, #4194240
and W13, W27, #4194272
and W13, W27, #4194288
and W13, W27, #4194296
and W13, W27, #4194300
and W13, W27, #4194302
and W13, W27, #4194303
and W13, W27, #4194304
and W13, W27, #4194368
and W13, W27, #6291456
and W13, W27, #6291552
and W13, W27, #7340032
and W13, W27, #7340144
and W13, W27, #7864320
and W13, W27, #7864440
and W13, W27, #8126464
and W13, W27, #8126588
and W13, W27, #8257536
and W13, W27, #8257662
and W13, W27, #8323072
and W13, W27, #8323199
and W13, W27, #8355840
and W13, W27, #8372224
and W13, W27, #8380416
and W13, W27, #8384512
and W13, W27, #8386560
and W13, W27, #8387584
and W13, W27, #8388096
and W13, W27, #8388352
and W13, W27, #8388480
and W13, W27, #8388544
and W13, W27, #8388576
and W13, W27, #8388592
and W13, W27, #8388600
and W13, W27, #8388604
and W13, W27, #8388606
and W13, W27, #8388607
and W13, W27, #8388608
and W13, W27, #8388736
and W13, W27, #12582912
and W13, W27, #12583104
and W13, W27, #14680064
and W13, W27, #14680288
and W13, W27, #15728640
and W13, W27, #15728880
and W13, W27, #16252928
and W13, W27, #16253176
and W13, W27, #16515072
and W13, W27, #16515324
and W13, W27, #16646144
and W13, W27, #16646398
and W13, W27, #16711680
and W13, W27, #16711935
and W13, W27, #16744448
and W13, W27, #16760832
and W13, W27, #16769024
and W13, W27, #16773120
and W13, W27, #16775168
and W13, W27, #16776192
and W13, W27, #16776704
and W13, W27, #16776960
and W13, W27, #16777088
and W13, W27, #16777152
and W13, W27, #16777184
and W13, W27, #16777200
and W13, W27, #16777208
and W13, W27, #16777212
and W13, W27, #16777214
and W13, W27, #16777215
and W13, W27, #16777216
and W13, W27, #16777472
and W13, W27, #16843009
and W13, W27, #25165824
and W13, W27, #25166208
and W13, W27, #29360128
and W13, W27, #29360576
and W13, W27, #31457280
and W13, W27, #31457760
and W13, W27, #32505856
and W13, W27, #32506352
and W13, W27, #33030144
and W13, W27, #33030648
and W13, W27, #33292288
and W13, W27, #33292796
and W13, W27, #33423360
and W13, W27, #33423870
and W13, W27, #33488896
and W13, W27, #33489407
and W13, W27, #33521664
and W13, W27, #33538048
and W13, W27, #33546240
and W13, W27, #33550336
and W13, W27, #33552384
and W13, W27, #33553408
and W13, W27, #33553920
and W13, W27, #33554176
and W13, W27, #33554304
and W13, W27, #33554368
and W13, W27, #33554400
and W13, W27, #33554416
and W13, W27, #33554424
and W13, W27, #33554428
and W13, W27, #33554430
and W13, W27, #33554431
and W13, W27, #33554432
and W13, W27, #33554944
and W13, W27, #33686018
and W13, W27, #50331648
and W13, W27, #50332416
and W13, W27, #50529027
and W13, W27, #58720256
and W13, W27, #58721152
and W13, W27, #62914560
and W13, W27, #62915520
and W13, W27, #65011712
and W13, W27, #65012704
and W13, W27, #66060288
and W13, W27, #66061296
and W13, W27, #66584576
and W13, W27, #66585592
and W13, W27, #66846720
and W13, W27, #66847740
and W13, W27, #66977792
and W13, W27, #66978814
and W13, W27, #67043328
and W13, W27, #67044351
and W13, W27, #67076096
and W13, W27, #67092480
and W13, W27, #67100672
and W13, W27, #67104768
and W13, W27, #67106816
and W13, W27, #67107840
and W13, W27, #67108352
and W13, W27, #67108608
and W13, W27, #67108736
and W13, W27, #67108800
and W13, W27, #67108832
and W13, W27, #67108848
and W13, W27, #67108856
and W13, W27, #67108860
and W13, W27, #67108862
and W13, W27, #67108863
and W13, W27, #67108864
and W13, W27, #67109888
and W13, W27, #67372036
and W13, W27, #100663296
and W13, W27, #100664832
and W13, W27, #101058054
and W13, W27, #117440512
and W13, W27, #117442304
and W13, W27, #117901063
and W13, W27, #125829120
and W13, W27, #125831040
and W13, W27, #130023424
and W13, W27, #130025408
and W13, W27, #132120576
and W13, W27, #132122592
and W13, W27, #133169152
and W13, W27, #133171184
and W13, W27, #133693440
and W13, W27, #133695480
and W13, W27, #133955584
and W13, W27, #133957628
and W13, W27, #134086656
and W13, W27, #134088702
and W13, W27, #134152192
and W13, W27, #134154239
and W13, W27, #134184960
and W13, W27, #134201344
and W13, W27, #134209536
and W13, W27, #134213632
and W13, W27, #134215680
and W13, W27, #134216704
and W13, W27, #134217216
and W13, W27, #134217472
and W13, W27, #134217600
and W13, W27, #134217664
and W13, W27, #134217696
and W13, W27, #134217712
and W13, W27, #134217720
and W13, W27, #134217724
and W13, W27, #134217726
and W13, W27, #134217727
and W13, W27, #134217728
and W13, W27, #134219776
and W13, W27, #134744072
and W13, W27, #201326592
and W13, W27, #201329664
and W13, W27, #202116108
and W13, W27, #234881024
and W13, W27, #234884608
and W13, W27, #235802126
and W13, W27, #251658240
and W13, W27, #251662080
and W13, W27, #252645135
and W13, W27, #260046848
and W13, W27, #260050816
and W13, W27, #264241152
and W13, W27, #264245184
and W13, W27, #266338304
and W13, W27, #266342368
and W13, W27, #267386880
and W13, W27, #267390960
and W13, W27, #267911168
and W13, W27, #267915256
and W13, W27, #268173312
and W13, W27, #268177404
and W13, W27, #268304384
and W13, W27, #268308478
and W13, W27, #268369920
and W13, W27, #268374015
and W13, W27, #268402688
and W13, W27, #268419072
and W13, W27, #268427264
and W13, W27, #268431360
and W13, W27, #268433408
and W13, W27, #268434432
and W13, W27, #268434944
and W13, W27, #268435200
and W13, W27, #268435328
and W13, W27, #268435392
and W13, W27, #268435424
and W13, W27, #268435440
and W13, W27, #268435448
and W13, W27, #268435452
and W13, W27, #268435454
and W13, W27, #268435455
and W13, W27, #268435456
and W13, W27, #268439552
and W13, W27, #269488144
and W13, W27, #286331153
and W13, W27, #402653184
and W13, W27, #402659328
and W13, W27, #404232216
and W13, W27, #469762048
and W13, W27, #469769216
and W13, W27, #471604252
and W13, W27, #503316480
and W13, W27, #503324160
and W13, W27, #505290270
and W13, W27, #520093696
and W13, W27, #520101632
and W13, W27, #522133279
and W13, W27, #528482304
and W13, W27, #528490368
and W13, W27, #532676608
and W13, W27, #532684736
and W13, W27, #534773760
and W13, W27, #534781920
and W13, W27, #535822336
and W13, W27, #535830512
and W13, W27, #536346624
and W13, W27, #536354808
and W13, W27, #536608768
and W13, W27, #536616956
and W13, W27, #536739840
and W13, W27, #536748030
and W13, W27, #536805376
and W13, W27, #536813567
and W13, W27, #536838144
and W13, W27, #536854528
and W13, W27, #536862720
and W13, W27, #536866816
and W13, W27, #536868864
and W13, W27, #536869888
and W13, W27, #536870400
and W13, W27, #536870656
and W13, W27, #536870784
and W13, W27, #536870848
and W13, W27, #536870880
and W13, W27, #536870896
and W13, W27, #536870904
and W13, W27, #536870908
and W13, W27, #536870910
and W13, W27, #536870911
and W13, W27, #536870912
and W13, W27, #536879104
and W13, W27, #538976288
and W13, W27, #572662306
and W13, W27, #805306368
and W13, W27, #805318656
and W13, W27, #808464432
and W13, W27, #858993459
and W13, W27, #939524096
and W13, W27, #939538432
and W13, W27, #943208504
and W13, W27, #1006632960
and W13, W27, #1006648320
and W13, W27, #1010580540
and W13, W27, #1040187392
and W13, W27, #1040203264
and W13, W27, #1044266558
and W13, W27, #1056964608
and W13, W27, #1056980736
and W13, W27, #1061109567
and W13, W27, #1065353216
and W13, W27, #1065369472
and W13, W27, #1069547520
and W13, W27, #1069563840
and W13, W27, #1071644672
and W13, W27, #1071661024
and W13, W27, #1072693248
and W13, W27, #1072709616
and W13, W27, #1073217536
and W13, W27, #1073233912
and W13, W27, #1073479680
and W13, W27, #1073496060
and W13, W27, #1073610752
and W13, W27, #1073627134
and W13, W27, #1073676288
and W13, W27, #1073692671
and W13, W27, #1073709056
and W13, W27, #1073725440
and W13, W27, #1073733632
and W13, W27, #1073737728
and W13, W27, #1073739776
and W13, W27, #1073740800
and W13, W27, #1073741312
and W13, W27, #1073741568
and W13, W27, #1073741696
and W13, W27, #1073741760
and W13, W27, #1073741792
and W13, W27, #1073741808
and W13, W27, #1073741816
and W13, W27, #1073741820
and W13, W27, #1073741822
and W13, W27, #1073741823
and W13, W27, #1073741824
and W13, W27, #1073758208
and W13, W27, #1077952576
and W13, W27, #1145324612
and W13, W27, #1431655765
and W13, W27, #1610612736
and W13, W27, #1610637312
and W13, W27, #1616928864
and W13, W27, #1717986918
and W13, W27, #1879048192
and W13, W27, #1879076864
and W13, W27, #1886417008
and W13, W27, #2004318071
and W13, W27, #2013265920
and W13, W27, #2013296640
and W13, W27, #2021161080
and W13, W27, #2080374784
and W13, W27, #2080406528
and W13, W27, #2088533116
and W13, W27, #2113929216
and W13, W27, #2113961472
and W13, W27, #2122219134
and W13, W27, #2130706432
and W13, W27, #2130738944
and W13, W27, #2139062143
and W13, W27, #2139095040
and W13, W27, #2139127680
and W13, W27, #2143289344
and W13, W27, #2143322048
and W13, W27, #2145386496
and W13, W27, #2145419232
and W13, W27, #2146435072
and W13, W27, #2146467824
and W13, W27, #2146959360
and W13, W27, #2146992120
and W13, W27, #2147221504
and W13, W27, #2147254268
and W13, W27, #2147352576
and W13, W27, #2147385342
and W13, W27, #2147418112
and W13, W27, #2147450879
and W13, W27, #2147450880
and W13, W27, #2147467264
and W13, W27, #2147475456
and W13, W27, #2147479552
and W13, W27, #2147481600
and W13, W27, #2147482624
and W13, W27, #2147483136
and W13, W27, #2147483392
and W13, W27, #2147483520
and W13, W27, #2147483584
and W13, W27, #2147483616
and W13, W27, #2147483632
and W13, W27, #2147483640
and W13, W27, #2147483644
and W13, W27, #2147483646
and W13, W27, #2147483647
and W13, W27, #2147483648
and W13, W27, #2147483649
and W13, W27, #2147483651
and W13, W27, #2147483655
and W13, W27, #2147483663
and W13, W27, #2147483679
and W13, W27, #2147483711
and W13, W27, #2147483775
and W13, W27, #2147483903
and W13, W27, #2147484159
and W13, W27, #2147484671
and W13, W27, #2147485695
and W13, W27, #2147487743
and W13, W27, #2147491839
and W13, W27, #2147500031
and W13, W27, #2147516415
and W13, W27, #2147516416
and W13, W27, #2147549183
and W13, W27, #2147581953
and W13, W27, #2147614719
and W13, W27, #2147713027
and W13, W27, #2147745791
and W13, W27, #2147975175
and W13, W27, #2148007935
and W13, W27, #2148499471
and W13, W27, #2148532223
and W13, W27, #2149548063
and W13, W27, #2149580799
and W13, W27, #2151645247
and W13, W27, #2151677951
and W13, W27, #2155839615
and W13, W27, #2155872255
and W13, W27, #2155905152
and W13, W27, #2164228351
and W13, W27, #2164260863
and W13, W27, #2172748161
and W13, W27, #2181005823
and W13, W27, #2181038079
and W13, W27, #2206434179
and W13, W27, #2214560767
and W13, W27, #2214592511
and W13, W27, #2273806215
and W13, W27, #2281670655
and W13, W27, #2281701375
and W13, W27, #2290649224
and W13, W27, #2408550287
and W13, W27, #2415890431
and W13, W27, #2415919103
and W13, W27, #2576980377
and W13, W27, #2678038431
and W13, W27, #2684329983
and W13, W27, #2684354559
and W13, W27, #2863311530
and W13, W27, #3149642683
and W13, W27, #3217014719
and W13, W27, #3221209087
and W13, W27, #3221225471
and W13, W27, #3221225472
and W13, W27, #3221225473
and W13, W27, #3221225475
and W13, W27, #3221225479
and W13, W27, #3221225487
and W13, W27, #3221225503
and W13, W27, #3221225535
and W13, W27, #3221225599
and W13, W27, #3221225727
and W13, W27, #3221225983
and W13, W27, #3221226495
and W13, W27, #3221227519
and W13, W27, #3221229567
and W13, W27, #3221233663
and W13, W27, #3221241855
and W13, W27, #3221258239
and W13, W27, #3221274624
and W13, W27, #3221291007
and W13, W27, #3221340161
and W13, W27, #3221356543
and W13, W27, #3221471235
and W13, W27, #3221487615
and W13, W27, #3221733383
and W13, W27, #3221749759
and W13, W27, #3222257679
and W13, W27, #3222274047
and W13, W27, #3223306271
and W13, W27, #3223322623
and W13, W27, #3225403455
and W13, W27, #3225419775
and W13, W27, #3229597823
and W13, W27, #3229614079
and W13, W27, #3233857728
and W13, W27, #3237986559
and W13, W27, #3238002687
and W13, W27, #3250700737
and W13, W27, #3254764031
and W13, W27, #3254779903
and W13, W27, #3284386755
and W13, W27, #3288318975
and W13, W27, #3288334335
and W13, W27, #3351758791
and W13, W27, #3355428863
and W13, W27, #3355443199
and W13, W27, #3435973836
and W13, W27, #3486502863
and W13, W27, #3489648639
and W13, W27, #3489660927
and W13, W27, #3722304989
and W13, W27, #3755991007
and W13, W27, #3758088191
and W13, W27, #3758096383
and W13, W27, #3758096384
and W13, W27, #3758096385
and W13, W27, #3758096387
and W13, W27, #3758096391
and W13, W27, #3758096399
and W13, W27, #3758096415
and W13, W27, #3758096447
and W13, W27, #3758096511
and W13, W27, #3758096639
and W13, W27, #3758096895
and W13, W27, #3758097407
and W13, W27, #3758098431
and W13, W27, #3758100479
and W13, W27, #3758104575
and W13, W27, #3758112767
and W13, W27, #3758129151
and W13, W27, #3758153728
and W13, W27, #3758161919
and W13, W27, #3758219265
and W13, W27, #3758227455
and W13, W27, #3758350339
and W13, W27, #3758358527
and W13, W27, #3758612487
and W13, W27, #3758620671
and W13, W27, #3759136783
and W13, W27, #3759144959
and W13, W27, #3760185375
and W13, W27, #3760193535
and W13, W27, #3762282559
and W13, W27, #3762290687
and W13, W27, #3766476927
and W13, W27, #3766484991
and W13, W27, #3772834016
and W13, W27, #3774865663
and W13, W27, #3774873599
and W13, W27, #3789677025
and W13, W27, #3791643135
and W13, W27, #3791650815
and W13, W27, #3823363043
and W13, W27, #3825198079
and W13, W27, #3825205247
and W13, W27, #3890735079
and W13, W27, #3892307967
and W13, W27, #3892314111
and W13, W27, #4008636142
and W13, W27, #4025479151
and W13, W27, #4026527743
and W13, W27, #4026531839
and W13, W27, #4026531840
and W13, W27, #4026531841
and W13, W27, #4026531843
and W13, W27, #4026531847
and W13, W27, #4026531855
and W13, W27, #4026531871
and W13, W27, #4026531903
and W13, W27, #4026531967
and W13, W27, #4026532095
and W13, W27, #4026532351
and W13, W27, #4026532863
and W13, W27, #4026533887
and W13, W27, #4026535935
and W13, W27, #4026540031
and W13, W27, #4026548223
and W13, W27, #4026564607
and W13, W27, #4026593280
and W13, W27, #4026597375
and W13, W27, #4026658817
and W13, W27, #4026662911
and W13, W27, #4026789891
and W13, W27, #4026793983
and W13, W27, #4027052039
and W13, W27, #4027056127
and W13, W27, #4027576335
and W13, W27, #4027580415
and W13, W27, #4028624927
and W13, W27, #4028628991
and W13, W27, #4030722111
and W13, W27, #4030726143
and W13, W27, #4034916479
and W13, W27, #4034920447
and W13, W27, #4042322160
and W13, W27, #4043305215
and W13, W27, #4043309055
and W13, W27, #4059165169
and W13, W27, #4060082687
and W13, W27, #4060086271
and W13, W27, #4092851187
and W13, W27, #4093637631
and W13, W27, #4093640703
and W13, W27, #4160223223
and W13, W27, #4160747519
and W13, W27, #4160749567
and W13, W27, #4160749568
and W13, W27, #4160749569
and W13, W27, #4160749571
and W13, W27, #4160749575
and W13, W27, #4160749583
and W13, W27, #4160749599
and W13, W27, #4160749631
and W13, W27, #4160749695
and W13, W27, #4160749823
and W13, W27, #4160750079
and W13, W27, #4160750591
and W13, W27, #4160751615
and W13, W27, #4160753663
and W13, W27, #4160757759
and W13, W27, #4160765951
and W13, W27, #4160782335
and W13, W27, #4160813056
and W13, W27, #4160815103
and W13, W27, #4160878593
and W13, W27, #4160880639
and W13, W27, #4161009667
and W13, W27, #4161011711
and W13, W27, #4161271815
and W13, W27, #4161273855
and W13, W27, #4161796111
and W13, W27, #4161798143
and W13, W27, #4162844703
and W13, W27, #4162846719
and W13, W27, #4164941887
and W13, W27, #4164943871
and W13, W27, #4169136255
and W13, W27, #4169138175
and W13, W27, #4177066232
and W13, W27, #4177524991
and W13, W27, #4177526783
and W13, W27, #4193909241
and W13, W27, #4194302463
and W13, W27, #4194303999
and W13, W27, #4227595259
and W13, W27, #4227857407
and W13, W27, #4227858431
and W13, W27, #4227858432
and W13, W27, #4227858433
and W13, W27, #4227858435
and W13, W27, #4227858439
and W13, W27, #4227858447
and W13, W27, #4227858463
and W13, W27, #4227858495
and W13, W27, #4227858559
and W13, W27, #4227858687
and W13, W27, #4227858943
and W13, W27, #4227859455
and W13, W27, #4227860479
and W13, W27, #4227862527
and W13, W27, #4227866623
and W13, W27, #4227874815
and W13, W27, #4227891199
and W13, W27, #4227922944
and W13, W27, #4227923967
and W13, W27, #4227988481
and W13, W27, #4227989503
and W13, W27, #4228119555
and W13, W27, #4228120575
and W13, W27, #4228381703
and W13, W27, #4228382719
and W13, W27, #4228905999
and W13, W27, #4228907007
and W13, W27, #4229954591
and W13, W27, #4229955583
and W13, W27, #4232051775
and W13, W27, #4232052735
and W13, W27, #4236246143
and W13, W27, #4236247039
and W13, W27, #4244438268
and W13, W27, #4244634879
and W13, W27, #4244635647
and W13, W27, #4261281277
and W13, W27, #4261412351
and W13, W27, #4261412863
and W13, W27, #4261412864
and W13, W27, #4261412865
and W13, W27, #4261412867
and W13, W27, #4261412871
and W13, W27, #4261412879
and W13, W27, #4261412895
and W13, W27, #4261412927
and W13, W27, #4261412991
and W13, W27, #4261413119
and W13, W27, #4261413375
and W13, W27, #4261413887
and W13, W27, #4261414911
and W13, W27, #4261416959
and W13, W27, #4261421055
and W13, W27, #4261429247
and W13, W27, #4261445631
and W13, W27, #4261477888
and W13, W27, #4261478399
and W13, W27, #4261543425
and W13, W27, #4261543935
and W13, W27, #4261674499
and W13, W27, #4261675007
and W13, W27, #4261936647
and W13, W27, #4261937151
and W13, W27, #4262460943
and W13, W27, #4262461439
and W13, W27, #4263509535
and W13, W27, #4263510015
and W13, W27, #4265606719
and W13, W27, #4265607167
and W13, W27, #4269801087
and W13, W27, #4269801471
and W13, W27, #4278124286
and W13, W27, #4278189823
and W13, W27, #4278190079
and W13, W27, #4278190080
and W13, W27, #4278190081
and W13, W27, #4278190083
and W13, W27, #4278190087
and W13, W27, #4278190095
and W13, W27, #4278190111
and W13, W27, #4278190143
and W13, W27, #4278190207
and W13, W27, #4278190335
and W13, W27, #4278190591
and W13, W27, #4278191103
and W13, W27, #4278192127
and W13, W27, #4278194175
and W13, W27, #4278198271
and W13, W27, #4278206463
and W13, W27, #4278222847
and W13, W27, #4278255360
and W13, W27, #4278255615
and W13, W27, #4278320897
and W13, W27, #4278321151
and W13, W27, #4278451971
and W13, W27, #4278452223
and W13, W27, #4278714119
and W13, W27, #4278714367
and W13, W27, #4279238415
and W13, W27, #4279238655
and W13, W27, #4280287007
and W13, W27, #4280287231
and W13, W27, #4282384191
and W13, W27, #4282384383
and W13, W27, #4286578559
and W13, W27, #4286578687
and W13, W27, #4286578688
and W13, W27, #4286578689
and W13, W27, #4286578691
and W13, W27, #4286578695
and W13, W27, #4286578703
and W13, W27, #4286578719
and W13, W27, #4286578751
and W13, W27, #4286578815
and W13, W27, #4286578943
and W13, W27, #4286579199
and W13, W27, #4286579711
and W13, W27, #4286580735
and W13, W27, #4286582783
and W13, W27, #4286586879
and W13, W27, #4286595071
and W13, W27, #4286611455
and W13, W27, #4286644096
and W13, W27, #4286644223
and W13, W27, #4286709633
and W13, W27, #4286709759
and W13, W27, #4286840707
and W13, W27, #4286840831
and W13, W27, #4287102855
and W13, W27, #4287102975
and W13, W27, #4287627151
and W13, W27, #4287627263
and W13, W27, #4288675743
and W13, W27, #4288675839
and W13, W27, #4290772927
and W13, W27, #4290772991
and W13, W27, #4290772992
and W13, W27, #4290772993
and W13, W27, #4290772995
and W13, W27, #4290772999
and W13, W27, #4290773007
and W13, W27, #4290773023
and W13, W27, #4290773055
and W13, W27, #4290773119
and W13, W27, #4290773247
and W13, W27, #4290773503
and W13, W27, #4290774015
and W13, W27, #4290775039
and W13, W27, #4290777087
and W13, W27, #4290781183
and W13, W27, #4290789375
and W13, W27, #4290805759
and W13, W27, #4290838464
and W13, W27, #4290838527
and W13, W27, #4290904001
and W13, W27, #4290904063
and W13, W27, #4291035075
and W13, W27, #4291035135
and W13, W27, #4291297223
and W13, W27, #4291297279
and W13, W27, #4291821519
and W13, W27, #4291821567
and W13, W27, #4292870111
and W13, W27, #4292870143
and W13, W27, #4292870144
and W13, W27, #4292870145
and W13, W27, #4292870147
and W13, W27, #4292870151
and W13, W27, #4292870159
and W13, W27, #4292870175
and W13, W27, #4292870207
and W13, W27, #4292870271
and W13, W27, #4292870399
and W13, W27, #4292870655
and W13, W27, #4292871167
and W13, W27, #4292872191
and W13, W27, #4292874239
and W13, W27, #4292878335
and W13, W27, #4292886527
and W13, W27, #4292902911
and W13, W27, #4292935648
and W13, W27, #4292935679
and W13, W27, #4293001185
and W13, W27, #4293001215
and W13, W27, #4293132259
and W13, W27, #4293132287
and W13, W27, #4293394407
and W13, W27, #4293394431
and W13, W27, #4293918703
and W13, W27, #4293918719
and W13, W27, #4293918720
and W13, W27, #4293918721
and W13, W27, #4293918723
and W13, W27, #4293918727
and W13, W27, #4293918735
and W13, W27, #4293918751
and W13, W27, #4293918783
and W13, W27, #4293918847
and W13, W27, #4293918975
and W13, W27, #4293919231
and W13, W27, #4293919743
and W13, W27, #4293920767
and W13, W27, #4293922815
and W13, W27, #4293926911
and W13, W27, #4293935103
and W13, W27, #4293951487
and W13, W27, #4293984240
and W13, W27, #4293984255
and W13, W27, #4294049777
and W13, W27, #4294049791
and W13, W27, #4294180851
and W13, W27, #4294180863
and W13, W27, #4294442999
and W13, W27, #4294443007
and W13, W27, #4294443008
and W13, W27, #4294443009
and W13, W27, #4294443011
and W13, W27, #4294443015
and W13, W27, #4294443023
and W13, W27, #4294443039
and W13, W27, #4294443071
and W13, W27, #4294443135
and W13, W27, #4294443263
and W13, W27, #4294443519
and W13, W27, #4294444031
and W13, W27, #4294445055
and W13, W27, #4294447103
and W13, W27, #4294451199
and W13, W27, #4294459391
and W13, W27, #4294475775
and W13, W27, #4294508536
and W13, W27, #4294508543
and W13, W27, #4294574073
and W13, W27, #4294574079
and W13, W27, #4294705147
and W13, W27, #4294705151
and W13, W27, #4294705152
and W13, W27, #4294705153
and W13, W27, #4294705155
and W13, W27, #4294705159
and W13, W27, #4294705167
and W13, W27, #4294705183
and W13, W27, #4294705215
and W13, W27, #4294705279
and W13, W27, #4294705407
and W13, W27, #4294705663
and W13, W27, #4294706175
and W13, W27, #4294707199
and W13, W27, #4294709247
and W13, W27, #4294713343
and W13, W27, #4294721535
and W13, W27, #4294737919
and W13, W27, #4294770684
and W13, W27, #4294770687
and W13, W27, #4294836221
and W13, W27, #4294836223
and W13, W27, #4294836224
and W13, W27, #4294836225
and W13, W27, #4294836227
and W13, W27, #4294836231
and W13, W27, #4294836239
and W13, W27, #4294836255
and W13, W27, #4294836287
and W13, W27, #4294836351
and W13, W27, #4294836479
and W13, W27, #4294836735
and W13, W27, #4294837247
and W13, W27, #4294838271
and W13, W27, #4294840319
and W13, W27, #4294844415
and W13, W27, #4294852607
and W13, W27, #4294868991
and W13, W27, #4294901758
and W13, W27, #4294901759
and W13, W27, #4294901760
and W13, W27, #4294901761
and W13, W27, #4294901763
and W13, W27, #4294901767
and W13, W27, #4294901775
and W13, W27, #4294901791
and W13, W27, #4294901823
and W13, W27, #4294901887
and W13, W27, #4294902015
and W13, W27, #4294902271
and W13, W27, #4294902783
and W13, W27, #4294903807
and W13, W27, #4294905855
and W13, W27, #4294909951
and W13, W27, #4294918143
and W13, W27, #4294934527
and W13, W27, #4294934528
and W13, W27, #4294934529
and W13, W27, #4294934531
and W13, W27, #4294934535
and W13, W27, #4294934543
and W13, W27, #4294934559
and W13, W27, #4294934591
and W13, W27, #4294934655
and W13, W27, #4294934783
and W13, W27, #4294935039
and W13, W27, #4294935551
and W13, W27, #4294936575
and W13, W27, #4294938623
and W13, W27, #4294942719
and W13, W27, #4294950911
and W13, W27, #4294950912
and W13, W27, #4294950913
and W13, W27, #4294950915
and W13, W27, #4294950919
and W13, W27, #4294950927
and W13, W27, #4294950943
and W13, W27, #4294950975
and W13, W27, #4294951039
and W13, W27, #4294951167
and W13, W27, #4294951423
and W13, W27, #4294951935
and W13, W27, #4294952959
and W13, W27, #4294955007
and W13, W27, #4294959103
and W13, W27, #4294959104
and W13, W27, #4294959105
and W13, W27, #4294959107
and W13, W27, #4294959111
and W13, W27, #4294959119
and W13, W27, #4294959135
and W13, W27, #4294959167
and W13, W27, #4294959231
and W13, W27, #4294959359
and W13, W27, #4294959615
and W13, W27, #4294960127
and W13, W27, #4294961151
and W13, W27, #4294963199
and W13, W27, #4294963200
and W13, W27, #4294963201
and W13, W27, #4294963203
and W13, W27, #4294963207
and W13, W27, #4294963215
and W13, W27, #4294963231
and W13, W27, #4294963263
and W13, W27, #4294963327
and W13, W27, #4294963455
and W13, W27, #4294963711
and W13, W27, #4294964223
and W13, W27, #4294965247
and W13, W27, #4294965248
and W13, W27, #4294965249
and W13, W27, #4294965251
and W13, W27, #4294965255
and W13, W27, #4294965263
and W13, W27, #4294965279
and W13, W27, #4294965311
and W13, W27, #4294965375
and W13, W27, #4294965503
and W13, W27, #4294965759
and W13, W27, #4294966271
and W13, W27, #4294966272
and W13, W27, #4294966273
and W13, W27, #4294966275
and W13, W27, #4294966279
and W13, W27, #4294966287
and W13, W27, #4294966303
and W13, W27, #4294966335
and W13, W27, #4294966399
and W13, W27, #4294966527
and W13, W27, #4294966783
and W13, W27, #4294966784
and W13, W27, #4294966785
and W13, W27, #4294966787
and W13, W27, #4294966791
and W13, W27, #4294966799
and W13, W27, #4294966815
and W13, W27, #4294966847
and W13, W27, #4294966911
and W13, W27, #4294967039
and W13, W27, #4294967040
and W13, W27, #4294967041
and W13, W27, #4294967043
and W13, W27, #4294967047
and W13, W27, #4294967055
and W13, W27, #4294967071
and W13, W27, #4294967103
and W13, W27, #4294967167
and W13, W27, #4294967168
and W13, W27, #4294967169
and W13, W27, #4294967171
and W13, W27, #4294967175
and W13, W27, #4294967183
and W13, W27, #4294967199
and W13, W27, #4294967231
and W13, W27, #4294967232
and W13, W27, #4294967233
and W13, W27, #4294967235
and W13, W27, #4294967239
and W13, W27, #4294967247
and W13, W27, #4294967263
and W13, W27, #4294967264
and W13, W27, #4294967265
and W13, W27, #4294967267
and W13, W27, #4294967271
and W13, W27, #4294967279
and W13, W27, #4294967280
and W13, W27, #4294967281
and W13, W27, #4294967283
and W13, W27, #4294967287
and W13, W27, #4294967288
and W13, W27, #4294967289
and W13, W27, #4294967291
and W13, W27, #4294967292
and W13, W27, #4294967293
and W13, W27, #4294967294
and X13, X27, #1
and X13, X27, #2
and X13, X27, #3
and X13, X27, #4
and X13, X27, #6
and X13, X27, #7
and X13, X27, #8
and X13, X27, #12
and X13, X27, #14
and X13, X27, #15
and X13, X27, #16
and X13, X27, #24
and X13, X27, #28
and X13, X27, #30
and X13, X27, #31
and X13, X27, #32
and X13, X27, #48
and X13, X27, #56
and X13, X27, #60
and X13, X27, #62
and X13, X27, #63
and X13, X27, #64
and X13, X27, #96
and X13, X27, #112
and X13, X27, #120
and X13, X27, #124
and X13, X27, #126
and X13, X27, #127
and X13, X27, #128
and X13, X27, #192
and X13, X27, #224
and X13, X27, #240
and X13, X27, #248
and X13, X27, #252
and X13, X27, #254
and X13, X27, #255
and X13, X27, #256
and X13, X27, #384
and X13, X27, #448
and X13, X27, #480
and X13, X27, #496
and X13, X27, #504
and X13, X27, #508
and X13, X27, #510
and X13, X27, #511
and X13, X27, #512
and X13, X27, #768
and X13, X27, #896
and X13, X27, #960
and X13, X27, #992
and X13, X27, #1008
and X13, X27, #1016
and X13, X27, #1020
and X13, X27, #1022
and X13, X27, #1023
and X13, X27, #1024
and X13, X27, #1536
and X13, X27, #1792
and X13, X27, #1920
and X13, X27, #1984
and X13, X27, #2016
and X13, X27, #2032
and X13, X27, #2040
and X13, X27, #2044
and X13, X27, #2046
and X13, X27, #2047
and X13, X27, #2048
and X13, X27, #3072
and X13, X27, #3584
and X13, X27, #3840
and X13, X27, #3968
and X13, X27, #4032
and X13, X27, #4064
and X13, X27, #4080
and X13, X27, #4088
and X13, X27, #4092
and X13, X27, #4094
and X13, X27, #4095
and X13, X27, #4096
and X13, X27, #6144
and X13, X27, #7168
and X13, X27, #7680
and X13, X27, #7936
and X13, X27, #8064
and X13, X27, #8128
and X13, X27, #8160
and X13, X27, #8176
and X13, X27, #8184
and X13, X27, #8188
and X13, X27, #8190
and X13, X27, #8191
and X13, X27, #8192
and X13, X27, #12288
and X13, X27, #14336
and X13, X27, #15360
and X13, X27, #15872
and X13, X27, #16128
and X13, X27, #16256
and X13, X27, #16320
and X13, X27, #16352
and X13, X27, #16368
and X13, X27, #16376
and X13, X27, #16380
and X13, X27, #16382
and X13, X27, #16383
and X13, X27, #16384
and X13, X27, #24576
and X13, X27, #28672
and X13, X27, #30720
and X13, X27, #31744
and X13, X27, #32256
and X13, X27, #32512
and X13, X27, #32640
and X13, X27, #32704
and X13, X27, #32736
and X13, X27, #32752
and X13, X27, #32760
and X13, X27, #32764
and X13, X27, #32766
and X13, X27, #32767
and X13, X27, #32768
and X13, X27, #49152
and X13, X27, #57344
and X13, X27, #61440
and X13, X27, #63488
and X13, X27, #64512
and X13, X27, #65024
and X13, X27, #65280
and X13, X27, #65408
and X13, X27, #65472
and X13, X27, #65504
and X13, X27, #65520
and X13, X27, #65528
and X13, X27, #65532
and X13, X27, #65534
and X13, X27, #65535
and X13, X27, #65536
and X13, X27, #98304
and X13, X27, #114688
and X13, X27, #122880
and X13, X27, #126976
and X13, X27, #129024
and X13, X27, #130048
and X13, X27, #130560
and X13, X27, #130816
and X13, X27, #130944
and X13, X27, #131008
and X13, X27, #131040
and X13, X27, #131056
and X13, X27, #131064
and X13, X27, #131068
and X13, X27, #131070
and X13, X27, #131071
and X13, X27, #131072
and X13, X27, #196608
and X13, X27, #229376
and X13, X27, #245760
and X13, X27, #253952
and X13, X27, #258048
and X13, X27, #260096
and X13, X27, #261120
and X13, X27, #261632
and X13, X27, #261888
and X13, X27, #262016
and X13, X27, #262080
and X13, X27, #262112
and X13, X27, #262128
and X13, X27, #262136
and X13, X27, #262140
and X13, X27, #262142
and X13, X27, #262143
and X13, X27, #262144
and X13, X27, #393216
and X13, X27, #458752
and X13, X27, #491520
and X13, X27, #507904
and X13, X27, #516096
and X13, X27, #520192
and X13, X27, #522240
and X13, X27, #523264
and X13, X27, #523776
and X13, X27, #524032
and X13, X27, #524160
and X13, X27, #524224
and X13, X27, #524256
and X13, X27, #524272
and X13, X27, #524280
and X13, X27, #524284
and X13, X27, #524286
and X13, X27, #524287
and X13, X27, #524288
and X13, X27, #786432
and X13, X27, #917504
and X13, X27, #983040
and X13, X27, #1015808
and X13, X27, #1032192
and X13, X27, #1040384
and X13, X27, #1044480
and X13, X27, #1046528
and X13, X27, #1047552
and X13, X27, #1048064
and X13, X27, #1048320
and X13, X27, #1048448
and X13, X27, #1048512
and X13, X27, #1048544
and X13, X27, #1048560
and X13, X27, #1048568
and X13, X27, #1048572
and X13, X27, #1048574
and X13, X27, #1048575
and X13, X27, #1048576
and X13, X27, #1572864
and X13, X27, #1835008
and X13, X27, #1966080
and X13, X27, #2031616
and X13, X27, #2064384
and X13, X27, #2080768
and X13, X27, #2088960
and X13, X27, #2093056
and X13, X27, #2095104
and X13, X27, #2096128
and X13, X27, #2096640
and X13, X27, #2096896
and X13, X27, #2097024
and X13, X27, #2097088
and X13, X27, #2097120
and X13, X27, #2097136
and X13, X27, #2097144
and X13, X27, #2097148
and X13, X27, #2097150
and X13, X27, #2097151
and X13, X27, #2097152
and X13, X27, #3145728
and X13, X27, #3670016
and X13, X27, #3932160
and X13, X27, #4063232
and X13, X27, #4128768
and X13, X27, #4161536
and X13, X27, #4177920
and X13, X27, #4186112
and X13, X27, #4190208
and X13, X27, #4192256
and X13, X27, #4193280
and X13, X27, #4193792
and X13, X27, #4194048
and X13, X27, #4194176
and X13, X27, #4194240
and X13, X27, #4194272
and X13, X27, #4194288
and X13, X27, #4194296
and X13, X27, #4194300
and X13, X27, #4194302
and X13, X27, #4194303
and X13, X27, #4194304
and X13, X27, #6291456
and X13, X27, #7340032
and X13, X27, #7864320
and X13, X27, #8126464
and X13, X27, #8257536
and X13, X27, #8323072
and X13, X27, #8355840
and X13, X27, #8372224
and X13, X27, #8380416
and X13, X27, #8384512
and X13, X27, #8386560
and X13, X27, #8387584
and X13, X27, #8388096
and X13, X27, #8388352
and X13, X27, #8388480
and X13, X27, #8388544
and X13, X27, #8388576
and X13, X27, #8388592
and X13, X27, #8388600
and X13, X27, #8388604
and X13, X27, #8388606
and X13, X27, #8388607
and X13, X27, #8388608
and X13, X27, #12582912
and X13, X27, #14680064
and X13, X27, #15728640
and X13, X27, #16252928
and X13, X27, #16515072
and X13, X27, #16646144
and X13, X27, #16711680
and X13, X27, #16744448
and X13, X27, #16760832
and X13, X27, #16769024
and X13, X27, #16773120
and X13, X27, #16775168
and X13, X27, #16776192
and X13, X27, #16776704
and X13, X27, #16776960
and X13, X27, #16777088
and X13, X27, #16777152
and X13, X27, #16777184
and X13, X27, #16777200
and X13, X27, #16777208
and X13, X27, #16777212
and X13, X27, #16777214
and X13, X27, #16777215
and X13, X27, #16777216
and X13, X27, #25165824
and X13, X27, #29360128
and X13, X27, #31457280
and X13, X27, #32505856
and X13, X27, #33030144
and X13, X27, #33292288
and X13, X27, #33423360
and X13, X27, #33488896
and X13, X27, #33521664
and X13, X27, #33538048
and X13, X27, #33546240
and X13, X27, #33550336
and X13, X27, #33552384
and X13, X27, #33553408
and X13, X27, #33553920
and X13, X27, #33554176
and X13, X27, #33554304
and X13, X27, #33554368
and X13, X27, #33554400
and X13, X27, #33554416
and X13, X27, #33554424
and X13, X27, #33554428
and X13, X27, #33554430
and X13, X27, #33554431
and X13, X27, #33554432
and X13, X27, #50331648
and X13, X27, #58720256
and X13, X27, #62914560
and X13, X27, #65011712
and X13, X27, #66060288
and X13, X27, #66584576
and X13, X27, #66846720
and X13, X27, #66977792
and X13, X27, #67043328
and X13, X27, #67076096
and X13, X27, #67092480
and X13, X27, #67100672
and X13, X27, #67104768
and X13, X27, #67106816
and X13, X27, #67107840
and X13, X27, #67108352
and X13, X27, #67108608
and X13, X27, #67108736
and X13, X27, #67108800
and X13, X27, #67108832
and X13, X27, #67108848
and X13, X27, #67108856
and X13, X27, #67108860
and X13, X27, #67108862
and X13, X27, #67108863
and X13, X27, #67108864
and X13, X27, #100663296
and X13, X27, #117440512
and X13, X27, #125829120
and X13, X27, #130023424
and X13, X27, #132120576
and X13, X27, #133169152
and X13, X27, #133693440
and X13, X27, #133955584
and X13, X27, #134086656
and X13, X27, #134152192
and X13, X27, #134184960
and X13, X27, #134201344
and X13, X27, #134209536
and X13, X27, #134213632
and X13, X27, #134215680
and X13, X27, #134216704
and X13, X27, #134217216
and X13, X27, #134217472
and X13, X27, #134217600
and X13, X27, #134217664
and X13, X27, #134217696
and X13, X27, #134217712
and X13, X27, #134217720
and X13, X27, #134217724
and X13, X27, #134217726
and X13, X27, #134217727
and X13, X27, #134217728
and X13, X27, #201326592
and X13, X27, #234881024
and X13, X27, #251658240
and X13, X27, #260046848
and X13, X27, #264241152
and X13, X27, #266338304
and X13, X27, #267386880
and X13, X27, #267911168
and X13, X27, #268173312
and X13, X27, #268304384
and X13, X27, #268369920
and X13, X27, #268402688
and X13, X27, #268419072
and X13, X27, #268427264
and X13, X27, #268431360
and X13, X27, #268433408
and X13, X27, #268434432
and X13, X27, #268434944
and X13, X27, #268435200
and X13, X27, #268435328
and X13, X27, #268435392
and X13, X27, #268435424
and X13, X27, #268435440
and X13, X27, #268435448
and X13, X27, #268435452
and X13, X27, #268435454
and X13, X27, #268435455
and X13, X27, #268435456
and X13, X27, #402653184
and X13, X27, #469762048
and X13, X27, #503316480
and X13, X27, #520093696
and X13, X27, #528482304
and X13, X27, #532676608
and X13, X27, #534773760
and X13, X27, #535822336
and X13, X27, #536346624
and X13, X27, #536608768
and X13, X27, #536739840
and X13, X27, #536805376
and X13, X27, #536838144
and X13, X27, #536854528
and X13, X27, #536862720
and X13, X27, #536866816
and X13, X27, #536868864
and X13, X27, #536869888
and X13, X27, #536870400
and X13, X27, #536870656
and X13, X27, #536870784
and X13, X27, #536870848
and X13, X27, #536870880
and X13, X27, #536870896
and X13, X27, #536870904
and X13, X27, #536870908
and X13, X27, #536870910
and X13, X27, #536870911
and X13, X27, #536870912
and X13, X27, #805306368
and X13, X27, #939524096
and X13, X27, #1006632960
and X13, X27, #1040187392
and X13, X27, #1056964608
and X13, X27, #1065353216
and X13, X27, #1069547520
and X13, X27, #1071644672
and X13, X27, #1072693248
and X13, X27, #1073217536
and X13, X27, #1073479680
and X13, X27, #1073610752
and X13, X27, #1073676288
and X13, X27, #1073709056
and X13, X27, #1073725440
and X13, X27, #1073733632
and X13, X27, #1073737728
and X13, X27, #1073739776
and X13, X27, #1073740800
and X13, X27, #1073741312
and X13, X27, #1073741568
and X13, X27, #1073741696
and X13, X27, #1073741760
and X13, X27, #1073741792
and X13, X27, #1073741808
and X13, X27, #1073741816
and X13, X27, #1073741820
and X13, X27, #1073741822
and X13, X27, #1073741823
and X13, X27, #1073741824
and X13, X27, #1610612736
and X13, X27, #1879048192
and X13, X27, #2013265920
and X13, X27, #2080374784
and X13, X27, #2113929216
and X13, X27, #2130706432
and X13, X27, #2139095040
and X13, X27, #2143289344
and X13, X27, #2145386496
and X13, X27, #2146435072
and X13, X27, #2146959360
and X13, X27, #2147221504
and X13, X27, #2147352576
and X13, X27, #2147418112
and X13, X27, #2147450880
and X13, X27, #2147467264
and X13, X27, #2147475456
and X13, X27, #2147479552
and X13, X27, #2147481600
and X13, X27, #2147482624
and X13, X27, #2147483136
and X13, X27, #2147483392
and X13, X27, #2147483520
and X13, X27, #2147483584
and X13, X27, #2147483616
and X13, X27, #2147483632
and X13, X27, #2147483640
and X13, X27, #2147483644
and X13, X27, #2147483646
and X13, X27, #2147483647
and X13, X27, #2147483648
and X13, X27, #3221225472
and X13, X27, #3758096384
and X13, X27, #4026531840
and X13, X27, #4160749568
and X13, X27, #4227858432
and X13, X27, #4261412864
and X13, X27, #4278190080
and X13, X27, #4286578688
and X13, X27, #4290772992
and X13, X27, #4292870144
and X13, X27, #4293918720
and X13, X27, #4294443008
and X13, X27, #4294705152
and X13, X27, #4294836224
and X13, X27, #4294901760
and X13, X27, #4294934528
and X13, X27, #4294950912
and X13, X27, #4294959104
and X13, X27, #4294963200
and X13, X27, #4294965248
and X13, X27, #4294966272
and X13, X27, #4294966784
and X13, X27, #4294967040
and X13, X27, #4294967168
and X13, X27, #4294967232
and X13, X27, #4294967264
and X13, X27, #4294967280
and X13, X27, #4294967288
and X13, X27, #4294967292
and X13, X27, #4294967294
and X13, X27, #4294967295
and X13, X27, #4294967296
and X13, X27, #4294967297
and X13, X27, #6442450944
and X13, X27, #7516192768
and X13, X27, #8053063680
and X13, X27, #8321499136
and X13, X27, #8455716864
and X13, X27, #8522825728
and X13, X27, #8556380160
and X13, X27, #8573157376
and X13, X27, #8581545984
and X13, X27, #8585740288
and X13, X27, #8587837440
and X13, X27, #8588886016
and X13, X27, #8589410304
and X13, X27, #8589672448
and X13, X27, #8589803520
and X13, X27, #8589869056
and X13, X27, #8589901824
and X13, X27, #8589918208
and X13, X27, #8589926400
and X13, X27, #8589930496
and X13, X27, #8589932544
and X13, X27, #8589933568
and X13, X27, #8589934080
and X13, X27, #8589934336
and X13, X27, #8589934464
and X13, X27, #8589934528
and X13, X27, #8589934560
and X13, X27, #8589934576
and X13, X27, #8589934584
and X13, X27, #8589934588
and X13, X27, #8589934590
and X13, X27, #8589934591
and X13, X27, #8589934592
and X13, X27, #8589934594
and X13, X27, #12884901888
and X13, X27, #12884901891
and X13, X27, #15032385536
and X13, X27, #16106127360
and X13, X27, #16642998272
and X13, X27, #16911433728
and X13, X27, #17045651456
and X13, X27, #17112760320
and X13, X27, #17146314752
and X13, X27, #17163091968
and X13, X27, #17171480576
and X13, X27, #17175674880
and X13, X27, #17177772032
and X13, X27, #17178820608
and X13, X27, #17179344896
and X13, X27, #17179607040
and X13, X27, #17179738112
and X13, X27, #17179803648
and X13, X27, #17179836416
and X13, X27, #17179852800
and X13, X27, #17179860992
and X13, X27, #17179865088
and X13, X27, #17179867136
and X13, X27, #17179868160
and X13, X27, #17179868672
and X13, X27, #17179868928
and X13, X27, #17179869056
and X13, X27, #17179869120
and X13, X27, #17179869152
and X13, X27, #17179869168
and X13, X27, #17179869176
and X13, X27, #17179869180
and X13, X27, #17179869182
and X13, X27, #17179869183
and X13, X27, #17179869184
and X13, X27, #17179869188
and X13, X27, #25769803776
and X13, X27, #25769803782
and X13, X27, #30064771072
and X13, X27, #30064771079
and X13, X27, #32212254720
and X13, X27, #33285996544
and X13, X27, #33822867456
and X13, X27, #34091302912
and X13, X27, #34225520640
and X13, X27, #34292629504
and X13, X27, #34326183936
and X13, X27, #34342961152
and X13, X27, #34351349760
and X13, X27, #34355544064
and X13, X27, #34357641216
and X13, X27, #34358689792
and X13, X27, #34359214080
and X13, X27, #34359476224
and X13, X27, #34359607296
and X13, X27, #34359672832
and X13, X27, #34359705600
and X13, X27, #34359721984
and X13, X27, #34359730176
and X13, X27, #34359734272
and X13, X27, #34359736320
and X13, X27, #34359737344
and X13, X27, #34359737856
and X13, X27, #34359738112
and X13, X27, #34359738240
and X13, X27, #34359738304
and X13, X27, #34359738336
and X13, X27, #34359738352
and X13, X27, #34359738360
and X13, X27, #34359738364
and X13, X27, #34359738366
and X13, X27, #34359738367
and X13, X27, #34359738368
and X13, X27, #34359738376
and X13, X27, #51539607552
and X13, X27, #51539607564
and X13, X27, #60129542144
and X13, X27, #60129542158
and X13, X27, #64424509440
and X13, X27, #64424509455
and X13, X27, #66571993088
and X13, X27, #67645734912
and X13, X27, #68182605824
and X13, X27, #68451041280
and X13, X27, #68585259008
and X13, X27, #68652367872
and X13, X27, #68685922304
and X13, X27, #68702699520
and X13, X27, #68711088128
and X13, X27, #68715282432
and X13, X27, #68717379584
and X13, X27, #68718428160
and X13, X27, #68718952448
and X13, X27, #68719214592
and X13, X27, #68719345664
and X13, X27, #68719411200
and X13, X27, #68719443968
and X13, X27, #68719460352
and X13, X27, #68719468544
and X13, X27, #68719472640
and X13, X27, #68719474688
and X13, X27, #68719475712
and X13, X27, #68719476224
and X13, X27, #68719476480
and X13, X27, #68719476608
and X13, X27, #68719476672
and X13, X27, #68719476704
and X13, X27, #68719476720
and X13, X27, #68719476728
and X13, X27, #68719476732
and X13, X27, #68719476734
and X13, X27, #68719476735
and X13, X27, #68719476736
and X13, X27, #68719476752
and X13, X27, #103079215104
and X13, X27, #103079215128
and X13, X27, #120259084288
and X13, X27, #120259084316
and X13, X27, #128849018880
and X13, X27, #128849018910
and X13, X27, #133143986176
and X13, X27, #133143986207
and X13, X27, #135291469824
and X13, X27, #136365211648
and X13, X27, #136902082560
and X13, X27, #137170518016
and X13, X27, #137304735744
and X13, X27, #137371844608
and X13, X27, #137405399040
and X13, X27, #137422176256
and X13, X27, #137430564864
and X13, X27, #137434759168
and X13, X27, #137436856320
and X13, X27, #137437904896
and X13, X27, #137438429184
and X13, X27, #137438691328
and X13, X27, #137438822400
and X13, X27, #137438887936
and X13, X27, #137438920704
and X13, X27, #137438937088
and X13, X27, #137438945280
and X13, X27, #137438949376
and X13, X27, #137438951424
and X13, X27, #137438952448
and X13, X27, #137438952960
and X13, X27, #137438953216
and X13, X27, #137438953344
and X13, X27, #137438953408
and X13, X27, #137438953440
and X13, X27, #137438953456
and X13, X27, #137438953464
and X13, X27, #137438953468
and X13, X27, #137438953470
and X13, X27, #137438953471
and X13, X27, #137438953472
and X13, X27, #137438953504
and X13, X27, #206158430208
and X13, X27, #206158430256
and X13, X27, #240518168576
and X13, X27, #240518168632
and X13, X27, #257698037760
and X13, X27, #257698037820
and X13, X27, #266287972352
and X13, X27, #266287972414
and X13, X27, #270582939648
and X13, X27, #270582939711
and X13, X27, #272730423296
and X13, X27, #273804165120
and X13, X27, #274341036032
and X13, X27, #274609471488
and X13, X27, #274743689216
and X13, X27, #274810798080
and X13, X27, #274844352512
and X13, X27, #274861129728
and X13, X27, #274869518336
and X13, X27, #274873712640
and X13, X27, #274875809792
and X13, X27, #274876858368
and X13, X27, #274877382656
and X13, X27, #274877644800
and X13, X27, #274877775872
and X13, X27, #274877841408
and X13, X27, #274877874176
and X13, X27, #274877890560
and X13, X27, #274877898752
and X13, X27, #274877902848
and X13, X27, #274877904896
and X13, X27, #274877905920
and X13, X27, #274877906432
and X13, X27, #274877906688
and X13, X27, #274877906816
and X13, X27, #274877906880
and X13, X27, #274877906912
and X13, X27, #274877906928
and X13, X27, #274877906936
and X13, X27, #274877906940
and X13, X27, #274877906942
and X13, X27, #274877906943
and X13, X27, #274877906944
and X13, X27, #274877907008
and X13, X27, #412316860416
and X13, X27, #412316860512
and X13, X27, #481036337152
and X13, X27, #481036337264
and X13, X27, #515396075520
and X13, X27, #515396075640
and X13, X27, #532575944704
and X13, X27, #532575944828
and X13, X27, #541165879296
and X13, X27, #541165879422
and X13, X27, #545460846592
and X13, X27, #545460846719
and X13, X27, #547608330240
and X13, X27, #548682072064
and X13, X27, #549218942976
and X13, X27, #549487378432
and X13, X27, #549621596160
and X13, X27, #549688705024
and X13, X27, #549722259456
and X13, X27, #549739036672
and X13, X27, #549747425280
and X13, X27, #549751619584
and X13, X27, #549753716736
and X13, X27, #549754765312
and X13, X27, #549755289600
and X13, X27, #549755551744
and X13, X27, #549755682816
and X13, X27, #549755748352
and X13, X27, #549755781120
and X13, X27, #549755797504
and X13, X27, #549755805696
and X13, X27, #549755809792
and X13, X27, #549755811840
and X13, X27, #549755812864
and X13, X27, #549755813376
and X13, X27, #549755813632
and X13, X27, #549755813760
and X13, X27, #549755813824
and X13, X27, #549755813856
and X13, X27, #549755813872
and X13, X27, #549755813880
and X13, X27, #549755813884
and X13, X27, #549755813886
and X13, X27, #549755813887
and X13, X27, #549755813888
and X13, X27, #549755814016
and X13, X27, #824633720832
and X13, X27, #824633721024
and X13, X27, #962072674304
and X13, X27, #962072674528
and X13, X27, #1030792151040
and X13, X27, #1030792151280
and X13, X27, #1065151889408
and X13, X27, #1065151889656
and X13, X27, #1082331758592
and X13, X27, #1082331758844
and X13, X27, #1090921693184
and X13, X27, #1090921693438
and X13, X27, #1095216660480
and X13, X27, #1095216660735
and X13, X27, #1097364144128
and X13, X27, #1098437885952
and X13, X27, #1098974756864
and X13, X27, #1099243192320
and X13, X27, #1099377410048
and X13, X27, #1099444518912
and X13, X27, #1099478073344
and X13, X27, #1099494850560
and X13, X27, #1099503239168
and X13, X27, #1099507433472
and X13, X27, #1099509530624
and X13, X27, #1099510579200
and X13, X27, #1099511103488
and X13, X27, #1099511365632
and X13, X27, #1099511496704
and X13, X27, #1099511562240
and X13, X27, #1099511595008
and X13, X27, #1099511611392
and X13, X27, #1099511619584
and X13, X27, #1099511623680
and X13, X27, #1099511625728
and X13, X27, #1099511626752
and X13, X27, #1099511627264
and X13, X27, #1099511627520
and X13, X27, #1099511627648
and X13, X27, #1099511627712
and X13, X27, #1099511627744
and X13, X27, #1099511627760
and X13, X27, #1099511627768
and X13, X27, #1099511627772
and X13, X27, #1099511627774
and X13, X27, #1099511627775
and X13, X27, #1099511627776
and X13, X27, #1099511628032
and X13, X27, #1649267441664
and X13, X27, #1649267442048
and X13, X27, #1924145348608
and X13, X27, #1924145349056
and X13, X27, #2061584302080
and X13, X27, #2061584302560
and X13, X27, #2130303778816
and X13, X27, #2130303779312
and X13, X27, #2164663517184
and X13, X27, #2164663517688
and X13, X27, #2181843386368
and X13, X27, #2181843386876
and X13, X27, #2190433320960
and X13, X27, #2190433321470
and X13, X27, #2194728288256
and X13, X27, #2194728288767
and X13, X27, #2196875771904
and X13, X27, #2197949513728
and X13, X27, #2198486384640
and X13, X27, #2198754820096
and X13, X27, #2198889037824
and X13, X27, #2198956146688
and X13, X27, #2198989701120
and X13, X27, #2199006478336
and X13, X27, #2199014866944
and X13, X27, #2199019061248
and X13, X27, #2199021158400
and X13, X27, #2199022206976
and X13, X27, #2199022731264
and X13, X27, #2199022993408
and X13, X27, #2199023124480
and X13, X27, #2199023190016
and X13, X27, #2199023222784
and X13, X27, #2199023239168
and X13, X27, #2199023247360
and X13, X27, #2199023251456
and X13, X27, #2199023253504
and X13, X27, #2199023254528
and X13, X27, #2199023255040
and X13, X27, #2199023255296
and X13, X27, #2199023255424
and X13, X27, #2199023255488
and X13, X27, #2199023255520
and X13, X27, #2199023255536
and X13, X27, #2199023255544
and X13, X27, #2199023255548
and X13, X27, #2199023255550
and X13, X27, #2199023255551
and X13, X27, #2199023255552
and X13, X27, #2199023256064
and X13, X27, #3298534883328
and X13, X27, #3298534884096
and X13, X27, #3848290697216
and X13, X27, #3848290698112
and X13, X27, #4123168604160
and X13, X27, #4123168605120
and X13, X27, #4260607557632
and X13, X27, #4260607558624
and X13, X27, #4329327034368
and X13, X27, #4329327035376
and X13, X27, #4363686772736
and X13, X27, #4363686773752
and X13, X27, #4380866641920
and X13, X27, #4380866642940
and X13, X27, #4389456576512
and X13, X27, #4389456577534
and X13, X27, #4393751543808
and X13, X27, #4393751544831
and X13, X27, #4395899027456
and X13, X27, #4396972769280
and X13, X27, #4397509640192
and X13, X27, #4397778075648
and X13, X27, #4397912293376
and X13, X27, #4397979402240
and X13, X27, #4398012956672
and X13, X27, #4398029733888
and X13, X27, #4398038122496
and X13, X27, #4398042316800
and X13, X27, #4398044413952
and X13, X27, #4398045462528
and X13, X27, #4398045986816
and X13, X27, #4398046248960
and X13, X27, #4398046380032
and X13, X27, #4398046445568
and X13, X27, #4398046478336
and X13, X27, #4398046494720
and X13, X27, #4398046502912
and X13, X27, #4398046507008
and X13, X27, #4398046509056
and X13, X27, #4398046510080
and X13, X27, #4398046510592
and X13, X27, #4398046510848
and X13, X27, #4398046510976
and X13, X27, #4398046511040
and X13, X27, #4398046511072
and X13, X27, #4398046511088
and X13, X27, #4398046511096
and X13, X27, #4398046511100
and X13, X27, #4398046511102
and X13, X27, #4398046511103
and X13, X27, #4398046511104
and X13, X27, #4398046512128
and X13, X27, #6597069766656
and X13, X27, #6597069768192
and X13, X27, #7696581394432
and X13, X27, #7696581396224
and X13, X27, #8246337208320
and X13, X27, #8246337210240
and X13, X27, #8521215115264
and X13, X27, #8521215117248
and X13, X27, #8658654068736
and X13, X27, #8658654070752
and X13, X27, #8727373545472
and X13, X27, #8727373547504
and X13, X27, #8761733283840
and X13, X27, #8761733285880
and X13, X27, #8778913153024
and X13, X27, #8778913155068
and X13, X27, #8787503087616
and X13, X27, #8787503089662
and X13, X27, #8791798054912
and X13, X27, #8791798056959
and X13, X27, #8793945538560
and X13, X27, #8795019280384
and X13, X27, #8795556151296
and X13, X27, #8795824586752
and X13, X27, #8795958804480
and X13, X27, #8796025913344
and X13, X27, #8796059467776
and X13, X27, #8796076244992
and X13, X27, #8796084633600
and X13, X27, #8796088827904
and X13, X27, #8796090925056
and X13, X27, #8796091973632
and X13, X27, #8796092497920
and X13, X27, #8796092760064
and X13, X27, #8796092891136
and X13, X27, #8796092956672
and X13, X27, #8796092989440
and X13, X27, #8796093005824
and X13, X27, #8796093014016
and X13, X27, #8796093018112
and X13, X27, #8796093020160
and X13, X27, #8796093021184
and X13, X27, #8796093021696
and X13, X27, #8796093021952
and X13, X27, #8796093022080
and X13, X27, #8796093022144
and X13, X27, #8796093022176
and X13, X27, #8796093022192
and X13, X27, #8796093022200
and X13, X27, #8796093022204
and X13, X27, #8796093022206
and X13, X27, #8796093022207
and X13, X27, #8796093022208
and X13, X27, #8796093024256
and X13, X27, #13194139533312
and X13, X27, #13194139536384
and X13, X27, #15393162788864
and X13, X27, #15393162792448
and X13, X27, #16492674416640
and X13, X27, #16492674420480
and X13, X27, #17042430230528
and X13, X27, #17042430234496
and X13, X27, #17317308137472
and X13, X27, #17317308141504
and X13, X27, #17454747090944
and X13, X27, #17454747095008
and X13, X27, #17523466567680
and X13, X27, #17523466571760
and X13, X27, #17557826306048
and X13, X27, #17557826310136
and X13, X27, #17575006175232
and X13, X27, #17575006179324
and X13, X27, #17583596109824
and X13, X27, #17583596113918
and X13, X27, #17587891077120
and X13, X27, #17587891081215
and X13, X27, #17590038560768
and X13, X27, #17591112302592
and X13, X27, #17591649173504
and X13, X27, #17591917608960
and X13, X27, #17592051826688
and X13, X27, #17592118935552
and X13, X27, #17592152489984
and X13, X27, #17592169267200
and X13, X27, #17592177655808
and X13, X27, #17592181850112
and X13, X27, #17592183947264
and X13, X27, #17592184995840
and X13, X27, #17592185520128
and X13, X27, #17592185782272
and X13, X27, #17592185913344
and X13, X27, #17592185978880
and X13, X27, #17592186011648
and X13, X27, #17592186028032
and X13, X27, #17592186036224
and X13, X27, #17592186040320
and X13, X27, #17592186042368
and X13, X27, #17592186043392
and X13, X27, #17592186043904
and X13, X27, #17592186044160
and X13, X27, #17592186044288
and X13, X27, #17592186044352
and X13, X27, #17592186044384
and X13, X27, #17592186044400
and X13, X27, #17592186044408
and X13, X27, #17592186044412
and X13, X27, #17592186044414
and X13, X27, #17592186044415
and X13, X27, #17592186044416
and X13, X27, #17592186048512
and X13, X27, #26388279066624
and X13, X27, #26388279072768
and X13, X27, #30786325577728
and X13, X27, #30786325584896
and X13, X27, #32985348833280
and X13, X27, #32985348840960
and X13, X27, #34084860461056
and X13, X27, #34084860468992
and X13, X27, #34634616274944
and X13, X27, #34634616283008
and X13, X27, #34909494181888
and X13, X27, #34909494190016
and X13, X27, #35046933135360
and X13, X27, #35046933143520
and X13, X27, #35115652612096
and X13, X27, #35115652620272
and X13, X27, #35150012350464
and X13, X27, #35150012358648
and X13, X27, #35167192219648
and X13, X27, #35167192227836
and X13, X27, #35175782154240
and X13, X27, #35175782162430
and X13, X27, #35180077121536
and X13, X27, #35180077129727
and X13, X27, #35182224605184
and X13, X27, #35183298347008
and X13, X27, #35183835217920
and X13, X27, #35184103653376
and X13, X27, #35184237871104
and X13, X27, #35184304979968
and X13, X27, #35184338534400
and X13, X27, #35184355311616
and X13, X27, #35184363700224
and X13, X27, #35184367894528
and X13, X27, #35184369991680
and X13, X27, #35184371040256
and X13, X27, #35184371564544
and X13, X27, #35184371826688
and X13, X27, #35184371957760
and X13, X27, #35184372023296
and X13, X27, #35184372056064
and X13, X27, #35184372072448
and X13, X27, #35184372080640
and X13, X27, #35184372084736
and X13, X27, #35184372086784
and X13, X27, #35184372087808
and X13, X27, #35184372088320
and X13, X27, #35184372088576
and X13, X27, #35184372088704
and X13, X27, #35184372088768
and X13, X27, #35184372088800
and X13, X27, #35184372088816
and X13, X27, #35184372088824
and X13, X27, #35184372088828
and X13, X27, #35184372088830
and X13, X27, #35184372088831
and X13, X27, #35184372088832
and X13, X27, #35184372097024
and X13, X27, #52776558133248
and X13, X27, #52776558145536
and X13, X27, #61572651155456
and X13, X27, #61572651169792
and X13, X27, #65970697666560
and X13, X27, #65970697681920
and X13, X27, #68169720922112
and X13, X27, #68169720937984
and X13, X27, #69269232549888
and X13, X27, #69269232566016
and X13, X27, #69818988363776
and X13, X27, #69818988380032
and X13, X27, #70093866270720
and X13, X27, #70093866287040
and X13, X27, #70231305224192
and X13, X27, #70231305240544
and X13, X27, #70300024700928
and X13, X27, #70300024717296
and X13, X27, #70334384439296
and X13, X27, #70334384455672
and X13, X27, #70351564308480
and X13, X27, #70351564324860
and X13, X27, #70360154243072
and X13, X27, #70360154259454
and X13, X27, #70364449210368
and X13, X27, #70364449226751
and X13, X27, #70366596694016
and X13, X27, #70367670435840
and X13, X27, #70368207306752
and X13, X27, #70368475742208
and X13, X27, #70368609959936
and X13, X27, #70368677068800
and X13, X27, #70368710623232
and X13, X27, #70368727400448
and X13, X27, #70368735789056
and X13, X27, #70368739983360
and X13, X27, #70368742080512
and X13, X27, #70368743129088
and X13, X27, #70368743653376
and X13, X27, #70368743915520
and X13, X27, #70368744046592
and X13, X27, #70368744112128
and X13, X27, #70368744144896
and X13, X27, #70368744161280
and X13, X27, #70368744169472
and X13, X27, #70368744173568
and X13, X27, #70368744175616
and X13, X27, #70368744176640
and X13, X27, #70368744177152
and X13, X27, #70368744177408
and X13, X27, #70368744177536
and X13, X27, #70368744177600
and X13, X27, #70368744177632
and X13, X27, #70368744177648
and X13, X27, #70368744177656
and X13, X27, #70368744177660
and X13, X27, #70368744177662
and X13, X27, #70368744177663
and X13, X27, #70368744177664
and X13, X27, #70368744194048
and X13, X27, #105553116266496
and X13, X27, #105553116291072
and X13, X27, #123145302310912
and X13, X27, #123145302339584
and X13, X27, #131941395333120
and X13, X27, #131941395363840
and X13, X27, #136339441844224
and X13, X27, #136339441875968
and X13, X27, #138538465099776
and X13, X27, #138538465132032
and X13, X27, #139637976727552
and X13, X27, #139637976760064
and X13, X27, #140187732541440
and X13, X27, #140187732574080
and X13, X27, #140462610448384
and X13, X27, #140462610481088
and X13, X27, #140600049401856
and X13, X27, #140600049434592
and X13, X27, #140668768878592
and X13, X27, #140668768911344
and X13, X27, #140703128616960
and X13, X27, #140703128649720
and X13, X27, #140720308486144
and X13, X27, #140720308518908
and X13, X27, #140728898420736
and X13, X27, #140728898453502
and X13, X27, #140733193388032
and X13, X27, #140733193420799
and X13, X27, #140735340871680
and X13, X27, #140736414613504
and X13, X27, #140736951484416
and X13, X27, #140737219919872
and X13, X27, #140737354137600
and X13, X27, #140737421246464
and X13, X27, #140737454800896
and X13, X27, #140737471578112
and X13, X27, #140737479966720
and X13, X27, #140737484161024
and X13, X27, #140737486258176
and X13, X27, #140737487306752
and X13, X27, #140737487831040
and X13, X27, #140737488093184
and X13, X27, #140737488224256
and X13, X27, #140737488289792
and X13, X27, #140737488322560
and X13, X27, #140737488338944
and X13, X27, #140737488347136
and X13, X27, #140737488351232
and X13, X27, #140737488353280
and X13, X27, #140737488354304
and X13, X27, #140737488354816
and X13, X27, #140737488355072
and X13, X27, #140737488355200
and X13, X27, #140737488355264
and X13, X27, #140737488355296
and X13, X27, #140737488355312
and X13, X27, #140737488355320
and X13, X27, #140737488355324
and X13, X27, #140737488355326
and X13, X27, #140737488355327
and X13, X27, #140737488355328
and X13, X27, #140737488388096
and X13, X27, #211106232532992
and X13, X27, #211106232582144
and X13, X27, #246290604621824
and X13, X27, #246290604679168
and X13, X27, #263882790666240
and X13, X27, #263882790727680
and X13, X27, #272678883688448
and X13, X27, #272678883751936
and X13, X27, #277076930199552
and X13, X27, #277076930264064
and X13, X27, #279275953455104
and X13, X27, #279275953520128
and X13, X27, #280375465082880
and X13, X27, #280375465148160
and X13, X27, #280925220896768
and X13, X27, #280925220962176
and X13, X27, #281200098803712
and X13, X27, #281200098869184
and X13, X27, #281337537757184
and X13, X27, #281337537822688
and X13, X27, #281406257233920
and X13, X27, #281406257299440
and X13, X27, #281440616972288
and X13, X27, #281440617037816
and X13, X27, #281457796841472
and X13, X27, #281457796907004
and X13, X27, #281466386776064
and X13, X27, #281466386841598
and X13, X27, #281470681743360
and X13, X27, #281470681808895
and X13, X27, #281472829227008
and X13, X27, #281473902968832
and X13, X27, #281474439839744
and X13, X27, #281474708275200
and X13, X27, #281474842492928
and X13, X27, #281474909601792
and X13, X27, #281474943156224
and X13, X27, #281474959933440
and X13, X27, #281474968322048
and X13, X27, #281474972516352
and X13, X27, #281474974613504
and X13, X27, #281474975662080
and X13, X27, #281474976186368
and X13, X27, #281474976448512
and X13, X27, #281474976579584
and X13, X27, #281474976645120
and X13, X27, #281474976677888
and X13, X27, #281474976694272
and X13, X27, #281474976702464
and X13, X27, #281474976706560
and X13, X27, #281474976708608
and X13, X27, #281474976709632
and X13, X27, #281474976710144
and X13, X27, #281474976710400
and X13, X27, #281474976710528
and X13, X27, #281474976710592
and X13, X27, #281474976710624
and X13, X27, #281474976710640
and X13, X27, #281474976710648
and X13, X27, #281474976710652
and X13, X27, #281474976710654
and X13, X27, #281474976710655
and X13, X27, #281474976710656
and X13, X27, #281474976776192
and X13, X27, #281479271743489
and X13, X27, #422212465065984
and X13, X27, #422212465164288
and X13, X27, #492581209243648
and X13, X27, #492581209358336
and X13, X27, #527765581332480
and X13, X27, #527765581455360
and X13, X27, #545357767376896
and X13, X27, #545357767503872
and X13, X27, #554153860399104
and X13, X27, #554153860528128
and X13, X27, #558551906910208
and X13, X27, #558551907040256
and X13, X27, #560750930165760
and X13, X27, #560750930296320
and X13, X27, #561850441793536
and X13, X27, #561850441924352
and X13, X27, #562400197607424
and X13, X27, #562400197738368
and X13, X27, #562675075514368
and X13, X27, #562675075645376
and X13, X27, #562812514467840
and X13, X27, #562812514598880
and X13, X27, #562881233944576
and X13, X27, #562881234075632
and X13, X27, #562915593682944
and X13, X27, #562915593814008
and X13, X27, #562932773552128
and X13, X27, #562932773683196
and X13, X27, #562941363486720
and X13, X27, #562941363617790
and X13, X27, #562945658454016
and X13, X27, #562945658585087
and X13, X27, #562947805937664
and X13, X27, #562948879679488
and X13, X27, #562949416550400
and X13, X27, #562949684985856
and X13, X27, #562949819203584
and X13, X27, #562949886312448
and X13, X27, #562949919866880
and X13, X27, #562949936644096
and X13, X27, #562949945032704
and X13, X27, #562949949227008
and X13, X27, #562949951324160
and X13, X27, #562949952372736
and X13, X27, #562949952897024
and X13, X27, #562949953159168
and X13, X27, #562949953290240
and X13, X27, #562949953355776
and X13, X27, #562949953388544
and X13, X27, #562949953404928
and X13, X27, #562949953413120
and X13, X27, #562949953417216
and X13, X27, #562949953419264
and X13, X27, #562949953420288
and X13, X27, #562949953420800
and X13, X27, #562949953421056
and X13, X27, #562949953421184
and X13, X27, #562949953421248
and X13, X27, #562949953421280
and X13, X27, #562949953421296
and X13, X27, #562949953421304
and X13, X27, #562949953421308
and X13, X27, #562949953421310
and X13, X27, #562949953421311
and X13, X27, #562949953421312
and X13, X27, #562949953552384
and X13, X27, #562958543486978
and X13, X27, #844424930131968
and X13, X27, #844424930328576
and X13, X27, #844437815230467
and X13, X27, #985162418487296
and X13, X27, #985162418716672
and X13, X27, #1055531162664960
and X13, X27, #1055531162910720
and X13, X27, #1090715534753792
and X13, X27, #1090715535007744
and X13, X27, #1108307720798208
and X13, X27, #1108307721056256
and X13, X27, #1117103813820416
and X13, X27, #1117103814080512
and X13, X27, #1121501860331520
and X13, X27, #1121501860592640
and X13, X27, #1123700883587072
and X13, X27, #1123700883848704
and X13, X27, #1124800395214848
and X13, X27, #1124800395476736
and X13, X27, #1125350151028736
and X13, X27, #1125350151290752
and X13, X27, #1125625028935680
and X13, X27, #1125625029197760
and X13, X27, #1125762467889152
and X13, X27, #1125762468151264
and X13, X27, #1125831187365888
and X13, X27, #1125831187628016
and X13, X27, #1125865547104256
and X13, X27, #1125865547366392
and X13, X27, #1125882726973440
and X13, X27, #1125882727235580
and X13, X27, #1125891316908032
and X13, X27, #1125891317170174
and X13, X27, #1125895611875328
and X13, X27, #1125895612137471
and X13, X27, #1125897759358976
and X13, X27, #1125898833100800
and X13, X27, #1125899369971712
and X13, X27, #1125899638407168
and X13, X27, #1125899772624896
and X13, X27, #1125899839733760
and X13, X27, #1125899873288192
and X13, X27, #1125899890065408
and X13, X27, #1125899898454016
and X13, X27, #1125899902648320
and X13, X27, #1125899904745472
and X13, X27, #1125899905794048
and X13, X27, #1125899906318336
and X13, X27, #1125899906580480
and X13, X27, #1125899906711552
and X13, X27, #1125899906777088
and X13, X27, #1125899906809856
and X13, X27, #1125899906826240
and X13, X27, #1125899906834432
and X13, X27, #1125899906838528
and X13, X27, #1125899906840576
and X13, X27, #1125899906841600
and X13, X27, #1125899906842112
and X13, X27, #1125899906842368
and X13, X27, #1125899906842496
and X13, X27, #1125899906842560
and X13, X27, #1125899906842592
and X13, X27, #1125899906842608
and X13, X27, #1125899906842616
and X13, X27, #1125899906842620
and X13, X27, #1125899906842622
and X13, X27, #1125899906842623
and X13, X27, #1125899906842624
and X13, X27, #1125899907104768
and X13, X27, #1125917086973956
and X13, X27, #1688849860263936
and X13, X27, #1688849860657152
and X13, X27, #1688875630460934
and X13, X27, #1970324836974592
and X13, X27, #1970324837433344
and X13, X27, #1970354902204423
and X13, X27, #2111062325329920
and X13, X27, #2111062325821440
and X13, X27, #2181431069507584
and X13, X27, #2181431070015488
and X13, X27, #2216615441596416
and X13, X27, #2216615442112512
and X13, X27, #2234207627640832
and X13, X27, #2234207628161024
and X13, X27, #2243003720663040
and X13, X27, #2243003721185280
and X13, X27, #2247401767174144
and X13, X27, #2247401767697408
and X13, X27, #2249600790429696
and X13, X27, #2249600790953472
and X13, X27, #2250700302057472
and X13, X27, #2250700302581504
and X13, X27, #2251250057871360
and X13, X27, #2251250058395520
and X13, X27, #2251524935778304
and X13, X27, #2251524936302528
and X13, X27, #2251662374731776
and X13, X27, #2251662375256032
and X13, X27, #2251731094208512
and X13, X27, #2251731094732784
and X13, X27, #2251765453946880
and X13, X27, #2251765454471160
and X13, X27, #2251782633816064
and X13, X27, #2251782634340348
and X13, X27, #2251791223750656
and X13, X27, #2251791224274942
and X13, X27, #2251795518717952
and X13, X27, #2251795519242239
and X13, X27, #2251797666201600
and X13, X27, #2251798739943424
and X13, X27, #2251799276814336
and X13, X27, #2251799545249792
and X13, X27, #2251799679467520
and X13, X27, #2251799746576384
and X13, X27, #2251799780130816
and X13, X27, #2251799796908032
and X13, X27, #2251799805296640
and X13, X27, #2251799809490944
and X13, X27, #2251799811588096
and X13, X27, #2251799812636672
and X13, X27, #2251799813160960
and X13, X27, #2251799813423104
and X13, X27, #2251799813554176
and X13, X27, #2251799813619712
and X13, X27, #2251799813652480
and X13, X27, #2251799813668864
and X13, X27, #2251799813677056
and X13, X27, #2251799813681152
and X13, X27, #2251799813683200
and X13, X27, #2251799813684224
and X13, X27, #2251799813684736
and X13, X27, #2251799813684992
and X13, X27, #2251799813685120
and X13, X27, #2251799813685184
and X13, X27, #2251799813685216
and X13, X27, #2251799813685232
and X13, X27, #2251799813685240
and X13, X27, #2251799813685244
and X13, X27, #2251799813685246
and X13, X27, #2251799813685247
and X13, X27, #2251799813685248
and X13, X27, #2251799814209536
and X13, X27, #2251834173947912
and X13, X27, #3377699720527872
and X13, X27, #3377699721314304
and X13, X27, #3377751260921868
and X13, X27, #3940649673949184
and X13, X27, #3940649674866688
and X13, X27, #3940709804408846
and X13, X27, #4222124650659840
and X13, X27, #4222124651642880
and X13, X27, #4222189076152335
and X13, X27, #4362862139015168
and X13, X27, #4362862140030976
and X13, X27, #4433230883192832
and X13, X27, #4433230884225024
and X13, X27, #4468415255281664
and X13, X27, #4468415256322048
and X13, X27, #4486007441326080
and X13, X27, #4486007442370560
and X13, X27, #4494803534348288
and X13, X27, #4494803535394816
and X13, X27, #4499201580859392
and X13, X27, #4499201581906944
and X13, X27, #4501400604114944
and X13, X27, #4501400605163008
and X13, X27, #4502500115742720
and X13, X27, #4502500116791040
and X13, X27, #4503049871556608
and X13, X27, #4503049872605056
and X13, X27, #4503324749463552
and X13, X27, #4503324750512064
and X13, X27, #4503462188417024
and X13, X27, #4503462189465568
and X13, X27, #4503530907893760
and X13, X27, #4503530908942320
and X13, X27, #4503565267632128
and X13, X27, #4503565268680696
and X13, X27, #4503582447501312
and X13, X27, #4503582448549884
and X13, X27, #4503591037435904
and X13, X27, #4503591038484478
and X13, X27, #4503595332403200
and X13, X27, #4503595333451775
and X13, X27, #4503597479886848
and X13, X27, #4503598553628672
and X13, X27, #4503599090499584
and X13, X27, #4503599358935040
and X13, X27, #4503599493152768
and X13, X27, #4503599560261632
and X13, X27, #4503599593816064
and X13, X27, #4503599610593280
and X13, X27, #4503599618981888
and X13, X27, #4503599623176192
and X13, X27, #4503599625273344
and X13, X27, #4503599626321920
and X13, X27, #4503599626846208
and X13, X27, #4503599627108352
and X13, X27, #4503599627239424
and X13, X27, #4503599627304960
and X13, X27, #4503599627337728
and X13, X27, #4503599627354112
and X13, X27, #4503599627362304
and X13, X27, #4503599627366400
and X13, X27, #4503599627368448
and X13, X27, #4503599627369472
and X13, X27, #4503599627369984
and X13, X27, #4503599627370240
and X13, X27, #4503599627370368
and X13, X27, #4503599627370432
and X13, X27, #4503599627370464
and X13, X27, #4503599627370480
and X13, X27, #4503599627370488
and X13, X27, #4503599627370492
and X13, X27, #4503599627370494
and X13, X27, #4503599627370495
and X13, X27, #4503599627370496
and X13, X27, #4503599628419072
and X13, X27, #4503668347895824
and X13, X27, #6755399441055744
and X13, X27, #6755399442628608
and X13, X27, #6755502521843736
and X13, X27, #7881299347898368
and X13, X27, #7881299349733376
and X13, X27, #7881419608817692
and X13, X27, #8444249301319680
and X13, X27, #8444249303285760
and X13, X27, #8444378152304670
and X13, X27, #8725724278030336
and X13, X27, #8725724280061952
and X13, X27, #8725857424048159
and X13, X27, #8866461766385664
and X13, X27, #8866461768450048
and X13, X27, #8936830510563328
and X13, X27, #8936830512644096
and X13, X27, #8972014882652160
and X13, X27, #8972014884741120
and X13, X27, #8989607068696576
and X13, X27, #8989607070789632
and X13, X27, #8998403161718784
and X13, X27, #8998403163813888
and X13, X27, #9002801208229888
and X13, X27, #9002801210326016
and X13, X27, #9005000231485440
and X13, X27, #9005000233582080
and X13, X27, #9006099743113216
and X13, X27, #9006099745210112
and X13, X27, #9006649498927104
and X13, X27, #9006649501024128
and X13, X27, #9006924376834048
and X13, X27, #9006924378931136
and X13, X27, #9007061815787520
and X13, X27, #9007061817884640
and X13, X27, #9007130535264256
and X13, X27, #9007130537361392
and X13, X27, #9007164895002624
and X13, X27, #9007164897099768
and X13, X27, #9007182074871808
and X13, X27, #9007182076968956
and X13, X27, #9007190664806400
and X13, X27, #9007190666903550
and X13, X27, #9007194959773696
and X13, X27, #9007194961870847
and X13, X27, #9007197107257344
and X13, X27, #9007198180999168
and X13, X27, #9007198717870080
and X13, X27, #9007198986305536
and X13, X27, #9007199120523264
and X13, X27, #9007199187632128
and X13, X27, #9007199221186560
and X13, X27, #9007199237963776
and X13, X27, #9007199246352384
and X13, X27, #9007199250546688
and X13, X27, #9007199252643840
and X13, X27, #9007199253692416
and X13, X27, #9007199254216704
and X13, X27, #9007199254478848
and X13, X27, #9007199254609920
and X13, X27, #9007199254675456
and X13, X27, #9007199254708224
and X13, X27, #9007199254724608
and X13, X27, #9007199254732800
and X13, X27, #9007199254736896
and X13, X27, #9007199254738944
and X13, X27, #9007199254739968
and X13, X27, #9007199254740480
and X13, X27, #9007199254740736
and X13, X27, #9007199254740864
and X13, X27, #9007199254740928
and X13, X27, #9007199254740960
and X13, X27, #9007199254740976
and X13, X27, #9007199254740984
and X13, X27, #9007199254740988
and X13, X27, #9007199254740990
and X13, X27, #9007199254740991
and X13, X27, #9007199254740992
and X13, X27, #9007199256838144
and X13, X27, #9007336695791648
and X13, X27, #13510798882111488
and X13, X27, #13510798885257216
and X13, X27, #13511005043687472
and X13, X27, #15762598695796736
and X13, X27, #15762598699466752
and X13, X27, #15762839217635384
and X13, X27, #16888498602639360
and X13, X27, #16888498606571520
and X13, X27, #16888756304609340
and X13, X27, #17451448556060672
and X13, X27, #17451448560123904
and X13, X27, #17451714848096318
and X13, X27, #17732923532771328
and X13, X27, #17732923536900096
and X13, X27, #17733194119839807
and X13, X27, #17873661021126656
and X13, X27, #17873661025288192
and X13, X27, #17944029765304320
and X13, X27, #17944029769482240
and X13, X27, #17979214137393152
and X13, X27, #17979214141579264
and X13, X27, #17996806323437568
and X13, X27, #17996806327627776
and X13, X27, #18005602416459776
and X13, X27, #18005602420652032
and X13, X27, #18010000462970880
and X13, X27, #18010000467164160
and X13, X27, #18012199486226432
and X13, X27, #18012199490420224
and X13, X27, #18013298997854208
and X13, X27, #18013299002048256
and X13, X27, #18013848753668096
and X13, X27, #18013848757862272
and X13, X27, #18014123631575040
and X13, X27, #18014123635769280
and X13, X27, #18014261070528512
and X13, X27, #18014261074722784
and X13, X27, #18014329790005248
and X13, X27, #18014329794199536
and X13, X27, #18014364149743616
and X13, X27, #18014364153937912
and X13, X27, #18014381329612800
and X13, X27, #18014381333807100
and X13, X27, #18014389919547392
and X13, X27, #18014389923741694
and X13, X27, #18014394214514688
and X13, X27, #18014394218708991
and X13, X27, #18014396361998336
and X13, X27, #18014397435740160
and X13, X27, #18014397972611072
and X13, X27, #18014398241046528
and X13, X27, #18014398375264256
and X13, X27, #18014398442373120
and X13, X27, #18014398475927552
and X13, X27, #18014398492704768
and X13, X27, #18014398501093376
and X13, X27, #18014398505287680
and X13, X27, #18014398507384832
and X13, X27, #18014398508433408
and X13, X27, #18014398508957696
and X13, X27, #18014398509219840
and X13, X27, #18014398509350912
and X13, X27, #18014398509416448
and X13, X27, #18014398509449216
and X13, X27, #18014398509465600
and X13, X27, #18014398509473792
and X13, X27, #18014398509477888
and X13, X27, #18014398509479936
and X13, X27, #18014398509480960
and X13, X27, #18014398509481472
and X13, X27, #18014398509481728
and X13, X27, #18014398509481856
and X13, X27, #18014398509481920
and X13, X27, #18014398509481952
and X13, X27, #18014398509481968
and X13, X27, #18014398509481976
and X13, X27, #18014398509481980
and X13, X27, #18014398509481982
and X13, X27, #18014398509481983
and X13, X27, #18014398509481984
and X13, X27, #18014398513676288
and X13, X27, #18014673391583296
and X13, X27, #27021597764222976
and X13, X27, #27021597770514432
and X13, X27, #27022010087374944
and X13, X27, #31525197391593472
and X13, X27, #31525197398933504
and X13, X27, #31525678435270768
and X13, X27, #33776997205278720
and X13, X27, #33776997213143040
and X13, X27, #33777512609218680
and X13, X27, #34902897112121344
and X13, X27, #34902897120247808
and X13, X27, #34903429696192636
and X13, X27, #35465847065542656
and X13, X27, #35465847073800192
and X13, X27, #35466388239679614
and X13, X27, #35747322042253312
and X13, X27, #35747322050576384
and X13, X27, #35747867511423103
and X13, X27, #35888059530608640
and X13, X27, #35888059538964480
and X13, X27, #35958428274786304
and X13, X27, #35958428283158528
and X13, X27, #35993612646875136
and X13, X27, #35993612655255552
and X13, X27, #36011204832919552
and X13, X27, #36011204841304064
and X13, X27, #36020000925941760
and X13, X27, #36020000934328320
and X13, X27, #36024398972452864
and X13, X27, #36024398980840448
and X13, X27, #36026597995708416
and X13, X27, #36026598004096512
and X13, X27, #36027697507336192
and X13, X27, #36027697515724544
and X13, X27, #36028247263150080
and X13, X27, #36028247271538560
and X13, X27, #36028522141057024
and X13, X27, #36028522149445568
and X13, X27, #36028659580010496
and X13, X27, #36028659588399072
and X13, X27, #36028728299487232
and X13, X27, #36028728307875824
and X13, X27, #36028762659225600
and X13, X27, #36028762667614200
and X13, X27, #36028779839094784
and X13, X27, #36028779847483388
and X13, X27, #36028788429029376
and X13, X27, #36028788437417982
and X13, X27, #36028792723996672
and X13, X27, #36028792732385279
and X13, X27, #36028794871480320
and X13, X27, #36028795945222144
and X13, X27, #36028796482093056
and X13, X27, #36028796750528512
and X13, X27, #36028796884746240
and X13, X27, #36028796951855104
and X13, X27, #36028796985409536
and X13, X27, #36028797002186752
and X13, X27, #36028797010575360
and X13, X27, #36028797014769664
and X13, X27, #36028797016866816
and X13, X27, #36028797017915392
and X13, X27, #36028797018439680
and X13, X27, #36028797018701824
and X13, X27, #36028797018832896
and X13, X27, #36028797018898432
and X13, X27, #36028797018931200
and X13, X27, #36028797018947584
and X13, X27, #36028797018955776
and X13, X27, #36028797018959872
and X13, X27, #36028797018961920
and X13, X27, #36028797018962944
and X13, X27, #36028797018963456
and X13, X27, #36028797018963712
and X13, X27, #36028797018963840
and X13, X27, #36028797018963904
and X13, X27, #36028797018963936
and X13, X27, #36028797018963952
and X13, X27, #36028797018963960
and X13, X27, #36028797018963964
and X13, X27, #36028797018963966
and X13, X27, #36028797018963967
and X13, X27, #36028797018963968
and X13, X27, #36028797027352576
and X13, X27, #36029346783166592
and X13, X27, #54043195528445952
and X13, X27, #54043195541028864
and X13, X27, #54044020174749888
and X13, X27, #63050394783186944
and X13, X27, #63050394797867008
and X13, X27, #63051356870541536
and X13, X27, #67553994410557440
and X13, X27, #67553994426286080
and X13, X27, #67555025218437360
and X13, X27, #69805794224242688
and X13, X27, #69805794240495616
and X13, X27, #69806859392385272
and X13, X27, #70931694131085312
and X13, X27, #70931694147600384
and X13, X27, #70932776479359228
and X13, X27, #71494644084506624
and X13, X27, #71494644101152768
and X13, X27, #71495735022846206
and X13, X27, #71776119061217280
and X13, X27, #71776119077928960
and X13, X27, #71777214294589695
and X13, X27, #71916856549572608
and X13, X27, #71916856566317056
and X13, X27, #71987225293750272
and X13, X27, #71987225310511104
and X13, X27, #72022409665839104
and X13, X27, #72022409682608128
and X13, X27, #72040001851883520
and X13, X27, #72040001868656640
and X13, X27, #72048797944905728
and X13, X27, #72048797961680896
and X13, X27, #72053195991416832
and X13, X27, #72053196008193024
and X13, X27, #72055395014672384
and X13, X27, #72055395031449088
and X13, X27, #72056494526300160
and X13, X27, #72056494543077120
and X13, X27, #72057044282114048
and X13, X27, #72057044298891136
and X13, X27, #72057319160020992
and X13, X27, #72057319176798144
and X13, X27, #72057456598974464
and X13, X27, #72057456615751648
and X13, X27, #72057525318451200
and X13, X27, #72057525335228400
and X13, X27, #72057559678189568
and X13, X27, #72057559694966776
and X13, X27, #72057576858058752
and X13, X27, #72057576874835964
and X13, X27, #72057585447993344
and X13, X27, #72057585464770558
and X13, X27, #72057589742960640
and X13, X27, #72057589759737855
and X13, X27, #72057591890444288
and X13, X27, #72057592964186112
and X13, X27, #72057593501057024
and X13, X27, #72057593769492480
and X13, X27, #72057593903710208
and X13, X27, #72057593970819072
and X13, X27, #72057594004373504
and X13, X27, #72057594021150720
and X13, X27, #72057594029539328
and X13, X27, #72057594033733632
and X13, X27, #72057594035830784
and X13, X27, #72057594036879360
and X13, X27, #72057594037403648
and X13, X27, #72057594037665792
and X13, X27, #72057594037796864
and X13, X27, #72057594037862400
and X13, X27, #72057594037895168
and X13, X27, #72057594037911552
and X13, X27, #72057594037919744
and X13, X27, #72057594037923840
and X13, X27, #72057594037925888
and X13, X27, #72057594037926912
and X13, X27, #72057594037927424
and X13, X27, #72057594037927680
and X13, X27, #72057594037927808
and X13, X27, #72057594037927872
and X13, X27, #72057594037927904
and X13, X27, #72057594037927920
and X13, X27, #72057594037927928
and X13, X27, #72057594037927932
and X13, X27, #72057594037927934
and X13, X27, #72057594037927935
and X13, X27, #72057594037927936
and X13, X27, #72057594054705152
and X13, X27, #72058693566333184
and X13, X27, #72340172838076673
and X13, X27, #108086391056891904
and X13, X27, #108086391082057728
and X13, X27, #108088040349499776
and X13, X27, #126100789566373888
and X13, X27, #126100789595734016
and X13, X27, #126102713741083072
and X13, X27, #135107988821114880
and X13, X27, #135107988852572160
and X13, X27, #135110050436874720
and X13, X27, #139611588448485376
and X13, X27, #139611588480991232
and X13, X27, #139613718784770544
and X13, X27, #141863388262170624
and X13, X27, #141863388295200768
and X13, X27, #141865552958718456
and X13, X27, #142989288169013248
and X13, X27, #142989288202305536
and X13, X27, #142991470045692412
and X13, X27, #143552238122434560
and X13, X27, #143552238155857920
and X13, X27, #143554428589179390
and X13, X27, #143833713099145216
and X13, X27, #143833713132634112
and X13, X27, #143835907860922879
and X13, X27, #143974450587500544
and X13, X27, #143974450621022208
and X13, X27, #144044819331678208
and X13, X27, #144044819365216256
and X13, X27, #144080003703767040
and X13, X27, #144080003737313280
and X13, X27, #144097595889811456
and X13, X27, #144097595923361792
and X13, X27, #144106391982833664
and X13, X27, #144106392016386048
and X13, X27, #144110790029344768
and X13, X27, #144110790062898176
and X13, X27, #144112989052600320
and X13, X27, #144112989086154240
and X13, X27, #144114088564228096
and X13, X27, #144114088597782272
and X13, X27, #144114638320041984
and X13, X27, #144114638353596288
and X13, X27, #144114913197948928
and X13, X27, #144114913231503296
and X13, X27, #144115050636902400
and X13, X27, #144115050670456800
and X13, X27, #144115119356379136
and X13, X27, #144115119389933552
and X13, X27, #144115153716117504
and X13, X27, #144115153749671928
and X13, X27, #144115170895986688
and X13, X27, #144115170929541116
and X13, X27, #144115179485921280
and X13, X27, #144115179519475710
and X13, X27, #144115183780888576
and X13, X27, #144115183814443007
and X13, X27, #144115185928372224
and X13, X27, #144115187002114048
and X13, X27, #144115187538984960
and X13, X27, #144115187807420416
and X13, X27, #144115187941638144
and X13, X27, #144115188008747008
and X13, X27, #144115188042301440
and X13, X27, #144115188059078656
and X13, X27, #144115188067467264
and X13, X27, #144115188071661568
and X13, X27, #144115188073758720
and X13, X27, #144115188074807296
and X13, X27, #144115188075331584
and X13, X27, #144115188075593728
and X13, X27, #144115188075724800
and X13, X27, #144115188075790336
and X13, X27, #144115188075823104
and X13, X27, #144115188075839488
and X13, X27, #144115188075847680
and X13, X27, #144115188075851776
and X13, X27, #144115188075853824
and X13, X27, #144115188075854848
and X13, X27, #144115188075855360
and X13, X27, #144115188075855616
and X13, X27, #144115188075855744
and X13, X27, #144115188075855808
and X13, X27, #144115188075855840
and X13, X27, #144115188075855856
and X13, X27, #144115188075855864
and X13, X27, #144115188075855868
and X13, X27, #144115188075855870
and X13, X27, #144115188075855871
and X13, X27, #144115188075855872
and X13, X27, #144115188109410304
and X13, X27, #144117387132666368
and X13, X27, #144680345676153346
and X13, X27, #216172782113783808
and X13, X27, #216172782164115456
and X13, X27, #216176080698999552
and X13, X27, #217020518514230019
and X13, X27, #252201579132747776
and X13, X27, #252201579191468032
and X13, X27, #252205427482166144
and X13, X27, #270215977642229760
and X13, X27, #270215977705144320
and X13, X27, #270220100873749440
and X13, X27, #279223176896970752
and X13, X27, #279223176961982464
and X13, X27, #279227437569541088
and X13, X27, #283726776524341248
and X13, X27, #283726776590401536
and X13, X27, #283731105917436912
and X13, X27, #285978576338026496
and X13, X27, #285978576404611072
and X13, X27, #285982940091384824
and X13, X27, #287104476244869120
and X13, X27, #287104476311715840
and X13, X27, #287108857178358780
and X13, X27, #287667426198290432
and X13, X27, #287667426265268224
and X13, X27, #287671815721845758
and X13, X27, #287948901175001088
and X13, X27, #287948901242044416
and X13, X27, #287953294993589247
and X13, X27, #288089638663356416
and X13, X27, #288089638730432512
and X13, X27, #288160007407534080
and X13, X27, #288160007474626560
and X13, X27, #288195191779622912
and X13, X27, #288195191846723584
and X13, X27, #288212783965667328
and X13, X27, #288212784032772096
and X13, X27, #288221580058689536
and X13, X27, #288221580125796352
and X13, X27, #288225978105200640
and X13, X27, #288225978172308480
and X13, X27, #288228177128456192
and X13, X27, #288228177195564544
and X13, X27, #288229276640083968
and X13, X27, #288229276707192576
and X13, X27, #288229826395897856
and X13, X27, #288229826463006592
and X13, X27, #288230101273804800
and X13, X27, #288230101340913600
and X13, X27, #288230238712758272
and X13, X27, #288230238779867104
and X13, X27, #288230307432235008
and X13, X27, #288230307499343856
and X13, X27, #288230341791973376
and X13, X27, #288230341859082232
and X13, X27, #288230358971842560
and X13, X27, #288230359038951420
and X13, X27, #288230367561777152
and X13, X27, #288230367628886014
and X13, X27, #288230371856744448
and X13, X27, #288230371923853311
and X13, X27, #288230374004228096
and X13, X27, #288230375077969920
and X13, X27, #288230375614840832
and X13, X27, #288230375883276288
and X13, X27, #288230376017494016
and X13, X27, #288230376084602880
and X13, X27, #288230376118157312
and X13, X27, #288230376134934528
and X13, X27, #288230376143323136
and X13, X27, #288230376147517440
and X13, X27, #288230376149614592
and X13, X27, #288230376150663168
and X13, X27, #288230376151187456
and X13, X27, #288230376151449600
and X13, X27, #288230376151580672
and X13, X27, #288230376151646208
and X13, X27, #288230376151678976
and X13, X27, #288230376151695360
and X13, X27, #288230376151703552
and X13, X27, #288230376151707648
and X13, X27, #288230376151709696
and X13, X27, #288230376151710720
and X13, X27, #288230376151711232
and X13, X27, #288230376151711488
and X13, X27, #288230376151711616
and X13, X27, #288230376151711680
and X13, X27, #288230376151711712
and X13, X27, #288230376151711728
and X13, X27, #288230376151711736
and X13, X27, #288230376151711740
and X13, X27, #288230376151711742
and X13, X27, #288230376151711743
and X13, X27, #288230376151711744
and X13, X27, #288230376218820608
and X13, X27, #288234774265332736
and X13, X27, #289360691352306692
and X13, X27, #432345564227567616
and X13, X27, #432345564328230912
and X13, X27, #432352161397999104
and X13, X27, #434041037028460038
and X13, X27, #504403158265495552
and X13, X27, #504403158382936064
and X13, X27, #504410854964332288
and X13, X27, #506381209866536711
and X13, X27, #540431955284459520
and X13, X27, #540431955410288640
and X13, X27, #540440201747498880
and X13, X27, #558446353793941504
and X13, X27, #558446353923964928
and X13, X27, #558454875139082176
and X13, X27, #567453553048682496
and X13, X27, #567453553180803072
and X13, X27, #567462211834873824
and X13, X27, #571957152676052992
and X13, X27, #571957152809222144
and X13, X27, #571965880182769648
and X13, X27, #574208952489738240
and X13, X27, #574208952623431680
and X13, X27, #574217714356717560
and X13, X27, #575334852396580864
and X13, X27, #575334852530536448
and X13, X27, #575343631443691516
and X13, X27, #575897802350002176
and X13, X27, #575897802484088832
and X13, X27, #575906589987178494
and X13, X27, #576179277326712832
and X13, X27, #576179277460865024
and X13, X27, #576188069258921983
and X13, X27, #576320014815068160
and X13, X27, #576320014949253120
and X13, X27, #576390383559245824
and X13, X27, #576390383693447168
and X13, X27, #576425567931334656
and X13, X27, #576425568065544192
and X13, X27, #576443160117379072
and X13, X27, #576443160251592704
and X13, X27, #576451956210401280
and X13, X27, #576451956344616960
and X13, X27, #576456354256912384
and X13, X27, #576456354391129088
and X13, X27, #576458553280167936
and X13, X27, #576458553414385152
and X13, X27, #576459652791795712
and X13, X27, #576459652926013184
and X13, X27, #576460202547609600
and X13, X27, #576460202681827200
and X13, X27, #576460477425516544
and X13, X27, #576460477559734208
and X13, X27, #576460614864470016
and X13, X27, #576460614998687712
and X13, X27, #576460683583946752
and X13, X27, #576460683718164464
and X13, X27, #576460717943685120
and X13, X27, #576460718077902840
and X13, X27, #576460735123554304
and X13, X27, #576460735257772028
and X13, X27, #576460743713488896
and X13, X27, #576460743847706622
and X13, X27, #576460748008456192
and X13, X27, #576460748142673919
and X13, X27, #576460750155939840
and X13, X27, #576460751229681664
and X13, X27, #576460751766552576
and X13, X27, #576460752034988032
and X13, X27, #576460752169205760
and X13, X27, #576460752236314624
and X13, X27, #576460752269869056
and X13, X27, #576460752286646272
and X13, X27, #576460752295034880
and X13, X27, #576460752299229184
and X13, X27, #576460752301326336
and X13, X27, #576460752302374912
and X13, X27, #576460752302899200
and X13, X27, #576460752303161344
and X13, X27, #576460752303292416
and X13, X27, #576460752303357952
and X13, X27, #576460752303390720
and X13, X27, #576460752303407104
and X13, X27, #576460752303415296
and X13, X27, #576460752303419392
and X13, X27, #576460752303421440
and X13, X27, #576460752303422464
and X13, X27, #576460752303422976
and X13, X27, #576460752303423232
and X13, X27, #576460752303423360
and X13, X27, #576460752303423424
and X13, X27, #576460752303423456
and X13, X27, #576460752303423472
and X13, X27, #576460752303423480
and X13, X27, #576460752303423484
and X13, X27, #576460752303423486
and X13, X27, #576460752303423487
and X13, X27, #576460752303423488
and X13, X27, #576460752437641216
and X13, X27, #576469548530665472
and X13, X27, #578721382704613384
and X13, X27, #864691128455135232
and X13, X27, #864691128656461824
and X13, X27, #864704322795998208
and X13, X27, #868082074056920076
and X13, X27, #1008806316530991104
and X13, X27, #1008806316765872128
and X13, X27, #1008821709928664576
and X13, X27, #1012762419733073422
and X13, X27, #1080863910568919040
and X13, X27, #1080863910820577280
and X13, X27, #1080880403494997760
and X13, X27, #1085102592571150095
and X13, X27, #1116892707587883008
and X13, X27, #1116892707847929856
and X13, X27, #1116909750278164352
and X13, X27, #1134907106097364992
and X13, X27, #1134907106361606144
and X13, X27, #1134924423669747648
and X13, X27, #1143914305352105984
and X13, X27, #1143914305618444288
and X13, X27, #1143931760365539296
and X13, X27, #1148417904979476480
and X13, X27, #1148417905246863360
and X13, X27, #1148435428713435120
and X13, X27, #1150669704793161728
and X13, X27, #1150669705061072896
and X13, X27, #1150687262887383032
and X13, X27, #1151795604700004352
and X13, X27, #1151795604968177664
and X13, X27, #1151813179974356988
and X13, X27, #1152358554653425664
and X13, X27, #1152358554921730048
and X13, X27, #1152376138517843966
and X13, X27, #1152640029630136320
and X13, X27, #1152640029898506240
and X13, X27, #1152657617789587455
and X13, X27, #1152780767118491648
and X13, X27, #1152780767386894336
and X13, X27, #1152851135862669312
and X13, X27, #1152851136131088384
and X13, X27, #1152886320234758144
and X13, X27, #1152886320503185408
and X13, X27, #1152903912420802560
and X13, X27, #1152903912689233920
and X13, X27, #1152912708513824768
and X13, X27, #1152912708782258176
and X13, X27, #1152917106560335872
and X13, X27, #1152917106828770304
and X13, X27, #1152919305583591424
and X13, X27, #1152919305852026368
and X13, X27, #1152920405095219200
and X13, X27, #1152920405363654400
and X13, X27, #1152920954851033088
and X13, X27, #1152920955119468416
and X13, X27, #1152921229728940032
and X13, X27, #1152921229997375424
and X13, X27, #1152921367167893504
and X13, X27, #1152921367436328928
and X13, X27, #1152921435887370240
and X13, X27, #1152921436155805680
and X13, X27, #1152921470247108608
and X13, X27, #1152921470515544056
and X13, X27, #1152921487426977792
and X13, X27, #1152921487695413244
and X13, X27, #1152921496016912384
and X13, X27, #1152921496285347838
and X13, X27, #1152921500311879680
and X13, X27, #1152921500580315135
and X13, X27, #1152921502459363328
and X13, X27, #1152921503533105152
and X13, X27, #1152921504069976064
and X13, X27, #1152921504338411520
and X13, X27, #1152921504472629248
and X13, X27, #1152921504539738112
and X13, X27, #1152921504573292544
and X13, X27, #1152921504590069760
and X13, X27, #1152921504598458368
and X13, X27, #1152921504602652672
and X13, X27, #1152921504604749824
and X13, X27, #1152921504605798400
and X13, X27, #1152921504606322688
and X13, X27, #1152921504606584832
and X13, X27, #1152921504606715904
and X13, X27, #1152921504606781440
and X13, X27, #1152921504606814208
and X13, X27, #1152921504606830592
and X13, X27, #1152921504606838784
and X13, X27, #1152921504606842880
and X13, X27, #1152921504606844928
and X13, X27, #1152921504606845952
and X13, X27, #1152921504606846464
and X13, X27, #1152921504606846720
and X13, X27, #1152921504606846848
and X13, X27, #1152921504606846912
and X13, X27, #1152921504606846944
and X13, X27, #1152921504606846960
and X13, X27, #1152921504606846968
and X13, X27, #1152921504606846972
and X13, X27, #1152921504606846974
and X13, X27, #1152921504606846975
and X13, X27, #1152921504606846976
and X13, X27, #1152921504875282432
and X13, X27, #1152939097061330944
and X13, X27, #1157442765409226768
and X13, X27, #1229782938247303441
and X13, X27, #1729382256910270464
and X13, X27, #1729382257312923648
and X13, X27, #1729408645591996416
and X13, X27, #1736164148113840152
and X13, X27, #2017612633061982208
and X13, X27, #2017612633531744256
and X13, X27, #2017643419857329152
and X13, X27, #2025524839466146844
and X13, X27, #2161727821137838080
and X13, X27, #2161727821641154560
and X13, X27, #2161760806989995520
and X13, X27, #2170205185142300190
and X13, X27, #2233785415175766016
and X13, X27, #2233785415695859712
and X13, X27, #2233819500556328704
and X13, X27, #2242545357980376863
and X13, X27, #2269814212194729984
and X13, X27, #2269814212723212288
and X13, X27, #2269848847339495296
and X13, X27, #2287828610704211968
and X13, X27, #2287828611236888576
and X13, X27, #2287863520731078592
and X13, X27, #2296835809958952960
and X13, X27, #2296835810493726720
and X13, X27, #2296870857426870240
and X13, X27, #2301339409586323456
and X13, X27, #2301339410122145792
and X13, X27, #2301374525774766064
and X13, X27, #2303591209400008704
and X13, X27, #2303591209936355328
and X13, X27, #2303626359948713976
and X13, X27, #2304717109306851328
and X13, X27, #2304717109843460096
and X13, X27, #2304752277035687932
and X13, X27, #2305280059260272640
and X13, X27, #2305280059797012480
and X13, X27, #2305315235579174910
and X13, X27, #2305561534236983296
and X13, X27, #2305561534773788672
and X13, X27, #2305596714850918399
and X13, X27, #2305702271725338624
and X13, X27, #2305702272262176768
and X13, X27, #2305772640469516288
and X13, X27, #2305772641006370816
and X13, X27, #2305807824841605120
and X13, X27, #2305807825378467840
and X13, X27, #2305825417027649536
and X13, X27, #2305825417564516352
and X13, X27, #2305834213120671744
and X13, X27, #2305834213657540608
and X13, X27, #2305838611167182848
and X13, X27, #2305838611704052736
and X13, X27, #2305840810190438400
and X13, X27, #2305840810727308800
and X13, X27, #2305841909702066176
and X13, X27, #2305841910238936832
and X13, X27, #2305842459457880064
and X13, X27, #2305842459994750848
and X13, X27, #2305842734335787008
and X13, X27, #2305842734872657856
and X13, X27, #2305842871774740480
and X13, X27, #2305842872311611360
and X13, X27, #2305842940494217216
and X13, X27, #2305842941031088112
and X13, X27, #2305842974853955584
and X13, X27, #2305842975390826488
and X13, X27, #2305842992033824768
and X13, X27, #2305842992570695676
and X13, X27, #2305843000623759360
and X13, X27, #2305843001160630270
and X13, X27, #2305843004918726656
and X13, X27, #2305843005455597567
and X13, X27, #2305843007066210304
and X13, X27, #2305843008139952128
and X13, X27, #2305843008676823040
and X13, X27, #2305843008945258496
and X13, X27, #2305843009079476224
and X13, X27, #2305843009146585088
and X13, X27, #2305843009180139520
and X13, X27, #2305843009196916736
and X13, X27, #2305843009205305344
and X13, X27, #2305843009209499648
and X13, X27, #2305843009211596800
and X13, X27, #2305843009212645376
and X13, X27, #2305843009213169664
and X13, X27, #2305843009213431808
and X13, X27, #2305843009213562880
and X13, X27, #2305843009213628416
and X13, X27, #2305843009213661184
and X13, X27, #2305843009213677568
and X13, X27, #2305843009213685760
and X13, X27, #2305843009213689856
and X13, X27, #2305843009213691904
and X13, X27, #2305843009213692928
and X13, X27, #2305843009213693440
and X13, X27, #2305843009213693696
and X13, X27, #2305843009213693824
and X13, X27, #2305843009213693888
and X13, X27, #2305843009213693920
and X13, X27, #2305843009213693936
and X13, X27, #2305843009213693944
and X13, X27, #2305843009213693948
and X13, X27, #2305843009213693950
and X13, X27, #2305843009213693951
and X13, X27, #2305843009213693952
and X13, X27, #2305843009750564864
and X13, X27, #2305878194122661888
and X13, X27, #2314885530818453536
and X13, X27, #2459565876494606882
and X13, X27, #3458764513820540928
and X13, X27, #3458764514625847296
and X13, X27, #3458817291183992832
and X13, X27, #3472328296227680304
and X13, X27, #3689348814741910323
and X13, X27, #4035225266123964416
and X13, X27, #4035225267063488512
and X13, X27, #4035286839714658304
and X13, X27, #4051049678932293688
and X13, X27, #4323455642275676160
and X13, X27, #4323455643282309120
and X13, X27, #4323521613979991040
and X13, X27, #4340410370284600380
and X13, X27, #4467570830351532032
and X13, X27, #4467570831391719424
and X13, X27, #4467639001112657408
and X13, X27, #4485090715960753726
and X13, X27, #4539628424389459968
and X13, X27, #4539628425446424576
and X13, X27, #4539697694678990592
and X13, X27, #4557430888798830399
and X13, X27, #4575657221408423936
and X13, X27, #4575657222473777152
and X13, X27, #4575727041462157184
and X13, X27, #4593671619917905920
and X13, X27, #4593671620987453440
and X13, X27, #4593741714853740480
and X13, X27, #4602678819172646912
and X13, X27, #4602678820244291584
and X13, X27, #4602749051549532128
and X13, X27, #4607182418800017408
and X13, X27, #4607182419872710656
and X13, X27, #4607252719897427952
and X13, X27, #4609434218613702656
and X13, X27, #4609434219686920192
and X13, X27, #4609504554071375864
and X13, X27, #4610560118520545280
and X13, X27, #4610560119594024960
and X13, X27, #4610630471158349820
and X13, X27, #4611123068473966592
and X13, X27, #4611123069547577344
and X13, X27, #4611193429701836798
and X13, X27, #4611404543450677248
and X13, X27, #4611404544524353536
and X13, X27, #4611474908973580287
and X13, X27, #4611545280939032576
and X13, X27, #4611545282012741632
and X13, X27, #4611615649683210240
and X13, X27, #4611615650756935680
and X13, X27, #4611650834055299072
and X13, X27, #4611650835129032704
and X13, X27, #4611668426241343488
and X13, X27, #4611668427315081216
and X13, X27, #4611677222334365696
and X13, X27, #4611677223408105472
and X13, X27, #4611681620380876800
and X13, X27, #4611681621454617600
and X13, X27, #4611683819404132352
and X13, X27, #4611683820477873664
and X13, X27, #4611684918915760128
and X13, X27, #4611684919989501696
and X13, X27, #4611685468671574016
and X13, X27, #4611685469745315712
and X13, X27, #4611685743549480960
and X13, X27, #4611685744623222720
and X13, X27, #4611685880988434432
and X13, X27, #4611685882062176224
and X13, X27, #4611685949707911168
and X13, X27, #4611685950781652976
and X13, X27, #4611685984067649536
and X13, X27, #4611685985141391352
and X13, X27, #4611686001247518720
and X13, X27, #4611686002321260540
and X13, X27, #4611686009837453312
and X13, X27, #4611686010911195134
and X13, X27, #4611686014132420608
and X13, X27, #4611686015206162431
and X13, X27, #4611686016279904256
and X13, X27, #4611686017353646080
and X13, X27, #4611686017890516992
and X13, X27, #4611686018158952448
and X13, X27, #4611686018293170176
and X13, X27, #4611686018360279040
and X13, X27, #4611686018393833472
and X13, X27, #4611686018410610688
and X13, X27, #4611686018418999296
and X13, X27, #4611686018423193600
and X13, X27, #4611686018425290752
and X13, X27, #4611686018426339328
and X13, X27, #4611686018426863616
and X13, X27, #4611686018427125760
and X13, X27, #4611686018427256832
and X13, X27, #4611686018427322368
and X13, X27, #4611686018427355136
and X13, X27, #4611686018427371520
and X13, X27, #4611686018427379712
and X13, X27, #4611686018427383808
and X13, X27, #4611686018427385856
and X13, X27, #4611686018427386880
and X13, X27, #4611686018427387392
and X13, X27, #4611686018427387648
and X13, X27, #4611686018427387776
and X13, X27, #4611686018427387840
and X13, X27, #4611686018427387872
and X13, X27, #4611686018427387888
and X13, X27, #4611686018427387896
and X13, X27, #4611686018427387900
and X13, X27, #4611686018427387902
and X13, X27, #4611686018427387903
and X13, X27, #4611686018427387904
and X13, X27, #4611686019501129728
and X13, X27, #4611756388245323776
and X13, X27, #4629771061636907072
and X13, X27, #4919131752989213764
and X13, X27, #6148914691236517205
and X13, X27, #6917529027641081856
and X13, X27, #6917529029251694592
and X13, X27, #6917634582367985664
and X13, X27, #6944656592455360608
and X13, X27, #7378697629483820646
and X13, X27, #8070450532247928832
and X13, X27, #8070450534126977024
and X13, X27, #8070573679429316608
and X13, X27, #8102099357864587376
and X13, X27, #8608480567731124087
and X13, X27, #8646911284551352320
and X13, X27, #8646911286564618240
and X13, X27, #8647043227959982080
and X13, X27, #8680820740569200760
and X13, X27, #8935141660703064064
and X13, X27, #8935141662783438848
and X13, X27, #8935278002225314816
and X13, X27, #8970181431921507452
and X13, X27, #9079256848778919936
and X13, X27, #9079256850892849152
and X13, X27, #9079395389357981184
and X13, X27, #9114861777597660798
and X13, X27, #9151314442816847872
and X13, X27, #9151314444947554304
and X13, X27, #9151454082924314368
and X13, X27, #9187201950435737471
and X13, X27, #9187343239835811840
and X13, X27, #9187343241974906880
and X13, X27, #9187483429707480960
and X13, X27, #9205357638345293824
and X13, X27, #9205357640488583168
and X13, X27, #9205498103099064256
and X13, X27, #9214364837600034816
and X13, X27, #9214364839745421312
and X13, X27, #9214505439794855904
and X13, X27, #9218868437227405312
and X13, X27, #9218868439373840384
and X13, X27, #9219009108142751728
and X13, X27, #9221120237041090560
and X13, X27, #9221120239188049920
and X13, X27, #9221260942316699640
and X13, X27, #9222246136947933184
and X13, X27, #9222246139095154688
and X13, X27, #9222386859403673596
and X13, X27, #9222809086901354496
and X13, X27, #9222809089048707072
and X13, X27, #9222949817947160574
and X13, X27, #9223090561878065152
and X13, X27, #9223090564025483264
and X13, X27, #9223231297218904063
and X13, X27, #9223231299366420480
and X13, X27, #9223231301513871360
and X13, X27, #9223301668110598144
and X13, X27, #9223301670258065408
and X13, X27, #9223336852482686976
and X13, X27, #9223336854630162432
and X13, X27, #9223354444668731392
and X13, X27, #9223354446816210944
and X13, X27, #9223363240761753600
and X13, X27, #9223363242909235200
and X13, X27, #9223367638808264704
and X13, X27, #9223367640955747328
and X13, X27, #9223369837831520256
and X13, X27, #9223369839979003392
and X13, X27, #9223370937343148032
and X13, X27, #9223370939490631424
and X13, X27, #9223371487098961920
and X13, X27, #9223371489246445440
and X13, X27, #9223371761976868864
and X13, X27, #9223371764124352448
and X13, X27, #9223371899415822336
and X13, X27, #9223371901563305952
and X13, X27, #9223371968135299072
and X13, X27, #9223371970282782704
and X13, X27, #9223372002495037440
and X13, X27, #9223372004642521080
and X13, X27, #9223372019674906624
and X13, X27, #9223372021822390268
and X13, X27, #9223372028264841216
and X13, X27, #9223372030412324862
and X13, X27, #9223372032559808512
and X13, X27, #9223372034707292159
and X13, X27, #9223372034707292160
and X13, X27, #9223372035781033984
and X13, X27, #9223372036317904896
and X13, X27, #9223372036586340352
and X13, X27, #9223372036720558080
and X13, X27, #9223372036787666944
and X13, X27, #9223372036821221376
and X13, X27, #9223372036837998592
and X13, X27, #9223372036846387200
and X13, X27, #9223372036850581504
and X13, X27, #9223372036852678656
and X13, X27, #9223372036853727232
and X13, X27, #9223372036854251520
and X13, X27, #9223372036854513664
and X13, X27, #9223372036854644736
and X13, X27, #9223372036854710272
and X13, X27, #9223372036854743040
and X13, X27, #9223372036854759424
and X13, X27, #9223372036854767616
and X13, X27, #9223372036854771712
and X13, X27, #9223372036854773760
and X13, X27, #9223372036854774784
and X13, X27, #9223372036854775296
and X13, X27, #9223372036854775552
and X13, X27, #9223372036854775680
and X13, X27, #9223372036854775744
and X13, X27, #9223372036854775776
and X13, X27, #9223372036854775792
and X13, X27, #9223372036854775800
and X13, X27, #9223372036854775804
and X13, X27, #9223372036854775806
and X13, X27, #9223372036854775807
and X13, X27, #9223372036854775808
and X13, X27, #9223372036854775809
and X13, X27, #9223372036854775811
and X13, X27, #9223372036854775815
and X13, X27, #9223372036854775823
and X13, X27, #9223372036854775839
and X13, X27, #9223372036854775871
and X13, X27, #9223372036854775935
and X13, X27, #9223372036854776063
and X13, X27, #9223372036854776319
and X13, X27, #9223372036854776831
and X13, X27, #9223372036854777855
and X13, X27, #9223372036854779903
and X13, X27, #9223372036854783999
and X13, X27, #9223372036854792191
and X13, X27, #9223372036854808575
and X13, X27, #9223372036854841343
and X13, X27, #9223372036854906879
and X13, X27, #9223372036855037951
and X13, X27, #9223372036855300095
and X13, X27, #9223372036855824383
and X13, X27, #9223372036856872959
and X13, X27, #9223372036858970111
and X13, X27, #9223372036863164415
and X13, X27, #9223372036871553023
and X13, X27, #9223372036888330239
and X13, X27, #9223372036921884671
and X13, X27, #9223372036988993535
and X13, X27, #9223372037123211263
and X13, X27, #9223372037391646719
and X13, X27, #9223372037928517631
and X13, X27, #9223372039002259455
and X13, X27, #9223372039002259456
and X13, X27, #9223372041149743103
and X13, X27, #9223372043297226753
and X13, X27, #9223372045444710399
and X13, X27, #9223372051887161347
and X13, X27, #9223372054034644991
and X13, X27, #9223372069067030535
and X13, X27, #9223372071214514175
and X13, X27, #9223372103426768911
and X13, X27, #9223372105574252543
and X13, X27, #9223372172146245663
and X13, X27, #9223372174293729279
and X13, X27, #9223372309585199167
and X13, X27, #9223372311732682751
and X13, X27, #9223372584463106175
and X13, X27, #9223372586610589695
and X13, X27, #9223373134218920191
and X13, X27, #9223373136366403583
and X13, X27, #9223374233730548223
and X13, X27, #9223374235878031359
and X13, X27, #9223376432753804287
and X13, X27, #9223376434901286911
and X13, X27, #9223380830800316415
and X13, X27, #9223380832947798015
and X13, X27, #9223389626893340671
and X13, X27, #9223389629040820223
and X13, X27, #9223407219079389183
and X13, X27, #9223407221226864639
and X13, X27, #9223442403451486207
and X13, X27, #9223442405598953471
and X13, X27, #9223512772195680255
and X13, X27, #9223512774343131135
and X13, X27, #9223512776490647552
and X13, X27, #9223653509684068351
and X13, X27, #9223653511831486463
and X13, X27, #9223794255762391041
and X13, X27, #9223934984660844543
and X13, X27, #9223934986808197119
and X13, X27, #9224357214305878019
and X13, X27, #9224497934614396927
and X13, X27, #9224497936761618431
and X13, X27, #9225483131392851975
and X13, X27, #9225623834521501695
and X13, X27, #9225623836668461055
and X13, X27, #9227734965566799887
and X13, X27, #9227875634335711231
and X13, X27, #9227875636482146303
and X13, X27, #9232238633914695711
and X13, X27, #9232379233964130303
and X13, X27, #9232379236109516799
and X13, X27, #9241245970610487359
and X13, X27, #9241386433220968447
and X13, X27, #9241386435364257791
and X13, X27, #9259260644002070655
and X13, X27, #9259400831734644735
and X13, X27, #9259400833873739775
and X13, X27, #9259542123273814144
and X13, X27, #9295289990785237247
and X13, X27, #9295429628761997311
and X13, X27, #9295429630892703743
and X13, X27, #9331882296111890817
and X13, X27, #9367348684351570431
and X13, X27, #9367487222816702463
and X13, X27, #9367487224930631679
and X13, X27, #9476562641788044163
and X13, X27, #9511466071484236799
and X13, X27, #9511602410926112767
and X13, X27, #9511602413006487551
and X13, X27, #9765923333140350855
and X13, X27, #9799700845749569535
and X13, X27, #9799832787144933375
and X13, X27, #9799832789158199295
and X13, X27, #9838263505978427528
and X13, X27, #10344644715844964239
and X13, X27, #10376170394280235007
and X13, X27, #10376293539582574591
and X13, X27, #10376293541461622783
and X13, X27, #11068046444225730969
and X13, X27, #11502087481254191007
and X13, X27, #11529109491341565951
and X13, X27, #11529215044457857023
and X13, X27, #11529215046068469759
and X13, X27, #12297829382473034410
and X13, X27, #13527612320720337851
and X13, X27, #13816973012072644543
and X13, X27, #13834987685464227839
and X13, X27, #13835058054208421887
and X13, X27, #13835058055282163711
and X13, X27, #13835058055282163712
and X13, X27, #13835058055282163713
and X13, X27, #13835058055282163715
and X13, X27, #13835058055282163719
and X13, X27, #13835058055282163727
and X13, X27, #13835058055282163743
and X13, X27, #13835058055282163775
and X13, X27, #13835058055282163839
and X13, X27, #13835058055282163967
and X13, X27, #13835058055282164223
and X13, X27, #13835058055282164735
and X13, X27, #13835058055282165759
and X13, X27, #13835058055282167807
and X13, X27, #13835058055282171903
and X13, X27, #13835058055282180095
and X13, X27, #13835058055282196479
and X13, X27, #13835058055282229247
and X13, X27, #13835058055282294783
and X13, X27, #13835058055282425855
and X13, X27, #13835058055282687999
and X13, X27, #13835058055283212287
and X13, X27, #13835058055284260863
and X13, X27, #13835058055286358015
and X13, X27, #13835058055290552319
and X13, X27, #13835058055298940927
and X13, X27, #13835058055315718143
and X13, X27, #13835058055349272575
and X13, X27, #13835058055416381439
and X13, X27, #13835058055550599167
and X13, X27, #13835058055819034623
and X13, X27, #13835058056355905535
and X13, X27, #13835058057429647359
and X13, X27, #13835058058503389184
and X13, X27, #13835058059577131007
and X13, X27, #13835058062798356481
and X13, X27, #13835058063872098303
and X13, X27, #13835058071388291075
and X13, X27, #13835058072462032895
and X13, X27, #13835058088568160263
and X13, X27, #13835058089641902079
and X13, X27, #13835058122927898639
and X13, X27, #13835058124001640447
and X13, X27, #13835058191647375391
and X13, X27, #13835058192721117183
and X13, X27, #13835058329086328895
and X13, X27, #13835058330160070655
and X13, X27, #13835058603964235903
and X13, X27, #13835058605037977599
and X13, X27, #13835059153720049919
and X13, X27, #13835059154793791487
and X13, X27, #13835060253231677951
and X13, X27, #13835060254305419263
and X13, X27, #13835062452254934015
and X13, X27, #13835062453328674815
and X13, X27, #13835066850301446143
and X13, X27, #13835066851375185919
and X13, X27, #13835075646394470399
and X13, X27, #13835075647468208127
and X13, X27, #13835093238580518911
and X13, X27, #13835093239654252543
and X13, X27, #13835128422952615935
and X13, X27, #13835128424026341375
and X13, X27, #13835198791696809983
and X13, X27, #13835198792770519039
and X13, X27, #13835269164735971328
and X13, X27, #13835339529185198079
and X13, X27, #13835339530258874367
and X13, X27, #13835550644007714817
and X13, X27, #13835621004161974271
and X13, X27, #13835621005235585023
and X13, X27, #13836113602551201795
and X13, X27, #13836183954115526655
and X13, X27, #13836183955189006335
and X13, X27, #13837239519638175751
and X13, X27, #13837309854022631423
and X13, X27, #13837309855095848959
and X13, X27, #13839491353812123663
and X13, X27, #13839561653836840959
and X13, X27, #13839561654909534207
and X13, X27, #13843995022160019487
and X13, X27, #13844065253465260031
and X13, X27, #13844065254536904703
and X13, X27, #13853002358855811135
and X13, X27, #13853072452722098175
and X13, X27, #13853072453791645695
and X13, X27, #13871017032247394431
and X13, X27, #13871086851235774463
and X13, X27, #13871086852301127679
and X13, X27, #13889313184910721216
and X13, X27, #13907046379030561023
and X13, X27, #13907115648263127039
and X13, X27, #13907115649320091647
and X13, X27, #13961653357748797889
and X13, X27, #13979105072596894207
and X13, X27, #13979173242317832191
and X13, X27, #13979173243358019583
and X13, X27, #14106333703424951235
and X13, X27, #14123222459729560575
and X13, X27, #14123288430427242495
and X13, X27, #14123288431433875455
and X13, X27, #14395694394777257927
and X13, X27, #14411457233994893311
and X13, X27, #14411518806646063103
and X13, X27, #14411518807585587199
and X13, X27, #14757395258967641292
and X13, X27, #14974415777481871311
and X13, X27, #14987926782525558783
and X13, X27, #14987979559083704319
and X13, X27, #14987979559889010687
and X13, X27, #15987178197214944733
and X13, X27, #16131858542891098079
and X13, X27, #16140865879586889727
and X13, X27, #16140901063958986751
and X13, X27, #16140901064495857663
and X13, X27, #16140901064495857664
and X13, X27, #16140901064495857665
and X13, X27, #16140901064495857667
and X13, X27, #16140901064495857671
and X13, X27, #16140901064495857679
and X13, X27, #16140901064495857695
and X13, X27, #16140901064495857727
and X13, X27, #16140901064495857791
and X13, X27, #16140901064495857919
and X13, X27, #16140901064495858175
and X13, X27, #16140901064495858687
and X13, X27, #16140901064495859711
and X13, X27, #16140901064495861759
and X13, X27, #16140901064495865855
and X13, X27, #16140901064495874047
and X13, X27, #16140901064495890431
and X13, X27, #16140901064495923199
and X13, X27, #16140901064495988735
and X13, X27, #16140901064496119807
and X13, X27, #16140901064496381951
and X13, X27, #16140901064496906239
and X13, X27, #16140901064497954815
and X13, X27, #16140901064500051967
and X13, X27, #16140901064504246271
and X13, X27, #16140901064512634879
and X13, X27, #16140901064529412095
and X13, X27, #16140901064562966527
and X13, X27, #16140901064630075391
and X13, X27, #16140901064764293119
and X13, X27, #16140901065032728575
and X13, X27, #16140901065569599487
and X13, X27, #16140901066643341311
and X13, X27, #16140901068253954048
and X13, X27, #16140901068790824959
and X13, X27, #16140901072548921345
and X13, X27, #16140901073085792255
and X13, X27, #16140901081138855939
and X13, X27, #16140901081675726847
and X13, X27, #16140901098318725127
and X13, X27, #16140901098855596031
and X13, X27, #16140901132678463503
and X13, X27, #16140901133215334399
and X13, X27, #16140901201397940255
and X13, X27, #16140901201934811135
and X13, X27, #16140901338836893759
and X13, X27, #16140901339373764607
and X13, X27, #16140901613714800767
and X13, X27, #16140901614251671551
and X13, X27, #16140902163470614783
and X13, X27, #16140902164007485439
and X13, X27, #16140903262982242815
and X13, X27, #16140903263519113215
and X13, X27, #16140905462005498879
and X13, X27, #16140905462542368767
and X13, X27, #16140909860052011007
and X13, X27, #16140909860588879871
and X13, X27, #16140918656145035263
and X13, X27, #16140918656681902079
and X13, X27, #16140936248331083775
and X13, X27, #16140936248867946495
and X13, X27, #16140971432703180799
and X13, X27, #16140971433240035327
and X13, X27, #16141041801447374847
and X13, X27, #16141041801984212991
and X13, X27, #16141147358858633216
and X13, X27, #16141182538935762943
and X13, X27, #16141182539472568319
and X13, X27, #16141428838130376705
and X13, X27, #16141464013912539135
and X13, X27, #16141464014449278975
and X13, X27, #16141991796673863683
and X13, X27, #16142026963866091519
and X13, X27, #16142026964402700287
and X13, X27, #16143117713760837639
and X13, X27, #16143152863773196287
and X13, X27, #16143152864309542911
and X13, X27, #16145369547934785551
and X13, X27, #16145404663587405823
and X13, X27, #16145404664123228159
and X13, X27, #16149873216282681375
and X13, X27, #16149908263215824895
and X13, X27, #16149908263750598655
and X13, X27, #16158880552978473023
and X13, X27, #16158915462472663039
and X13, X27, #16158915463005339647
and X13, X27, #16176895226370056319
and X13, X27, #16176929860986339327
and X13, X27, #16176929861514821631
and X13, X27, #16204198715729174752
and X13, X27, #16212924573153222911
and X13, X27, #16212958658013691903
and X13, X27, #16212958658533785599
and X13, X27, #16276538888567251425
and X13, X27, #16284983266719556095
and X13, X27, #16285016252068397055
and X13, X27, #16285016252571713535
and X13, X27, #16421219234243404771
and X13, X27, #16429100653852222463
and X13, X27, #16429131440177807359
and X13, X27, #16429131440647569407
and X13, X27, #16710579925595711463
and X13, X27, #16717335428117555199
and X13, X27, #16717361816396627967
and X13, X27, #16717361816799281151
and X13, X27, #17216961135462248174
and X13, X27, #17289301308300324847
and X13, X27, #17293804976648220671
and X13, X27, #17293822568834269183
and X13, X27, #17293822569102704639
and X13, X27, #17293822569102704640
and X13, X27, #17293822569102704641
and X13, X27, #17293822569102704643
and X13, X27, #17293822569102704647
and X13, X27, #17293822569102704655
and X13, X27, #17293822569102704671
and X13, X27, #17293822569102704703
and X13, X27, #17293822569102704767
and X13, X27, #17293822569102704895
and X13, X27, #17293822569102705151
and X13, X27, #17293822569102705663
and X13, X27, #17293822569102706687
and X13, X27, #17293822569102708735
and X13, X27, #17293822569102712831
and X13, X27, #17293822569102721023
and X13, X27, #17293822569102737407
and X13, X27, #17293822569102770175
and X13, X27, #17293822569102835711
and X13, X27, #17293822569102966783
and X13, X27, #17293822569103228927
and X13, X27, #17293822569103753215
and X13, X27, #17293822569104801791
and X13, X27, #17293822569106898943
and X13, X27, #17293822569111093247
and X13, X27, #17293822569119481855
and X13, X27, #17293822569136259071
and X13, X27, #17293822569169813503
and X13, X27, #17293822569236922367
and X13, X27, #17293822569371140095
and X13, X27, #17293822569639575551
and X13, X27, #17293822570176446463
and X13, X27, #17293822571250188287
and X13, X27, #17293822573129236480
and X13, X27, #17293822573397671935
and X13, X27, #17293822577424203777
and X13, X27, #17293822577692639231
and X13, X27, #17293822586014138371
and X13, X27, #17293822586282573823
and X13, X27, #17293822603194007559
and X13, X27, #17293822603462443007
and X13, X27, #17293822637553745935
and X13, X27, #17293822637822181375
and X13, X27, #17293822706273222687
and X13, X27, #17293822706541658111
and X13, X27, #17293822843712176191
and X13, X27, #17293822843980611583
and X13, X27, #17293823118590083199
and X13, X27, #17293823118858518527
and X13, X27, #17293823668345897215
and X13, X27, #17293823668614332415
and X13, X27, #17293824767857525247
and X13, X27, #17293824768125960191
and X13, X27, #17293826966880781311
and X13, X27, #17293826967149215743
and X13, X27, #17293831364927293439
and X13, X27, #17293831365195726847
and X13, X27, #17293840161020317695
and X13, X27, #17293840161288749055
and X13, X27, #17293857753206366207
and X13, X27, #17293857753474793471
and X13, X27, #17293892937578463231
and X13, X27, #17293892937846882303
and X13, X27, #17293963306322657279
and X13, X27, #17293963306591059967
and X13, X27, #17294086455919964160
and X13, X27, #17294104043811045375
and X13, X27, #17294104044079415295
and X13, X27, #17294367935191707649
and X13, X27, #17294385518787821567
and X13, X27, #17294385519056125951
and X13, X27, #17294930893735194627
and X13, X27, #17294948468741373951
and X13, X27, #17294948469009547263
and X13, X27, #17296056810822168583
and X13, X27, #17296074368648478719
and X13, X27, #17296074368916389887
and X13, X27, #17298308644996116495
and X13, X27, #17298326168462688255
and X13, X27, #17298326168730075135
and X13, X27, #17302812313344012319
and X13, X27, #17302829768091107327
and X13, X27, #17302829768357445631
and X13, X27, #17311819650039803967
and X13, X27, #17311836967347945471
and X13, X27, #17311836967612186623
and X13, X27, #17329834323431387263
and X13, X27, #17329851365861621759
and X13, X27, #17329851366121668607
and X13, X27, #17361641481138401520
and X13, X27, #17365863670214553855
and X13, X27, #17365880162888974335
and X13, X27, #17365880163140632575
and X13, X27, #17433981653976478193
and X13, X27, #17437922363780887039
and X13, X27, #17437937756943679487
and X13, X27, #17437937757178560511
and X13, X27, #17578661999652631539
and X13, X27, #17582039750913553407
and X13, X27, #17582052945053089791
and X13, X27, #17582052945254416383
and X13, X27, #17868022691004938231
and X13, X27, #17870274525178886143
and X13, X27, #17870283321271910399
and X13, X27, #17870283321406128127
and X13, X27, #17870283321406128128
and X13, X27, #17870283321406128129
and X13, X27, #17870283321406128131
and X13, X27, #17870283321406128135
and X13, X27, #17870283321406128143
and X13, X27, #17870283321406128159
and X13, X27, #17870283321406128191
and X13, X27, #17870283321406128255
and X13, X27, #17870283321406128383
and X13, X27, #17870283321406128639
and X13, X27, #17870283321406129151
and X13, X27, #17870283321406130175
and X13, X27, #17870283321406132223
and X13, X27, #17870283321406136319
and X13, X27, #17870283321406144511
and X13, X27, #17870283321406160895
and X13, X27, #17870283321406193663
and X13, X27, #17870283321406259199
and X13, X27, #17870283321406390271
and X13, X27, #17870283321406652415
and X13, X27, #17870283321407176703
and X13, X27, #17870283321408225279
and X13, X27, #17870283321410322431
and X13, X27, #17870283321414516735
and X13, X27, #17870283321422905343
and X13, X27, #17870283321439682559
and X13, X27, #17870283321473236991
and X13, X27, #17870283321540345855
and X13, X27, #17870283321674563583
and X13, X27, #17870283321942999039
and X13, X27, #17870283322479869951
and X13, X27, #17870283323553611775
and X13, X27, #17870283325566877696
and X13, X27, #17870283325701095423
and X13, X27, #17870283329861844993
and X13, X27, #17870283329996062719
and X13, X27, #17870283338451779587
and X13, X27, #17870283338585997311
and X13, X27, #17870283355631648775
and X13, X27, #17870283355765866495
and X13, X27, #17870283389991387151
and X13, X27, #17870283390125604863
and X13, X27, #17870283458710863903
and X13, X27, #17870283458845081599
and X13, X27, #17870283596149817407
and X13, X27, #17870283596284035071
and X13, X27, #17870283871027724415
and X13, X27, #17870283871161942015
and X13, X27, #17870284420783538431
and X13, X27, #17870284420917755903
and X13, X27, #17870285520295166463
and X13, X27, #17870285520429383679
and X13, X27, #17870287719318422527
and X13, X27, #17870287719452639231
and X13, X27, #17870292117364934655
and X13, X27, #17870292117499150335
and X13, X27, #17870300913457958911
and X13, X27, #17870300913592172543
and X13, X27, #17870318505644007423
and X13, X27, #17870318505778216959
and X13, X27, #17870353690016104447
and X13, X27, #17870353690150305791
and X13, X27, #17870424058760298495
and X13, X27, #17870424058894483455
and X13, X27, #17870556004450629632
and X13, X27, #17870564796248686591
and X13, X27, #17870564796382838783
and X13, X27, #17870837483722373121
and X13, X27, #17870846271225462783
and X13, X27, #17870846271359549439
and X13, X27, #17871400442265860099
and X13, X27, #17871409221179015167
and X13, X27, #17871409221312970751
and X13, X27, #17872526359352834055
and X13, X27, #17872535121086119935
and X13, X27, #17872535121219813375
and X13, X27, #17874778193526781967
and X13, X27, #17874786920900329471
and X13, X27, #17874786921033498623
and X13, X27, #17879281861874677791
and X13, X27, #17879290520528748543
and X13, X27, #17879290520660869119
and X13, X27, #17888289198570469439
and X13, X27, #17888297719785586687
and X13, X27, #17888297719915610111
and X13, X27, #17906303871962052735
and X13, X27, #17906312118299262975
and X13, X27, #17906312118425092095
and X13, X27, #17940362863843014904
and X13, X27, #17942333218745219327
and X13, X27, #17942340915326615551
and X13, X27, #17942340915444056063
and X13, X27, #18012703036681091577
and X13, X27, #18014391912311552511
and X13, X27, #18014398509381320703
and X13, X27, #18014398509481983999
and X13, X27, #18157383382357244923
and X13, X27, #18158509299444218879
and X13, X27, #18158513697490731007
and X13, X27, #18158513697557839871
and X13, X27, #18158513697557839872
and X13, X27, #18158513697557839873
and X13, X27, #18158513697557839875
and X13, X27, #18158513697557839879
and X13, X27, #18158513697557839887
and X13, X27, #18158513697557839903
and X13, X27, #18158513697557839935
and X13, X27, #18158513697557839999
and X13, X27, #18158513697557840127
and X13, X27, #18158513697557840383
and X13, X27, #18158513697557840895
and X13, X27, #18158513697557841919
and X13, X27, #18158513697557843967
and X13, X27, #18158513697557848063
and X13, X27, #18158513697557856255
and X13, X27, #18158513697557872639
and X13, X27, #18158513697557905407
and X13, X27, #18158513697557970943
and X13, X27, #18158513697558102015
and X13, X27, #18158513697558364159
and X13, X27, #18158513697558888447
and X13, X27, #18158513697559937023
and X13, X27, #18158513697562034175
and X13, X27, #18158513697566228479
and X13, X27, #18158513697574617087
and X13, X27, #18158513697591394303
and X13, X27, #18158513697624948735
and X13, X27, #18158513697692057599
and X13, X27, #18158513697826275327
and X13, X27, #18158513698094710783
and X13, X27, #18158513698631581695
and X13, X27, #18158513699705323519
and X13, X27, #18158513701785698304
and X13, X27, #18158513701852807167
and X13, X27, #18158513706080665601
and X13, X27, #18158513706147774463
and X13, X27, #18158513714670600195
and X13, X27, #18158513714737709055
and X13, X27, #18158513731850469383
and X13, X27, #18158513731917578239
and X13, X27, #18158513766210207759
and X13, X27, #18158513766277316607
and X13, X27, #18158513834929684511
and X13, X27, #18158513834996793343
and X13, X27, #18158513972368638015
and X13, X27, #18158513972435746815
and X13, X27, #18158514247246545023
and X13, X27, #18158514247313653759
and X13, X27, #18158514797002359039
and X13, X27, #18158514797069467647
and X13, X27, #18158515896513987071
and X13, X27, #18158515896581095423
and X13, X27, #18158518095537243135
and X13, X27, #18158518095604350975
and X13, X27, #18158522493583755263
and X13, X27, #18158522493650862079
and X13, X27, #18158531289676779519
and X13, X27, #18158531289743884287
and X13, X27, #18158548881862828031
and X13, X27, #18158548881929928703
and X13, X27, #18158584066234925055
and X13, X27, #18158584066302017535
and X13, X27, #18158654434979119103
and X13, X27, #18158654435046195199
and X13, X27, #18158790778715962368
and X13, X27, #18158795172467507199
and X13, X27, #18158795172534550527
and X13, X27, #18159072257987705857
and X13, X27, #18159076647444283391
and X13, X27, #18159076647511261183
and X13, X27, #18159635216531192835
and X13, X27, #18159639597397835775
and X13, X27, #18159639597464682495
and X13, X27, #18160761133618166791
and X13, X27, #18160765497304940543
and X13, X27, #18160765497371525119
and X13, X27, #18163012967792114703
and X13, X27, #18163017297119150079
and X13, X27, #18163017297185210367
and X13, X27, #18167516636140010527
and X13, X27, #18167520896747569151
and X13, X27, #18167520896812580863
and X13, X27, #18176523972835802175
and X13, X27, #18176528096004407295
and X13, X27, #18176528096067321855
and X13, X27, #18194538646227385471
and X13, X27, #18194542494518083583
and X13, X27, #18194542494576803839
and X13, X27, #18229723555195321596
and X13, X27, #18230567993010552063
and X13, X27, #18230571291545436159
and X13, X27, #18230571291595767807
and X13, X27, #18302063728033398269
and X13, X27, #18302626686576885247
and X13, X27, #18302628885600141311
and X13, X27, #18302628885633695743
and X13, X27, #18302628885633695744
and X13, X27, #18302628885633695745
and X13, X27, #18302628885633695747
and X13, X27, #18302628885633695751
and X13, X27, #18302628885633695759
and X13, X27, #18302628885633695775
and X13, X27, #18302628885633695807
and X13, X27, #18302628885633695871
and X13, X27, #18302628885633695999
and X13, X27, #18302628885633696255
and X13, X27, #18302628885633696767
and X13, X27, #18302628885633697791
and X13, X27, #18302628885633699839
and X13, X27, #18302628885633703935
and X13, X27, #18302628885633712127
and X13, X27, #18302628885633728511
and X13, X27, #18302628885633761279
and X13, X27, #18302628885633826815
and X13, X27, #18302628885633957887
and X13, X27, #18302628885634220031
and X13, X27, #18302628885634744319
and X13, X27, #18302628885635792895
and X13, X27, #18302628885637890047
and X13, X27, #18302628885642084351
and X13, X27, #18302628885650472959
and X13, X27, #18302628885667250175
and X13, X27, #18302628885700804607
and X13, X27, #18302628885767913471
and X13, X27, #18302628885902131199
and X13, X27, #18302628886170566655
and X13, X27, #18302628886707437567
and X13, X27, #18302628887781179391
and X13, X27, #18302628889895108608
and X13, X27, #18302628889928663039
and X13, X27, #18302628894190075905
and X13, X27, #18302628894223630335
and X13, X27, #18302628902780010499
and X13, X27, #18302628902813564927
and X13, X27, #18302628919959879687
and X13, X27, #18302628919993434111
and X13, X27, #18302628954319618063
and X13, X27, #18302628954353172479
and X13, X27, #18302629023039094815
and X13, X27, #18302629023072649215
and X13, X27, #18302629160478048319
and X13, X27, #18302629160511602687
and X13, X27, #18302629435355955327
and X13, X27, #18302629435389509631
and X13, X27, #18302629985111769343
and X13, X27, #18302629985145323519
and X13, X27, #18302631084623397375
and X13, X27, #18302631084656951295
and X13, X27, #18302633283646653439
and X13, X27, #18302633283680206847
and X13, X27, #18302637681693165567
and X13, X27, #18302637681726717951
and X13, X27, #18302646477786189823
and X13, X27, #18302646477819740159
and X13, X27, #18302664069972238335
and X13, X27, #18302664070005784575
and X13, X27, #18302699254344335359
and X13, X27, #18302699254377873407
and X13, X27, #18302769623088529407
and X13, X27, #18302769623122051071
and X13, X27, #18302908165848628736
and X13, X27, #18302910360576917503
and X13, X27, #18302910360610406399
and X13, X27, #18303189645120372225
and X13, X27, #18303191835553693695
and X13, X27, #18303191835587117055
and X13, X27, #18303752603663859203
and X13, X27, #18303754785507246079
and X13, X27, #18303754785540538367
and X13, X27, #18304878520750833159
and X13, X27, #18304880685414350847
and X13, X27, #18304880685447380991
and X13, X27, #18307130354924781071
and X13, X27, #18307132485228560383
and X13, X27, #18307132485261066239
and X13, X27, #18311634023272676895
and X13, X27, #18311636084856979455
and X13, X27, #18311636084888436735
and X13, X27, #18320641359968468543
and X13, X27, #18320643284113817599
and X13, X27, #18320643284143177727
and X13, X27, #18338656033360051839
and X13, X27, #18338657682627493887
and X13, X27, #18338657682652659711
and X13, X27, #18374403900871474942
and X13, X27, #18374685380143218431
and X13, X27, #18374686479654846463
and X13, X27, #18374686479671623679
and X13, X27, #18374686479671623680
and X13, X27, #18374686479671623681
and X13, X27, #18374686479671623683
and X13, X27, #18374686479671623687
and X13, X27, #18374686479671623695
and X13, X27, #18374686479671623711
and X13, X27, #18374686479671623743
and X13, X27, #18374686479671623807
and X13, X27, #18374686479671623935
and X13, X27, #18374686479671624191
and X13, X27, #18374686479671624703
and X13, X27, #18374686479671625727
and X13, X27, #18374686479671627775
and X13, X27, #18374686479671631871
and X13, X27, #18374686479671640063
and X13, X27, #18374686479671656447
and X13, X27, #18374686479671689215
and X13, X27, #18374686479671754751
and X13, X27, #18374686479671885823
and X13, X27, #18374686479672147967
and X13, X27, #18374686479672672255
and X13, X27, #18374686479673720831
and X13, X27, #18374686479675817983
and X13, X27, #18374686479680012287
and X13, X27, #18374686479688400895
and X13, X27, #18374686479705178111
and X13, X27, #18374686479738732543
and X13, X27, #18374686479805841407
and X13, X27, #18374686479940059135
and X13, X27, #18374686480208494591
and X13, X27, #18374686480745365503
and X13, X27, #18374686481819107327
and X13, X27, #18374686483949813760
and X13, X27, #18374686483966590975
and X13, X27, #18374686488244781057
and X13, X27, #18374686488261558271
and X13, X27, #18374686496834715651
and X13, X27, #18374686496851492863
and X13, X27, #18374686514014584839
and X13, X27, #18374686514031362047
and X13, X27, #18374686548374323215
and X13, X27, #18374686548391100415
and X13, X27, #18374686617093799967
and X13, X27, #18374686617110577151
and X13, X27, #18374686754532753471
and X13, X27, #18374686754549530623
and X13, X27, #18374687029410660479
and X13, X27, #18374687029427437567
and X13, X27, #18374687579166474495
and X13, X27, #18374687579183251455
and X13, X27, #18374688678678102527
and X13, X27, #18374688678694879231
and X13, X27, #18374690877701358591
and X13, X27, #18374690877718134783
and X13, X27, #18374695275747870719
and X13, X27, #18374695275764645887
and X13, X27, #18374704071840894975
and X13, X27, #18374704071857668095
and X13, X27, #18374721664026943487
and X13, X27, #18374721664043712511
and X13, X27, #18374756848399040511
and X13, X27, #18374756848415801343
and X13, X27, #18374827217143234559
and X13, X27, #18374827217159979007
and X13, X27, #18374966859414961920
and X13, X27, #18374967954631622655
and X13, X27, #18374967954648334335
and X13, X27, #18375248338686705409
and X13, X27, #18375249429608398847
and X13, X27, #18375249429625044991
and X13, X27, #18375811297230192387
and X13, X27, #18375812379561951231
and X13, X27, #18375812379578466303
and X13, X27, #18376937214317166343
and X13, X27, #18376938279469055999
and X13, X27, #18376938279485308927
and X13, X27, #18379189048491114255
and X13, X27, #18379190079283265535
and X13, X27, #18379190079298994175
and X13, X27, #18383692716839010079
and X13, X27, #18383693678911684607
and X13, X27, #18383693678926364671
and X13, X27, #18392700053534801727
and X13, X27, #18392700878168522751
and X13, X27, #18392700878181105663
and X13, X27, #18410714726926385023
and X13, X27, #18410715276682199039
and X13, X27, #18410715276690587647
and X13, X27, #18410715276690587648
and X13, X27, #18410715276690587649
and X13, X27, #18410715276690587651
and X13, X27, #18410715276690587655
and X13, X27, #18410715276690587663
and X13, X27, #18410715276690587679
and X13, X27, #18410715276690587711
and X13, X27, #18410715276690587775
and X13, X27, #18410715276690587903
and X13, X27, #18410715276690588159
and X13, X27, #18410715276690588671
and X13, X27, #18410715276690589695
and X13, X27, #18410715276690591743
and X13, X27, #18410715276690595839
and X13, X27, #18410715276690604031
and X13, X27, #18410715276690620415
and X13, X27, #18410715276690653183
and X13, X27, #18410715276690718719
and X13, X27, #18410715276690849791
and X13, X27, #18410715276691111935
and X13, X27, #18410715276691636223
and X13, X27, #18410715276692684799
and X13, X27, #18410715276694781951
and X13, X27, #18410715276698976255
and X13, X27, #18410715276707364863
and X13, X27, #18410715276724142079
and X13, X27, #18410715276757696511
and X13, X27, #18410715276824805375
and X13, X27, #18410715276959023103
and X13, X27, #18410715277227458559
and X13, X27, #18410715277764329471
and X13, X27, #18410715278838071295
and X13, X27, #18410715280977166336
and X13, X27, #18410715280985554943
and X13, X27, #18410715285272133633
and X13, X27, #18410715285280522239
and X13, X27, #18410715293862068227
and X13, X27, #18410715293870456831
and X13, X27, #18410715311041937415
and X13, X27, #18410715311050326015
and X13, X27, #18410715345401675791
and X13, X27, #18410715345410064383
and X13, X27, #18410715414121152543
and X13, X27, #18410715414129541119
and X13, X27, #18410715551560106047
and X13, X27, #18410715551568494591
and X13, X27, #18410715826438013055
and X13, X27, #18410715826446401535
and X13, X27, #18410716376193827071
and X13, X27, #18410716376202215423
and X13, X27, #18410717475705455103
and X13, X27, #18410717475713843199
and X13, X27, #18410719674728711167
and X13, X27, #18410719674737098751
and X13, X27, #18410724072775223295
and X13, X27, #18410724072783609855
and X13, X27, #18410732868868247551
and X13, X27, #18410732868876632063
and X13, X27, #18410750461054296063
and X13, X27, #18410750461062676479
and X13, X27, #18410785645426393087
and X13, X27, #18410785645434765311
and X13, X27, #18410856014170587135
and X13, X27, #18410856014178942975
and X13, X27, #18410996206198128512
and X13, X27, #18410996751658975231
and X13, X27, #18410996751667298303
and X13, X27, #18411277685469872001
and X13, X27, #18411278226635751423
and X13, X27, #18411278226644008959
and X13, X27, #18411840644013358979
and X13, X27, #18411841176589303807
and X13, X27, #18411841176597430271
and X13, X27, #18412966561100332935
and X13, X27, #18412967076496408575
and X13, X27, #18412967076504272895
and X13, X27, #18415218395274280847
and X13, X27, #18415218876310618111
and X13, X27, #18415218876317958143
and X13, X27, #18419722063622176671
and X13, X27, #18419722475939037183
and X13, X27, #18419722475945328639
and X13, X27, #18428729400317968319
and X13, X27, #18428729675195875327
and X13, X27, #18428729675200069631
and X13, X27, #18428729675200069632
and X13, X27, #18428729675200069633
and X13, X27, #18428729675200069635
and X13, X27, #18428729675200069639
and X13, X27, #18428729675200069647
and X13, X27, #18428729675200069663
and X13, X27, #18428729675200069695
and X13, X27, #18428729675200069759
and X13, X27, #18428729675200069887
and X13, X27, #18428729675200070143
and X13, X27, #18428729675200070655
and X13, X27, #18428729675200071679
and X13, X27, #18428729675200073727
and X13, X27, #18428729675200077823
and X13, X27, #18428729675200086015
and X13, X27, #18428729675200102399
and X13, X27, #18428729675200135167
and X13, X27, #18428729675200200703
and X13, X27, #18428729675200331775
and X13, X27, #18428729675200593919
and X13, X27, #18428729675201118207
and X13, X27, #18428729675202166783
and X13, X27, #18428729675204263935
and X13, X27, #18428729675208458239
and X13, X27, #18428729675216846847
and X13, X27, #18428729675233624063
and X13, X27, #18428729675267178495
and X13, X27, #18428729675334287359
and X13, X27, #18428729675468505087
and X13, X27, #18428729675736940543
and X13, X27, #18428729676273811455
and X13, X27, #18428729677347553279
and X13, X27, #18428729679490842624
and X13, X27, #18428729679495036927
and X13, X27, #18428729683785809921
and X13, X27, #18428729683790004223
and X13, X27, #18428729692375744515
and X13, X27, #18428729692379938815
and X13, X27, #18428729709555613703
and X13, X27, #18428729709559807999
and X13, X27, #18428729743915352079
and X13, X27, #18428729743919546367
and X13, X27, #18428729812634828831
and X13, X27, #18428729812639023103
and X13, X27, #18428729950073782335
and X13, X27, #18428729950077976575
and X13, X27, #18428730224951689343
and X13, X27, #18428730224955883519
and X13, X27, #18428730774707503359
and X13, X27, #18428730774711697407
and X13, X27, #18428731874219131391
and X13, X27, #18428731874223325183
and X13, X27, #18428734073242387455
and X13, X27, #18428734073246580735
and X13, X27, #18428738471288899583
and X13, X27, #18428738471293091839
and X13, X27, #18428747267381923839
and X13, X27, #18428747267386114047
and X13, X27, #18428764859567972351
and X13, X27, #18428764859572158463
and X13, X27, #18428800043940069375
and X13, X27, #18428800043944247295
and X13, X27, #18428870412684263423
and X13, X27, #18428870412688424959
and X13, X27, #18429010879589711808
and X13, X27, #18429011150172651519
and X13, X27, #18429011150176780287
and X13, X27, #18429292358861455297
and X13, X27, #18429292625149427711
and X13, X27, #18429292625153490943
and X13, X27, #18429855317404942275
and X13, X27, #18429855575102980095
and X13, X27, #18429855575106912255
and X13, X27, #18430981234491916231
and X13, X27, #18430981475010084863
and X13, X27, #18430981475013754879
and X13, X27, #18433233068665864143
and X13, X27, #18433233274824294399
and X13, X27, #18433233274827440127
and X13, X27, #18437736737013759967
and X13, X27, #18437736874452713471
and X13, X27, #18437736874454810623
and X13, X27, #18437736874454810624
and X13, X27, #18437736874454810625
and X13, X27, #18437736874454810627
and X13, X27, #18437736874454810631
and X13, X27, #18437736874454810639
and X13, X27, #18437736874454810655
and X13, X27, #18437736874454810687
and X13, X27, #18437736874454810751
and X13, X27, #18437736874454810879
and X13, X27, #18437736874454811135
and X13, X27, #18437736874454811647
and X13, X27, #18437736874454812671
and X13, X27, #18437736874454814719
and X13, X27, #18437736874454818815
and X13, X27, #18437736874454827007
and X13, X27, #18437736874454843391
and X13, X27, #18437736874454876159
and X13, X27, #18437736874454941695
and X13, X27, #18437736874455072767
and X13, X27, #18437736874455334911
and X13, X27, #18437736874455859199
and X13, X27, #18437736874456907775
and X13, X27, #18437736874459004927
and X13, X27, #18437736874463199231
and X13, X27, #18437736874471587839
and X13, X27, #18437736874488365055
and X13, X27, #18437736874521919487
and X13, X27, #18437736874589028351
and X13, X27, #18437736874723246079
and X13, X27, #18437736874991681535
and X13, X27, #18437736875528552447
and X13, X27, #18437736876602294271
and X13, X27, #18437736878747680768
and X13, X27, #18437736878749777919
and X13, X27, #18437736883042648065
and X13, X27, #18437736883044745215
and X13, X27, #18437736891632582659
and X13, X27, #18437736891634679807
and X13, X27, #18437736908812451847
and X13, X27, #18437736908814548991
and X13, X27, #18437736943172190223
and X13, X27, #18437736943174287359
and X13, X27, #18437737011891666975
and X13, X27, #18437737011893764095
and X13, X27, #18437737149330620479
and X13, X27, #18437737149332717567
and X13, X27, #18437737424208527487
and X13, X27, #18437737424210624511
and X13, X27, #18437737973964341503
and X13, X27, #18437737973966438399
and X13, X27, #18437739073475969535
and X13, X27, #18437739073478066175
and X13, X27, #18437741272499225599
and X13, X27, #18437741272501321727
and X13, X27, #18437745670545737727
and X13, X27, #18437745670547832831
and X13, X27, #18437754466638761983
and X13, X27, #18437754466640855039
and X13, X27, #18437772058824810495
and X13, X27, #18437772058826899455
and X13, X27, #18437807243196907519
and X13, X27, #18437807243198988287
and X13, X27, #18437877611941101567
and X13, X27, #18437877611943165951
and X13, X27, #18438018216285503456
and X13, X27, #18438018349429489663
and X13, X27, #18438018349431521279
and X13, X27, #18438299695557246945
and X13, X27, #18438299824406265855
and X13, X27, #18438299824408231935
and X13, X27, #18438862654100733923
and X13, X27, #18438862774359818239
and X13, X27, #18438862774361653247
and X13, X27, #18439988571187707879
and X13, X27, #18439988674266923007
and X13, X27, #18439988674268495871
and X13, X27, #18442240405361655791
and X13, X27, #18442240474081132543
and X13, X27, #18442240474082181119
and X13, X27, #18442240474082181120
and X13, X27, #18442240474082181121
and X13, X27, #18442240474082181123
and X13, X27, #18442240474082181127
and X13, X27, #18442240474082181135
and X13, X27, #18442240474082181151
and X13, X27, #18442240474082181183
and X13, X27, #18442240474082181247
and X13, X27, #18442240474082181375
and X13, X27, #18442240474082181631
and X13, X27, #18442240474082182143
and X13, X27, #18442240474082183167
and X13, X27, #18442240474082185215
and X13, X27, #18442240474082189311
and X13, X27, #18442240474082197503
and X13, X27, #18442240474082213887
and X13, X27, #18442240474082246655
and X13, X27, #18442240474082312191
and X13, X27, #18442240474082443263
and X13, X27, #18442240474082705407
and X13, X27, #18442240474083229695
and X13, X27, #18442240474084278271
and X13, X27, #18442240474086375423
and X13, X27, #18442240474090569727
and X13, X27, #18442240474098958335
and X13, X27, #18442240474115735551
and X13, X27, #18442240474149289983
and X13, X27, #18442240474216398847
and X13, X27, #18442240474350616575
and X13, X27, #18442240474619052031
and X13, X27, #18442240475155922943
and X13, X27, #18442240476229664767
and X13, X27, #18442240478376099840
and X13, X27, #18442240478377148415
and X13, X27, #18442240482671067137
and X13, X27, #18442240482672115711
and X13, X27, #18442240491261001731
and X13, X27, #18442240491262050303
and X13, X27, #18442240508440870919
and X13, X27, #18442240508441919487
and X13, X27, #18442240542800609295
and X13, X27, #18442240542801657855
and X13, X27, #18442240611520086047
and X13, X27, #18442240611521134591
and X13, X27, #18442240748959039551
and X13, X27, #18442240748960088063
and X13, X27, #18442241023836946559
and X13, X27, #18442241023837995007
and X13, X27, #18442241573592760575
and X13, X27, #18442241573593808895
and X13, X27, #18442242673104388607
and X13, X27, #18442242673105436671
and X13, X27, #18442244872127644671
and X13, X27, #18442244872128692223
and X13, X27, #18442249270174156799
and X13, X27, #18442249270175203327
and X13, X27, #18442258066267181055
and X13, X27, #18442258066268225535
and X13, X27, #18442275658453229567
and X13, X27, #18442275658454269951
and X13, X27, #18442310842825326591
and X13, X27, #18442310842826358783
and X13, X27, #18442381211569520639
and X13, X27, #18442381211570536447
and X13, X27, #18442521884633399280
and X13, X27, #18442521949057908735
and X13, X27, #18442521949058891775
and X13, X27, #18442803363905142769
and X13, X27, #18442803424034684927
and X13, X27, #18442803424035602431
and X13, X27, #18443366322448629747
and X13, X27, #18443366373988237311
and X13, X27, #18443366373989023743
and X13, X27, #18444492239535603703
and X13, X27, #18444492273895342079
and X13, X27, #18444492273895866367
and X13, X27, #18444492273895866368
and X13, X27, #18444492273895866369
and X13, X27, #18444492273895866371
and X13, X27, #18444492273895866375
and X13, X27, #18444492273895866383
and X13, X27, #18444492273895866399
and X13, X27, #18444492273895866431
and X13, X27, #18444492273895866495
and X13, X27, #18444492273895866623
and X13, X27, #18444492273895866879
and X13, X27, #18444492273895867391
and X13, X27, #18444492273895868415
and X13, X27, #18444492273895870463
and X13, X27, #18444492273895874559
and X13, X27, #18444492273895882751
and X13, X27, #18444492273895899135
and X13, X27, #18444492273895931903
and X13, X27, #18444492273895997439
and X13, X27, #18444492273896128511
and X13, X27, #18444492273896390655
and X13, X27, #18444492273896914943
and X13, X27, #18444492273897963519
and X13, X27, #18444492273900060671
and X13, X27, #18444492273904254975
and X13, X27, #18444492273912643583
and X13, X27, #18444492273929420799
and X13, X27, #18444492273962975231
and X13, X27, #18444492274030084095
and X13, X27, #18444492274164301823
and X13, X27, #18444492274432737279
and X13, X27, #18444492274969608191
and X13, X27, #18444492276043350015
and X13, X27, #18444492278190309376
and X13, X27, #18444492278190833663
and X13, X27, #18444492282485276673
and X13, X27, #18444492282485800959
and X13, X27, #18444492291075211267
and X13, X27, #18444492291075735551
and X13, X27, #18444492308255080455
and X13, X27, #18444492308255604735
and X13, X27, #18444492342614818831
and X13, X27, #18444492342615343103
and X13, X27, #18444492411334295583
and X13, X27, #18444492411334819839
and X13, X27, #18444492548773249087
and X13, X27, #18444492548773773311
and X13, X27, #18444492823651156095
and X13, X27, #18444492823651680255
and X13, X27, #18444493373406970111
and X13, X27, #18444493373407494143
and X13, X27, #18444494472918598143
and X13, X27, #18444494472919121919
and X13, X27, #18444496671941854207
and X13, X27, #18444496671942377471
and X13, X27, #18444501069988366335
and X13, X27, #18444501069988888575
and X13, X27, #18444509866081390591
and X13, X27, #18444509866081910783
and X13, X27, #18444527458267439103
and X13, X27, #18444527458267955199
and X13, X27, #18444562642639536127
and X13, X27, #18444562642640044031
and X13, X27, #18444633011383730175
and X13, X27, #18444633011384221695
and X13, X27, #18444773718807347192
and X13, X27, #18444773748872118271
and X13, X27, #18444773748872577023
and X13, X27, #18445055198079090681
and X13, X27, #18445055223848894463
and X13, X27, #18445055223849287679
and X13, X27, #18445618156622577659
and X13, X27, #18445618173802446847
and X13, X27, #18445618173802708991
and X13, X27, #18445618173802708992
and X13, X27, #18445618173802708993
and X13, X27, #18445618173802708995
and X13, X27, #18445618173802708999
and X13, X27, #18445618173802709007
and X13, X27, #18445618173802709023
and X13, X27, #18445618173802709055
and X13, X27, #18445618173802709119
and X13, X27, #18445618173802709247
and X13, X27, #18445618173802709503
and X13, X27, #18445618173802710015
and X13, X27, #18445618173802711039
and X13, X27, #18445618173802713087
and X13, X27, #18445618173802717183
and X13, X27, #18445618173802725375
and X13, X27, #18445618173802741759
and X13, X27, #18445618173802774527
and X13, X27, #18445618173802840063
and X13, X27, #18445618173802971135
and X13, X27, #18445618173803233279
and X13, X27, #18445618173803757567
and X13, X27, #18445618173804806143
and X13, X27, #18445618173806903295
and X13, X27, #18445618173811097599
and X13, X27, #18445618173819486207
and X13, X27, #18445618173836263423
and X13, X27, #18445618173869817855
and X13, X27, #18445618173936926719
and X13, X27, #18445618174071144447
and X13, X27, #18445618174339579903
and X13, X27, #18445618174876450815
and X13, X27, #18445618175950192639
and X13, X27, #18445618178097414144
and X13, X27, #18445618178097676287
and X13, X27, #18445618182392381441
and X13, X27, #18445618182392643583
and X13, X27, #18445618190982316035
and X13, X27, #18445618190982578175
and X13, X27, #18445618208162185223
and X13, X27, #18445618208162447359
and X13, X27, #18445618242521923599
and X13, X27, #18445618242522185727
and X13, X27, #18445618311241400351
and X13, X27, #18445618311241662463
and X13, X27, #18445618448680353855
and X13, X27, #18445618448680615935
and X13, X27, #18445618723558260863
and X13, X27, #18445618723558522879
and X13, X27, #18445619273314074879
and X13, X27, #18445619273314336767
and X13, X27, #18445620372825702911
and X13, X27, #18445620372825964543
and X13, X27, #18445622571848958975
and X13, X27, #18445622571849220095
and X13, X27, #18445626969895471103
and X13, X27, #18445626969895731199
and X13, X27, #18445635765988495359
and X13, X27, #18445635765988753407
and X13, X27, #18445653358174543871
and X13, X27, #18445653358174797823
and X13, X27, #18445688542546640895
and X13, X27, #18445688542546886655
and X13, X27, #18445758911290834943
and X13, X27, #18445758911291064319
and X13, X27, #18445899635894321148
and X13, X27, #18445899648779223039
and X13, X27, #18445899648779419647
and X13, X27, #18446181115166064637
and X13, X27, #18446181123755999231
and X13, X27, #18446181123756130303
and X13, X27, #18446181123756130304
and X13, X27, #18446181123756130305
and X13, X27, #18446181123756130307
and X13, X27, #18446181123756130311
and X13, X27, #18446181123756130319
and X13, X27, #18446181123756130335
and X13, X27, #18446181123756130367
and X13, X27, #18446181123756130431
and X13, X27, #18446181123756130559
and X13, X27, #18446181123756130815
and X13, X27, #18446181123756131327
and X13, X27, #18446181123756132351
and X13, X27, #18446181123756134399
and X13, X27, #18446181123756138495
and X13, X27, #18446181123756146687
and X13, X27, #18446181123756163071
and X13, X27, #18446181123756195839
and X13, X27, #18446181123756261375
and X13, X27, #18446181123756392447
and X13, X27, #18446181123756654591
and X13, X27, #18446181123757178879
and X13, X27, #18446181123758227455
and X13, X27, #18446181123760324607
and X13, X27, #18446181123764518911
and X13, X27, #18446181123772907519
and X13, X27, #18446181123789684735
and X13, X27, #18446181123823239167
and X13, X27, #18446181123890348031
and X13, X27, #18446181124024565759
and X13, X27, #18446181124293001215
and X13, X27, #18446181124829872127
and X13, X27, #18446181125903613951
and X13, X27, #18446181128050966528
and X13, X27, #18446181128051097599
and X13, X27, #18446181132345933825
and X13, X27, #18446181132346064895
and X13, X27, #18446181140935868419
and X13, X27, #18446181140935999487
and X13, X27, #18446181158115737607
and X13, X27, #18446181158115868671
and X13, X27, #18446181192475475983
and X13, X27, #18446181192475607039
and X13, X27, #18446181261194952735
and X13, X27, #18446181261195083775
and X13, X27, #18446181398633906239
and X13, X27, #18446181398634037247
and X13, X27, #18446181673511813247
and X13, X27, #18446181673511944191
and X13, X27, #18446182223267627263
and X13, X27, #18446182223267758079
and X13, X27, #18446183322779255295
and X13, X27, #18446183322779385855
and X13, X27, #18446185521802511359
and X13, X27, #18446185521802641407
and X13, X27, #18446189919849023487
and X13, X27, #18446189919849152511
and X13, X27, #18446198715942047743
and X13, X27, #18446198715942174719
and X13, X27, #18446216308128096255
and X13, X27, #18446216308128219135
and X13, X27, #18446251492500193279
and X13, X27, #18446251492500307967
and X13, X27, #18446321861244387327
and X13, X27, #18446321861244485631
and X13, X27, #18446462594437808126
and X13, X27, #18446462598732775423
and X13, X27, #18446462598732840959
and X13, X27, #18446462598732840960
and X13, X27, #18446462598732840961
and X13, X27, #18446462598732840963
and X13, X27, #18446462598732840967
and X13, X27, #18446462598732840975
and X13, X27, #18446462598732840991
and X13, X27, #18446462598732841023
and X13, X27, #18446462598732841087
and X13, X27, #18446462598732841215
and X13, X27, #18446462598732841471
and X13, X27, #18446462598732841983
and X13, X27, #18446462598732843007
and X13, X27, #18446462598732845055
and X13, X27, #18446462598732849151
and X13, X27, #18446462598732857343
and X13, X27, #18446462598732873727
and X13, X27, #18446462598732906495
and X13, X27, #18446462598732972031
and X13, X27, #18446462598733103103
and X13, X27, #18446462598733365247
and X13, X27, #18446462598733889535
and X13, X27, #18446462598734938111
and X13, X27, #18446462598737035263
and X13, X27, #18446462598741229567
and X13, X27, #18446462598749618175
and X13, X27, #18446462598766395391
and X13, X27, #18446462598799949823
and X13, X27, #18446462598867058687
and X13, X27, #18446462599001276415
and X13, X27, #18446462599269711871
and X13, X27, #18446462599806582783
and X13, X27, #18446462600880324607
and X13, X27, #18446462603027742720
and X13, X27, #18446462603027808255
and X13, X27, #18446462607322710017
and X13, X27, #18446462607322775551
and X13, X27, #18446462615912644611
and X13, X27, #18446462615912710143
and X13, X27, #18446462633092513799
and X13, X27, #18446462633092579327
and X13, X27, #18446462667452252175
and X13, X27, #18446462667452317695
and X13, X27, #18446462736171728927
and X13, X27, #18446462736171794431
and X13, X27, #18446462873610682431
and X13, X27, #18446462873610747903
and X13, X27, #18446463148488589439
and X13, X27, #18446463148488654847
and X13, X27, #18446463698244403455
and X13, X27, #18446463698244468735
and X13, X27, #18446464797756031487
and X13, X27, #18446464797756096511
and X13, X27, #18446466996779287551
and X13, X27, #18446466996779352063
and X13, X27, #18446471394825799679
and X13, X27, #18446471394825863167
and X13, X27, #18446480190918823935
and X13, X27, #18446480190918885375
and X13, X27, #18446497783104872447
and X13, X27, #18446497783104929791
and X13, X27, #18446532967476969471
and X13, X27, #18446532967477018623
and X13, X27, #18446603336221163519
and X13, X27, #18446603336221196287
and X13, X27, #18446603336221196288
and X13, X27, #18446603336221196289
and X13, X27, #18446603336221196291
and X13, X27, #18446603336221196295
and X13, X27, #18446603336221196303
and X13, X27, #18446603336221196319
and X13, X27, #18446603336221196351
and X13, X27, #18446603336221196415
and X13, X27, #18446603336221196543
and X13, X27, #18446603336221196799
and X13, X27, #18446603336221197311
and X13, X27, #18446603336221198335
and X13, X27, #18446603336221200383
and X13, X27, #18446603336221204479
and X13, X27, #18446603336221212671
and X13, X27, #18446603336221229055
and X13, X27, #18446603336221261823
and X13, X27, #18446603336221327359
and X13, X27, #18446603336221458431
and X13, X27, #18446603336221720575
and X13, X27, #18446603336222244863
and X13, X27, #18446603336223293439
and X13, X27, #18446603336225390591
and X13, X27, #18446603336229584895
and X13, X27, #18446603336237973503
and X13, X27, #18446603336254750719
and X13, X27, #18446603336288305151
and X13, X27, #18446603336355414015
and X13, X27, #18446603336489631743
and X13, X27, #18446603336758067199
and X13, X27, #18446603337294938111
and X13, X27, #18446603338368679935
and X13, X27, #18446603340516130816
and X13, X27, #18446603340516163583
and X13, X27, #18446603344811098113
and X13, X27, #18446603344811130879
and X13, X27, #18446603353401032707
and X13, X27, #18446603353401065471
and X13, X27, #18446603370580901895
and X13, X27, #18446603370580934655
and X13, X27, #18446603404940640271
and X13, X27, #18446603404940673023
and X13, X27, #18446603473660117023
and X13, X27, #18446603473660149759
and X13, X27, #18446603611099070527
and X13, X27, #18446603611099103231
and X13, X27, #18446603885976977535
and X13, X27, #18446603885977010175
and X13, X27, #18446604435732791551
and X13, X27, #18446604435732824063
and X13, X27, #18446605535244419583
and X13, X27, #18446605535244451839
and X13, X27, #18446607734267675647
and X13, X27, #18446607734267707391
and X13, X27, #18446612132314187775
and X13, X27, #18446612132314218495
and X13, X27, #18446620928407212031
and X13, X27, #18446620928407240703
and X13, X27, #18446638520593260543
and X13, X27, #18446638520593285119
and X13, X27, #18446673704965357567
and X13, X27, #18446673704965373951
and X13, X27, #18446673704965373952
and X13, X27, #18446673704965373953
and X13, X27, #18446673704965373955
and X13, X27, #18446673704965373959
and X13, X27, #18446673704965373967
and X13, X27, #18446673704965373983
and X13, X27, #18446673704965374015
and X13, X27, #18446673704965374079
and X13, X27, #18446673704965374207
and X13, X27, #18446673704965374463
and X13, X27, #18446673704965374975
and X13, X27, #18446673704965375999
and X13, X27, #18446673704965378047
and X13, X27, #18446673704965382143
and X13, X27, #18446673704965390335
and X13, X27, #18446673704965406719
and X13, X27, #18446673704965439487
and X13, X27, #18446673704965505023
and X13, X27, #18446673704965636095
and X13, X27, #18446673704965898239
and X13, X27, #18446673704966422527
and X13, X27, #18446673704967471103
and X13, X27, #18446673704969568255
and X13, X27, #18446673704973762559
and X13, X27, #18446673704982151167
and X13, X27, #18446673704998928383
and X13, X27, #18446673705032482815
and X13, X27, #18446673705099591679
and X13, X27, #18446673705233809407
and X13, X27, #18446673705502244863
and X13, X27, #18446673706039115775
and X13, X27, #18446673707112857599
and X13, X27, #18446673709260324864
and X13, X27, #18446673709260341247
and X13, X27, #18446673713555292161
and X13, X27, #18446673713555308543
and X13, X27, #18446673722145226755
and X13, X27, #18446673722145243135
and X13, X27, #18446673739325095943
and X13, X27, #18446673739325112319
and X13, X27, #18446673773684834319
and X13, X27, #18446673773684850687
and X13, X27, #18446673842404311071
and X13, X27, #18446673842404327423
and X13, X27, #18446673979843264575
and X13, X27, #18446673979843280895
and X13, X27, #18446674254721171583
and X13, X27, #18446674254721187839
and X13, X27, #18446674804476985599
and X13, X27, #18446674804477001727
and X13, X27, #18446675903988613631
and X13, X27, #18446675903988629503
and X13, X27, #18446678103011869695
and X13, X27, #18446678103011885055
and X13, X27, #18446682501058381823
and X13, X27, #18446682501058396159
and X13, X27, #18446691297151406079
and X13, X27, #18446691297151418367
and X13, X27, #18446708889337454591
and X13, X27, #18446708889337462783
and X13, X27, #18446708889337462784
and X13, X27, #18446708889337462785
and X13, X27, #18446708889337462787
and X13, X27, #18446708889337462791
and X13, X27, #18446708889337462799
and X13, X27, #18446708889337462815
and X13, X27, #18446708889337462847
and X13, X27, #18446708889337462911
and X13, X27, #18446708889337463039
and X13, X27, #18446708889337463295
and X13, X27, #18446708889337463807
and X13, X27, #18446708889337464831
and X13, X27, #18446708889337466879
and X13, X27, #18446708889337470975
and X13, X27, #18446708889337479167
and X13, X27, #18446708889337495551
and X13, X27, #18446708889337528319
and X13, X27, #18446708889337593855
and X13, X27, #18446708889337724927
and X13, X27, #18446708889337987071
and X13, X27, #18446708889338511359
and X13, X27, #18446708889339559935
and X13, X27, #18446708889341657087
and X13, X27, #18446708889345851391
and X13, X27, #18446708889354239999
and X13, X27, #18446708889371017215
and X13, X27, #18446708889404571647
and X13, X27, #18446708889471680511
and X13, X27, #18446708889605898239
and X13, X27, #18446708889874333695
and X13, X27, #18446708890411204607
and X13, X27, #18446708891484946431
and X13, X27, #18446708893632421888
and X13, X27, #18446708893632430079
and X13, X27, #18446708897927389185
and X13, X27, #18446708897927397375
and X13, X27, #18446708906517323779
and X13, X27, #18446708906517331967
and X13, X27, #18446708923697192967
and X13, X27, #18446708923697201151
and X13, X27, #18446708958056931343
and X13, X27, #18446708958056939519
and X13, X27, #18446709026776408095
and X13, X27, #18446709026776416255
and X13, X27, #18446709164215361599
and X13, X27, #18446709164215369727
and X13, X27, #18446709439093268607
and X13, X27, #18446709439093276671
and X13, X27, #18446709988849082623
and X13, X27, #18446709988849090559
and X13, X27, #18446711088360710655
and X13, X27, #18446711088360718335
and X13, X27, #18446713287383966719
and X13, X27, #18446713287383973887
and X13, X27, #18446717685430478847
and X13, X27, #18446717685430484991
and X13, X27, #18446726481523503103
and X13, X27, #18446726481523507199
and X13, X27, #18446726481523507200
and X13, X27, #18446726481523507201
and X13, X27, #18446726481523507203
and X13, X27, #18446726481523507207
and X13, X27, #18446726481523507215
and X13, X27, #18446726481523507231
and X13, X27, #18446726481523507263
and X13, X27, #18446726481523507327
and X13, X27, #18446726481523507455
and X13, X27, #18446726481523507711
and X13, X27, #18446726481523508223
and X13, X27, #18446726481523509247
and X13, X27, #18446726481523511295
and X13, X27, #18446726481523515391
and X13, X27, #18446726481523523583
and X13, X27, #18446726481523539967
and X13, X27, #18446726481523572735
and X13, X27, #18446726481523638271
and X13, X27, #18446726481523769343
and X13, X27, #18446726481524031487
and X13, X27, #18446726481524555775
and X13, X27, #18446726481525604351
and X13, X27, #18446726481527701503
and X13, X27, #18446726481531895807
and X13, X27, #18446726481540284415
and X13, X27, #18446726481557061631
and X13, X27, #18446726481590616063
and X13, X27, #18446726481657724927
and X13, X27, #18446726481791942655
and X13, X27, #18446726482060378111
and X13, X27, #18446726482597249023
and X13, X27, #18446726483670990847
and X13, X27, #18446726485818470400
and X13, X27, #18446726485818474495
and X13, X27, #18446726490113437697
and X13, X27, #18446726490113441791
and X13, X27, #18446726498703372291
and X13, X27, #18446726498703376383
and X13, X27, #18446726515883241479
and X13, X27, #18446726515883245567
and X13, X27, #18446726550242979855
and X13, X27, #18446726550242983935
and X13, X27, #18446726618962456607
and X13, X27, #18446726618962460671
and X13, X27, #18446726756401410111
and X13, X27, #18446726756401414143
and X13, X27, #18446727031279317119
and X13, X27, #18446727031279321087
and X13, X27, #18446727581035131135
and X13, X27, #18446727581035134975
and X13, X27, #18446728680546759167
and X13, X27, #18446728680546762751
and X13, X27, #18446730879570015231
and X13, X27, #18446730879570018303
and X13, X27, #18446735277616527359
and X13, X27, #18446735277616529407
and X13, X27, #18446735277616529408
and X13, X27, #18446735277616529409
and X13, X27, #18446735277616529411
and X13, X27, #18446735277616529415
and X13, X27, #18446735277616529423
and X13, X27, #18446735277616529439
and X13, X27, #18446735277616529471
and X13, X27, #18446735277616529535
and X13, X27, #18446735277616529663
and X13, X27, #18446735277616529919
and X13, X27, #18446735277616530431
and X13, X27, #18446735277616531455
and X13, X27, #18446735277616533503
and X13, X27, #18446735277616537599
and X13, X27, #18446735277616545791
and X13, X27, #18446735277616562175
and X13, X27, #18446735277616594943
and X13, X27, #18446735277616660479
and X13, X27, #18446735277616791551
and X13, X27, #18446735277617053695
and X13, X27, #18446735277617577983
and X13, X27, #18446735277618626559
and X13, X27, #18446735277620723711
and X13, X27, #18446735277624918015
and X13, X27, #18446735277633306623
and X13, X27, #18446735277650083839
and X13, X27, #18446735277683638271
and X13, X27, #18446735277750747135
and X13, X27, #18446735277884964863
and X13, X27, #18446735278153400319
and X13, X27, #18446735278690271231
and X13, X27, #18446735279764013055
and X13, X27, #18446735281911494656
and X13, X27, #18446735281911496703
and X13, X27, #18446735286206461953
and X13, X27, #18446735286206463999
and X13, X27, #18446735294796396547
and X13, X27, #18446735294796398591
and X13, X27, #18446735311976265735
and X13, X27, #18446735311976267775
and X13, X27, #18446735346336004111
and X13, X27, #18446735346336006143
and X13, X27, #18446735415055480863
and X13, X27, #18446735415055482879
and X13, X27, #18446735552494434367
and X13, X27, #18446735552494436351
and X13, X27, #18446735827372341375
and X13, X27, #18446735827372343295
and X13, X27, #18446736377128155391
and X13, X27, #18446736377128157183
and X13, X27, #18446737476639783423
and X13, X27, #18446737476639784959
and X13, X27, #18446739675663039487
and X13, X27, #18446739675663040511
and X13, X27, #18446739675663040512
and X13, X27, #18446739675663040513
and X13, X27, #18446739675663040515
and X13, X27, #18446739675663040519
and X13, X27, #18446739675663040527
and X13, X27, #18446739675663040543
and X13, X27, #18446739675663040575
and X13, X27, #18446739675663040639
and X13, X27, #18446739675663040767
and X13, X27, #18446739675663041023
and X13, X27, #18446739675663041535
and X13, X27, #18446739675663042559
and X13, X27, #18446739675663044607
and X13, X27, #18446739675663048703
and X13, X27, #18446739675663056895
and X13, X27, #18446739675663073279
and X13, X27, #18446739675663106047
and X13, X27, #18446739675663171583
and X13, X27, #18446739675663302655
and X13, X27, #18446739675663564799
and X13, X27, #18446739675664089087
and X13, X27, #18446739675665137663
and X13, X27, #18446739675667234815
and X13, X27, #18446739675671429119
and X13, X27, #18446739675679817727
and X13, X27, #18446739675696594943
and X13, X27, #18446739675730149375
and X13, X27, #18446739675797258239
and X13, X27, #18446739675931475967
and X13, X27, #18446739676199911423
and X13, X27, #18446739676736782335
and X13, X27, #18446739677810524159
and X13, X27, #18446739679958006784
and X13, X27, #18446739679958007807
and X13, X27, #18446739684252974081
and X13, X27, #18446739684252975103
and X13, X27, #18446739692842908675
and X13, X27, #18446739692842909695
and X13, X27, #18446739710022777863
and X13, X27, #18446739710022778879
and X13, X27, #18446739744382516239
and X13, X27, #18446739744382517247
and X13, X27, #18446739813101992991
and X13, X27, #18446739813101993983
and X13, X27, #18446739950540946495
and X13, X27, #18446739950540947455
and X13, X27, #18446740225418853503
and X13, X27, #18446740225418854399
and X13, X27, #18446740775174667519
and X13, X27, #18446740775174668287
and X13, X27, #18446741874686295551
and X13, X27, #18446741874686296063
and X13, X27, #18446741874686296064
and X13, X27, #18446741874686296065
and X13, X27, #18446741874686296067
and X13, X27, #18446741874686296071
and X13, X27, #18446741874686296079
and X13, X27, #18446741874686296095
and X13, X27, #18446741874686296127
and X13, X27, #18446741874686296191
and X13, X27, #18446741874686296319
and X13, X27, #18446741874686296575
and X13, X27, #18446741874686297087
and X13, X27, #18446741874686298111
and X13, X27, #18446741874686300159
and X13, X27, #18446741874686304255
and X13, X27, #18446741874686312447
and X13, X27, #18446741874686328831
and X13, X27, #18446741874686361599
and X13, X27, #18446741874686427135
and X13, X27, #18446741874686558207
and X13, X27, #18446741874686820351
and X13, X27, #18446741874687344639
and X13, X27, #18446741874688393215
and X13, X27, #18446741874690490367
and X13, X27, #18446741874694684671
and X13, X27, #18446741874703073279
and X13, X27, #18446741874719850495
and X13, X27, #18446741874753404927
and X13, X27, #18446741874820513791
and X13, X27, #18446741874954731519
and X13, X27, #18446741875223166975
and X13, X27, #18446741875760037887
and X13, X27, #18446741876833779711
and X13, X27, #18446741878981262848
and X13, X27, #18446741878981263359
and X13, X27, #18446741883276230145
and X13, X27, #18446741883276230655
and X13, X27, #18446741891866164739
and X13, X27, #18446741891866165247
and X13, X27, #18446741909046033927
and X13, X27, #18446741909046034431
and X13, X27, #18446741943405772303
and X13, X27, #18446741943405772799
and X13, X27, #18446742012125249055
and X13, X27, #18446742012125249535
and X13, X27, #18446742149564202559
and X13, X27, #18446742149564203007
and X13, X27, #18446742424442109567
and X13, X27, #18446742424442109951
and X13, X27, #18446742974197923583
and X13, X27, #18446742974197923839
and X13, X27, #18446742974197923840
and X13, X27, #18446742974197923841
and X13, X27, #18446742974197923843
and X13, X27, #18446742974197923847
and X13, X27, #18446742974197923855
and X13, X27, #18446742974197923871
and X13, X27, #18446742974197923903
and X13, X27, #18446742974197923967
and X13, X27, #18446742974197924095
and X13, X27, #18446742974197924351
and X13, X27, #18446742974197924863
and X13, X27, #18446742974197925887
and X13, X27, #18446742974197927935
and X13, X27, #18446742974197932031
and X13, X27, #18446742974197940223
and X13, X27, #18446742974197956607
and X13, X27, #18446742974197989375
and X13, X27, #18446742974198054911
and X13, X27, #18446742974198185983
and X13, X27, #18446742974198448127
and X13, X27, #18446742974198972415
and X13, X27, #18446742974200020991
and X13, X27, #18446742974202118143
and X13, X27, #18446742974206312447
and X13, X27, #18446742974214701055
and X13, X27, #18446742974231478271
and X13, X27, #18446742974265032703
and X13, X27, #18446742974332141567
and X13, X27, #18446742974466359295
and X13, X27, #18446742974734794751
and X13, X27, #18446742975271665663
and X13, X27, #18446742976345407487
and X13, X27, #18446742978492890880
and X13, X27, #18446742978492891135
and X13, X27, #18446742982787858177
and X13, X27, #18446742982787858431
and X13, X27, #18446742991377792771
and X13, X27, #18446742991377793023
and X13, X27, #18446743008557661959
and X13, X27, #18446743008557662207
and X13, X27, #18446743042917400335
and X13, X27, #18446743042917400575
and X13, X27, #18446743111636877087
and X13, X27, #18446743111636877311
and X13, X27, #18446743249075830591
and X13, X27, #18446743249075830783
and X13, X27, #18446743523953737599
and X13, X27, #18446743523953737727
and X13, X27, #18446743523953737728
and X13, X27, #18446743523953737729
and X13, X27, #18446743523953737731
and X13, X27, #18446743523953737735
and X13, X27, #18446743523953737743
and X13, X27, #18446743523953737759
and X13, X27, #18446743523953737791
and X13, X27, #18446743523953737855
and X13, X27, #18446743523953737983
and X13, X27, #18446743523953738239
and X13, X27, #18446743523953738751
and X13, X27, #18446743523953739775
and X13, X27, #18446743523953741823
and X13, X27, #18446743523953745919
and X13, X27, #18446743523953754111
and X13, X27, #18446743523953770495
and X13, X27, #18446743523953803263
and X13, X27, #18446743523953868799
and X13, X27, #18446743523953999871
and X13, X27, #18446743523954262015
and X13, X27, #18446743523954786303
and X13, X27, #18446743523955834879
and X13, X27, #18446743523957932031
and X13, X27, #18446743523962126335
and X13, X27, #18446743523970514943
and X13, X27, #18446743523987292159
and X13, X27, #18446743524020846591
and X13, X27, #18446743524087955455
and X13, X27, #18446743524222173183
and X13, X27, #18446743524490608639
and X13, X27, #18446743525027479551
and X13, X27, #18446743526101221375
and X13, X27, #18446743528248704896
and X13, X27, #18446743528248705023
and X13, X27, #18446743532543672193
and X13, X27, #18446743532543672319
and X13, X27, #18446743541133606787
and X13, X27, #18446743541133606911
and X13, X27, #18446743558313475975
and X13, X27, #18446743558313476095
and X13, X27, #18446743592673214351
and X13, X27, #18446743592673214463
and X13, X27, #18446743661392691103
and X13, X27, #18446743661392691199
and X13, X27, #18446743798831644607
and X13, X27, #18446743798831644671
and X13, X27, #18446743798831644672
and X13, X27, #18446743798831644673
and X13, X27, #18446743798831644675
and X13, X27, #18446743798831644679
and X13, X27, #18446743798831644687
and X13, X27, #18446743798831644703
and X13, X27, #18446743798831644735
and X13, X27, #18446743798831644799
and X13, X27, #18446743798831644927
and X13, X27, #18446743798831645183
and X13, X27, #18446743798831645695
and X13, X27, #18446743798831646719
and X13, X27, #18446743798831648767
and X13, X27, #18446743798831652863
and X13, X27, #18446743798831661055
and X13, X27, #18446743798831677439
and X13, X27, #18446743798831710207
and X13, X27, #18446743798831775743
and X13, X27, #18446743798831906815
and X13, X27, #18446743798832168959
and X13, X27, #18446743798832693247
and X13, X27, #18446743798833741823
and X13, X27, #18446743798835838975
and X13, X27, #18446743798840033279
and X13, X27, #18446743798848421887
and X13, X27, #18446743798865199103
and X13, X27, #18446743798898753535
and X13, X27, #18446743798965862399
and X13, X27, #18446743799100080127
and X13, X27, #18446743799368515583
and X13, X27, #18446743799905386495
and X13, X27, #18446743800979128319
and X13, X27, #18446743803126611904
and X13, X27, #18446743803126611967
and X13, X27, #18446743807421579201
and X13, X27, #18446743807421579263
and X13, X27, #18446743816011513795
and X13, X27, #18446743816011513855
and X13, X27, #18446743833191382983
and X13, X27, #18446743833191383039
and X13, X27, #18446743867551121359
and X13, X27, #18446743867551121407
and X13, X27, #18446743936270598111
and X13, X27, #18446743936270598143
and X13, X27, #18446743936270598144
and X13, X27, #18446743936270598145
and X13, X27, #18446743936270598147
and X13, X27, #18446743936270598151
and X13, X27, #18446743936270598159
and X13, X27, #18446743936270598175
and X13, X27, #18446743936270598207
and X13, X27, #18446743936270598271
and X13, X27, #18446743936270598399
and X13, X27, #18446743936270598655
and X13, X27, #18446743936270599167
and X13, X27, #18446743936270600191
and X13, X27, #18446743936270602239
and X13, X27, #18446743936270606335
and X13, X27, #18446743936270614527
and X13, X27, #18446743936270630911
and X13, X27, #18446743936270663679
and X13, X27, #18446743936270729215
and X13, X27, #18446743936270860287
and X13, X27, #18446743936271122431
and X13, X27, #18446743936271646719
and X13, X27, #18446743936272695295
and X13, X27, #18446743936274792447
and X13, X27, #18446743936278986751
and X13, X27, #18446743936287375359
and X13, X27, #18446743936304152575
and X13, X27, #18446743936337707007
and X13, X27, #18446743936404815871
and X13, X27, #18446743936539033599
and X13, X27, #18446743936807469055
and X13, X27, #18446743937344339967
and X13, X27, #18446743938418081791
and X13, X27, #18446743940565565408
and X13, X27, #18446743940565565439
and X13, X27, #18446743944860532705
and X13, X27, #18446743944860532735
and X13, X27, #18446743953450467299
and X13, X27, #18446743953450467327
and X13, X27, #18446743970630336487
and X13, X27, #18446743970630336511
and X13, X27, #18446744004990074863
and X13, X27, #18446744004990074879
and X13, X27, #18446744004990074880
and X13, X27, #18446744004990074881
and X13, X27, #18446744004990074883
and X13, X27, #18446744004990074887
and X13, X27, #18446744004990074895
and X13, X27, #18446744004990074911
and X13, X27, #18446744004990074943
and X13, X27, #18446744004990075007
and X13, X27, #18446744004990075135
and X13, X27, #18446744004990075391
and X13, X27, #18446744004990075903
and X13, X27, #18446744004990076927
and X13, X27, #18446744004990078975
and X13, X27, #18446744004990083071
and X13, X27, #18446744004990091263
and X13, X27, #18446744004990107647
and X13, X27, #18446744004990140415
and X13, X27, #18446744004990205951
and X13, X27, #18446744004990337023
and X13, X27, #18446744004990599167
and X13, X27, #18446744004991123455
and X13, X27, #18446744004992172031
and X13, X27, #18446744004994269183
and X13, X27, #18446744004998463487
and X13, X27, #18446744005006852095
and X13, X27, #18446744005023629311
and X13, X27, #18446744005057183743
and X13, X27, #18446744005124292607
and X13, X27, #18446744005258510335
and X13, X27, #18446744005526945791
and X13, X27, #18446744006063816703
and X13, X27, #18446744007137558527
and X13, X27, #18446744009285042160
and X13, X27, #18446744009285042175
and X13, X27, #18446744013580009457
and X13, X27, #18446744013580009471
and X13, X27, #18446744022169944051
and X13, X27, #18446744022169944063
and X13, X27, #18446744039349813239
and X13, X27, #18446744039349813247
and X13, X27, #18446744039349813248
and X13, X27, #18446744039349813249
and X13, X27, #18446744039349813251
and X13, X27, #18446744039349813255
and X13, X27, #18446744039349813263
and X13, X27, #18446744039349813279
and X13, X27, #18446744039349813311
and X13, X27, #18446744039349813375
and X13, X27, #18446744039349813503
and X13, X27, #18446744039349813759
and X13, X27, #18446744039349814271
and X13, X27, #18446744039349815295
and X13, X27, #18446744039349817343
and X13, X27, #18446744039349821439
and X13, X27, #18446744039349829631
and X13, X27, #18446744039349846015
and X13, X27, #18446744039349878783
and X13, X27, #18446744039349944319
and X13, X27, #18446744039350075391
and X13, X27, #18446744039350337535
and X13, X27, #18446744039350861823
and X13, X27, #18446744039351910399
and X13, X27, #18446744039354007551
and X13, X27, #18446744039358201855
and X13, X27, #18446744039366590463
and X13, X27, #18446744039383367679
and X13, X27, #18446744039416922111
and X13, X27, #18446744039484030975
and X13, X27, #18446744039618248703
and X13, X27, #18446744039886684159
and X13, X27, #18446744040423555071
and X13, X27, #18446744041497296895
and X13, X27, #18446744043644780536
and X13, X27, #18446744043644780543
and X13, X27, #18446744047939747833
and X13, X27, #18446744047939747839
and X13, X27, #18446744056529682427
and X13, X27, #18446744056529682431
and X13, X27, #18446744056529682432
and X13, X27, #18446744056529682433
and X13, X27, #18446744056529682435
and X13, X27, #18446744056529682439
and X13, X27, #18446744056529682447
and X13, X27, #18446744056529682463
and X13, X27, #18446744056529682495
and X13, X27, #18446744056529682559
and X13, X27, #18446744056529682687
and X13, X27, #18446744056529682943
and X13, X27, #18446744056529683455
and X13, X27, #18446744056529684479
and X13, X27, #18446744056529686527
and X13, X27, #18446744056529690623
and X13, X27, #18446744056529698815
and X13, X27, #18446744056529715199
and X13, X27, #18446744056529747967
and X13, X27, #18446744056529813503
and X13, X27, #18446744056529944575
and X13, X27, #18446744056530206719
and X13, X27, #18446744056530731007
and X13, X27, #18446744056531779583
and X13, X27, #18446744056533876735
and X13, X27, #18446744056538071039
and X13, X27, #18446744056546459647
and X13, X27, #18446744056563236863
and X13, X27, #18446744056596791295
and X13, X27, #18446744056663900159
and X13, X27, #18446744056798117887
and X13, X27, #18446744057066553343
and X13, X27, #18446744057603424255
and X13, X27, #18446744058677166079
and X13, X27, #18446744060824649724
and X13, X27, #18446744060824649727
and X13, X27, #18446744065119617021
and X13, X27, #18446744065119617023
and X13, X27, #18446744065119617024
and X13, X27, #18446744065119617025
and X13, X27, #18446744065119617027
and X13, X27, #18446744065119617031
and X13, X27, #18446744065119617039
and X13, X27, #18446744065119617055
and X13, X27, #18446744065119617087
and X13, X27, #18446744065119617151
and X13, X27, #18446744065119617279
and X13, X27, #18446744065119617535
and X13, X27, #18446744065119618047
and X13, X27, #18446744065119619071
and X13, X27, #18446744065119621119
and X13, X27, #18446744065119625215
and X13, X27, #18446744065119633407
and X13, X27, #18446744065119649791
and X13, X27, #18446744065119682559
and X13, X27, #18446744065119748095
and X13, X27, #18446744065119879167
and X13, X27, #18446744065120141311
and X13, X27, #18446744065120665599
and X13, X27, #18446744065121714175
and X13, X27, #18446744065123811327
and X13, X27, #18446744065128005631
and X13, X27, #18446744065136394239
and X13, X27, #18446744065153171455
and X13, X27, #18446744065186725887
and X13, X27, #18446744065253834751
and X13, X27, #18446744065388052479
and X13, X27, #18446744065656487935
and X13, X27, #18446744066193358847
and X13, X27, #18446744067267100671
and X13, X27, #18446744069414584318
and X13, X27, #18446744069414584319
and X13, X27, #18446744069414584320
and X13, X27, #18446744069414584321
and X13, X27, #18446744069414584323
and X13, X27, #18446744069414584327
and X13, X27, #18446744069414584335
and X13, X27, #18446744069414584351
and X13, X27, #18446744069414584383
and X13, X27, #18446744069414584447
and X13, X27, #18446744069414584575
and X13, X27, #18446744069414584831
and X13, X27, #18446744069414585343
and X13, X27, #18446744069414586367
and X13, X27, #18446744069414588415
and X13, X27, #18446744069414592511
and X13, X27, #18446744069414600703
and X13, X27, #18446744069414617087
and X13, X27, #18446744069414649855
and X13, X27, #18446744069414715391
and X13, X27, #18446744069414846463
and X13, X27, #18446744069415108607
and X13, X27, #18446744069415632895
and X13, X27, #18446744069416681471
and X13, X27, #18446744069418778623
and X13, X27, #18446744069422972927
and X13, X27, #18446744069431361535
and X13, X27, #18446744069448138751
and X13, X27, #18446744069481693183
and X13, X27, #18446744069548802047
and X13, X27, #18446744069683019775
and X13, X27, #18446744069951455231
and X13, X27, #18446744070488326143
and X13, X27, #18446744071562067967
and X13, X27, #18446744071562067968
and X13, X27, #18446744071562067969
and X13, X27, #18446744071562067971
and X13, X27, #18446744071562067975
and X13, X27, #18446744071562067983
and X13, X27, #18446744071562067999
and X13, X27, #18446744071562068031
and X13, X27, #18446744071562068095
and X13, X27, #18446744071562068223
and X13, X27, #18446744071562068479
and X13, X27, #18446744071562068991
and X13, X27, #18446744071562070015
and X13, X27, #18446744071562072063
and X13, X27, #18446744071562076159
and X13, X27, #18446744071562084351
and X13, X27, #18446744071562100735
and X13, X27, #18446744071562133503
and X13, X27, #18446744071562199039
and X13, X27, #18446744071562330111
and X13, X27, #18446744071562592255
and X13, X27, #18446744071563116543
and X13, X27, #18446744071564165119
and X13, X27, #18446744071566262271
and X13, X27, #18446744071570456575
and X13, X27, #18446744071578845183
and X13, X27, #18446744071595622399
and X13, X27, #18446744071629176831
and X13, X27, #18446744071696285695
and X13, X27, #18446744071830503423
and X13, X27, #18446744072098938879
and X13, X27, #18446744072635809791
and X13, X27, #18446744072635809792
and X13, X27, #18446744072635809793
and X13, X27, #18446744072635809795
and X13, X27, #18446744072635809799
and X13, X27, #18446744072635809807
and X13, X27, #18446744072635809823
and X13, X27, #18446744072635809855
and X13, X27, #18446744072635809919
and X13, X27, #18446744072635810047
and X13, X27, #18446744072635810303
and X13, X27, #18446744072635810815
and X13, X27, #18446744072635811839
and X13, X27, #18446744072635813887
and X13, X27, #18446744072635817983
and X13, X27, #18446744072635826175
and X13, X27, #18446744072635842559
and X13, X27, #18446744072635875327
and X13, X27, #18446744072635940863
and X13, X27, #18446744072636071935
and X13, X27, #18446744072636334079
and X13, X27, #18446744072636858367
and X13, X27, #18446744072637906943
and X13, X27, #18446744072640004095
and X13, X27, #18446744072644198399
and X13, X27, #18446744072652587007
and X13, X27, #18446744072669364223
and X13, X27, #18446744072702918655
and X13, X27, #18446744072770027519
and X13, X27, #18446744072904245247
and X13, X27, #18446744073172680703
and X13, X27, #18446744073172680704
and X13, X27, #18446744073172680705
and X13, X27, #18446744073172680707
and X13, X27, #18446744073172680711
and X13, X27, #18446744073172680719
and X13, X27, #18446744073172680735
and X13, X27, #18446744073172680767
and X13, X27, #18446744073172680831
and X13, X27, #18446744073172680959
and X13, X27, #18446744073172681215
and X13, X27, #18446744073172681727
and X13, X27, #18446744073172682751
and X13, X27, #18446744073172684799
and X13, X27, #18446744073172688895
and X13, X27, #18446744073172697087
and X13, X27, #18446744073172713471
and X13, X27, #18446744073172746239
and X13, X27, #18446744073172811775
and X13, X27, #18446744073172942847
and X13, X27, #18446744073173204991
and X13, X27, #18446744073173729279
and X13, X27, #18446744073174777855
and X13, X27, #18446744073176875007
and X13, X27, #18446744073181069311
and X13, X27, #18446744073189457919
and X13, X27, #18446744073206235135
and X13, X27, #18446744073239789567
and X13, X27, #18446744073306898431
and X13, X27, #18446744073441116159
and X13, X27, #18446744073441116160
and X13, X27, #18446744073441116161
and X13, X27, #18446744073441116163
and X13, X27, #18446744073441116167
and X13, X27, #18446744073441116175
and X13, X27, #18446744073441116191
and X13, X27, #18446744073441116223
and X13, X27, #18446744073441116287
and X13, X27, #18446744073441116415
and X13, X27, #18446744073441116671
and X13, X27, #18446744073441117183
and X13, X27, #18446744073441118207
and X13, X27, #18446744073441120255
and X13, X27, #18446744073441124351
and X13, X27, #18446744073441132543
and X13, X27, #18446744073441148927
and X13, X27, #18446744073441181695
and X13, X27, #18446744073441247231
and X13, X27, #18446744073441378303
and X13, X27, #18446744073441640447
and X13, X27, #18446744073442164735
and X13, X27, #18446744073443213311
and X13, X27, #18446744073445310463
and X13, X27, #18446744073449504767
and X13, X27, #18446744073457893375
and X13, X27, #18446744073474670591
and X13, X27, #18446744073508225023
and X13, X27, #18446744073575333887
and X13, X27, #18446744073575333888
and X13, X27, #18446744073575333889
and X13, X27, #18446744073575333891
and X13, X27, #18446744073575333895
and X13, X27, #18446744073575333903
and X13, X27, #18446744073575333919
and X13, X27, #18446744073575333951
and X13, X27, #18446744073575334015
and X13, X27, #18446744073575334143
and X13, X27, #18446744073575334399
and X13, X27, #18446744073575334911
and X13, X27, #18446744073575335935
and X13, X27, #18446744073575337983
and X13, X27, #18446744073575342079
and X13, X27, #18446744073575350271
and X13, X27, #18446744073575366655
and X13, X27, #18446744073575399423
and X13, X27, #18446744073575464959
and X13, X27, #18446744073575596031
and X13, X27, #18446744073575858175
and X13, X27, #18446744073576382463
and X13, X27, #18446744073577431039
and X13, X27, #18446744073579528191
and X13, X27, #18446744073583722495
and X13, X27, #18446744073592111103
and X13, X27, #18446744073608888319
and X13, X27, #18446744073642442751
and X13, X27, #18446744073642442752
and X13, X27, #18446744073642442753
and X13, X27, #18446744073642442755
and X13, X27, #18446744073642442759
and X13, X27, #18446744073642442767
and X13, X27, #18446744073642442783
and X13, X27, #18446744073642442815
and X13, X27, #18446744073642442879
and X13, X27, #18446744073642443007
and X13, X27, #18446744073642443263
and X13, X27, #18446744073642443775
and X13, X27, #18446744073642444799
and X13, X27, #18446744073642446847
and X13, X27, #18446744073642450943
and X13, X27, #18446744073642459135
and X13, X27, #18446744073642475519
and X13, X27, #18446744073642508287
and X13, X27, #18446744073642573823
and X13, X27, #18446744073642704895
and X13, X27, #18446744073642967039
and X13, X27, #18446744073643491327
and X13, X27, #18446744073644539903
and X13, X27, #18446744073646637055
and X13, X27, #18446744073650831359
and X13, X27, #18446744073659219967
and X13, X27, #18446744073675997183
and X13, X27, #18446744073675997184
and X13, X27, #18446744073675997185
and X13, X27, #18446744073675997187
and X13, X27, #18446744073675997191
and X13, X27, #18446744073675997199
and X13, X27, #18446744073675997215
and X13, X27, #18446744073675997247
and X13, X27, #18446744073675997311
and X13, X27, #18446744073675997439
and X13, X27, #18446744073675997695
and X13, X27, #18446744073675998207
and X13, X27, #18446744073675999231
and X13, X27, #18446744073676001279
and X13, X27, #18446744073676005375
and X13, X27, #18446744073676013567
and X13, X27, #18446744073676029951
and X13, X27, #18446744073676062719
and X13, X27, #18446744073676128255
and X13, X27, #18446744073676259327
and X13, X27, #18446744073676521471
and X13, X27, #18446744073677045759
and X13, X27, #18446744073678094335
and X13, X27, #18446744073680191487
and X13, X27, #18446744073684385791
and X13, X27, #18446744073692774399
and X13, X27, #18446744073692774400
and X13, X27, #18446744073692774401
and X13, X27, #18446744073692774403
and X13, X27, #18446744073692774407
and X13, X27, #18446744073692774415
and X13, X27, #18446744073692774431
and X13, X27, #18446744073692774463
and X13, X27, #18446744073692774527
and X13, X27, #18446744073692774655
and X13, X27, #18446744073692774911
and X13, X27, #18446744073692775423
and X13, X27, #18446744073692776447
and X13, X27, #18446744073692778495
and X13, X27, #18446744073692782591
and X13, X27, #18446744073692790783
and X13, X27, #18446744073692807167
and X13, X27, #18446744073692839935
and X13, X27, #18446744073692905471
and X13, X27, #18446744073693036543
and X13, X27, #18446744073693298687
and X13, X27, #18446744073693822975
and X13, X27, #18446744073694871551
and X13, X27, #18446744073696968703
and X13, X27, #18446744073701163007
and X13, X27, #18446744073701163008
and X13, X27, #18446744073701163009
and X13, X27, #18446744073701163011
and X13, X27, #18446744073701163015
and X13, X27, #18446744073701163023
and X13, X27, #18446744073701163039
and X13, X27, #18446744073701163071
and X13, X27, #18446744073701163135
and X13, X27, #18446744073701163263
and X13, X27, #18446744073701163519
and X13, X27, #18446744073701164031
and X13, X27, #18446744073701165055
and X13, X27, #18446744073701167103
and X13, X27, #18446744073701171199
and X13, X27, #18446744073701179391
and X13, X27, #18446744073701195775
and X13, X27, #18446744073701228543
and X13, X27, #18446744073701294079
and X13, X27, #18446744073701425151
and X13, X27, #18446744073701687295
and X13, X27, #18446744073702211583
and X13, X27, #18446744073703260159
and X13, X27, #18446744073705357311
and X13, X27, #18446744073705357312
and X13, X27, #18446744073705357313
and X13, X27, #18446744073705357315
and X13, X27, #18446744073705357319
and X13, X27, #18446744073705357327
and X13, X27, #18446744073705357343
and X13, X27, #18446744073705357375
and X13, X27, #18446744073705357439
and X13, X27, #18446744073705357567
and X13, X27, #18446744073705357823
and X13, X27, #18446744073705358335
and X13, X27, #18446744073705359359
and X13, X27, #18446744073705361407
and X13, X27, #18446744073705365503
and X13, X27, #18446744073705373695
and X13, X27, #18446744073705390079
and X13, X27, #18446744073705422847
and X13, X27, #18446744073705488383
and X13, X27, #18446744073705619455
and X13, X27, #18446744073705881599
and X13, X27, #18446744073706405887
and X13, X27, #18446744073707454463
and X13, X27, #18446744073707454464
and X13, X27, #18446744073707454465
and X13, X27, #18446744073707454467
and X13, X27, #18446744073707454471
and X13, X27, #18446744073707454479
and X13, X27, #18446744073707454495
and X13, X27, #18446744073707454527
and X13, X27, #18446744073707454591
and X13, X27, #18446744073707454719
and X13, X27, #18446744073707454975
and X13, X27, #18446744073707455487
and X13, X27, #18446744073707456511
and X13, X27, #18446744073707458559
and X13, X27, #18446744073707462655
and X13, X27, #18446744073707470847
and X13, X27, #18446744073707487231
and X13, X27, #18446744073707519999
and X13, X27, #18446744073707585535
and X13, X27, #18446744073707716607
and X13, X27, #18446744073707978751
and X13, X27, #18446744073708503039
and X13, X27, #18446744073708503040
and X13, X27, #18446744073708503041
and X13, X27, #18446744073708503043
and X13, X27, #18446744073708503047
and X13, X27, #18446744073708503055
and X13, X27, #18446744073708503071
and X13, X27, #18446744073708503103
and X13, X27, #18446744073708503167
and X13, X27, #18446744073708503295
and X13, X27, #18446744073708503551
and X13, X27, #18446744073708504063
and X13, X27, #18446744073708505087
and X13, X27, #18446744073708507135
and X13, X27, #18446744073708511231
and X13, X27, #18446744073708519423
and X13, X27, #18446744073708535807
and X13, X27, #18446744073708568575
and X13, X27, #18446744073708634111
and X13, X27, #18446744073708765183
and X13, X27, #18446744073709027327
and X13, X27, #18446744073709027328
and X13, X27, #18446744073709027329
and X13, X27, #18446744073709027331
and X13, X27, #18446744073709027335
and X13, X27, #18446744073709027343
and X13, X27, #18446744073709027359
and X13, X27, #18446744073709027391
and X13, X27, #18446744073709027455
and X13, X27, #18446744073709027583
and X13, X27, #18446744073709027839
and X13, X27, #18446744073709028351
and X13, X27, #18446744073709029375
and X13, X27, #18446744073709031423
and X13, X27, #18446744073709035519
and X13, X27, #18446744073709043711
and X13, X27, #18446744073709060095
and X13, X27, #18446744073709092863
and X13, X27, #18446744073709158399
and X13, X27, #18446744073709289471
and X13, X27, #18446744073709289472
and X13, X27, #18446744073709289473
and X13, X27, #18446744073709289475
and X13, X27, #18446744073709289479
and X13, X27, #18446744073709289487
and X13, X27, #18446744073709289503
and X13, X27, #18446744073709289535
and X13, X27, #18446744073709289599
and X13, X27, #18446744073709289727
and X13, X27, #18446744073709289983
and X13, X27, #18446744073709290495
and X13, X27, #18446744073709291519
and X13, X27, #18446744073709293567
and X13, X27, #18446744073709297663
and X13, X27, #18446744073709305855
and X13, X27, #18446744073709322239
and X13, X27, #18446744073709355007
and X13, X27, #18446744073709420543
and X13, X27, #18446744073709420544
and X13, X27, #18446744073709420545
and X13, X27, #18446744073709420547
and X13, X27, #18446744073709420551
and X13, X27, #18446744073709420559
and X13, X27, #18446744073709420575
and X13, X27, #18446744073709420607
and X13, X27, #18446744073709420671
and X13, X27, #18446744073709420799
and X13, X27, #18446744073709421055
and X13, X27, #18446744073709421567
and X13, X27, #18446744073709422591
and X13, X27, #18446744073709424639
and X13, X27, #18446744073709428735
and X13, X27, #18446744073709436927
and X13, X27, #18446744073709453311
and X13, X27, #18446744073709486079
and X13, X27, #18446744073709486080
and X13, X27, #18446744073709486081
and X13, X27, #18446744073709486083
and X13, X27, #18446744073709486087
and X13, X27, #18446744073709486095
and X13, X27, #18446744073709486111
and X13, X27, #18446744073709486143
and X13, X27, #18446744073709486207
and X13, X27, #18446744073709486335
and X13, X27, #18446744073709486591
and X13, X27, #18446744073709487103
and X13, X27, #18446744073709488127
and X13, X27, #18446744073709490175
and X13, X27, #18446744073709494271
and X13, X27, #18446744073709502463
and X13, X27, #18446744073709518847
and X13, X27, #18446744073709518848
and X13, X27, #18446744073709518849
and X13, X27, #18446744073709518851
and X13, X27, #18446744073709518855
and X13, X27, #18446744073709518863
and X13, X27, #18446744073709518879
and X13, X27, #18446744073709518911
and X13, X27, #18446744073709518975
and X13, X27, #18446744073709519103
and X13, X27, #18446744073709519359
and X13, X27, #18446744073709519871
and X13, X27, #18446744073709520895
and X13, X27, #18446744073709522943
and X13, X27, #18446744073709527039
and X13, X27, #18446744073709535231
and X13, X27, #18446744073709535232
and X13, X27, #18446744073709535233
and X13, X27, #18446744073709535235
and X13, X27, #18446744073709535239
and X13, X27, #18446744073709535247
and X13, X27, #18446744073709535263
and X13, X27, #18446744073709535295
and X13, X27, #18446744073709535359
and X13, X27, #18446744073709535487
and X13, X27, #18446744073709535743
and X13, X27, #18446744073709536255
and X13, X27, #18446744073709537279
and X13, X27, #18446744073709539327
and X13, X27, #18446744073709543423
and X13, X27, #18446744073709543424
and X13, X27, #18446744073709543425
and X13, X27, #18446744073709543427
and X13, X27, #18446744073709543431
and X13, X27, #18446744073709543439
and X13, X27, #18446744073709543455
and X13, X27, #18446744073709543487
and X13, X27, #18446744073709543551
and X13, X27, #18446744073709543679
and X13, X27, #18446744073709543935
and X13, X27, #18446744073709544447
and X13, X27, #18446744073709545471
and X13, X27, #18446744073709547519
and X13, X27, #18446744073709547520
and X13, X27, #18446744073709547521
and X13, X27, #18446744073709547523
and X13, X27, #18446744073709547527
and X13, X27, #18446744073709547535
and X13, X27, #18446744073709547551
and X13, X27, #18446744073709547583
and X13, X27, #18446744073709547647
and X13, X27, #18446744073709547775
and X13, X27, #18446744073709548031
and X13, X27, #18446744073709548543
and X13, X27, #18446744073709549567
and X13, X27, #18446744073709549568
and X13, X27, #18446744073709549569
and X13, X27, #18446744073709549571
and X13, X27, #18446744073709549575
and X13, X27, #18446744073709549583
and X13, X27, #18446744073709549599
and X13, X27, #18446744073709549631
and X13, X27, #18446744073709549695
and X13, X27, #18446744073709549823
and X13, X27, #18446744073709550079
and X13, X27, #18446744073709550591
and X13, X27, #18446744073709550592
and X13, X27, #18446744073709550593
and X13, X27, #18446744073709550595
and X13, X27, #18446744073709550599
and X13, X27, #18446744073709550607
and X13, X27, #18446744073709550623
and X13, X27, #18446744073709550655
and X13, X27, #18446744073709550719
and X13, X27, #18446744073709550847
and X13, X27, #18446744073709551103
and X13, X27, #18446744073709551104
and X13, X27, #18446744073709551105
and X13, X27, #18446744073709551107
and X13, X27, #18446744073709551111
and X13, X27, #18446744073709551119
and X13, X27, #18446744073709551135
and X13, X27, #18446744073709551167
and X13, X27, #18446744073709551231
and X13, X27, #18446744073709551359
and X13, X27, #18446744073709551360
and X13, X27, #18446744073709551361
and X13, X27, #18446744073709551363
and X13, X27, #18446744073709551367
and X13, X27, #18446744073709551375
and X13, X27, #18446744073709551391
and X13, X27, #18446744073709551423
and X13, X27, #18446744073709551487
and X13, X27, #18446744073709551488
and X13, X27, #18446744073709551489
and X13, X27, #18446744073709551491
and X13, X27, #18446744073709551495
and X13, X27, #18446744073709551503
and X13, X27, #18446744073709551519
and X13, X27, #18446744073709551551
and X13, X27, #18446744073709551552
and X13, X27, #18446744073709551553
and X13, X27, #18446744073709551555
and X13, X27, #18446744073709551559
and X13, X27, #18446744073709551567
and X13, X27, #18446744073709551583
and X13, X27, #18446744073709551584
and X13, X27, #18446744073709551585
and X13, X27, #18446744073709551587
and X13, X27, #18446744073709551591
and X13, X27, #18446744073709551599
and X13, X27, #18446744073709551600
and X13, X27, #18446744073709551601
and X13, X27, #18446744073709551603
and X13, X27, #18446744073709551607
and X13, X27, #18446744073709551608
and X13, X27, #18446744073709551609
and X13, X27, #18446744073709551611
and X13, X27, #18446744073709551612
and X13, X27, #18446744073709551613
and X13, X27, #18446744073709551614
tbz W30, #0, #-32768
tbnz W30, #0, #-32768
tbz W30, #0, #-4
tbnz W30, #0, #-4
tbz W30, #0, #0
tbnz W30, #0, #0
tbz W30, #0, #4
tbnz W30, #0, #4
tbz W30, #0, #32764
tbnz W30, #0, #32764
tbz W30, #5, #-32768
tbnz W30, #5, #-32768
tbz W30, #5, #-4
tbnz W30, #5, #-4
tbz W30, #5, #0
tbnz W30, #5, #0
tbz W30, #5, #4
tbnz W30, #5, #4
tbz W30, #5, #32764
tbnz W30, #5, #32764
tbz W30, #31, #-32768
tbnz W30, #31, #-32768
tbz W30, #31, #-4
tbnz W30, #31, #-4
tbz W30, #31, #0
tbnz W30, #31, #0
tbz W30, #31, #4
tbnz W30, #31, #4
tbz W30, #31, #32764
tbnz W30, #31, #32764
tbz X30, #0, #-32768
tbnz X30, #0, #-32768
tbz X30, #0, #-4
tbnz X30, #0, #-4
tbz X30, #0, #0
tbnz X30, #0, #0
tbz X30, #0, #4
tbnz X30, #0, #4
tbz X30, #0, #32764
tbnz X30, #0, #32764
tbz X30, #5, #-32768
tbnz X30, #5, #-32768
tbz X30, #5, #-4
tbnz X30, #5, #-4
tbz X30, #5, #0
tbnz X30, #5, #0
tbz X30, #5, #4
tbnz X30, #5, #4
tbz X30, #5, #32764
tbnz X30, #5, #32764
tbz X30, #31, #-32768
tbnz X30, #31, #-32768
tbz X30, #31, #-4
tbnz X30, #31, #-4
tbz X30, #31, #0
tbnz X30, #31, #0
tbz X30, #31, #4
tbnz X30, #31, #4
tbz X30, #31, #32764
tbnz X30, #31, #32764
tbz X30, #32, #-32768
tbnz X30, #32, #-32768
tbz X30, #32, #-4
tbnz X30, #32, #-4
tbz X30, #32, #0
tbnz X30, #32, #0
tbz X30, #32, #4
tbnz X30, #32, #4
tbz X30, #32, #32764
tbnz X30, #32, #32764
tbz X30, #63, #-32768
tbnz X30, #63, #-32768
tbz X30, #63, #-4
tbnz X30, #63, #-4
tbz X30, #63, #0
tbnz X30, #63, #0
tbz X30, #63, #4
tbnz X30, #63, #4
tbz X30, #63, #32764
tbnz X30, #63, #32764
b.eq #-1048576
b.eq #-4
b.eq #0
b.eq #4
b.eq #1048572
b.ne #-1048576
b.ne #-4
b.ne #0
b.ne #4
b.ne #1048572
b.hs #-1048576
b.hs #-4
b.hs #0
b.hs #4
b.hs #1048572
b.lo #-1048576
b.lo #-4
b.lo #0
b.lo #4
b.lo #1048572
b.mi #-1048576
b.mi #-4
b.mi #0
b.mi #4
b.mi #1048572
b.pl #-1048576
b.pl #-4
b.pl #0
b.pl #4
b.pl #1048572
b.vs #-1048576
b.vs #-4
b.vs #0
b.vs #4
b.vs #1048572
b.vc #-1048576
b.vc #-4
b.vc #0
b.vc #4
b.vc #1048572
b.hi #-1048576
b.hi #-4
b.hi #0
b.hi #4
b.hi #1048572
b.ls #-1048576
b.ls #-4
b.ls #0
b.ls #4
b.ls #1048572
b.ge #-1048576
b.ge #-4
b.ge #0
b.ge #4
b.ge #1048572
b.lt #-1048576
b.lt #-4
b.lt #0
b.lt #4
b.lt #1048572
b.gt #-1048576
b.gt #-4
b.gt #0
b.gt #4
b.gt #1048572
b.le #-1048576
b.le #-4
b.le #0
b.le #4
b.le #1048572
b.al #-1048576
b.al #-4
b.al #0
b.al #4
b.al #1048572
b.nv #-1048576
b.nv #-4
b.nv #0
b.nv #4
b.nv #1048572
