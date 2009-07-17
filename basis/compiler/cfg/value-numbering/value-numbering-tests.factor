IN: compiler.cfg.value-numbering.tests
USING: compiler.cfg.value-numbering compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.debugger compiler.cfg.comparisons
cpu.architecture tools.test kernel math combinators.short-circuit
accessors sequences compiler.cfg.predecessors locals
compiler.cfg.phi-elimination compiler.cfg.dce compiler.cfg.liveness
compiler.cfg assocs vectors arrays layouts namespaces ;

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

! Folding constants together
[
    {
        T{ ##load-reference f V int-regs 0 0.0 }
        T{ ##load-reference f V int-regs 1 -0.0 }
        T{ ##replace f V int-regs 0 D 0 }
        T{ ##replace f V int-regs 1 D 1 }
    }
] [
    {
        T{ ##load-reference f V int-regs 0 0.0 }
        T{ ##load-reference f V int-regs 1 -0.0 }
        T{ ##replace f V int-regs 0 D 0 }
        T{ ##replace f V int-regs 1 D 1 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##load-reference f V int-regs 0 0.0 }
        T{ ##load-reference f V int-regs 1 0.0 }
        T{ ##replace f V int-regs 0 D 0 }
        T{ ##replace f V int-regs 0 D 1 }
    }
] [
    {
        T{ ##load-reference f V int-regs 0 0.0 }
        T{ ##load-reference f V int-regs 1 0.0 }
        T{ ##replace f V int-regs 0 D 0 }
        T{ ##replace f V int-regs 1 D 1 }
    } test-value-numbering
] unit-test

[
    {
        T{ ##load-reference f V int-regs 0 t }
        T{ ##load-reference f V int-regs 1 t }
        T{ ##replace f V int-regs 0 D 0 }
        T{ ##replace f V int-regs 0 D 1 }
    }
] [
    {
        T{ ##load-reference f V int-regs 0 t }
        T{ ##load-reference f V int-regs 1 t }
        T{ ##replace f V int-regs 0 D 0 }
        T{ ##replace f V int-regs 1 D 1 }
    } test-value-numbering
] unit-test

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

    [
        {
            T{ ##peek f V int-regs 0 D 0 }
            T{ ##load-immediate f V int-regs 2 140737488355328 }
            T{ ##add f V int-regs 3 V int-regs 0 V int-regs 2 }
        }
    ] [
        {
            T{ ##peek f V int-regs 0 D 0 }
            T{ ##load-immediate f V int-regs 2 140737488355328 }
            T{ ##add f V int-regs 3 V int-regs 0 V int-regs 2 }
        } test-value-numbering
    ] unit-test

    [
        {
            T{ ##peek f V int-regs 0 D 0 }
            T{ ##load-immediate f V int-regs 2 2147483647 }
            T{ ##add-imm f V int-regs 3 V int-regs 0 2147483647 }
            T{ ##add-imm f V int-regs 4 V int-regs 3 2147483647 }
        }
    ] [
        {
            T{ ##peek f V int-regs 0 D 0 }
            T{ ##load-immediate f V int-regs 2 2147483647 }
            T{ ##add f V int-regs 3 V int-regs 0 V int-regs 2 }
            T{ ##add f V int-regs 4 V int-regs 3 V int-regs 2 }
        } test-value-numbering
    ] unit-test
] when

! Branch folding
[
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##load-immediate f V int-regs 3 5 }
    }
] [
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##compare f V int-regs 3 V int-regs 1 V int-regs 2 cc= }
    } test-value-numbering
] unit-test

[
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##load-reference f V int-regs 3 t }
    }
] [
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##compare f V int-regs 3 V int-regs 1 V int-regs 2 cc/= }
    } test-value-numbering
] unit-test

[
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##load-reference f V int-regs 3 t }
    }
] [
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##compare f V int-regs 3 V int-regs 1 V int-regs 2 cc< }
    } test-value-numbering
] unit-test

[
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##load-immediate f V int-regs 3 5 }
    }
] [
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##compare f V int-regs 3 V int-regs 2 V int-regs 1 cc< }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 5 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##compare f V int-regs 1 V int-regs 0 V int-regs 0 cc< }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-reference f V int-regs 1 t }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##compare f V int-regs 1 V int-regs 0 V int-regs 0 cc<= }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 5 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##compare f V int-regs 1 V int-regs 0 V int-regs 0 cc> }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-reference f V int-regs 1 t }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##compare f V int-regs 1 V int-regs 0 V int-regs 0 cc>= }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-immediate f V int-regs 1 5 }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##compare f V int-regs 1 V int-regs 0 V int-regs 0 cc/= }
    } test-value-numbering
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-reference f V int-regs 1 t }
    }
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##compare f V int-regs 1 V int-regs 0 V int-regs 0 cc= }
    } test-value-numbering
] unit-test

: test-branch-folding ( insns -- insns' n )
    <basic-block>
    [ V{ 0 1 } clone >>successors basic-block set test-value-numbering ] keep
    successors>> first ;

[
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##branch }
    }
    1
] [
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##compare-branch f V int-regs 1 V int-regs 2 cc= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##compare-branch f V int-regs 1 V int-regs 2 cc/= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##compare-branch f V int-regs 1 V int-regs 2 cc< }
    } test-branch-folding
] unit-test

[
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##branch }
    }
    1
] [
    {
        T{ ##load-immediate f V int-regs 1 1 }
        T{ ##load-immediate f V int-regs 2 2 }
        T{ ##compare-branch f V int-regs 2 V int-regs 1 cc< }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##branch }
    }
    1
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##compare-branch f V int-regs 0 V int-regs 0 cc< }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##compare-branch f V int-regs 0 V int-regs 0 cc<= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##branch }
    }
    1
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##compare-branch f V int-regs 0 V int-regs 0 cc> }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##compare-branch f V int-regs 0 V int-regs 0 cc>= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##compare-branch f V int-regs 0 V int-regs 0 cc= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##branch }
    }
    1
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##compare-branch f V int-regs 0 V int-regs 0 cc/= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##load-reference f V int-regs 1 t }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##compare f V int-regs 1 V int-regs 0 V int-regs 0 cc<= }
        T{ ##compare-imm-branch f V int-regs 1 5 cc/= }
    } test-branch-folding
] unit-test

! More branch folding tests
V{ T{ ##branch } } 0 test-bb

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##compare-branch f V int-regs 0 V int-regs 0 cc< }
} 1 test-bb

V{
    T{ ##load-immediate f V int-regs 1 1 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##load-immediate f V int-regs 2 2 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##phi f V int-regs 3 { } }
    T{ ##replace f V int-regs 3 D 0 }
    T{ ##return }
} 4 test-bb

4 get instructions>> first
2 get V int-regs 1 2array
3 get V int-regs 2 2array 2array
>>inputs drop

test-diamond

[ ] [
    cfg new 0 get >>entry
    compute-liveness
    value-numbering
    compute-predecessors
    eliminate-phis drop
] unit-test

[ 1 ] [ 1 get successors>> length ] unit-test

[ t ] [ 1 get successors>> first 3 get eq? ] unit-test

[let | n! [ f ] |

[ ] [ 2 get successors>> first instructions>> first src>> n>> n! ] unit-test

[ t ] [
    T{ ##copy f V int-regs n V int-regs 2 }
    3 get successors>> first instructions>> first =
] unit-test

]

[ 3 ] [ 4 get instructions>> length ] unit-test

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f V int-regs 1 D 1 }
    T{ ##compare-branch f V int-regs 1 V int-regs 1 cc< }
} 1 test-bb

V{
    T{ ##copy f V int-regs 2 V int-regs 0 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##phi f V int-regs 3 V{ } }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace f V int-regs 3 D 0 }
    T{ ##return }
} 4 test-bb

1 get V int-regs 1 2array
2 get V int-regs 0 2array 2array 3 get instructions>> first (>>inputs)

test-diamond

[ ] [
    cfg new 0 get >>entry
    compute-predecessors
    compute-liveness
    value-numbering
    compute-predecessors
    eliminate-dead-code
    drop
] unit-test

[ t ] [ 1 get successors>> first 3 get eq? ] unit-test

[ 1 ] [ 3 get instructions>> first inputs>> assoc-size ] unit-test

V{ T{ ##prologue } T{ ##branch } } 0 test-bb

V{
    T{ ##peek { dst V int-regs 15 } { loc D 0 } }
    T{ ##copy { dst V int-regs 16 } { src V int-regs 15 } }
    T{ ##copy { dst V int-regs 17 } { src V int-regs 15 } }
    T{ ##copy { dst V int-regs 18 } { src V int-regs 15 } }
    T{ ##copy { dst V int-regs 19 } { src V int-regs 15 } }
    T{ ##compare
        { dst V int-regs 20 }
        { src1 V int-regs 18 }
        { src2 V int-regs 19 }
        { cc cc= }
        { temp V int-regs 22 }
    }
    T{ ##copy { dst V int-regs 21 } { src V int-regs 20 } }
    T{ ##compare-imm-branch
        { src1 V int-regs 21 }
        { src2 5 }
        { cc cc/= }
    }
} 1 test-bb

V{
    T{ ##copy { dst V int-regs 23 } { src V int-regs 15 } }
    T{ ##copy { dst V int-regs 24 } { src V int-regs 15 } }
    T{ ##load-reference { dst V int-regs 25 } { obj t } }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace { src V int-regs 25 } { loc D 0 } }
    T{ ##epilogue }
    T{ ##return }
} 3 test-bb

V{
    T{ ##copy { dst V int-regs 26 } { src V int-regs 15 } }
    T{ ##copy { dst V int-regs 27 } { src V int-regs 15 } }
    T{ ##add
        { dst V int-regs 28 }
        { src1 V int-regs 26 }
        { src2 V int-regs 27 }
    }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##replace { src V int-regs 28 } { loc D 0 } }
    T{ ##epilogue }
    T{ ##return }
} 5 test-bb

0 get 1 get 1vector >>successors drop
1 get 2 get 4 get V{ } 2sequence >>successors drop
2 get 3 get 1vector >>successors drop
4 get 5 get 1vector >>successors drop

[ ] [
    cfg new 0 get >>entry
    compute-liveness value-numbering eliminate-dead-code drop
] unit-test

[ f ] [ 1 get instructions>> [ ##peek? ] any? ] unit-test
