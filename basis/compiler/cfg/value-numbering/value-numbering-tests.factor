USING: accessors alien assocs combinators.short-circuit compiler.cfg
compiler.cfg.comparisons compiler.cfg.dce compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.representations
compiler.cfg.ssa.destruction compiler.cfg.utilities
compiler.cfg.value-numbering compiler.test cpu.architecture kernel
layouts literals math namespaces sequences system tools.test ;
! need cfg simd loaded for some tests
USE: compiler.cfg.value-numbering.simd
QUALIFIED-WITH: alien.c-types c
IN: compiler.cfg.value-numbering.tests

: trim-temps ( insns -- insns )
    [
        dup {
            [ ##compare? ]
            [ ##compare-imm? ]
            [ ##compare-integer? ]
            [ ##compare-integer-imm? ]
            [ ##compare-float-unordered? ]
            [ ##compare-float-ordered? ]
            [ ##test? ]
            [ ##test-imm? ]
            [ ##test-vector? ]
            [ ##test-vector-branch? ]
        } 1|| [ f >>temp ] when
    ] map ;

! Folding constants together
{
    {
        T{ ##load-reference f 0 0.0 }
        T{ ##load-reference f 1 -0.0 }
    }
} [
    {
        T{ ##load-reference f 0 0.0 }
        T{ ##load-reference f 1 -0.0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-reference f 0 0.0 }
        T{ ##copy f 1 0 any-rep }
    }
} [
    {
        T{ ##load-reference f 0 0.0 }
        T{ ##load-reference f 1 0.0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-reference f 0 t }
        T{ ##copy f 1 0 any-rep }
    }
} [
    {
        T{ ##load-reference f 0 t }
        T{ ##load-reference f 1 t }
    } value-numbering-step
] unit-test

! ##load-reference/##replace fusion
cpu x86? [
    [
        {
            T{ ##load-integer f 0 10 }
            T{ ##replace-imm f 10 D: 0 }
        }
    ] [
        {
            T{ ##load-integer f 0 10 }
            T{ ##replace f 0 D: 0 }
        } value-numbering-step
    ] unit-test

    [
        {
            T{ ##load-reference f 0 f }
            T{ ##replace-imm f f D: 0 }
        }
    ] [
        {
            T{ ##load-reference f 0 f }
            T{ ##replace f 0 D: 0 }
        } value-numbering-step
    ] unit-test
] when

cpu x86.32? [
    [
        {
            T{ ##load-reference f 0 + }
            T{ ##replace-imm f + D: 0 }
        }
    ] [
        {
            T{ ##load-reference f 0 + }
            T{ ##replace f 0 D: 0 }
        } value-numbering-step
    ] unit-test
] when

cpu x86.64? [
    [
        {
            T{ ##load-integer f 0 10,000,000,000 }
            T{ ##replace f 0 D: 0 }
        }
    ] [
        {
            T{ ##load-integer f 0 10,000,000,000 }
            T{ ##replace f 0 D: 0 }
        } value-numbering-step
    ] unit-test

    ! Boundary case
    [
        {
            T{ ##load-integer f 0 0x7fffffff }
            T{ ##replace f 0 D: 0 }
        }
    ] [
        {
            T{ ##load-integer f 0 0x7fffffff }
            T{ ##replace f 0 D: 0 }
        } value-numbering-step
    ] unit-test
] when

! Double compare elimination
{
    {
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##compare f 4 2 1 cc= }
        T{ ##copy f 6 4 any-rep }
        T{ ##replace f 6 D: 0 }
    }
} [
    {
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##compare f 4 2 1 cc= }
        T{ ##compare-imm f 6 4 f cc/= }
        T{ ##replace f 6 D: 0 }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##peek f 1 D: 1 }
        T{ ##compare-imm f 2 1 16 cc= }
        T{ ##copy f 3 2 any-rep }
        T{ ##replace f 3 D: 0 }
    }
} [
    {
        T{ ##peek f 1 D: 1 }
        T{ ##compare-imm f 2 1 16 cc= }
        T{ ##compare-imm f 3 2 f cc/= }
        T{ ##replace f 3 D: 0 }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##compare-integer f 4 2 1 cc> }
        T{ ##copy f 6 4 any-rep }
        T{ ##replace f 6 D: 0 }
    }
} [
    {
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##compare-integer f 4 2 1 cc> }
        T{ ##compare-imm f 6 4 f cc/= }
        T{ ##replace f 6 D: 0 }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##compare-integer f 4 2 1 cc<= }
        T{ ##compare-integer f 6 2 1 cc/<= }
        T{ ##replace f 6 D: 0 }
    }
} [
    {
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##compare-integer f 4 2 1 cc<= }
        T{ ##compare-imm f 6 4 f cc= }
        T{ ##replace f 6 D: 0 }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##peek f 1 D: 1 }
        T{ ##compare-integer-imm f 2 1 100 cc<= }
        T{ ##compare-integer-imm f 3 1 100 cc/<= }
        T{ ##replace f 3 D: 0 }
    }
} [
    {
        T{ ##peek f 1 D: 1 }
        T{ ##compare-integer-imm f 2 1 100 cc<= }
        T{ ##compare-imm f 3 2 f cc= }
        T{ ##replace f 3 D: 0 }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##peek f 8 D: 0 }
        T{ ##peek f 9 D: -1 }
        T{ ##compare-float-unordered f 12 8 9 cc< }
        T{ ##compare-float-unordered f 14 8 9 cc/< }
        T{ ##replace f 14 D: 0 }
    }
} [
    {
        T{ ##peek f 8 D: 0 }
        T{ ##peek f 9 D: -1 }
        T{ ##compare-float-unordered f 12 8 9 cc< }
        T{ ##compare-imm f 14 12 f cc= }
        T{ ##replace f 14 D: 0 }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##peek f 29 D: -1 }
        T{ ##peek f 30 D: -2 }
        T{ ##compare f 33 29 30 cc= }
        T{ ##compare-branch f 29 30 cc= }
    }
} [
    {
        T{ ##peek f 29 D: -1 }
        T{ ##peek f 30 D: -2 }
        T{ ##compare f 33 29 30 cc= }
        T{ ##compare-imm-branch f 33 f cc/= }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##peek f 29 D: -1 }
        T{ ##peek f 30 D: -2 }
        T{ ##compare-integer f 33 29 30 cc<= }
        T{ ##compare-integer-branch f 29 30 cc<= }
    }
} [
    {
        T{ ##peek f 29 D: -1 }
        T{ ##peek f 30 D: -2 }
        T{ ##compare-integer f 33 29 30 cc<= }
        T{ ##compare-imm-branch f 33 f cc/= }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##peek f 29 D: -1 }
        T{ ##peek f 30 D: -2 }
        T{ ##test f 33 29 30 cc= }
        T{ ##test-branch f 29 30 cc= }
    }
} [
    {
        T{ ##peek f 29 D: -1 }
        T{ ##peek f 30 D: -2 }
        T{ ##test f 33 29 30 cc= }
        T{ ##compare-imm-branch f 33 f cc/= }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##peek f 29 D: -1 }
        T{ ##test-imm f 33 29 30 cc= }
        T{ ##test-imm-branch f 29 30 cc= }
    }
} [
    {
        T{ ##peek f 29 D: -1 }
        T{ ##test-imm f 33 29 30 cc= }
        T{ ##compare-imm-branch f 33 f cc/= }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##peek f 1 D: -1 }
        T{ ##test-vector f 2 1 f float-4-rep vcc-any }
        T{ ##test-vector-branch f 1 f float-4-rep vcc-any }
    }
} [
    {
        T{ ##peek f 1 D: -1 }
        T{ ##test-vector f 2 1 f float-4-rep vcc-any }
        T{ ##compare-imm-branch f 2 f cc/= }
    } value-numbering-step trim-temps
] unit-test

cpu x86.32? [
    [
        {
            T{ ##peek f 1 D: 0 }
            T{ ##compare-imm f 2 1 + cc= }
            T{ ##compare-imm-branch f 1 + cc= }
        }
    ] [
        {
            T{ ##peek f 1 D: 0 }
            T{ ##compare-imm f 2 1 + cc= }
            T{ ##compare-imm-branch f 2 f cc/= }
        } value-numbering-step trim-temps
    ] unit-test
] when

! Immediate operand fusion
{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##add-imm f 2 0 100 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##add f 2 0 1 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##add-imm f 2 0 100 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##add f 2 1 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##add-imm f 2 0 -100 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##sub f 2 0 1 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##sub f 1 0 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##mul-imm f 2 0 100 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##mul f 2 0 1 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##mul-imm f 2 0 100 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##mul f 2 1 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 1 D: 0 }
        T{ ##shl-imm f 2 1 3 }
    }
} [
    {
        T{ ##peek f 1 D: 0 }
        T{ ##mul-imm f 2 1 8 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 -1 }
        T{ ##neg f 2 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 -1 }
        T{ ##mul f 2 0 1 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 -1 }
        T{ ##neg f 2 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 -1 }
        T{ ##mul f 2 1 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 0 }
        T{ ##neg f 2 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 0 }
        T{ ##sub f 2 1 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 0 }
        T{ ##neg f 2 0 }
        T{ ##copy f 3 0 any-rep }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 0 }
        T{ ##sub f 2 1 0 }
        T{ ##sub f 3 1 2 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##neg f 1 0 }
        T{ ##copy f 2 0 any-rep }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##neg f 1 0 }
        T{ ##neg f 2 1 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##not f 1 0 }
        T{ ##copy f 2 0 any-rep }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##not f 1 0 }
        T{ ##not f 2 1 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##and-imm f 2 0 100 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##and f 2 0 1 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##and-imm f 2 0 100 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##and f 2 1 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##or-imm f 2 0 100 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##or f 2 0 1 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##or-imm f 2 0 100 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##or f 2 1 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##xor-imm f 2 0 100 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##xor f 2 0 1 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##xor-imm f 2 0 100 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##xor f 2 1 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##compare-imm f 2 0 100 cc= }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##compare f 2 0 1 cc= }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##compare-integer-imm f 2 0 100 cc<= }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##compare-integer f 2 0 1 cc<= }
    } value-numbering-step trim-temps
] unit-test

cpu x86.32? [
    [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-reference f 1 + }
            T{ ##compare-imm f 2 0 + cc= }
        }
    ] [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-reference f 1 + }
            T{ ##compare f 2 0 1 cc= }
        } value-numbering-step trim-temps
    ] unit-test

    [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-reference f 1 + }
            T{ ##compare-imm-branch f 0 + cc= }
        }
    ] [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-reference f 1 + }
            T{ ##compare-branch f 0 1 cc= }
        } value-numbering-step trim-temps
    ] unit-test
] when

cpu x86.32? [
    [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-reference f 1 3.5 }
            T{ ##compare f 2 0 1 cc= }
        }
    ] [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-reference f 1 3.5 }
            T{ ##compare f 2 0 1 cc= }
        } value-numbering-step trim-temps
    ] unit-test

    [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-reference f 1 3.5 }
            T{ ##compare-branch f 0 1 cc= }
        }
    ] [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-reference f 1 3.5 }
            T{ ##compare-branch f 0 1 cc= }
        } value-numbering-step trim-temps
    ] unit-test
] unless

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##compare-integer-imm f 2 0 100 cc>= }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##compare-integer f 2 1 0 cc<= }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##compare-integer-imm-branch f 0 100 cc<= }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##compare-integer-branch f 0 1 cc<= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##compare-integer-imm-branch f 0 100 cc>= }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##compare-integer-branch f 1 0 cc<= }
    } value-numbering-step trim-temps
] unit-test

! Compare folding
{
    {
        T{ ##load-integer f 1 100 }
        T{ ##load-integer f 2 200 }
        T{ ##load-reference f 3 t }
    }
} [
    {
        T{ ##load-integer f 1 100 }
        T{ ##load-integer f 2 200 }
        T{ ##compare-integer f 3 1 2 cc<= }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##load-integer f 1 100 }
        T{ ##load-integer f 2 200 }
        T{ ##load-reference f 3 f }
    }
} [
    {
        T{ ##load-integer f 1 100 }
        T{ ##load-integer f 2 200 }
        T{ ##compare-integer f 3 1 2 cc= }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##load-integer f 1 100 }
        T{ ##load-reference f 2 f }
    }
} [
    {
        T{ ##load-integer f 1 100 }
        T{ ##compare-integer-imm f 2 1 123 cc= }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##load-integer f 1 10 }
        T{ ##load-integer f 2 20 }
        T{ ##load-reference f 3 f }
    }
} [
    {
        T{ ##load-integer f 1 10 }
        T{ ##load-integer f 2 20 }
        T{ ##compare-integer f 3 1 2 cc= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 2 }
        T{ ##load-reference f 3 t }
    }
} [
    {
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 2 }
        T{ ##compare-integer f 3 1 2 cc/= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 2 }
        T{ ##load-reference f 3 t }
    }
} [
    {
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 2 }
        T{ ##compare-integer f 3 1 2 cc< }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 1 10 }
        T{ ##load-integer f 2 20 }
        T{ ##load-reference f 3 f }
    }
} [
    {
        T{ ##load-integer f 1 10 }
        T{ ##load-integer f 2 20 }
        T{ ##compare-integer f 3 2 1 cc< }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-reference f 1 f }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##compare-integer f 1 0 0 cc< }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##copy f 1 0 any-rep }
        T{ ##load-reference f 2 f }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##copy f 1 0 any-rep }
        T{ ##compare-integer f 2 0 1 cc< }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-reference f 1 t }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##compare-integer f 1 0 0 cc<= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-reference f 1 f }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##compare-integer f 1 0 0 cc> }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-reference f 1 t }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##compare-integer f 1 0 0 cc>= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-reference f 1 f }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##compare-integer f 1 0 0 cc/= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-reference f 1 t }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##compare-integer f 1 0 0 cc= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 1 10 }
        T{ ##load-reference f 2 t }
    }
} [
    {
        T{ ##load-integer f 1 10 }
        T{ ##compare-imm f 2 1 10 cc= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 1 10 }
        T{ ##load-reference f 2 f }
    }
} [
    {
        T{ ##load-integer f 1 10 }
        T{ ##compare-imm f 2 1 20 cc= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 1 10 }
        T{ ##load-reference f 2 t }
    }
} [
    {
        T{ ##load-integer f 1 10 }
        T{ ##compare-imm f 2 1 100 cc/= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 1 10 }
        T{ ##load-reference f 2 f }
    }
} [
    {
        T{ ##load-integer f 1 10 }
        T{ ##compare-imm f 2 1 10 cc/= }
    } value-numbering-step
] unit-test

cpu x86.32? [
    [
        {
            T{ ##load-reference f 1 + }
            T{ ##load-reference f 2 f }
        }
    ] [
        {
            T{ ##load-reference f 1 + }
            T{ ##compare-imm f 2 1 + cc/= }
        } value-numbering-step
    ] unit-test

    [
        {
            T{ ##load-reference f 1 + }
            T{ ##load-reference f 2 t }
        }
    ] [
        {
            T{ ##load-reference f 1 + }
            T{ ##compare-imm f 2 1 * cc/= }
        } value-numbering-step
    ] unit-test

    [
        {
            T{ ##load-reference f 1 + }
            T{ ##load-reference f 2 t }
        }
    ] [
        {
            T{ ##load-reference f 1 + }
            T{ ##compare-imm f 2 1 + cc= }
        } value-numbering-step
    ] unit-test

    [
        {
            T{ ##load-reference f 1 + }
            T{ ##load-reference f 2 f }
        }
    ] [
        {
            T{ ##load-reference f 1 + }
            T{ ##compare-imm f 2 1 * cc= }
        } value-numbering-step
    ] unit-test
] when

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-reference f 1 t }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##compare f 1 0 0 cc= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-reference f 1 f }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##compare f 1 0 0 cc/= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 1 12 }
        T{ ##load-reference f 3 t }
    }
} [
    {
        T{ ##load-integer f 1 12 }
        T{ ##test-imm f 3 1 13 cc/= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 1 15 }
        T{ ##load-reference f 3 f }
    }
} [
    {
        T{ ##load-integer f 1 15 }
        T{ ##test-imm f 3 1 16 cc/= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 1 12 }
        T{ ##load-reference f 3 f }
    }
} [
    {
        T{ ##load-integer f 1 12 }
        T{ ##test-imm f 3 1 13 cc= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 1 15 }
        T{ ##load-reference f 3 t }
    }
} [
    {
        T{ ##load-integer f 1 15 }
        T{ ##test-imm f 3 1 16 cc= }
    } value-numbering-step
] unit-test

! Rewriting a ##test of an ##and into a ##test
{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##and f 2 0 1 }
        T{ ##test f 3 0 1 cc= }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##and f 2 0 1 }
        T{ ##test f 3 2 2 cc= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##and-imm f 2 0 12 }
        T{ ##test-imm f 3 0 12 cc= }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##and-imm f 2 0 12 }
        T{ ##test f 3 2 2 cc= }
    } value-numbering-step
] unit-test

! Rewriting ##test into ##test-imm
{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 10 }
        T{ ##test-imm f 2 0 10 cc= }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 10 }
        T{ ##test f 2 0 1 cc= }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 10 }
        T{ ##test-imm f 2 0 10 cc= }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 10 }
        T{ ##test f 2 1 0 cc= }
    } value-numbering-step trim-temps
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 10 }
        T{ ##test-imm-branch f 0 10 cc= }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 10 }
        T{ ##test-branch f 0 1 cc= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 10 }
        T{ ##test-imm-branch f 0 10 cc= }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 10 }
        T{ ##test-branch f 1 0 cc= }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 10 }
        T{ ##test-imm-branch f 0 10 cc= }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 10 }
        T{ ##test-branch f 1 0 cc= }
    } value-numbering-step
] unit-test

! Make sure the immediate fits
cpu x86.64? [
    [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-integer f 1 100000000000 }
            T{ ##test f 2 1 0 cc= }
        }
    ] [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-integer f 1 100000000000 }
            T{ ##test f 2 1 0 cc= }
        } value-numbering-step
    ] unit-test

    [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-integer f 1 100000000000 }
            T{ ##test-branch f 1 0 cc= }
        }
    ] [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-integer f 1 100000000000 }
            T{ ##test-branch f 1 0 cc= }
        } value-numbering-step
    ] unit-test
] when

! Rewriting ##compare into ##test
cpu x86? [
    [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##test f 1 0 0 cc= }
        }
    ] [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##compare-integer-imm f 1 0 0 cc= }
        } value-numbering-step
    ] unit-test

    [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##test f 1 0 0 cc/= }
        }
    ] [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##compare-integer-imm f 1 0 0 cc/= }
        } value-numbering-step
    ] unit-test

    [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##compare-integer-imm f 1 0 0 cc<= }
        }
    ] [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##compare-integer-imm f 1 0 0 cc<= }
        } value-numbering-step
    ] unit-test

    [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##test-branch f 0 0 cc= }
        }
    ] [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##compare-integer-imm-branch f 0 0 cc= }
        } value-numbering-step
    ] unit-test

    [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##test-branch f 0 0 cc/= }
        }
    ] [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##compare-integer-imm-branch f 0 0 cc/= }
        } value-numbering-step
    ] unit-test

    [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##compare-integer-imm-branch f 0 0 cc<= }
        }
    ] [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##compare-integer-imm-branch f 0 0 cc<= }
        } value-numbering-step
    ] unit-test
] when

! Reassociation
{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##add-imm f 2 0 100 }
        T{ ##load-integer f 3 50 }
        T{ ##add-imm f 4 0 150 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##add f 2 0 1 }
        T{ ##load-integer f 3 50 }
        T{ ##add f 4 2 3 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##add-imm f 2 0 100 }
        T{ ##load-integer f 3 50 }
        T{ ##add-imm f 4 0 150 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##add f 2 1 0 }
        T{ ##load-integer f 3 50 }
        T{ ##add f 4 3 2 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##add-imm f 2 0 100 }
        T{ ##load-integer f 3 50 }
        T{ ##add-imm f 4 0 50 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##add f 2 0 1 }
        T{ ##load-integer f 3 50 }
        T{ ##sub f 4 2 3 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##add-imm f 2 0 -100 }
        T{ ##load-integer f 3 50 }
        T{ ##add-imm f 4 0 -150 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##sub f 2 0 1 }
        T{ ##load-integer f 3 50 }
        T{ ##sub f 4 2 3 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##mul-imm f 2 0 100 }
        T{ ##load-integer f 3 50 }
        T{ ##mul-imm f 4 0 5000 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##mul f 2 0 1 }
        T{ ##load-integer f 3 50 }
        T{ ##mul f 4 2 3 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##mul-imm f 2 0 100 }
        T{ ##load-integer f 3 50 }
        T{ ##mul-imm f 4 0 5000 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##mul f 2 1 0 }
        T{ ##load-integer f 3 50 }
        T{ ##mul f 4 3 2 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##and-imm f 2 0 100 }
        T{ ##load-integer f 3 50 }
        T{ ##and-imm f 4 0 32 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##and f 2 0 1 }
        T{ ##load-integer f 3 50 }
        T{ ##and f 4 2 3 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##and-imm f 2 0 100 }
        T{ ##load-integer f 3 50 }
        T{ ##and-imm f 4 0 32 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##and f 2 1 0 }
        T{ ##load-integer f 3 50 }
        T{ ##and f 4 3 2 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##or-imm f 2 0 100 }
        T{ ##load-integer f 3 50 }
        T{ ##or-imm f 4 0 118 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##or f 2 0 1 }
        T{ ##load-integer f 3 50 }
        T{ ##or f 4 2 3 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##or-imm f 2 0 100 }
        T{ ##load-integer f 3 50 }
        T{ ##or-imm f 4 0 118 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##or f 2 1 0 }
        T{ ##load-integer f 3 50 }
        T{ ##or f 4 3 2 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##xor-imm f 2 0 100 }
        T{ ##load-integer f 3 50 }
        T{ ##xor-imm f 4 0 86 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##xor f 2 0 1 }
        T{ ##load-integer f 3 50 }
        T{ ##xor f 4 2 3 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##xor-imm f 2 0 100 }
        T{ ##load-integer f 3 50 }
        T{ ##xor-imm f 4 0 86 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 100 }
        T{ ##xor f 2 1 0 }
        T{ ##load-integer f 3 50 }
        T{ ##xor f 4 3 2 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##shl-imm f 1 0 10 }
        T{ ##shl-imm f 2 0 21 }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##shl-imm f 1 0 10 }
        T{ ##shl-imm f 2 1 11 }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##shl-imm f 1 0 10 }
        T{ ##shl-imm f 2 1 $[ cell-bits 1 - ] }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##shl-imm f 1 0 10 }
        T{ ##shl-imm f 2 1 $[ cell-bits 1 - ] }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##sar-imm f 1 0 10 }
        T{ ##sar-imm f 2 0 21 }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##sar-imm f 1 0 10 }
        T{ ##sar-imm f 2 1 11 }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##sar-imm f 1 0 10 }
        T{ ##sar-imm f 2 1 $[ cell-bits 1 - ] }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##sar-imm f 1 0 10 }
        T{ ##sar-imm f 2 1 $[ cell-bits 1 - ] }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##shr-imm f 1 0 10 }
        T{ ##shr-imm f 2 0 21 }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##shr-imm f 1 0 10 }
        T{ ##shr-imm f 2 1 11 }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##shr-imm f 1 0 10 }
        T{ ##shr-imm f 2 1 $[ cell-bits 1 - ] }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##shr-imm f 1 0 10 }
        T{ ##shr-imm f 2 1 $[ cell-bits 1 - ] }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##shr-imm f 1 0 10 }
        T{ ##sar-imm f 2 1 11 }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##shr-imm f 1 0 10 }
        T{ ##sar-imm f 2 1 11 }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

! Distributive law
2 vreg-counter set-global

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##add-imm f 1 0 10 }
        T{ ##shl-imm f 3 0 2 }
        T{ ##add-imm f 2 3 40 }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##add-imm f 1 0 10 }
        T{ ##shl-imm f 2 1 2 }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##add-imm f 1 0 10 }
        T{ ##mul-imm f 4 0 3 }
        T{ ##add-imm f 2 4 30 }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##add-imm f 1 0 10 }
        T{ ##mul-imm f 2 1 3 }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##add-imm f 1 0 -10 }
        T{ ##shl-imm f 5 0 2 }
        T{ ##add-imm f 2 5 -40 }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##sub-imm f 1 0 10 }
        T{ ##shl-imm f 2 1 2 }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##add-imm f 1 0 -10 }
        T{ ##mul-imm f 6 0 3 }
        T{ ##add-imm f 2 6 -30 }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##sub-imm f 1 0 10 }
        T{ ##mul-imm f 2 1 3 }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

! Simplification
{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##copy f 3 0 any-rep }
        T{ ##replace f 3 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##add-imm f 3 0 0 }
        T{ ##replace f 3 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##copy f 3 0 any-rep }
        T{ ##replace f 3 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##or-imm f 3 0 0 }
        T{ ##replace f 3 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##copy f 3 0 any-rep }
        T{ ##replace f 3 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##xor-imm f 3 0 0 }
        T{ ##replace f 3 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##and-imm f 1 0 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##copy f 1 0 any-rep }
        T{ ##replace f 1 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##and-imm f 1 0 -1 }
        T{ ##replace f 1 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##copy f 1 0 any-rep }
        T{ ##replace f 1 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##and f 1 0 0 }
        T{ ##replace f 1 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##copy f 1 0 any-rep }
        T{ ##replace f 1 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##or-imm f 1 0 0 }
        T{ ##replace f 1 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 -1 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##or-imm f 1 0 -1 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##copy f 1 0 any-rep }
        T{ ##replace f 1 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##or f 1 0 0 }
        T{ ##replace f 1 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##copy f 1 0 any-rep }
        T{ ##replace f 1 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##xor-imm f 1 0 0 }
        T{ ##replace f 1 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##not f 1 0 }
        T{ ##replace f 1 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##xor-imm f 1 0 -1 }
        T{ ##replace f 1 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##xor f 1 0 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##copy f 2 0 any-rep }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##mul-imm f 2 0 1 }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##copy f 2 0 any-rep }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##shl-imm f 2 0 0 }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##copy f 2 0 any-rep }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##shr-imm f 2 0 0 }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##copy f 2 0 any-rep }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##sar-imm f 2 0 0 }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

! Constant folding
{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 3 }
        T{ ##load-integer f 3 4 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 3 }
        T{ ##add f 3 1 2 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 3 }
        T{ ##load-integer f 3 -2 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 3 }
        T{ ##sub f 3 1 2 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 2 }
        T{ ##load-integer f 2 3 }
        T{ ##load-integer f 3 6 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 2 }
        T{ ##load-integer f 2 3 }
        T{ ##mul f 3 1 2 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 2 }
        T{ ##load-integer f 2 1 }
        T{ ##load-integer f 3 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 2 }
        T{ ##load-integer f 2 1 }
        T{ ##and f 3 1 2 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 2 }
        T{ ##load-integer f 2 1 }
        T{ ##load-integer f 3 3 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 2 }
        T{ ##load-integer f 2 1 }
        T{ ##or f 3 1 2 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 2 }
        T{ ##load-integer f 2 3 }
        T{ ##load-integer f 3 1 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 2 }
        T{ ##load-integer f 2 3 }
        T{ ##xor f 3 1 2 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 3 8 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 1 }
        T{ ##shl-imm f 3 1 3 }
    } value-numbering-step
] unit-test

cell 8 = [
    [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-integer f 1 -1 }
            T{ ##load-integer f 3 0xffffffffffff }
        }
    ] [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-integer f 1 -1 }
            T{ ##shr-imm f 3 1 16 }
        } value-numbering-step
    ] unit-test
] when

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 -8 }
        T{ ##load-integer f 3 -4 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 -8 }
        T{ ##sar-imm f 3 1 1 }
    } value-numbering-step
] unit-test

cell 8 = [
    [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-integer f 1 65536 }
            T{ ##load-integer f 2 140737488355328 }
            T{ ##add f 3 0 2 }
        }
    ] [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-integer f 1 65536 }
            T{ ##shl-imm f 2 1 31 }
            T{ ##add f 3 0 2 }
        } value-numbering-step
    ] unit-test

    [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-integer f 2 140737488355328 }
            T{ ##add f 3 0 2 }
        }
    ] [
        {
            T{ ##peek f 0 D: 0 }
            T{ ##load-integer f 2 140737488355328 }
            T{ ##add f 3 0 2 }
        } value-numbering-step
    ] unit-test

    ! PPC ADDI can't hold immediates this big.
    cpu ppc? [
        [
            {
                T{ ##peek f 0 D: 0 }
                T{ ##load-integer f 2 2147483647 }
                T{ ##add-imm f 3 0 2147483647 }
                T{ ##add-imm f 4 3 2147483647 }
            }
        ] [
            {
                T{ ##peek f 0 D: 0 }
                T{ ##load-integer f 2 2147483647 }
                T{ ##add f 3 0 2 }
                T{ ##add f 4 3 2 }
            } value-numbering-step
        ] unit-test
    ] unless
] when

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 -1 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 1 }
        T{ ##neg f 2 1 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 -2 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 1 1 }
        T{ ##not f 2 1 }
    } value-numbering-step
] unit-test

! ##tagged>integer constant folding
{
    {
        T{ ##load-reference f 1 f }
        T{ ##load-integer f 2 $[ \ f type-number ] }
        T{ ##copy f 3 2 any-rep }
    }
} [
    {
        T{ ##load-reference f 1 f }
        T{ ##tagged>integer f 2 1 }
        T{ ##and-imm f 3 2 15 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 1 100 }
        T{ ##load-integer f 2 $[ 100 tag-fixnum ] }
        T{ ##load-integer f 3 $[ 100 tag-fixnum 1 + ] }
    }
} [
    {
        T{ ##load-integer f 1 100 }
        T{ ##tagged>integer f 2 1 }
        T{ ##add-imm f 3 2 1 }
    } value-numbering-step
] unit-test

! Alien boxing and unboxing
{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##box-alien f 1 0 }
        T{ ##copy f 2 0 any-rep }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##box-alien f 1 0 }
        T{ ##unbox-alien f 2 1 }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##box-alien f 1 0 }
        T{ ##copy f 2 0 any-rep }
        T{ ##replace f 2 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##box-alien f 1 0 }
        T{ ##unbox-any-c-ptr f 2 1 }
        T{ ##replace f 2 D: 0 }
    } value-numbering-step
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 2 0 }
        T{ ##copy f 1 0 any-rep }
        T{ ##replace f 1 D: 0 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 2 0 }
        T{ ##box-displaced-alien f 1 2 0 c-ptr }
        T{ ##replace f 1 D: 0 }
    } value-numbering-step
] unit-test

3 vreg-counter set-global

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 2 16 }
        T{ ##box-displaced-alien f 1 2 0 c-ptr }
        T{ ##unbox-any-c-ptr f 4 0 }
        T{ ##add-imm f 3 4 16 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 2 16 }
        T{ ##box-displaced-alien f 1 2 0 c-ptr }
        T{ ##unbox-any-c-ptr f 3 1 }
    } value-numbering-step
] unit-test

4 vreg-counter set-global

{
    {
        T{ ##box-alien f 0 1 }
        T{ ##load-integer f 2 16 }
        T{ ##box-displaced-alien f 3 2 0 c-ptr }
        T{ ##copy f 5 1 any-rep }
        T{ ##add-imm f 4 5 16 }
    }
} [
    {
        T{ ##box-alien f 0 1 }
        T{ ##load-integer f 2 16 }
        T{ ##box-displaced-alien f 3 2 0 c-ptr }
        T{ ##unbox-any-c-ptr f 4 3 }
    } value-numbering-step
] unit-test

3 vreg-counter set-global

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 2 0 }
        T{ ##copy f 3 0 any-rep }
        T{ ##replace f 3 D: 1 }
    }
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-integer f 2 0 }
        T{ ##box-displaced-alien f 3 2 0 c-ptr }
        T{ ##replace f 3 D: 1 }
    } value-numbering-step
] unit-test

! Various SIMD simplifications
{
    {
        T{ ##vector>scalar f 1 0 float-4-rep }
        T{ ##copy f 2 0 any-rep }
    }
} [
    {
        T{ ##vector>scalar f 1 0 float-4-rep }
        T{ ##scalar>vector f 2 1 float-4-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##copy f 1 0 any-rep }
    }
} [
    {
        T{ ##shuffle-vector-imm f 1 0 { 0 1 2 3 } float-4-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##shuffle-vector-imm f 1 0 { 1 2 3 0 } float-4-rep }
        T{ ##shuffle-vector-imm f 2 0 { 0 2 3 1 } float-4-rep }
    }
} [
    {
        T{ ##shuffle-vector-imm f 1 0 { 1 2 3 0 } float-4-rep }
        T{ ##shuffle-vector-imm f 2 1 { 3 1 2 0 } float-4-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##shuffle-vector-imm f 1 0 { 1 2 3 0 } float-4-rep }
        T{ ##shuffle-vector-imm f 2 1 { 1 0 } double-2-rep }
    }
} [
    {
        T{ ##shuffle-vector-imm f 1 0 { 1 2 3 0 } float-4-rep }
        T{ ##shuffle-vector-imm f 2 1 { 1 0 } double-2-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 0 55 }
        T{ ##load-reference f 1 B{ 55 0 0 0  55 0 0 0  55 0 0 0  55 0 0 0 } }
        T{ ##load-reference f 2 B{ 55 0 0 0  55 0 0 0  55 0 0 0  55 0 0 0 } }
    }
} [
    {
        T{ ##load-integer f 0 55 }
        T{ ##scalar>vector f 1 0 int-4-rep }
        T{ ##shuffle-vector-imm f 2 1 { 0 0 0 0 } float-4-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-reference f 0 1.25 }
        T{ ##load-reference f 1 B{ 0 0 160 63 0 0 160 63 0 0 160 63 0 0 160 63 } }
        T{ ##load-reference f 2 B{ 0 0 160 63 0 0 160 63 0 0 160 63 0 0 160 63 } }
    }
} [
    {
        T{ ##load-reference f 0 1.25 }
        T{ ##scalar>vector f 1 0 float-4-rep }
        T{ ##shuffle-vector-imm f 2 1 { 0 0 0 0 } float-4-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-reference f 0 1.25 }
        T{ ##load-reference f 1 B{ 0 0 160 63 0 0 160 63 0 0 160 63 0 0 160 63 } }
        T{ ##load-reference f 2 B{ 0 0 160 63 0 0 160 63 0 0 160 63 0 0 160 63 } }
    }
} [
    {
        T{ ##load-reference f 0 1.25 }
        T{ ##scalar>vector f 1 0 float-4-rep }
        T{ ##shuffle-vector-imm f 2 1 { 0 0 0 0 } float-4-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 0 55 }
        T{ ##load-reference f 1 B{ 55 0 55 0 55 0 55 0 55 0 55 0 55 0 55 0 } }
        T{ ##load-reference f 2 B{ 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 } }
        T{ ##load-reference f 3 B{ 0 55 0 55 0 55 0 55 0 55 0 55 0 55 0 55 } }
    }
} [
    {
        T{ ##load-integer f 0 55 }
        T{ ##scalar>vector f 1 0 short-8-rep }
        T{ ##load-reference f 2 B{ 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 } }
        T{ ##shuffle-vector f 3 1 2 float-4-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-reference f 0 1.25 }
        T{ ##load-reference f 2 3.75 }
        T{ ##load-reference f 4 B{ 0 0 0 0 0 0 244 63 0 0 0 0 0 0 14 64 } }
    }
} [
    {
        T{ ##load-reference f 0 1.25 }
        T{ ##load-reference f 2 3.75 }
        T{ ##gather-vector-2 f 4 0 2 double-2-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 0 125 }
        T{ ##load-integer f 2 375 }
        T{ ##load-reference f 4 B{ 125 0 0 0 0 0 0 0 119 1 0 0 0 0 0 0 } }
    }
} [
    {
        T{ ##load-integer f 0 125 }
        T{ ##load-integer f 2 375 }
        T{ ##gather-vector-2 f 4 0 2 longlong-2-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-reference f 0 1.25 }
        T{ ##load-reference f 1 2.50 }
        T{ ##load-reference f 2 3.75 }
        T{ ##load-reference f 3 5.00 }
        T{ ##load-reference f 4 B{ 0 0 160 63 0 0 32 64 0 0 112 64 0 0 160 64 } }
    }
} [
    {
        T{ ##load-reference f 0 1.25 }
        T{ ##load-reference f 1 2.50 }
        T{ ##load-reference f 2 3.75 }
        T{ ##load-reference f 3 5.00 }
        T{ ##gather-vector-4 f 4 0 1 2 3 float-4-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##load-integer f 0 125 }
        T{ ##load-integer f 1 250 }
        T{ ##load-integer f 2 375 }
        T{ ##load-integer f 3 500 }
        T{ ##load-reference f 4 B{ 125 0 0 0 250 0 0 0 119 1 0 0 244 1 0 0 } }
    }
} [
    {
        T{ ##load-integer f 0 125 }
        T{ ##load-integer f 1 250 }
        T{ ##load-integer f 2 375 }
        T{ ##load-integer f 3 500 }
        T{ ##gather-vector-4 f 4 0 1 2 3 int-4-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##zero-vector f 2 float-4-rep }
    }
} [
    {
        T{ ##xor-vector f 2 1 1 float-4-rep }
    } value-numbering-step
] unit-test

! NOT x AND y => x ANDN y

{
    {
        T{ ##fill-vector f 3 float-4-rep }
        T{ ##xor-vector  f 4 0 3 float-4-rep }
        T{ ##andn-vector f 5 0 1 float-4-rep }
    }
} [
    {
        T{ ##fill-vector f 3 float-4-rep }
        T{ ##xor-vector  f 4 0 3 float-4-rep }
        T{ ##and-vector  f 5 4 1 float-4-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##not-vector  f 4 0 float-4-rep }
        T{ ##andn-vector f 5 0 1 float-4-rep }
    }
} [
    {
        T{ ##not-vector  f 4 0 float-4-rep }
        T{ ##and-vector  f 5 4 1 float-4-rep }
    } value-numbering-step
] unit-test

! x AND NOT y => y ANDN x

{
    {
        T{ ##fill-vector f 3 float-4-rep }
        T{ ##xor-vector  f 4 0 3 float-4-rep }
        T{ ##andn-vector f 5 0 1 float-4-rep }
    }
} [
    {
        T{ ##fill-vector f 3 float-4-rep }
        T{ ##xor-vector  f 4 0 3 float-4-rep }
        T{ ##and-vector  f 5 1 4 float-4-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##not-vector  f 4 0 float-4-rep }
        T{ ##andn-vector f 5 0 1 float-4-rep }
    }
} [
    {
        T{ ##not-vector  f 4 0 float-4-rep }
        T{ ##and-vector  f 5 1 4 float-4-rep }
    } value-numbering-step
] unit-test

! NOT x ANDN y => x AND y

{
    {
        T{ ##fill-vector f 3 float-4-rep }
        T{ ##xor-vector  f 4 0 3 float-4-rep }
        T{ ##and-vector  f 5 0 1 float-4-rep }
    }
} [
    {
        T{ ##fill-vector f 3 float-4-rep }
        T{ ##xor-vector  f 4 0 3 float-4-rep }
        T{ ##andn-vector f 5 4 1 float-4-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##not-vector  f 4 0 float-4-rep }
        T{ ##and-vector  f 5 0 1 float-4-rep }
    }
} [
    {
        T{ ##not-vector  f 4 0 float-4-rep }
        T{ ##andn-vector f 5 4 1 float-4-rep }
    } value-numbering-step
] unit-test

! AND <=> ANDN

{
    {
        T{ ##fill-vector f 3 float-4-rep }
        T{ ##xor-vector  f 4 0 3 float-4-rep }
        T{ ##andn-vector f 5 0 1 float-4-rep }
        T{ ##and-vector  f 6 0 2 float-4-rep }
        T{ ##or-vector   f 7 5 6 float-4-rep }
    }
} [
    {
        T{ ##fill-vector f 3 float-4-rep }
        T{ ##xor-vector  f 4 0 3 float-4-rep }
        T{ ##and-vector  f 5 4 1 float-4-rep }
        T{ ##andn-vector f 6 4 2 float-4-rep }
        T{ ##or-vector   f 7 5 6 float-4-rep }
    } value-numbering-step
] unit-test

{
    {
        T{ ##not-vector  f 4 0   float-4-rep }
        T{ ##andn-vector f 5 0 1 float-4-rep }
        T{ ##and-vector  f 6 0 2 float-4-rep }
        T{ ##or-vector   f 7 5 6 float-4-rep }
    }
} [
    {
        T{ ##not-vector  f 4 0   float-4-rep }
        T{ ##and-vector  f 5 4 1 float-4-rep }
        T{ ##andn-vector f 6 4 2 float-4-rep }
        T{ ##or-vector   f 7 5 6 float-4-rep }
    } value-numbering-step
] unit-test

! Branch folding
: test-branch-folding ( insns -- insns' n )
    <basic-block>
    [ V{ 0 1 } clone >>successors basic-block set value-numbering-step ] keep
    successors>> first ;

{
    {
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 2 }
        T{ ##branch }
    }
    1
} [
    {
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 2 }
        T{ ##compare-branch f 1 2 cc= }
    } test-branch-folding
] unit-test

{
    {
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 2 }
        T{ ##branch }
    }
    0
} [
    {
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 2 }
        T{ ##compare-branch f 1 2 cc/= }
    } test-branch-folding
] unit-test

{
    {
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 2 }
        T{ ##branch }
    }
    0
} [
    {
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 2 }
        T{ ##compare-integer-branch f 1 2 cc< }
    } test-branch-folding
] unit-test

{
    {
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 2 }
        T{ ##branch }
    }
    1
} [
    {
        T{ ##load-integer f 1 1 }
        T{ ##load-integer f 2 2 }
        T{ ##compare-integer-branch f 2 1 cc< }
    } test-branch-folding
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##branch }
    }
    1
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##compare-integer-branch f 0 0 cc< }
    } test-branch-folding
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##branch }
    }
    0
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##compare-integer-branch f 0 0 cc<= }
    } test-branch-folding
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##branch }
    }
    1
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##compare-integer-branch f 0 0 cc> }
    } test-branch-folding
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##branch }
    }
    0
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##compare-integer-branch f 0 0 cc>= }
    } test-branch-folding
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##branch }
    }
    0
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##compare-integer-branch f 0 0 cc= }
    } test-branch-folding
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##branch }
    }
    1
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##compare-integer-branch f 0 0 cc/= }
    } test-branch-folding
] unit-test

{
    {
        T{ ##peek f 0 D: 0 }
        T{ ##load-reference f 1 t }
        T{ ##branch }
    }
    0
} [
    {
        T{ ##peek f 0 D: 0 }
        T{ ##compare f 1 0 0 cc<= }
        T{ ##compare-imm-branch f 1 f cc/= }
    } test-branch-folding
] unit-test

! More branch folding tests
V{ T{ ##branch } } 0 test-bb

V{
    T{ ##peek f 0 D: 0 }
    T{ ##compare-integer-branch f 0 0 cc< }
} 1 test-bb

V{
    T{ ##load-integer f 1 1 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##load-integer f 2 2 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##phi f 3 H{ { 2 1 } { 3 2 } } }
    T{ ##replace f 3 D: 0 }
    T{ ##return }
} 4 test-bb

test-diamond

{ } [
    0 get block>cfg dup cfg set
    [ value-numbering ]
    [ select-representations ]
    [ destruct-ssa ] tri
] unit-test

{ 1 } [ 1 get successors>> length ] unit-test

{ t } [ 1 get successors>> first 3 get eq? ] unit-test

{ 2 } [ 4 get instructions>> length ] unit-test

V{
    T{ ##peek f 0 D: 0 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 1 D: 1 }
    T{ ##compare-integer-branch f 1 1 cc< }
} 1 test-bb

V{
    T{ ##copy f 2 0 any-rep }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##phi f 3 H{ { 1 1 } { 2 0 } } }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace f 3 D: 0 }
    T{ ##return }
} 4 test-bb

test-diamond

{ } [
    0 get block>cfg
    { value-numbering eliminate-dead-code } apply-passes
] unit-test

{ t } [ 1 get successors>> first 3 get eq? ] unit-test

{ 1 } [ 3 get instructions>> first inputs>> assoc-size ] unit-test

V{ T{ ##prologue } T{ ##branch } } 0 test-bb

V{
    T{ ##peek { dst 15 } { loc D: 0 } }
    T{ ##copy { dst 16 } { src 15 } { rep any-rep } }
    T{ ##copy { dst 17 } { src 15 } { rep any-rep } }
    T{ ##copy { dst 18 } { src 15 } { rep any-rep } }
    T{ ##copy { dst 19 } { src 15 } { rep any-rep } }
    T{ ##compare
        { dst 20 }
        { src1 18 }
        { src2 19 }
        { cc cc= }
        { temp 22 }
    }
    T{ ##copy { dst 21 } { src 20 } { rep any-rep } }
    T{ ##compare-imm-branch
        { src1 21 }
        { src2 f }
        { cc cc/= }
    }
} 1 test-bb

V{
    T{ ##copy { dst 23 } { src 15 } { rep any-rep } }
    T{ ##copy { dst 24 } { src 15 } { rep any-rep } }
    T{ ##load-reference { dst 25 } { obj t } }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace { src 25 } { loc D: 0 } }
    T{ ##epilogue }
    T{ ##return }
} 3 test-bb

V{
    T{ ##copy { dst 26 } { src 15 } { rep any-rep } }
    T{ ##copy { dst 27 } { src 15 } { rep any-rep } }
    T{ ##add
        { dst 28 }
        { src1 26 }
        { src2 27 }
    }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##replace { src 28 } { loc D: 0 } }
    T{ ##epilogue }
    T{ ##return }
} 5 test-bb

0 1 edge
1 { 2 4 } edges
2 3 edge
4 5 edge

{ } [
    0 get block>cfg
    { value-numbering eliminate-dead-code } apply-passes
] unit-test

{ f } [ 1 get instructions>> [ ##peek? ] any? ] unit-test

! Slot addressing optimization
cpu x86? [
    [
        V{
            T{ ##peek f 0 D: 0 }
            T{ ##peek f 1 D: 1 }
            T{ ##add-imm f 2 1 2 }
            T{ ##slot f 3 0 1 $[ cell log2 ] $[ 7 2 cells - ] }
        }
    ] [
        V{
            T{ ##peek f 0 D: 0 }
            T{ ##peek f 1 D: 1 }
            T{ ##add-imm f 2 1 2 }
            T{ ##slot f 3 0 2 $[ cell log2 ] 7 }
        } value-numbering-step
    ] unit-test
] when

! Alien addressing optimization

! Base offset fusion on ##load/store-memory-imm
{
    V{
        T{ ##peek f 1 D: 0 }
        T{ ##tagged>integer f 2 1 }
        T{ ##add-imm f 3 2 10 }
        T{ ##load-memory-imm f 4 2 10 int-rep c:uchar }
    }
} [
    V{
        T{ ##peek f 1 D: 0 }
        T{ ##tagged>integer f 2 1 }
        T{ ##add-imm f 3 2 10 }
        T{ ##load-memory-imm f 4 3 0 int-rep c:uchar }
    } value-numbering-step
] unit-test

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##add-imm f 4 3 10 }
        T{ ##store-memory-imm f 2 3 10 int-rep c:uchar }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##add-imm f 4 3 10 }
        T{ ##store-memory-imm f 2 4 0 int-rep c:uchar }
    } value-numbering-step
] unit-test

! Displacement fusion on ##load/store-memory-imm
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##add f 4 2 3 }
        T{ ##load-memory f 5 2 3 0 0 int-rep c:uchar }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##add f 4 2 3 }
        T{ ##load-memory-imm f 5 4 0 int-rep c:uchar }
    } value-numbering-step
] unit-test

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##add f 4 2 3 }
        T{ ##store-memory f 5 2 3 0 0 int-rep c:uchar }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##add f 4 2 3 }
        T{ ##store-memory-imm f 5 4 0 int-rep c:uchar }
    } value-numbering-step
] unit-test

! Base offset fusion on ##load/store-memory -- only on x86
cpu x86?
[
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##add-imm f 4 2 31337 }
        T{ ##load-memory f 5 2 3 0 31337 int-rep c:uchar }
    }
]
[
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##add-imm f 4 2 31337 }
        T{ ##load-memory f 5 4 3 0 0 int-rep c:uchar }
    }
] ?
[
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##add-imm f 4 2 31337 }
        T{ ##load-memory f 5 4 3 0 0 int-rep c:uchar }
    } value-numbering-step
] unit-test

! Displacement offset fusion on ##load/store-memory -- only on x86
cpu x86?
[
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##add-imm f 4 3 31337 }
        T{ ##load-memory f 5 2 3 0 31338 int-rep c:uchar }
    }
]
[
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##add-imm f 4 3 31337 }
        T{ ##load-memory f 5 2 4 0 1 int-rep c:uchar }
    }
] ?
[
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##add-imm f 4 3 31337 }
        T{ ##load-memory f 5 2 4 0 1 int-rep c:uchar }
    } value-numbering-step
] unit-test

! Displacement offset fusion should not occur on
! ##load/store-memory with non-zero scale
{ } [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##add-imm f 4 3 10 }
        T{ ##load-memory f 5 2 4 1 1 int-rep c:uchar }
    } dup value-numbering-step assert=
] unit-test

! Scale fusion on ##load/store-memory
${
    cpu x86?
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##shl-imm f 4 3 2 }
        T{ ##load-memory f 5 2 3 2 0 int-rep c:uchar }
    }
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##shl-imm f 4 3 2 }
        T{ ##load-memory f 5 2 4 0 0 int-rep c:uchar }
    } ?
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##tagged>integer f 2 0 }
        T{ ##tagged>integer f 3 1 }
        T{ ##shl-imm f 4 3 2 }
        T{ ##load-memory f 5 2 4 0 0 int-rep c:uchar }
    } value-numbering-step
] unit-test

cpu x86? [
    ! Don't do scale fusion if there's already a scale
    [ ] [
        V{
            T{ ##peek f 0 D: 0 }
            T{ ##peek f 1 D: 1 }
            T{ ##tagged>integer f 2 0 }
            T{ ##tagged>integer f 3 1 }
            T{ ##shl-imm f 4 3 2 }
            T{ ##load-memory f 5 2 4 1 0 int-rep c:uchar }
        } dup value-numbering-step assert=
    ] unit-test

    ! Don't do scale fusion if the scale factor is out of range
    [ ] [
        V{
            T{ ##peek f 0 D: 0 }
            T{ ##peek f 1 D: 1 }
            T{ ##tagged>integer f 2 0 }
            T{ ##tagged>integer f 3 1 }
            T{ ##shl-imm f 4 3 4 }
            T{ ##load-memory f 5 2 4 0 0 int-rep c:uchar }
        } dup value-numbering-step assert=
    ] unit-test
] when
