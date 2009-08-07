IN: compiler.cfg.value-numbering.tests
USING: compiler.cfg.value-numbering compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.debugger compiler.cfg.comparisons
cpu.architecture tools.test kernel math combinators.short-circuit
accessors sequences compiler.cfg.predecessors locals
compiler.cfg.dce compiler.cfg.ssa.destruction
compiler.cfg assocs vectors arrays layouts namespaces ;

: trim-temps ( insns -- insns )
    [
        dup {
            [ ##compare? ]
            [ ##compare-imm? ]
            [ ##compare-float? ]
        } 1|| [ f >>temp ] when
    ] map ;

! Folding constants together
[
    {
        T{ ##load-reference f V int-rep 0 0.0 }
        T{ ##load-reference f V int-rep 1 -0.0 }
        T{ ##replace f V int-rep 0 D 0 }
        T{ ##replace f V int-rep 1 D 1 }
    }
] [
    {
        T{ ##load-reference f V int-rep 0 0.0 }
        T{ ##load-reference f V int-rep 1 -0.0 }
        T{ ##replace f V int-rep 0 D 0 }
        T{ ##replace f V int-rep 1 D 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##load-reference f V int-rep 0 0.0 }
        T{ ##copy f V int-rep 1 V int-rep 0 int-rep }
        T{ ##replace f V int-rep 0 D 0 }
        T{ ##replace f V int-rep 1 D 1 }
    }
] [
    {
        T{ ##load-reference f V int-rep 0 0.0 }
        T{ ##load-reference f V int-rep 1 0.0 }
        T{ ##replace f V int-rep 0 D 0 }
        T{ ##replace f V int-rep 1 D 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##load-reference f V int-rep 0 t }
        T{ ##copy f V int-rep 1 V int-rep 0 int-rep }
        T{ ##replace f V int-rep 0 D 0 }
        T{ ##replace f V int-rep 1 D 1 }
    }
] [
    {
        T{ ##load-reference f V int-rep 0 t }
        T{ ##load-reference f V int-rep 1 t }
        T{ ##replace f V int-rep 0 D 0 }
        T{ ##replace f V int-rep 1 D 1 }
    } value-numbering-step
] unit-test

! Compare propagation
[
    {
        T{ ##load-reference f V int-rep 1 + }
        T{ ##peek f V int-rep 2 D 0 }
        T{ ##compare f V int-rep 4 V int-rep 2 V int-rep 1 cc> }
        T{ ##copy f V int-rep 6 V int-rep 4 int-rep }
        T{ ##replace f V int-rep 6 D 0 }
    }
] [
    {
        T{ ##load-reference f V int-rep 1 + }
        T{ ##peek f V int-rep 2 D 0 }
        T{ ##compare f V int-rep 4 V int-rep 2 V int-rep 1 cc> }
        T{ ##compare-imm f V int-rep 6 V int-rep 4 5 cc/= }
        T{ ##replace f V int-rep 6 D 0 }
    } value-numbering-step trim-temps
] unit-test

[
    {
        T{ ##load-reference f V int-rep 1 + }
        T{ ##peek f V int-rep 2 D 0 }
        T{ ##compare f V int-rep 4 V int-rep 2 V int-rep 1 cc<= }
        T{ ##compare f V int-rep 6 V int-rep 2 V int-rep 1 cc> }
        T{ ##replace f V int-rep 6 D 0 }
    }
] [
    {
        T{ ##load-reference f V int-rep 1 + }
        T{ ##peek f V int-rep 2 D 0 }
        T{ ##compare f V int-rep 4 V int-rep 2 V int-rep 1 cc<= }
        T{ ##compare-imm f V int-rep 6 V int-rep 4 5 cc= }
        T{ ##replace f V int-rep 6 D 0 }
    } value-numbering-step trim-temps
] unit-test

[
    {
        T{ ##peek f V int-rep 8 D 0 }
        T{ ##peek f V int-rep 9 D -1 }
        T{ ##unbox-float f V double-float-rep 10 V int-rep 8 }
        T{ ##unbox-float f V double-float-rep 11 V int-rep 9 }
        T{ ##compare-float f V int-rep 12 V double-float-rep 10 V double-float-rep 11 cc< }
        T{ ##compare-float f V int-rep 14 V double-float-rep 10 V double-float-rep 11 cc>= }
        T{ ##replace f V int-rep 14 D 0 }
    }
] [
    {
        T{ ##peek f V int-rep 8 D 0 }
        T{ ##peek f V int-rep 9 D -1 }
        T{ ##unbox-float f V double-float-rep 10 V int-rep 8 }
        T{ ##unbox-float f V double-float-rep 11 V int-rep 9 }
        T{ ##compare-float f V int-rep 12 V double-float-rep 10 V double-float-rep 11 cc< }
        T{ ##compare-imm f V int-rep 14 V int-rep 12 5 cc= }
        T{ ##replace f V int-rep 14 D 0 }
    } value-numbering-step trim-temps
] unit-test

[
    {
        T{ ##peek f V int-rep 29 D -1 }
        T{ ##peek f V int-rep 30 D -2 }
        T{ ##compare f V int-rep 33 V int-rep 29 V int-rep 30 cc<= }
        T{ ##compare-branch f V int-rep 29 V int-rep 30 cc<= }
    }
] [
    {
        T{ ##peek f V int-rep 29 D -1 }
        T{ ##peek f V int-rep 30 D -2 }
        T{ ##compare f V int-rep 33 V int-rep 29 V int-rep 30 cc<= }
        T{ ##compare-imm-branch f V int-rep 33 5 cc/= }
    } value-numbering-step trim-temps
] unit-test

! Immediate operand conversion
[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##add-imm f V int-rep 2 V int-rep 0 100 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##add f V int-rep 2 V int-rep 0 V int-rep 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##add-imm f V int-rep 2 V int-rep 0 100 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##add f V int-rep 2 V int-rep 1 V int-rep 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##add-imm f V int-rep 2 V int-rep 0 -100 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##sub f V int-rep 2 V int-rep 0 V int-rep 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 0 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##sub f V int-rep 1 V int-rep 0 V int-rep 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##mul-imm f V int-rep 2 V int-rep 0 100 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##mul f V int-rep 2 V int-rep 0 V int-rep 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##mul-imm f V int-rep 2 V int-rep 0 100 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##mul f V int-rep 2 V int-rep 1 V int-rep 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 1 D 0 }
        T{ ##shl-imm f V int-rep 2 V int-rep 1 3 }
    }
] [
    {
        T{ ##peek f V int-rep 1 D 0 }
        T{ ##mul-imm f V int-rep 2 V int-rep 1 8 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##and-imm f V int-rep 2 V int-rep 0 100 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##and f V int-rep 2 V int-rep 0 V int-rep 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##and-imm f V int-rep 2 V int-rep 0 100 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##and f V int-rep 2 V int-rep 1 V int-rep 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##or-imm f V int-rep 2 V int-rep 0 100 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##or f V int-rep 2 V int-rep 0 V int-rep 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##or-imm f V int-rep 2 V int-rep 0 100 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##or f V int-rep 2 V int-rep 1 V int-rep 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##xor-imm f V int-rep 2 V int-rep 0 100 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##xor f V int-rep 2 V int-rep 0 V int-rep 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##xor-imm f V int-rep 2 V int-rep 0 100 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##xor f V int-rep 2 V int-rep 1 V int-rep 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##compare-imm f V int-rep 2 V int-rep 0 100 cc<= }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##compare f V int-rep 2 V int-rep 0 V int-rep 1 cc<= }
    } value-numbering-step trim-temps
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##compare-imm f V int-rep 2 V int-rep 0 100 cc>= }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##compare f V int-rep 2 V int-rep 1 V int-rep 0 cc<= }
    } value-numbering-step trim-temps
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##compare-imm-branch f V int-rep 0 100 cc<= }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##compare-branch f V int-rep 0 V int-rep 1 cc<= }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##compare-imm-branch f V int-rep 0 100 cc>= }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##compare-branch f V int-rep 1 V int-rep 0 cc<= }
    } value-numbering-step trim-temps
] unit-test

! Reassociation
[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##add-imm f V int-rep 2 V int-rep 0 100 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##add-imm f V int-rep 4 V int-rep 0 150 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##add f V int-rep 2 V int-rep 0 V int-rep 1 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##add f V int-rep 4 V int-rep 2 V int-rep 3 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##add-imm f V int-rep 2 V int-rep 0 100 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##add-imm f V int-rep 4 V int-rep 0 150 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##add f V int-rep 2 V int-rep 1 V int-rep 0 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##add f V int-rep 4 V int-rep 3 V int-rep 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##add-imm f V int-rep 2 V int-rep 0 100 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##add-imm f V int-rep 4 V int-rep 0 50 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##add f V int-rep 2 V int-rep 0 V int-rep 1 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##sub f V int-rep 4 V int-rep 2 V int-rep 3 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##add-imm f V int-rep 2 V int-rep 0 -100 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##add-imm f V int-rep 4 V int-rep 0 -150 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##sub f V int-rep 2 V int-rep 0 V int-rep 1 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##sub f V int-rep 4 V int-rep 2 V int-rep 3 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##mul-imm f V int-rep 2 V int-rep 0 100 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##mul-imm f V int-rep 4 V int-rep 0 5000 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##mul f V int-rep 2 V int-rep 0 V int-rep 1 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##mul f V int-rep 4 V int-rep 2 V int-rep 3 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##mul-imm f V int-rep 2 V int-rep 0 100 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##mul-imm f V int-rep 4 V int-rep 0 5000 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##mul f V int-rep 2 V int-rep 1 V int-rep 0 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##mul f V int-rep 4 V int-rep 3 V int-rep 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##and-imm f V int-rep 2 V int-rep 0 100 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##and-imm f V int-rep 4 V int-rep 0 32 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##and f V int-rep 2 V int-rep 0 V int-rep 1 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##and f V int-rep 4 V int-rep 2 V int-rep 3 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##and-imm f V int-rep 2 V int-rep 0 100 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##and-imm f V int-rep 4 V int-rep 0 32 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##and f V int-rep 2 V int-rep 1 V int-rep 0 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##and f V int-rep 4 V int-rep 3 V int-rep 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##or-imm f V int-rep 2 V int-rep 0 100 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##or-imm f V int-rep 4 V int-rep 0 118 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##or f V int-rep 2 V int-rep 0 V int-rep 1 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##or f V int-rep 4 V int-rep 2 V int-rep 3 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##or-imm f V int-rep 2 V int-rep 0 100 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##or-imm f V int-rep 4 V int-rep 0 118 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##or f V int-rep 2 V int-rep 1 V int-rep 0 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##or f V int-rep 4 V int-rep 3 V int-rep 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##xor-imm f V int-rep 2 V int-rep 0 100 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##xor-imm f V int-rep 4 V int-rep 0 86 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##xor f V int-rep 2 V int-rep 0 V int-rep 1 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##xor f V int-rep 4 V int-rep 2 V int-rep 3 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##xor-imm f V int-rep 2 V int-rep 0 100 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##xor-imm f V int-rep 4 V int-rep 0 86 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 100 }
        T{ ##xor f V int-rep 2 V int-rep 1 V int-rep 0 }
        T{ ##load-immediate f V int-rep 3 50 }
        T{ ##xor f V int-rep 4 V int-rep 3 V int-rep 2 }
    } value-numbering-step
] unit-test

! Simplification
[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##peek f V int-rep 1 D 1 }
        T{ ##load-immediate f V int-rep 2 0 }
        T{ ##copy f V int-rep 3 V int-rep 0 int-rep }
        T{ ##replace f V int-rep 3 D 0 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##peek f V int-rep 1 D 1 }
        T{ ##sub f V int-rep 2 V int-rep 1 V int-rep 1 }
        T{ ##add f V int-rep 3 V int-rep 0 V int-rep 2 }
        T{ ##replace f V int-rep 3 D 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##peek f V int-rep 1 D 1 }
        T{ ##load-immediate f V int-rep 2 0 }
        T{ ##copy f V int-rep 3 V int-rep 0 int-rep }
        T{ ##replace f V int-rep 3 D 0 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##peek f V int-rep 1 D 1 }
        T{ ##sub f V int-rep 2 V int-rep 1 V int-rep 1 }
        T{ ##sub f V int-rep 3 V int-rep 0 V int-rep 2 }
        T{ ##replace f V int-rep 3 D 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##peek f V int-rep 1 D 1 }
        T{ ##load-immediate f V int-rep 2 0 }
        T{ ##copy f V int-rep 3 V int-rep 0 int-rep }
        T{ ##replace f V int-rep 3 D 0 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##peek f V int-rep 1 D 1 }
        T{ ##sub f V int-rep 2 V int-rep 1 V int-rep 1 }
        T{ ##or f V int-rep 3 V int-rep 0 V int-rep 2 }
        T{ ##replace f V int-rep 3 D 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##peek f V int-rep 1 D 1 }
        T{ ##load-immediate f V int-rep 2 0 }
        T{ ##copy f V int-rep 3 V int-rep 0 int-rep }
        T{ ##replace f V int-rep 3 D 0 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##peek f V int-rep 1 D 1 }
        T{ ##sub f V int-rep 2 V int-rep 1 V int-rep 1 }
        T{ ##xor f V int-rep 3 V int-rep 0 V int-rep 2 }
        T{ ##replace f V int-rep 3 D 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##copy f V int-rep 2 V int-rep 0 int-rep }
        T{ ##replace f V int-rep 2 D 0 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##mul f V int-rep 2 V int-rep 0 V int-rep 1 }
        T{ ##replace f V int-rep 2 D 0 }
    } value-numbering-step
] unit-test

! Constant folding
[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 3 }
        T{ ##load-immediate f V int-rep 3 4 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 3 }
        T{ ##add f V int-rep 3 V int-rep 1 V int-rep 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 3 }
        T{ ##load-immediate f V int-rep 3 -2 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 3 }
        T{ ##sub f V int-rep 3 V int-rep 1 V int-rep 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 2 }
        T{ ##load-immediate f V int-rep 2 3 }
        T{ ##load-immediate f V int-rep 3 6 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 2 }
        T{ ##load-immediate f V int-rep 2 3 }
        T{ ##mul f V int-rep 3 V int-rep 1 V int-rep 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 2 }
        T{ ##load-immediate f V int-rep 2 1 }
        T{ ##load-immediate f V int-rep 3 0 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 2 }
        T{ ##load-immediate f V int-rep 2 1 }
        T{ ##and f V int-rep 3 V int-rep 1 V int-rep 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 2 }
        T{ ##load-immediate f V int-rep 2 1 }
        T{ ##load-immediate f V int-rep 3 3 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 2 }
        T{ ##load-immediate f V int-rep 2 1 }
        T{ ##or f V int-rep 3 V int-rep 1 V int-rep 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 2 }
        T{ ##load-immediate f V int-rep 2 3 }
        T{ ##load-immediate f V int-rep 3 1 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 2 }
        T{ ##load-immediate f V int-rep 2 3 }
        T{ ##xor f V int-rep 3 V int-rep 1 V int-rep 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 3 8 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##shl-imm f V int-rep 3 V int-rep 1 3 }
    } value-numbering-step
] unit-test

cell 8 = [
    [
        {
            T{ ##peek f V int-rep 0 D 0 }
            T{ ##load-immediate f V int-rep 1 -1 }
            T{ ##load-immediate f V int-rep 3 HEX: ffffffffffff }
        }
    ] [
        {
            T{ ##peek f V int-rep 0 D 0 }
            T{ ##load-immediate f V int-rep 1 -1 }
            T{ ##shr-imm f V int-rep 3 V int-rep 1 16 }
        } value-numbering-step
    ] unit-test
] when

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 -8 }
        T{ ##load-immediate f V int-rep 3 -4 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 -8 }
        T{ ##sar-imm f V int-rep 3 V int-rep 1 1 }
    } value-numbering-step
] unit-test

cell 8 = [
    [
        {
            T{ ##peek f V int-rep 0 D 0 }
            T{ ##load-immediate f V int-rep 1 65536 }
            T{ ##load-immediate f V int-rep 2 140737488355328 }
            T{ ##add f V int-rep 3 V int-rep 0 V int-rep 2 }
        }
    ] [
        {
            T{ ##peek f V int-rep 0 D 0 }
            T{ ##load-immediate f V int-rep 1 65536 }
            T{ ##shl-imm f V int-rep 2 V int-rep 1 31 }
            T{ ##add f V int-rep 3 V int-rep 0 V int-rep 2 }
        } value-numbering-step
    ] unit-test

    [
        {
            T{ ##peek f V int-rep 0 D 0 }
            T{ ##load-immediate f V int-rep 2 140737488355328 }
            T{ ##add f V int-rep 3 V int-rep 0 V int-rep 2 }
        }
    ] [
        {
            T{ ##peek f V int-rep 0 D 0 }
            T{ ##load-immediate f V int-rep 2 140737488355328 }
            T{ ##add f V int-rep 3 V int-rep 0 V int-rep 2 }
        } value-numbering-step
    ] unit-test

    [
        {
            T{ ##peek f V int-rep 0 D 0 }
            T{ ##load-immediate f V int-rep 2 2147483647 }
            T{ ##add-imm f V int-rep 3 V int-rep 0 2147483647 }
            T{ ##add-imm f V int-rep 4 V int-rep 3 2147483647 }
        }
    ] [
        {
            T{ ##peek f V int-rep 0 D 0 }
            T{ ##load-immediate f V int-rep 2 2147483647 }
            T{ ##add f V int-rep 3 V int-rep 0 V int-rep 2 }
            T{ ##add f V int-rep 4 V int-rep 3 V int-rep 2 }
        } value-numbering-step
    ] unit-test
] when

! Branch folding
[
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##load-immediate f V int-rep 3 5 }
    }
] [
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##compare f V int-rep 3 V int-rep 1 V int-rep 2 cc= }
    } value-numbering-step
] unit-test

[
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##load-reference f V int-rep 3 t }
    }
] [
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##compare f V int-rep 3 V int-rep 1 V int-rep 2 cc/= }
    } value-numbering-step
] unit-test

[
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##load-reference f V int-rep 3 t }
    }
] [
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##compare f V int-rep 3 V int-rep 1 V int-rep 2 cc< }
    } value-numbering-step
] unit-test

[
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##load-immediate f V int-rep 3 5 }
    }
] [
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##compare f V int-rep 3 V int-rep 2 V int-rep 1 cc< }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 5 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##compare f V int-rep 1 V int-rep 0 V int-rep 0 cc< }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-reference f V int-rep 1 t }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##compare f V int-rep 1 V int-rep 0 V int-rep 0 cc<= }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 5 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##compare f V int-rep 1 V int-rep 0 V int-rep 0 cc> }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-reference f V int-rep 1 t }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##compare f V int-rep 1 V int-rep 0 V int-rep 0 cc>= }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-immediate f V int-rep 1 5 }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##compare f V int-rep 1 V int-rep 0 V int-rep 0 cc/= }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-reference f V int-rep 1 t }
    }
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##compare f V int-rep 1 V int-rep 0 V int-rep 0 cc= }
    } value-numbering-step
] unit-test

: test-branch-folding ( insns -- insns' n )
    <basic-block>
    [ V{ 0 1 } clone >>successors basic-block set value-numbering-step ] keep
    successors>> first ;

[
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##branch }
    }
    1
] [
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##compare-branch f V int-rep 1 V int-rep 2 cc= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##compare-branch f V int-rep 1 V int-rep 2 cc/= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##compare-branch f V int-rep 1 V int-rep 2 cc< }
    } test-branch-folding
] unit-test

[
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##branch }
    }
    1
] [
    {
        T{ ##load-immediate f V int-rep 1 1 }
        T{ ##load-immediate f V int-rep 2 2 }
        T{ ##compare-branch f V int-rep 2 V int-rep 1 cc< }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##branch }
    }
    1
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##compare-branch f V int-rep 0 V int-rep 0 cc< }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##compare-branch f V int-rep 0 V int-rep 0 cc<= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##branch }
    }
    1
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##compare-branch f V int-rep 0 V int-rep 0 cc> }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##compare-branch f V int-rep 0 V int-rep 0 cc>= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##compare-branch f V int-rep 0 V int-rep 0 cc= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##branch }
    }
    1
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##compare-branch f V int-rep 0 V int-rep 0 cc/= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##load-reference f V int-rep 1 t }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##peek f V int-rep 0 D 0 }
        T{ ##compare f V int-rep 1 V int-rep 0 V int-rep 0 cc<= }
        T{ ##compare-imm-branch f V int-rep 1 5 cc/= }
    } test-branch-folding
] unit-test

! More branch folding tests
V{ T{ ##branch } } 0 test-bb

V{
    T{ ##peek f V int-rep 0 D 0 }
    T{ ##compare-branch f V int-rep 0 V int-rep 0 cc< }
} 1 test-bb

V{
    T{ ##load-immediate f V int-rep 1 1 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##load-immediate f V int-rep 2 2 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##phi f V int-rep 3 H{ { 2 V int-rep 1 } { 3 V int-rep 2 } } }
    T{ ##replace f V int-rep 3 D 0 }
    T{ ##return }
} 4 test-bb

test-diamond

[ ] [
    cfg new 0 get >>entry
    value-numbering
    compute-predecessors
    destruct-ssa drop
] unit-test

[ 1 ] [ 1 get successors>> length ] unit-test

[ t ] [ 1 get successors>> first 3 get eq? ] unit-test

[ 2 ] [ 4 get instructions>> length ] unit-test

V{
    T{ ##peek f V int-rep 0 D 0 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f V int-rep 1 D 1 }
    T{ ##compare-branch f V int-rep 1 V int-rep 1 cc< }
} 1 test-bb

V{
    T{ ##copy f V int-rep 2 V int-rep 0 int-rep }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##phi f V int-rep 3 V{ } }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace f V int-rep 3 D 0 }
    T{ ##return }
} 4 test-bb

1 get V int-rep 1 2array
2 get V int-rep 0 2array 2array 3 get instructions>> first (>>inputs)

test-diamond

[ ] [
    cfg new 0 get >>entry
    compute-predecessors
    value-numbering
    compute-predecessors
    eliminate-dead-code
    drop
] unit-test

[ t ] [ 1 get successors>> first 3 get eq? ] unit-test

[ 1 ] [ 3 get instructions>> first inputs>> assoc-size ] unit-test

V{ T{ ##prologue } T{ ##branch } } 0 test-bb

V{
    T{ ##peek { dst V int-rep 15 } { loc D 0 } }
    T{ ##copy { dst V int-rep 16 } { src V int-rep 15 } { rep int-rep } }
    T{ ##copy { dst V int-rep 17 } { src V int-rep 15 } { rep int-rep } }
    T{ ##copy { dst V int-rep 18 } { src V int-rep 15 } { rep int-rep } }
    T{ ##copy { dst V int-rep 19 } { src V int-rep 15 } { rep int-rep } }
    T{ ##compare
        { dst V int-rep 20 }
        { src1 V int-rep 18 }
        { src2 V int-rep 19 }
        { cc cc= }
        { temp V int-rep 22 }
    }
    T{ ##copy { dst V int-rep 21 } { src V int-rep 20 } { rep int-rep } }
    T{ ##compare-imm-branch
        { src1 V int-rep 21 }
        { src2 5 }
        { cc cc/= }
    }
} 1 test-bb

V{
    T{ ##copy { dst V int-rep 23 } { src V int-rep 15 } { rep int-rep } }
    T{ ##copy { dst V int-rep 24 } { src V int-rep 15 } { rep int-rep } }
    T{ ##load-reference { dst V int-rep 25 } { obj t } }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace { src V int-rep 25 } { loc D 0 } }
    T{ ##epilogue }
    T{ ##return }
} 3 test-bb

V{
    T{ ##copy { dst V int-rep 26 } { src V int-rep 15 } { rep int-rep } }
    T{ ##copy { dst V int-rep 27 } { src V int-rep 15 } { rep int-rep } }
    T{ ##add
        { dst V int-rep 28 }
        { src1 V int-rep 26 }
        { src2 V int-rep 27 }
    }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##replace { src V int-rep 28 } { loc D 0 } }
    T{ ##epilogue }
    T{ ##return }
} 5 test-bb

0 1 edge
1 { 2 4 } edges
2 3 edge
4 5 edge

[ ] [
    cfg new 0 get >>entry
    value-numbering eliminate-dead-code drop
] unit-test

[ f ] [ 1 get instructions>> [ ##peek? ] any? ] unit-test
