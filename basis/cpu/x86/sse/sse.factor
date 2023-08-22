! Copyright (C) 2009, 2010 Joe Groff, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.data arrays assocs combinators compiler.cfg.comparisons
compiler.cfg.intrinsics cpu.architecture cpu.x86 cpu.x86.assembler
cpu.x86.assembler.operands cpu.x86.features fry kernel locals macros
math math.vectors quotations sequences system ;
QUALIFIED-WITH: alien.c-types c
IN: cpu.x86.sse

! Scalar floating point with SSE2
M: x86 %load-float c:float <ref> float-rep %load-vector ;
M: x86 %load-double c:double <ref> double-rep %load-vector ;

M: float-rep copy-register* drop MOVAPS ;
M: double-rep copy-register* drop MOVAPS ;

M: float-rep copy-memory* drop MOVSS ;
M: double-rep copy-memory* drop MOVSD ;

M: x86 %add-float double-rep two-operand ADDSD ;
M: x86 %sub-float double-rep two-operand SUBSD ;
M: x86 %mul-float double-rep two-operand MULSD ;
M: x86 %div-float double-rep two-operand DIVSD ;
M: x86 %min-float double-rep two-operand MINSD ;
M: x86 %max-float double-rep two-operand MAXSD ;
M: x86 %sqrt SQRTSD ;

: %clear-unless-in-place ( dst src -- )
    over = [ drop ] [ dup XORPS ] if ;

M: x86 %single>double-float [ %clear-unless-in-place ] [ CVTSS2SD ] 2bi ;
M: x86 %double>single-float [ %clear-unless-in-place ] [ CVTSD2SS ] 2bi ;

M: x86 integer-float-needs-stack-frame? f ;
M: x86 %integer>float [ drop dup XORPS ] [ CVTSI2SD ] 2bi ;
M: x86 %float>integer CVTTSD2SI ;

M: x86 %compare-float-ordered
    [ COMISD ] (%compare-float) ;

M: x86 %compare-float-unordered
    [ UCOMISD ] (%compare-float) ;

M: x86 %compare-float-ordered-branch
    [ COMISD ] (%compare-float-branch) ;

M: x86 %compare-float-unordered-branch
    [ UCOMISD ] (%compare-float-branch) ;

! SIMD
M: float-4-rep copy-register* drop MOVAPS ;
M: double-2-rep copy-register* drop MOVAPS ;
M: vector-rep copy-register* drop MOVDQA ;

MACRO: available-reps ( alist -- quot )
    ! Each SSE version adds new representations and supports
    ! all old ones
    unzip { } [ append ] accumulate*
    [ [ 1quotation ] map ] bi@ zip
    reverse [ { } ] suffix
    '[ _ cond ] ;

M: x86 %alien-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %zero-vector
    {
        { double-2-rep [ dup XORPS ] }
        { float-4-rep [ dup XORPS ] }
        [ drop dup PXOR ]
    } case ;

M: x86 %zero-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %fill-vector
    {
        { double-2-rep [ dup [ XORPS ] [ CMPEQPS ] 2bi ] }
        { float-4-rep  [ dup [ XORPS ] [ CMPEQPS ] 2bi ] }
        [ drop dup PCMPEQB ]
    } case ;

M: x86 %fill-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M:: x86 %gather-vector-4 ( dst src1 src2 src3 src4 rep -- )
    rep signed-rep {
        { float-4-rep [
            dst src1 float-4-rep %copy
            dst src2 UNPCKLPS
            src3 src4 UNPCKLPS
            dst src3 MOVLHPS
        ] }
        { int-4-rep [
            dst src1 int-4-rep %copy
            dst src2 PUNPCKLDQ
            src3 src4 PUNPCKLDQ
            dst src3 PUNPCKLQDQ
        ] }
    } case ;

M: x86 %gather-vector-4-reps
    {
        ! Can't do this with sse1 since it will want to unbox
        ! double-precision floats and convert to single precision
        { sse2? { float-4-rep int-4-rep uint-4-rep } }
    } available-reps ;

M:: x86 %gather-int-vector-4 ( dst src1 src2 src3 src4 rep -- )
    dst rep %zero-vector
    dst src1 32-bit-version-of 0 PINSRD
    dst src2 32-bit-version-of 1 PINSRD
    dst src3 32-bit-version-of 2 PINSRD
    dst src4 32-bit-version-of 3 PINSRD ;

