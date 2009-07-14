IN: compiler.cfg.value-numbering.tests
USING: compiler.cfg.value-numbering compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.debugger compiler.cfg.comparisons
cpu.architecture tools.test kernel math combinators.short-circuit
accessors sequences compiler.cfg vectors arrays layouts ;

: trim-temps ( insns -- insns )
    [
        dup {
            [ ##compare? ]
            [ ##compare-imm? ]
            [ ##compare-float? ]
        } 1|| [ f >>temp ] when
    ] map ;

: test-value-numbering ( insns -- insns )
    { } init-value-numbering
    value-numbering-step ;

! Copy propagation
[
    {
        T{ ##peek f V int-regs 45 D 1 }
        T{ ##copy f V int-regs 48 V int-regs 45 }
        T{ ##compare-imm-branch f V int-regs 45 7 cc/= }
    }
] [
    {
        T{ ##peek f V int-regs 45 D 1 }
        T{ ##copy f V int-regs 48 V int-regs 45 }
        T{ ##compare-imm-branch f V int-regs 48 7 cc/= }
    } test-value-numbering
] unit-test

! Compare propagation
[
    {
        T{ ##load-reference f V int-regs 1 + }
        T{ ##peek f V int-regs 2 D 0 }
        T{ ##compare f V int-regs 4 V int-regs 2 V int-regs 1 cc> }
        T{ ##compare f V int-regs 6 V int-regs 2 V int-regs 1 cc> }
        T{ ##replace f V int-regs 4 D 0 }
    }
] [
    {
        T{ ##load-reference f V int-regs 1 + }
        T{ ##peek f V int-regs 2 D 0 }
        T{ ##compare f V int-regs 4 V int-regs 2 V int-regs 1 cc> }
        T{ ##compare-imm f V int-regs 6 V int-regs 4 5 cc/= }
        T{ ##replace f V int-regs 6 D 0 }
    } test-value-numbering trim-temps
] unit-test

[
    {
        T{ ##load-reference f V int-regs 1 + }
        T{ ##peek f V int-regs 2 D 0 }
        T{ ##compare f V int-regs 4 V int-regs 2 V int-regs 1 cc<= }
        T{ ##compare f V int-regs 6 V int-regs 2 V int-regs 1 cc> }
        T{ ##replace f V int-regs 6 D 0 }
    }
] [
    {
        T{ ##load-reference f V int-regs 1 + }
        T{ ##peek f V int-regs 2 D 0 }
        T{ ##compare f V int-regs 4 V int-regs 2 V int-regs 1 cc<= }
        T{ ##compare-imm f V int-regs 6 V int-regs 4 5 cc= }
        T{ ##replace f V int-regs 6 D 0 }
    } test-value-numbering trim-temps
] unit-test

[
    {
        T{ ##peek f V int-regs 8 D 0 }
        T{ ##peek f V int-regs 9 D -1 }
        T{ ##unbox-float f V double-float-regs 10 V int-regs 8 }
        T{ ##unbox-float f V double-float-regs 11 V int-regs 9 }
        T{ ##compare-float f V int-regs 12 V double-float-regs 10 V double-float-regs 11 cc< }
        T{ ##compare-float f V int-regs 14 V double-float-regs 10 V double-float-regs 11 cc>= }
        T{ ##replace f V int-regs 14 D 0 }
    }
] [
    {
        T{ ##peek f V int-regs 8 D 0 }
        T{ ##peek f V int-regs 9 D -1 }
        T{ ##unbox-float f V double-float-regs 10 V int-regs 8 }
        T{ ##unbox-float f V double-float-regs 11 V int-regs 9 }
        T{ ##compare-float f V int-regs 12 V double-float-regs 10 V double-float-regs 11 cc< }
        T{ ##compare-imm f V int-regs 14 V int-regs 12 5 cc= }
        T{ ##replace f V int-regs 14 D 0 }
    } test-value-numbering trim-temps
] unit-test

[
    {
        T{ ##peek f V int-regs 29 D -1 }
        T{ ##peek f V int-regs 30 D -2 }
        T{ ##compare f V int-regs 33 V int-regs 29 V int-regs 30 cc<= }
        T{ ##compare-branch f V int-regs 29 V int-regs 30 cc<= }
    }
] [
    {
        T{ ##peek f V int-regs 29 D -1 }
        T{ ##peek f V int-regs 30 D -2 }
        T{ ##compare f V int-regs 33 V int-regs 29 V int-regs 30 cc<= }
        T{ ##compare-imm-branch f V int-regs 33 5 cc/= }
    } test-value-numbering trim-temps
] unit-test

! Immediate operand conversion
[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##add-imm f V int-regs 2 V int-regs 0 100 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##add f V int-regs 2 V int-regs 0 V int-regs 1 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##add-imm f V int-regs 2 V int-regs 0 100 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##add f V int-regs 2 V int-regs 1 V int-regs 0 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##add-imm f V int-regs 2 V int-regs 0 -100 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##sub f V int-regs 2 V int-regs 0 V int-regs 1 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 0 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##sub f V int-regs 1 V int-regs 0 V int-regs 0 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##mul-imm f V int-regs 2 V int-regs 0 100 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##mul f V int-regs 2 V int-regs 0 V int-regs 1 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##mul-imm f V int-regs 2 V int-regs 0 100 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##mul f V int-regs 2 V int-regs 1 V int-regs 0 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 1 D 0 }
        T{ ##shl-imm f V int-regs 2 V int-regs 1 3 }
    }
] [
    {
        T{ ##peek f V int-regs 1 D 0 }
        T{ ##mul-imm f V int-regs 2 V int-regs 1 8 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##and-imm f V int-regs 2 V int-regs 0 100 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##and f V int-regs 2 V int-regs 0 V int-regs 1 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##and-imm f V int-regs 2 V int-regs 0 100 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##and f V int-regs 2 V int-regs 1 V int-regs 0 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##or-imm f V int-regs 2 V int-regs 0 100 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##or f V int-regs 2 V int-regs 0 V int-regs 1 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##or-imm f V int-regs 2 V int-regs 0 100 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##or f V int-regs 2 V int-regs 1 V int-regs 0 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##xor-imm f V int-regs 2 V int-regs 0 100 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##xor f V int-regs 2 V int-regs 0 V int-regs 1 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##xor-imm f V int-regs 2 V int-regs 0 100 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##xor f V int-regs 2 V int-regs 1 V int-regs 0 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##compare-imm f V int-regs 2 V int-regs 0 100 cc<= }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##compare f V int-regs 2 V int-regs 0 V int-regs 1 cc<= }
    } test-value-numbering trim-temps
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##compare-imm f V int-regs 2 V int-regs 0 100 cc>= }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##compare f V int-regs 2 V int-regs 1 V int-regs 0 cc<= }
    } test-value-numbering trim-temps
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##compare-imm-branch f V int-regs 0 100 cc<= }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##compare-branch f V int-regs 0 V int-regs 1 cc<= }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##compare-imm-branch f V int-regs 0 100 cc>= }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##compare-branch f V int-regs 1 V int-regs 0 cc<= }
    } test-value-numbering trim-temps
] unit-test

! Reassociation
[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##add-imm f V int-regs 2 V int-regs 0 100 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##add-imm f V int-regs 4 V int-regs 0 150 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##add f V int-regs 2 V int-regs 0 V int-regs 1 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##add f V int-regs 4 V int-regs 2 V int-regs 3 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##add-imm f V int-regs 2 V int-regs 0 100 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##add-imm f V int-regs 4 V int-regs 0 150 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##add f V int-regs 2 V int-regs 1 V int-regs 0 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##add f V int-regs 4 V int-regs 3 V int-regs 2 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##add-imm f V int-regs 2 V int-regs 0 100 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##add-imm f V int-regs 4 V int-regs 0 50 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##add f V int-regs 2 V int-regs 0 V int-regs 1 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##sub f V int-regs 4 V int-regs 2 V int-regs 3 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##add-imm f V int-regs 2 V int-regs 0 -100 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##add-imm f V int-regs 4 V int-regs 0 -150 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##sub f V int-regs 2 V int-regs 0 V int-regs 1 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##sub f V int-regs 4 V int-regs 2 V int-regs 3 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##mul-imm f V int-regs 2 V int-regs 0 100 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##mul-imm f V int-regs 4 V int-regs 0 5000 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##mul f V int-regs 2 V int-regs 0 V int-regs 1 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##mul f V int-regs 4 V int-regs 2 V int-regs 3 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##mul-imm f V int-regs 2 V int-regs 0 100 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##mul-imm f V int-regs 4 V int-regs 0 5000 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##mul f V int-regs 2 V int-regs 1 V int-regs 0 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##mul f V int-regs 4 V int-regs 3 V int-regs 2 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##and-imm f V int-regs 2 V int-regs 0 100 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##and-imm f V int-regs 4 V int-regs 0 32 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##and f V int-regs 2 V int-regs 0 V int-regs 1 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##and f V int-regs 4 V int-regs 2 V int-regs 3 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##and-imm f V int-regs 2 V int-regs 0 100 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##and-imm f V int-regs 4 V int-regs 0 32 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##and f V int-regs 2 V int-regs 1 V int-regs 0 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##and f V int-regs 4 V int-regs 3 V int-regs 2 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##or-imm f V int-regs 2 V int-regs 0 100 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##or-imm f V int-regs 4 V int-regs 0 118 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##or f V int-regs 2 V int-regs 0 V int-regs 1 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##or f V int-regs 4 V int-regs 2 V int-regs 3 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##or-imm f V int-regs 2 V int-regs 0 100 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##or-imm f V int-regs 4 V int-regs 0 118 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##or f V int-regs 2 V int-regs 1 V int-regs 0 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##or f V int-regs 4 V int-regs 3 V int-regs 2 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##xor-imm f V int-regs 2 V int-regs 0 100 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##xor-imm f V int-regs 4 V int-regs 0 86 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##xor f V int-regs 2 V int-regs 0 V int-regs 1 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##xor f V int-regs 4 V int-regs 2 V int-regs 3 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##xor-imm f V int-regs 2 V int-regs 0 100 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##xor-imm f V int-regs 4 V int-regs 0 86 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##xor f V int-regs 2 V int-regs 1 V int-regs 0 }
        T{ ##load-immediate f V int-regs 3 50 }
        T{ ##xor f V int-regs 4 V int-regs 3 V int-regs 2 }
    } test-value-numbering
] unit-test

! Simplification
[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##peek f V int-regs 1 D 1 }
        T{ ##load-immediate f V int-regs 2 0 }
        T{ ##add-imm f V int-regs 3 V int-regs 0 0 }
        T{ ##replace f V int-regs 0 D 0 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##peek f V int-regs 1 D 1 }
        T{ ##sub f V int-regs 2 V int-regs 1 V int-regs 1 }
        T{ ##add f V int-regs 3 V int-regs 0 V int-regs 2 }
        T{ ##replace f V int-regs 3 D 0 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##peek f V int-regs 1 D 1 }
        T{ ##load-immediate f V int-regs 2 0 }
        T{ ##add-imm f V int-regs 3 V int-regs 0 0 }
        T{ ##replace f V int-regs 0 D 0 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##peek f V int-regs 1 D 1 }
        T{ ##sub f V int-regs 2 V int-regs 1 V int-regs 1 }
        T{ ##sub f V int-regs 3 V int-regs 0 V int-regs 2 }
        T{ ##replace f V int-regs 3 D 0 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##peek f V int-regs 1 D 1 }
        T{ ##load-immediate f V int-regs 2 0 }
        T{ ##or-imm f V int-regs 3 V int-regs 0 0 }
        T{ ##replace f V int-regs 0 D 0 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##peek f V int-regs 1 D 1 }
        T{ ##sub f V int-regs 2 V int-regs 1 V int-regs 1 }
        T{ ##or f V int-regs 3 V int-regs 0 V int-regs 2 }
        T{ ##replace f V int-regs 3 D 0 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##peek f V int-regs 1 D 1 }
        T{ ##load-immediate f V int-regs 2 0 }
        T{ ##xor-imm f V int-regs 3 V int-regs 0 0 }
        T{ ##replace f V int-regs 0 D 0 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##peek f V int-regs 1 D 1 }
        T{ ##sub f V int-regs 2 V int-regs 1 V int-regs 1 }
        T{ ##xor f V int-regs 3 V int-regs 0 V int-regs 2 }
        T{ ##replace f V int-regs 3 D 0 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##shl-imm f V int-regs 2 V int-regs 0 0 }
        T{ ##replace f V int-regs 0 D 0 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##mul f V int-regs 2 V int-regs 0 V int-regs 1 }
        T{ ##replace f V int-regs 2 D 0 }
    } test-value-numbering
] unit-test

! Constant folding
[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 3 }
        T{ ##load-immediate f V int-regs 3 4 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 3 }
        T{ ##add f V int-regs 3 V int-regs 1 V int-regs 2 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 3 }
        T{ ##load-immediate f V int-regs 3 -2 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 3 }
        T{ ##sub f V int-regs 3 V int-regs 1 V int-regs 2 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 2 }
        T{ ##load-immediate f V int-regs 2 3 }
        T{ ##load-immediate f V int-regs 3 6 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 2 }
        T{ ##load-immediate f V int-regs 2 3 }
        T{ ##mul f V int-regs 3 V int-regs 1 V int-regs 2 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 2 }
        T{ ##load-immediate f V int-regs 2 1 }
        T{ ##load-immediate f V int-regs 3 0 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 2 }
        T{ ##load-immediate f V int-regs 2 1 }
        T{ ##and f V int-regs 3 V int-regs 1 V int-regs 2 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 2 }
        T{ ##load-immediate f V int-regs 2 1 }
        T{ ##load-immediate f V int-regs 3 3 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 2 }
        T{ ##load-immediate f V int-regs 2 1 }
        T{ ##or f V int-regs 3 V int-regs 1 V int-regs 2 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 2 }
        T{ ##load-immediate f V int-regs 2 3 }
        T{ ##load-immediate f V int-regs 3 1 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 2 }
        T{ ##load-immediate f V int-regs 2 3 }
        T{ ##xor f V int-regs 3 V int-regs 1 V int-regs 2 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 3 8 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##shl-imm f V int-regs 3 V int-regs 1 3 }
    } test-value-numbering
] unit-test

cell 8 = [
    [
        {
            T{ ##peek f V int-regs 0 D 0 }
            T{ ##load-immediate f V int-regs 1 -1 }
            T{ ##load-immediate f V int-regs 3 HEX: ffffffffffff }
        }
    ] [
        {
            T{ ##peek f V int-regs 0 D 0 }
            T{ ##load-immediate f V int-regs 1 -1 }
            T{ ##shr-imm f V int-regs 3 V int-regs 1 16 }
        } test-value-numbering
    ] unit-test
] when

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 -8 }
        T{ ##load-immediate f V int-regs 3 -4 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 -8 }
        T{ ##sar-imm f V int-regs 3 V int-regs 1 1 }
    } test-value-numbering
] unit-test

cell 8 = [
    [
        {
            T{ ##peek f V int-regs 0 D 0 }
            T{ ##load-immediate f V int-regs 1 65536 }
            T{ ##load-immediate f V int-regs 2 140737488355328 }
            T{ ##add f V int-regs 3 V int-regs 0 V int-regs 2 }
        }
    ] [
        {
            T{ ##peek f V int-regs 0 D 0 }
            T{ ##load-immediate f V int-regs 1 65536 }
            T{ ##shl-imm f V int-regs 2 V int-regs 1 31 }
            T{ ##add f V int-regs 3 V int-regs 0 V int-regs 2 }
        } test-value-numbering
    ] unit-test
] when