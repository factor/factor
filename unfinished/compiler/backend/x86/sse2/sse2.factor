! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.accessors arrays generic kernel system
kernel.private math math.private memory namespaces sequences
words math.floats.private layouts quotations cpu.x86
compiler.cfg.templates compiler.cfg.builder compiler.cfg.registers
compiler.constants compiler.backend compiler.backend.x86 ;
IN: compiler.backend.x86.sse2

M: x86 %box-float ( dst src -- )
    #! Only called by pentium4 backend, uses SSE2 instruction
    #! dest is a loc or a vreg
    float 16 [
        8 (object@) swap v>operand MOVSD
        float %store-tagged
    ] %allot ;

M: x86 %unbox-float ( dst src -- )
    [ v>operand ] bi@ float-offset [+] MOVSD ;

: define-float-op ( word op -- )
    [ "x" operand "y" operand ] swap suffix T{ template
        { input { { float "x" } { float "y" } } }
        { output { "x" } }
        { gc t }
    } define-intrinsic ;

{
    { float+ ADDSD }
    { float- SUBSD }
    { float* MULSD }
    { float/f DIVSD }
} [
    first2 define-float-op
] each

: define-float-jump ( word op -- )
    [ "x" operand "y" operand UCOMISD ] swap suffix
    { { float "x" } { float "y" } } define-if-intrinsic ;

{
    { float< JAE }
    { float<= JA }
    { float> JBE }
    { float>= JB }
    { float= JNE }
} [
    first2 define-float-jump
] each

\ float>fixnum [
    "out" operand "in" operand CVTTSD2SI
    "out" operand tag-bits get SHL
] T{ template
    { input { { float "in" } } }
    { scratch { { f "out" } } }
    { output { "out" } }
} define-intrinsic

\ fixnum>float [
    "in" operand %untag-fixnum
    "out" operand "in" operand CVTSI2SD
] T{ template
    { input { { f "in" } } }
    { scratch { { float "out" } } }
    { output { "out" } }
    { clobber { "in" } }
    { gc t }
} define-intrinsic

: alien-float-get-template
    T{ template
        { input {
            { unboxed-c-ptr "alien" c-ptr }
            { f "offset" fixnum }
        } }
        { scratch { { float "value" } } }
        { output { "value" } }
        { clobber { "offset" } }
    } ;

: alien-float-set-template
    T{ template
        { input {
            { float "value" float }
            { unboxed-c-ptr "alien" c-ptr }
            { f "offset" fixnum }
        } }
        { clobber { "offset" } }
    } ;

: define-alien-float-intrinsics ( word get-quot word set-quot -- )
    [ "value" operand swap %alien-accessor ] curry
    alien-float-set-template
    define-intrinsic
    [ "value" operand swap %alien-accessor ] curry
    alien-float-get-template
    define-intrinsic ;

\ alien-double
[ MOVSD ]
\ set-alien-double
[ swap MOVSD ]
define-alien-float-intrinsics

\ alien-float
[ dupd MOVSS dup CVTSS2SD ]
\ set-alien-float
[ swap dup dup CVTSD2SS MOVSS ]
define-alien-float-intrinsics