M: x86 %gather-int-vector-4-reps
    {
        { sse4.1? { int-4-rep uint-4-rep } }
    } available-reps ;

M:: x86 %gather-vector-2 ( dst src1 src2 rep -- )
    rep signed-rep {
        { double-2-rep [
            dst src1 double-2-rep %copy
            dst src2 MOVLHPS
        ] }
        { longlong-2-rep [
            dst src1 longlong-2-rep %copy
            dst src2 PUNPCKLQDQ
        ] }
    } case ;

M: x86 %gather-vector-2-reps
    {
        { sse2? { double-2-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M:: x86.64 %gather-int-vector-2 ( dst src1 src2 rep -- )
    dst rep %zero-vector
    dst src1 0 PINSRQ
    dst src2 1 PINSRQ ;

M: x86.64 %gather-int-vector-2-reps
    {
        { sse4.1? { longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

:: %select-vector-32 ( dst src n rep -- )
    rep {
        { char-16-rep [
            dst 32-bit-version-of src n PEXTRB
            dst dst 8-bit-version-of MOVSX
        ] }
        { uchar-16-rep [
            dst 32-bit-version-of src n PEXTRB
        ] }
        { short-8-rep [
            dst 32-bit-version-of src n PEXTRW
            dst dst 16-bit-version-of MOVSX
        ] }
        { ushort-8-rep [
            dst 32-bit-version-of src n PEXTRW
        ] }
        { int-4-rep [
            dst 32-bit-version-of src n PEXTRD
            dst dst 32-bit-version-of 2dup = [ 2drop ] [ MOVSX ] if
        ] }
        { uint-4-rep [
            dst 32-bit-version-of src n PEXTRD
        ] }
    } case ;

M: x86.32 %select-vector
    %select-vector-32 ;

M: x86.32 %select-vector-reps
    {
        { sse4.1? { uchar-16-rep char-16-rep ushort-8-rep short-8-rep uint-4-rep int-4-rep } }
    } available-reps ;

M: x86.64 %select-vector
    {
        { longlong-2-rep  [ PEXTRQ ] }
        { ulonglong-2-rep [ PEXTRQ ] }
        [ %select-vector-32 ]
    } case ;

M: x86.64 %select-vector-reps
    {
        { sse4.1? { uchar-16-rep char-16-rep ushort-8-rep short-8-rep uint-4-rep int-4-rep ulonglong-2-rep longlong-2-rep } }
    } available-reps ;

: sse1-float-4-shuffle ( dst shuffle -- )
    {
        { { 0 1 2 3 } [ drop ] }
        { { 0 1 0 1 } [ dup MOVLHPS ] }
        { { 2 3 2 3 } [ dup MOVHLPS ] }
        { { 0 0 1 1 } [ dup UNPCKLPS ] }
        { { 2 2 3 3 } [ dup UNPCKHPS ] }
        [ dupd SHUFPS ]
    } case ;

: float-4-shuffle ( dst shuffle -- )
    sse3? [
        {
            { { 0 0 2 2 } [ dup MOVSLDUP ] }
            { { 1 1 3 3 } [ dup MOVSHDUP ] }
            [ sse1-float-4-shuffle ]
        } case
    ] [ sse1-float-4-shuffle ] if ;

: int-4-shuffle ( dst shuffle -- )
    {
        { { 0 1 2 3 } [ drop ] }
        { { 0 0 1 1 } [ dup PUNPCKLDQ ] }
        { { 2 2 3 3 } [ dup PUNPCKHDQ ] }
        { { 0 1 0 1 } [ dup PUNPCKLQDQ ] }
        { { 2 3 2 3 } [ dup PUNPCKHQDQ ] }
        [ dupd PSHUFD ]
    } case ;

: longlong-2-shuffle ( dst shuffle -- )
    first2 [ 2 * dup 1 + ] bi@ 4array int-4-shuffle ;

: >float-4-shuffle ( double-2-shuffle -- float-4-shuffle )
    [ 2 * { 0 1 } n+v ] map concat ;

M:: x86 %shuffle-vector-imm ( dst src shuffle rep -- )
    dst src rep %copy
    dst shuffle rep signed-rep {
        { double-2-rep [ >float-4-shuffle float-4-shuffle ] }
        { float-4-rep [ float-4-shuffle ] }
        { int-4-rep [ int-4-shuffle ] }
        { longlong-2-rep [ longlong-2-shuffle ] }
    } case ;

M: x86 %shuffle-vector-imm-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M:: x86 %shuffle-vector-halves-imm ( dst src1 src2 shuffle rep -- )
    dst src1 src2 rep two-operand
    shuffle rep {
        { double-2-rep [ >float-4-shuffle SHUFPS ] }
        { float-4-rep [ SHUFPS ] }
    } case ;

M: x86 %shuffle-vector-halves-imm-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep } }
    } available-reps ;

M: x86 %shuffle-vector
    two-operand PSHUFB ;

M: x86 %shuffle-vector-reps
    {
        { ssse3? { float-4-rep double-2-rep longlong-2-rep ulonglong-2-rep int-4-rep uint-4-rep short-8-rep ushort-8-rep char-16-rep uchar-16-rep } }
    } available-reps ;

M: x86 %merge-vector-head
    [ two-operand ] keep
    signed-rep {
        { double-2-rep   [ MOVLHPS ] }
        { float-4-rep    [ UNPCKLPS ] }
        { longlong-2-rep [ PUNPCKLQDQ ] }
        { int-4-rep      [ PUNPCKLDQ ] }
        { short-8-rep    [ PUNPCKLWD ] }
        { char-16-rep    [ PUNPCKLBW ] }
    } case ;

M: x86 %merge-vector-tail
    [ two-operand ] keep
    signed-rep {
        { double-2-rep   [ UNPCKHPD ] }
        { float-4-rep    [ UNPCKHPS ] }
        { longlong-2-rep [ PUNPCKHQDQ ] }
        { int-4-rep      [ PUNPCKHDQ ] }
        { short-8-rep    [ PUNPCKHWD ] }
        { char-16-rep    [ PUNPCKHBW ] }
    } case ;

M: x86 %merge-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %float-pack-vector
    drop CVTPD2PS ;

M: x86 %float-pack-vector-reps
    {
        { sse2? { double-2-rep } }
    } available-reps ;

M: x86 %signed-pack-vector
    [ two-operand ] keep
    {
        { int-4-rep    [ PACKSSDW ] }
        { short-8-rep  [ PACKSSWB ] }
    } case ;

M: x86 %signed-pack-vector-reps
    {
        { sse2? { short-8-rep int-4-rep } }
    } available-reps ;

M: x86 %unsigned-pack-vector
    [ two-operand ] keep
    signed-rep {
        { int-4-rep   [ PACKUSDW ] }
        { short-8-rep [ PACKUSWB ] }
    } case ;

M: x86 %unsigned-pack-vector-reps
    {
        { sse2? { short-8-rep } }
        { sse4.1? { int-4-rep } }
    } available-reps ;

M: x86 %tail>head-vector
    dup {
        { float-4-rep [ drop UNPCKHPD ] }
        { double-2-rep [ drop UNPCKHPD ] }
        [ drop [ %copy ] [ drop PUNPCKHQDQ ] 3bi ]
    } case ;

M: x86 %unpack-vector-head
    {
        { char-16-rep  [ PMOVSXBW ] }
        { uchar-16-rep [ PMOVZXBW ] }
        { short-8-rep  [ PMOVSXWD ] }
        { ushort-8-rep [ PMOVZXWD ] }
        { int-4-rep    [ PMOVSXDQ ] }
        { uint-4-rep   [ PMOVZXDQ ] }
        { float-4-rep  [ CVTPS2PD ] }
    } case ;

M: x86 %unpack-vector-head-reps
    {
        { sse2? { float-4-rep } }
        { sse4.1? { char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep } }
    } available-reps ;

M: x86 %integer>float-vector
    {
        { int-4-rep [ CVTDQ2PS ] }
    } case ;

M: x86 %integer>float-vector-reps
    {
        { sse2? { int-4-rep } }
    } available-reps ;

M: x86 %float>integer-vector
    {
        { float-4-rep [ CVTTPS2DQ ] }
    } case ;

M: x86 %float>integer-vector-reps
    {
        { sse2? { float-4-rep } }
    } available-reps ;

: (%compare-float-vector) ( dst src rep double single -- )
    [ double-2-rep eq? ] 2dip if ; inline

: %compare-float-vector ( dst src rep cc -- )
    {
        { cc<    [ [ CMPLTPD    ] [ CMPLTPS    ] (%compare-float-vector) ] }
        { cc<=   [ [ CMPLEPD    ] [ CMPLEPS    ] (%compare-float-vector) ] }
        { cc=    [ [ CMPEQPD    ] [ CMPEQPS    ] (%compare-float-vector) ] }
        { cc<>=  [ [ CMPORDPD   ] [ CMPORDPS   ] (%compare-float-vector) ] }
        { cc/<   [ [ CMPNLTPD   ] [ CMPNLTPS   ] (%compare-float-vector) ] }
        { cc/<=  [ [ CMPNLEPD   ] [ CMPNLEPS   ] (%compare-float-vector) ] }
        { cc/=   [ [ CMPNEQPD   ] [ CMPNEQPS   ] (%compare-float-vector) ] }
        { cc/<>= [ [ CMPUNORDPD ] [ CMPUNORDPS ] (%compare-float-vector) ] }
    } case ;

:: (%compare-int-vector) ( dst src rep int64 int32 int16 int8 -- )
    rep signed-rep :> rep'
    dst src rep' {
        { longlong-2-rep [ int64 call ] }
        { int-4-rep      [ int32 call ] }
        { short-8-rep    [ int16 call ] }
        { char-16-rep    [ int8  call ] }
    } case ; inline

: %compare-int-vector ( dst src rep cc -- )
    {
        { cc= [ [ PCMPEQQ ] [ PCMPEQD ] [ PCMPEQW ] [ PCMPEQB ] (%compare-int-vector) ] }
        { cc> [ [ PCMPGTQ ] [ PCMPGTD ] [ PCMPGTW ] [ PCMPGTB ] (%compare-int-vector) ] }
    } case ;

M: x86 %compare-vector
    [ [ two-operand ] keep ] dip
    over float-vector-rep?
    [ %compare-float-vector ]
    [ %compare-int-vector ] if ;

: %compare-vector-eq-reps ( -- reps )
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep } }
        { sse4.1? { longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

: %compare-vector-ord-reps ( -- reps )
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep short-8-rep int-4-rep } }
        { sse4.2? { longlong-2-rep } }
    } available-reps ;

