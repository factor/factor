! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data combinators kernel locals system
namespaces compiler.codegen.labels compiler.codegen.relocation
compiler.constants compiler.cfg.comparisons
compiler.cfg.intrinsics cpu.architecture cpu.x86
cpu.x86.assembler cpu.x86.assembler.operands ;
IN: cpu.x86.x87

! x87 unit is only used if SSE2 is not available.

: copy-register-x87 ( dst src -- )
    2dup eq? [ 2drop ] [ FLD shuffle-down FSTP ] if ;

M: float-rep copy-register* drop copy-register-x87 ;
M: double-rep copy-register* drop copy-register-x87 ;

: load-x87 ( dst src rep -- )
    {
        { float-rep [ FLDS shuffle-down FSTP ] }
        { double-rep [ FLDL shuffle-down FSTP ] }
    } case ;

: store-x87 ( dst src rep -- )
    {
        { float-rep [ FLD FSTPS ] }
        { double-rep [ FLD FSTPL ] }
    } case ;

: copy-memory-x87 ( dst src rep -- )
    {
        { [ pick register? ] [ load-x87 ] }
        { [ over register? ] [ store-x87 ] }
    } cond ;

M: float-rep copy-memory* copy-memory-x87 ;
M: double-rep copy-memory* copy-memory-x87 ;

M: x86 %load-float
    0 [] FLDS
    float <ref> rc-absolute rel-binary-literal
    shuffle-down FSTP ;

M: x86 %load-double
    0 [] FLDL
    double <ref> rc-absolute rel-binary-literal
    shuffle-down FSTP ;

:: binary-op ( dst src1 src2 quot -- )
    src1 FLD
    ST0 src2 shuffle-down quot call
    dst shuffle-down FSTP ; inline

M: x86 %add-float [ FADD ] binary-op ;
M: x86 %sub-float [ FSUB ] binary-op ;
M: x86 %mul-float [ FMUL ] binary-op ;
M: x86 %div-float [ FDIV ] binary-op ;

M: x86 %sqrt FLD FSQRT shuffle-down FSTP ;

M: x86 %single>double-float copy-register-x87 ;
M: x86 %double>single-float copy-register-x87 ;

M: x86 integer-float-needs-stack-frame? t ;

M:: x86 %integer>float ( dst src -- )
    4 stack@ src MOV
    4 stack@ FILDD
    dst shuffle-down FSTP ;

M:: x86 %float>integer ( dst src -- )
    src FLD
    8 stack@ EAX MOV
    0 stack@ FNSTCW
    AX 0 stack@ MOV
    AH 12 <byte> MOV
    2 stack@ AX MOV
    2 stack@ FLDCW
    4 stack@ FISTPD
    0 stack@ FLDCW
    EAX 8 stack@ MOV
    dst 4 stack@ MOV ;

:: compare-op ( src1 src2 quot -- )
    src1 FLD
    src2 shuffle-down quot call
    ST0 FSTP ; inline

M: x86 %compare-float-ordered
    [ [ FCOMI ] compare-op ] (%compare-float) ;

M: x86 %compare-float-unordered
    [ [ FUCOMI ] compare-op ] (%compare-float) ;

M: x86 %compare-float-ordered-branch
    [ [ FCOMI ] compare-op ] (%compare-float-branch) ;

M: x86 %compare-float-unordered-branch
    [ [ FUCOMI ] compare-op ] (%compare-float-branch) ;
