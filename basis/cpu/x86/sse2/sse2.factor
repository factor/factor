! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.accessors arrays generic kernel
kernel.private math math.private memory namespaces sequences
words math.floats.private layouts quotations locals fry
system compiler.constants compiler.codegen compiler.cfg.templates
compiler.cfg.registers compiler.cfg.builder cpu.architecture
cpu.x86.assembler cpu.x86.architecture cpu.x86.intrinsics ;
IN: cpu.x86.sse2

M: x86 %copy-float MOVSD ;

M:: x86 %box-float ( dst src temp -- )
    dst 16 float float temp %allot
    dst 8 float tag-number - [+] src MOVSD ;

M: x86 %unbox-float ( dst src -- )
    float-offset [+] MOVSD ;

: define-float-op ( word op -- )
    [ "x" operand "y" operand ] swap suffix T{ template
        { input { { float "x" } { float "y" } } }
        { output { "x" } }
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
    { float< JB }
    { float<= JBE }
    { float> JA }
    { float>= JAE }
    { float= JE }
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

: define-float-getter ( word get-quot -- )
    '[
        %prepare-alien-accessor
        "value" operand "offset" operand [] @
    ]
    alien-float-get-template
    define-intrinsic ;

: define-float-setter ( word set-quot -- )
    '[
        %prepare-alien-accessor
        "offset" operand [] "value" operand @
    ]
    alien-float-set-template
    define-intrinsic ;

\ alien-double [ MOVSD ] define-float-getter
\ set-alien-double [ MOVSD ] define-float-setter

\ alien-float [ dupd MOVSS dup CVTSS2SD ] define-float-getter
\ set-alien-float [ dup dup CVTSD2SS MOVSS ] define-float-setter