M: x86 %compare-vector-reps
    {
        { [ dup { cc= cc/= cc/<>= cc<>= } member-eq? ] [ drop %compare-vector-eq-reps ] }
        [ drop %compare-vector-ord-reps ]
    } cond ;

: %compare-float-vector-ccs ( cc -- ccs not? )
    {
        { cc<    [ { { cc<  f   }              } f ] }
        { cc<=   [ { { cc<= f   }              } f ] }
        { cc>    [ { { cc<  t   }              } f ] }
        { cc>=   [ { { cc<= t   }              } f ] }
        { cc=    [ { { cc=  f   }              } f ] }
        { cc<>   [ { { cc<  f   } { cc<    t } } f ] }
        { cc<>=  [ { { cc<>= f  }              } f ] }
        { cc/<   [ { { cc/<  f  }              } f ] }
        { cc/<=  [ { { cc/<= f  }              } f ] }
        { cc/>   [ { { cc/<  t  }              } f ] }
        { cc/>=  [ { { cc/<= t  }              } f ] }
        { cc/=   [ { { cc/=  f  }              } f ] }
        { cc/<>  [ { { cc/=  f  } { cc/<>= f } } f ] }
        { cc/<>= [ { { cc/<>= f }              } f ] }
    } case ;

: %compare-int-vector-ccs ( cc -- ccs not? )
    order-cc {
        { cc<    [ { { cc> t } } f ] }
        { cc<=   [ { { cc> f } } t ] }
        { cc>    [ { { cc> f } } f ] }
        { cc>=   [ { { cc> t } } t ] }
        { cc=    [ { { cc= f } } f ] }
        { cc/=   [ { { cc= f } } t ] }
        { t      [ {           } t ] }
        { f      [ {           } f ] }
    } case ;

M: x86 %compare-vector-ccs
    swap float-vector-rep?
    [ %compare-float-vector-ccs ]
    [ %compare-int-vector-ccs ] if ;

:: %test-vector-mask ( dst temp mask vcc -- )
    vcc {
        { vcc-any    [ dst dst TEST dst temp \ CMOVNE (%boolean) ] }
        { vcc-none   [ dst dst TEST dst temp \ CMOVE  (%boolean) ] }
        { vcc-all    [ dst mask CMP dst temp \ CMOVE  (%boolean) ] }
        { vcc-notall [ dst mask CMP dst temp \ CMOVNE (%boolean) ] }
    } case ;

: (%move-vector-mask) ( dst src rep -- mask )
    {
        { double-2-rep [ MOVMSKPS 0xf ] }
        { float-4-rep  [ MOVMSKPS 0xf ] }
        [ drop PMOVMSKB 0xffff ]
    } case ;

M: x86 %move-vector-mask
    (%move-vector-mask) drop ;

M: x86 %move-vector-mask-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M:: x86 %test-vector ( dst src temp rep vcc -- )
    dst src rep (%move-vector-mask) :> mask
    dst temp mask vcc %test-vector-mask ;

:: %test-vector-mask-branch ( label temp mask vcc -- )
    vcc {
        { vcc-any    [ temp temp TEST label JNE ] }
        { vcc-none   [ temp temp TEST label JE ] }
        { vcc-all    [ temp mask CMP label JE ] }
        { vcc-notall [ temp mask CMP label JNE ] }
    } case ;

M:: x86 %test-vector-branch ( label src temp rep vcc -- )
    temp src rep (%move-vector-mask) :> mask
    label temp mask vcc %test-vector-mask-branch ;

M: x86 %test-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %add-vector
    [ two-operand ] keep
    {
        { float-4-rep [ ADDPS ] }
        { double-2-rep [ ADDPD ] }
        { char-16-rep [ PADDB ] }
        { uchar-16-rep [ PADDB ] }
        { short-8-rep [ PADDW ] }
        { ushort-8-rep [ PADDW ] }
        { int-4-rep [ PADDD ] }
        { uint-4-rep [ PADDD ] }
        { longlong-2-rep [ PADDQ ] }
        { ulonglong-2-rep [ PADDQ ] }
    } case ;

M: x86 %add-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %saturated-add-vector
    [ two-operand ] keep
    {
        { char-16-rep [ PADDSB ] }
        { uchar-16-rep [ PADDUSB ] }
        { short-8-rep [ PADDSW ] }
        { ushort-8-rep [ PADDUSW ] }
    } case ;

M: x86 %saturated-add-vector-reps
    {
        { sse2? { char-16-rep uchar-16-rep short-8-rep ushort-8-rep } }
    } available-reps ;

M: x86 %add-sub-vector
    [ two-operand ] keep
    {
        { float-4-rep [ ADDSUBPS ] }
        { double-2-rep [ ADDSUBPD ] }
    } case ;

M: x86 %add-sub-vector-reps
    {
        { sse3? { float-4-rep double-2-rep } }
    } available-reps ;

M: x86 %sub-vector
    [ two-operand ] keep
    {
        { float-4-rep [ SUBPS ] }
        { double-2-rep [ SUBPD ] }
        { char-16-rep [ PSUBB ] }
        { uchar-16-rep [ PSUBB ] }
        { short-8-rep [ PSUBW ] }
        { ushort-8-rep [ PSUBW ] }
        { int-4-rep [ PSUBD ] }
        { uint-4-rep [ PSUBD ] }
        { longlong-2-rep [ PSUBQ ] }
        { ulonglong-2-rep [ PSUBQ ] }
    } case ;

M: x86 %sub-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %saturated-sub-vector
    [ two-operand ] keep
    {
        { char-16-rep [ PSUBSB ] }
        { uchar-16-rep [ PSUBUSB ] }
        { short-8-rep [ PSUBSW ] }
        { ushort-8-rep [ PSUBUSW ] }
    } case ;

M: x86 %saturated-sub-vector-reps
    {
        { sse2? { char-16-rep uchar-16-rep short-8-rep ushort-8-rep } }
    } available-reps ;

M: x86 %mul-vector
    [ two-operand ] keep
    {
        { float-4-rep [ MULPS ] }
        { double-2-rep [ MULPD ] }
        { short-8-rep [ PMULLW ] }
        { ushort-8-rep [ PMULLW ] }
        { int-4-rep [ PMULLD ] }
        { uint-4-rep [ PMULLD ] }
    } case ;

M: x86 %mul-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep short-8-rep ushort-8-rep } }
        { sse4.1? { int-4-rep uint-4-rep } }
    } available-reps ;

M: x86 %mul-high-vector
    [ two-operand ] keep
    {
        { short-8-rep  [ PMULHW ] }
        { ushort-8-rep [ PMULHUW ] }
    } case ;

M: x86 %mul-high-vector-reps
    {
        { sse2? { short-8-rep ushort-8-rep } }
    } available-reps ;

M: x86 %mul-horizontal-add-vector
    [ two-operand ] keep
    {
        { char-16-rep  [ PMADDUBSW ] }
        { uchar-16-rep [ PMADDUBSW ] }
        { short-8-rep  [ PMADDWD ] }
    } case ;

M: x86 %mul-horizontal-add-vector-reps
    {
        { sse2?  { short-8-rep } }
        { ssse3? { char-16-rep uchar-16-rep } }
    } available-reps ;

M: x86 %div-vector
    [ two-operand ] keep
    {
        { float-4-rep [ DIVPS ] }
        { double-2-rep [ DIVPD ] }
    } case ;

M: x86 %div-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep } }
    } available-reps ;

M: x86 %min-vector
    [ two-operand ] keep
    {
        { char-16-rep [ PMINSB ] }
        { uchar-16-rep [ PMINUB ] }
        { short-8-rep [ PMINSW ] }
        { ushort-8-rep [ PMINUW ] }
        { int-4-rep [ PMINSD ] }
        { uint-4-rep [ PMINUD ] }
        { float-4-rep [ MINPS ] }
        { double-2-rep [ MINPD ] }
    } case ;

M: x86 %min-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { uchar-16-rep short-8-rep double-2-rep } }
        { sse4.1? { char-16-rep ushort-8-rep int-4-rep uint-4-rep } }
    } available-reps ;

M: x86 %max-vector
    [ two-operand ] keep
    {
        { char-16-rep [ PMAXSB ] }
        { uchar-16-rep [ PMAXUB ] }
        { short-8-rep [ PMAXSW ] }
        { ushort-8-rep [ PMAXUW ] }
        { int-4-rep [ PMAXSD ] }
        { uint-4-rep [ PMAXUD ] }
        { float-4-rep [ MAXPS ] }
        { double-2-rep [ MAXPD ] }
    } case ;

M: x86 %max-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { uchar-16-rep short-8-rep double-2-rep } }
        { sse4.1? { char-16-rep ushort-8-rep int-4-rep uint-4-rep } }
    } available-reps ;

M: x86 %avg-vector
    [ two-operand ] keep
    {
        { uchar-16-rep [ PAVGB ] }
        { ushort-8-rep [ PAVGW ] }
    } case ;

M: x86 %avg-vector-reps
    {
        { sse2? { uchar-16-rep ushort-8-rep } }
    } available-reps ;

M: x86 %dot-vector
    [ two-operand ] keep
    {
        { float-4-rep [ 0xff DPPS ] }
        { double-2-rep [ 0xff DPPD ] }
    } case ;

M: x86 %dot-vector-reps
    {
        { sse4.1? { float-4-rep double-2-rep } }
    } available-reps ;

M: x86 %sad-vector
    [ two-operand ] keep
    {
        { uchar-16-rep [ PSADBW ] }
    } case ;

M: x86 %sad-vector-reps
    {
        { sse2? { uchar-16-rep } }
    } available-reps ;

M: x86 %horizontal-add-vector
    [ two-operand ] keep
    signed-rep {
        { float-4-rep  [ HADDPS ] }
        { double-2-rep [ HADDPD ] }
        { int-4-rep    [ PHADDD ] }
        { short-8-rep  [ PHADDW ] }
    } case ;

M: x86 %horizontal-add-vector-reps
    {
        { sse3? { float-4-rep double-2-rep } }
        { ssse3? { int-4-rep uint-4-rep short-8-rep ushort-8-rep } }
    } available-reps ;

M: x86 %horizontal-shl-vector-imm
    two-operand PSLLDQ ;

M: x86 %horizontal-shl-vector-imm-reps
    {
        { sse2? { char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep float-4-rep double-2-rep } }
    } available-reps ;

M: x86 %horizontal-shr-vector-imm
    two-operand PSRLDQ ;

M: x86 %horizontal-shr-vector-imm-reps
    {
        { sse2? { char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep float-4-rep double-2-rep } }
    } available-reps ;

M: x86 %abs-vector
    {
        { char-16-rep [ PABSB ] }
        { short-8-rep [ PABSW ] }
        { int-4-rep [ PABSD ] }
    } case ;

M: x86 %abs-vector-reps
    {
        { ssse3? { char-16-rep short-8-rep int-4-rep } }
    } available-reps ;

M: x86 %sqrt-vector
    {
        { float-4-rep [ SQRTPS ] }
        { double-2-rep [ SQRTPD ] }
    } case ;

M: x86 %sqrt-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep } }
    } available-reps ;

M: x86 %and-vector
    [ two-operand ] keep
    {
        { float-4-rep [ ANDPS ] }
        { double-2-rep [ ANDPS ] }
        [ drop PAND ]
    } case ;

M: x86 %and-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %andn-vector
    [ two-operand ] keep
    {
        { float-4-rep [ ANDNPS ] }
        { double-2-rep [ ANDNPS ] }
        [ drop PANDN ]
    } case ;

M: x86 %andn-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %or-vector
    [ two-operand ] keep
    {
        { float-4-rep [ ORPS ] }
        { double-2-rep [ ORPS ] }
        [ drop POR ]
    } case ;

M: x86 %or-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %xor-vector
    [ two-operand ] keep
    {
        { float-4-rep [ XORPS ] }
        { double-2-rep [ XORPS ] }
        [ drop PXOR ]
    } case ;

M: x86 %xor-vector-reps
    {
        { sse? { float-4-rep } }
        { sse2? { double-2-rep char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %shl-vector
    [ two-operand ] keep
    {
        { short-8-rep [ PSLLW ] }
        { ushort-8-rep [ PSLLW ] }
        { int-4-rep [ PSLLD ] }
        { uint-4-rep [ PSLLD ] }
        { longlong-2-rep [ PSLLQ ] }
        { ulonglong-2-rep [ PSLLQ ] }
    } case ;

M: x86 %shl-vector-reps
    {
        { sse2? { short-8-rep ushort-8-rep int-4-rep uint-4-rep longlong-2-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %shr-vector
    [ two-operand ] keep
    {
        { short-8-rep [ PSRAW ] }
        { ushort-8-rep [ PSRLW ] }
        { int-4-rep [ PSRAD ] }
        { uint-4-rep [ PSRLD ] }
        { ulonglong-2-rep [ PSRLQ ] }
    } case ;

M: x86 %shr-vector-reps
    {
        { sse2? { short-8-rep ushort-8-rep int-4-rep uint-4-rep ulonglong-2-rep } }
    } available-reps ;

M: x86 %shl-vector-imm %shl-vector ;
M: x86 %shl-vector-imm-reps %shl-vector-reps ;
M: x86 %shr-vector-imm %shr-vector ;
M: x86 %shr-vector-imm-reps %shr-vector-reps ;

M: x86 %integer>scalar drop MOVD ;

:: %scalar>integer-32 ( dst src rep -- )
    rep {
        { int-scalar-rep [
            dst 32-bit-version-of src MOVD
            dst dst 32-bit-version-of
            2dup eq? [ 2drop ] [ MOVSX ] if
        ] }
        { uint-scalar-rep [
            dst 32-bit-version-of src MOVD
        ] }
        { short-scalar-rep [
            dst 32-bit-version-of src MOVD
            dst dst 16-bit-version-of MOVSX
        ] }
        { ushort-scalar-rep [
            dst 32-bit-version-of src MOVD
            dst dst 16-bit-version-of MOVZX
        ] }
        { char-scalar-rep [
            dst 32-bit-version-of src MOVD
            dst { } 8 [| tmp-dst |
                tmp-dst dst int-rep %copy
                tmp-dst tmp-dst 8-bit-version-of MOVSX
                dst tmp-dst int-rep %copy
            ] with-small-register
        ] }
        { uchar-scalar-rep [
            dst 32-bit-version-of src MOVD
            dst { } 8 [| tmp-dst |
                tmp-dst dst int-rep %copy
                tmp-dst tmp-dst 8-bit-version-of MOVZX
                dst tmp-dst int-rep %copy
            ] with-small-register
        ] }
    } case ;

M: x86.32 %scalar>integer %scalar>integer-32 ;

M: x86.64 %scalar>integer
    {
        { longlong-scalar-rep  [ MOVD ] }
        { ulonglong-scalar-rep [ MOVD ] }
        [ %scalar>integer-32 ]
    } case ;

M: x86 %vector>scalar %copy ;

M: x86 %scalar>vector %copy ;
