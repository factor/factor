USING: compiler.cfg.value-numbering compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.debugger compiler.cfg.comparisons
cpu.architecture tools.test kernel math combinators.short-circuit
accessors sequences compiler.cfg.predecessors locals compiler.cfg.dce
compiler.cfg.ssa.destruction compiler.cfg.loop-detection
compiler.cfg.representations compiler.cfg assocs vectors arrays
layouts namespaces alien ;
IN: compiler.cfg.value-numbering.tests

: trim-temps ( insns -- insns )
    [
        dup {
            [ ##compare? ]
            [ ##compare-imm? ]
            [ ##compare-float-unordered? ]
            [ ##compare-float-ordered? ]
        } 1|| [ f >>temp ] when
    ] map ;

! Folding constants together
[
    {
        T{ ##load-constant f 0 0.0 }
        T{ ##load-constant f 1 -0.0 }
        T{ ##replace f 0 D 0 }
        T{ ##replace f 1 D 1 }
    }
] [
    {
        T{ ##load-constant f 0 0.0 }
        T{ ##load-constant f 1 -0.0 }
        T{ ##replace f 0 D 0 }
        T{ ##replace f 1 D 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##load-constant f 0 0.0 }
        T{ ##copy f 1 0 any-rep }
        T{ ##replace f 0 D 0 }
        T{ ##replace f 1 D 1 }
    }
] [
    {
        T{ ##load-constant f 0 0.0 }
        T{ ##load-constant f 1 0.0 }
        T{ ##replace f 0 D 0 }
        T{ ##replace f 1 D 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##load-constant f 0 t }
        T{ ##copy f 1 0 any-rep }
        T{ ##replace f 0 D 0 }
        T{ ##replace f 1 D 1 }
    }
] [
    {
        T{ ##load-constant f 0 t }
        T{ ##load-constant f 1 t }
        T{ ##replace f 0 D 0 }
        T{ ##replace f 1 D 1 }
    } value-numbering-step
] unit-test

! Compare propagation
[
    {
        T{ ##load-reference f 1 + }
        T{ ##peek f 2 D 0 }
        T{ ##compare f 4 2 1 cc> }
        T{ ##copy f 6 4 any-rep }
        T{ ##replace f 6 D 0 }
    }
] [
    {
        T{ ##load-reference f 1 + }
        T{ ##peek f 2 D 0 }
        T{ ##compare f 4 2 1 cc> }
        T{ ##compare-imm f 6 4 5 cc/= }
        T{ ##replace f 6 D 0 }
    } value-numbering-step trim-temps
] unit-test

[
    {
        T{ ##load-reference f 1 + }
        T{ ##peek f 2 D 0 }
        T{ ##compare f 4 2 1 cc<= }
        T{ ##compare f 6 2 1 cc/<= }
        T{ ##replace f 6 D 0 }
    }
] [
    {
        T{ ##load-reference f 1 + }
        T{ ##peek f 2 D 0 }
        T{ ##compare f 4 2 1 cc<= }
        T{ ##compare-imm f 6 4 5 cc= }
        T{ ##replace f 6 D 0 }
    } value-numbering-step trim-temps
] unit-test

[
    {
        T{ ##peek f 8 D 0 }
        T{ ##peek f 9 D -1 }
        T{ ##unbox-float f 10 8 }
        T{ ##unbox-float f 11 9 }
        T{ ##compare-float-unordered f 12 10 11 cc< }
        T{ ##compare-float-unordered f 14 10 11 cc/< }
        T{ ##replace f 14 D 0 }
    }
] [
    {
        T{ ##peek f 8 D 0 }
        T{ ##peek f 9 D -1 }
        T{ ##unbox-float f 10 8 }
        T{ ##unbox-float f 11 9 }
        T{ ##compare-float-unordered f 12 10 11 cc< }
        T{ ##compare-imm f 14 12 5 cc= }
        T{ ##replace f 14 D 0 }
    } value-numbering-step trim-temps
] unit-test

[
    {
        T{ ##peek f 29 D -1 }
        T{ ##peek f 30 D -2 }
        T{ ##compare f 33 29 30 cc<= }
        T{ ##compare-branch f 29 30 cc<= }
    }
] [
    {
        T{ ##peek f 29 D -1 }
        T{ ##peek f 30 D -2 }
        T{ ##compare f 33 29 30 cc<= }
        T{ ##compare-imm-branch f 33 5 cc/= }
    } value-numbering-step trim-temps
] unit-test

! Immediate operand conversion
[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##add-imm f 2 0 100 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##add f 2 0 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##add-imm f 2 0 100 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##add f 2 1 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##add-imm f 2 0 -100 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##sub f 2 0 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 0 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##sub f 1 0 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##mul-imm f 2 0 100 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##mul f 2 0 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##mul-imm f 2 0 100 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##mul f 2 1 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 1 D 0 }
        T{ ##shl-imm f 2 1 3 }
    }
] [
    {
        T{ ##peek f 1 D 0 }
        T{ ##mul-imm f 2 1 8 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 -1 }
        T{ ##neg f 2 0 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 -1 }
        T{ ##mul f 2 0 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 -1 }
        T{ ##neg f 2 0 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 -1 }
        T{ ##mul f 2 1 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 0 }
        T{ ##neg f 2 0 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 0 }
        T{ ##sub f 2 1 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 0 }
        T{ ##neg f 2 0 }
        T{ ##copy f 3 0 any-rep }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 0 }
        T{ ##sub f 2 1 0 }
        T{ ##sub f 3 1 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##not f 1 0 }
        T{ ##copy f 2 0 any-rep }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##not f 1 0 }
        T{ ##not f 2 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##and-imm f 2 0 100 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##and f 2 0 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##and-imm f 2 0 100 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##and f 2 1 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##or-imm f 2 0 100 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##or f 2 0 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##or-imm f 2 0 100 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##or f 2 1 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##xor-imm f 2 0 100 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##xor f 2 0 1 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##xor-imm f 2 0 100 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##xor f 2 1 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##compare-imm f 2 0 100 cc<= }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##compare f 2 0 1 cc<= }
    } value-numbering-step trim-temps
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##compare-imm f 2 0 100 cc>= }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##compare f 2 1 0 cc<= }
    } value-numbering-step trim-temps
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##compare-imm-branch f 0 100 cc<= }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##compare-branch f 0 1 cc<= }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##compare-imm-branch f 0 100 cc>= }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##compare-branch f 1 0 cc<= }
    } value-numbering-step trim-temps
] unit-test

! Reassociation
[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##add-imm f 2 0 100 }
        T{ ##load-immediate f 3 50 }
        T{ ##add-imm f 4 0 150 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##add f 2 0 1 }
        T{ ##load-immediate f 3 50 }
        T{ ##add f 4 2 3 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##add-imm f 2 0 100 }
        T{ ##load-immediate f 3 50 }
        T{ ##add-imm f 4 0 150 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##add f 2 1 0 }
        T{ ##load-immediate f 3 50 }
        T{ ##add f 4 3 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##add-imm f 2 0 100 }
        T{ ##load-immediate f 3 50 }
        T{ ##add-imm f 4 0 50 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##add f 2 0 1 }
        T{ ##load-immediate f 3 50 }
        T{ ##sub f 4 2 3 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##add-imm f 2 0 -100 }
        T{ ##load-immediate f 3 50 }
        T{ ##add-imm f 4 0 -150 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##sub f 2 0 1 }
        T{ ##load-immediate f 3 50 }
        T{ ##sub f 4 2 3 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##mul-imm f 2 0 100 }
        T{ ##load-immediate f 3 50 }
        T{ ##mul-imm f 4 0 5000 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##mul f 2 0 1 }
        T{ ##load-immediate f 3 50 }
        T{ ##mul f 4 2 3 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##mul-imm f 2 0 100 }
        T{ ##load-immediate f 3 50 }
        T{ ##mul-imm f 4 0 5000 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##mul f 2 1 0 }
        T{ ##load-immediate f 3 50 }
        T{ ##mul f 4 3 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##and-imm f 2 0 100 }
        T{ ##load-immediate f 3 50 }
        T{ ##and-imm f 4 0 32 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##and f 2 0 1 }
        T{ ##load-immediate f 3 50 }
        T{ ##and f 4 2 3 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##and-imm f 2 0 100 }
        T{ ##load-immediate f 3 50 }
        T{ ##and-imm f 4 0 32 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##and f 2 1 0 }
        T{ ##load-immediate f 3 50 }
        T{ ##and f 4 3 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##or-imm f 2 0 100 }
        T{ ##load-immediate f 3 50 }
        T{ ##or-imm f 4 0 118 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##or f 2 0 1 }
        T{ ##load-immediate f 3 50 }
        T{ ##or f 4 2 3 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##or-imm f 2 0 100 }
        T{ ##load-immediate f 3 50 }
        T{ ##or-imm f 4 0 118 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##or f 2 1 0 }
        T{ ##load-immediate f 3 50 }
        T{ ##or f 4 3 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##xor-imm f 2 0 100 }
        T{ ##load-immediate f 3 50 }
        T{ ##xor-imm f 4 0 86 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##xor f 2 0 1 }
        T{ ##load-immediate f 3 50 }
        T{ ##xor f 4 2 3 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##xor-imm f 2 0 100 }
        T{ ##load-immediate f 3 50 }
        T{ ##xor-imm f 4 0 86 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 100 }
        T{ ##xor f 2 1 0 }
        T{ ##load-immediate f 3 50 }
        T{ ##xor f 4 3 2 }
    } value-numbering-step
] unit-test

! Simplification
[
    {
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##load-immediate f 2 0 }
        T{ ##copy f 3 0 any-rep }
        T{ ##replace f 3 D 0 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##sub f 2 1 1 }
        T{ ##add f 3 0 2 }
        T{ ##replace f 3 D 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##load-immediate f 2 0 }
        T{ ##copy f 3 0 any-rep }
        T{ ##replace f 3 D 0 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##sub f 2 1 1 }
        T{ ##sub f 3 0 2 }
        T{ ##replace f 3 D 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##load-immediate f 2 0 }
        T{ ##copy f 3 0 any-rep }
        T{ ##replace f 3 D 0 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##sub f 2 1 1 }
        T{ ##or f 3 0 2 }
        T{ ##replace f 3 D 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##load-immediate f 2 0 }
        T{ ##copy f 3 0 any-rep }
        T{ ##replace f 3 D 0 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##sub f 2 1 1 }
        T{ ##xor f 3 0 2 }
        T{ ##replace f 3 D 0 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 1 }
        T{ ##copy f 2 0 any-rep }
        T{ ##replace f 2 D 0 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 1 }
        T{ ##mul f 2 0 1 }
        T{ ##replace f 2 D 0 }
    } value-numbering-step
] unit-test

! Constant folding
[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 3 }
        T{ ##load-immediate f 3 4 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 3 }
        T{ ##add f 3 1 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 3 }
        T{ ##load-immediate f 3 -2 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 3 }
        T{ ##sub f 3 1 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 2 }
        T{ ##load-immediate f 2 3 }
        T{ ##load-immediate f 3 6 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 2 }
        T{ ##load-immediate f 2 3 }
        T{ ##mul f 3 1 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 2 }
        T{ ##load-immediate f 2 1 }
        T{ ##load-immediate f 3 0 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 2 }
        T{ ##load-immediate f 2 1 }
        T{ ##and f 3 1 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 2 }
        T{ ##load-immediate f 2 1 }
        T{ ##load-immediate f 3 3 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 2 }
        T{ ##load-immediate f 2 1 }
        T{ ##or f 3 1 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 2 }
        T{ ##load-immediate f 2 3 }
        T{ ##load-immediate f 3 1 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 2 }
        T{ ##load-immediate f 2 3 }
        T{ ##xor f 3 1 2 }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 3 8 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 1 }
        T{ ##shl-imm f 3 1 3 }
    } value-numbering-step
] unit-test

cell 8 = [
    [
        {
            T{ ##peek f 0 D 0 }
            T{ ##load-immediate f 1 -1 }
            T{ ##load-immediate f 3 HEX: ffffffffffff }
        }
    ] [
        {
            T{ ##peek f 0 D 0 }
            T{ ##load-immediate f 1 -1 }
            T{ ##shr-imm f 3 1 16 }
        } value-numbering-step
    ] unit-test
] when

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 -8 }
        T{ ##load-immediate f 3 -4 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 -8 }
        T{ ##sar-imm f 3 1 1 }
    } value-numbering-step
] unit-test

cell 8 = [
    [
        {
            T{ ##peek f 0 D 0 }
            T{ ##load-immediate f 1 65536 }
            T{ ##load-immediate f 2 140737488355328 }
            T{ ##add f 3 0 2 }
        }
    ] [
        {
            T{ ##peek f 0 D 0 }
            T{ ##load-immediate f 1 65536 }
            T{ ##shl-imm f 2 1 31 }
            T{ ##add f 3 0 2 }
        } value-numbering-step
    ] unit-test

    [
        {
            T{ ##peek f 0 D 0 }
            T{ ##load-immediate f 2 140737488355328 }
            T{ ##add f 3 0 2 }
        }
    ] [
        {
            T{ ##peek f 0 D 0 }
            T{ ##load-immediate f 2 140737488355328 }
            T{ ##add f 3 0 2 }
        } value-numbering-step
    ] unit-test

    [
        {
            T{ ##peek f 0 D 0 }
            T{ ##load-immediate f 2 2147483647 }
            T{ ##add-imm f 3 0 2147483647 }
            T{ ##add-imm f 4 3 2147483647 }
        }
    ] [
        {
            T{ ##peek f 0 D 0 }
            T{ ##load-immediate f 2 2147483647 }
            T{ ##add f 3 0 2 }
            T{ ##add f 4 3 2 }
        } value-numbering-step
    ] unit-test
] when

! Displaced alien optimizations
3 vreg-counter set-global

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 2 16 }
        T{ ##box-displaced-alien f 1 2 0 c-ptr }
        T{ ##unbox-any-c-ptr f 4 0 }
        T{ ##add-imm f 3 4 16 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 2 16 }
        T{ ##box-displaced-alien f 1 2 0 c-ptr }
        T{ ##unbox-any-c-ptr f 3 1 }
    } value-numbering-step
] unit-test

4 vreg-counter set-global

[
    {
        T{ ##box-alien f 0 1 }
        T{ ##load-immediate f 2 16 }
        T{ ##box-displaced-alien f 3 2 0 c-ptr }
        T{ ##copy f 5 1 any-rep }
        T{ ##add-imm f 4 5 16 }
    }
] [
    {
        T{ ##box-alien f 0 1 }
        T{ ##load-immediate f 2 16 }
        T{ ##box-displaced-alien f 3 2 0 c-ptr }
        T{ ##unbox-any-c-ptr f 4 3 }
    } value-numbering-step
] unit-test

3 vreg-counter set-global

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 2 0 }
        T{ ##copy f 3 0 any-rep }
        T{ ##replace f 3 D 1 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 2 0 }
        T{ ##box-displaced-alien f 3 2 0 c-ptr }
        T{ ##replace f 3 D 1 }
    } value-numbering-step
] unit-test

! Branch folding
[
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##load-immediate f 3 5 }
    }
] [
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##compare f 3 1 2 cc= }
    } value-numbering-step
] unit-test

[
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##load-constant f 3 t }
    }
] [
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##compare f 3 1 2 cc/= }
    } value-numbering-step
] unit-test

[
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##load-constant f 3 t }
    }
] [
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##compare f 3 1 2 cc< }
    } value-numbering-step
] unit-test

[
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##load-immediate f 3 5 }
    }
] [
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##compare f 3 2 1 cc< }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 5 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##compare f 1 0 0 cc< }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-constant f 1 t }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##compare f 1 0 0 cc<= }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 5 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##compare f 1 0 0 cc> }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-constant f 1 t }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##compare f 1 0 0 cc>= }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-immediate f 1 5 }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##compare f 1 0 0 cc/= }
    } value-numbering-step
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-constant f 1 t }
    }
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##compare f 1 0 0 cc= }
    } value-numbering-step
] unit-test

[
    {
        T{ ##vector>scalar f 1 0 float-4-rep }
        T{ ##copy f 2 0 any-rep }
    }
] [
    {
        T{ ##vector>scalar f 1 0 float-4-rep }
        T{ ##scalar>vector f 2 1 float-4-rep }
    } value-numbering-step
] unit-test

[
    {
        T{ ##copy f 1 0 any-rep }
    }
] [
    {
        T{ ##shuffle-vector f 1 0 { 0 1 2 3 } float-4-rep }
    } value-numbering-step
] unit-test

[
    {
        T{ ##shuffle-vector f 1 0 { 1 2 3 0 } float-4-rep }
        T{ ##shuffle-vector f 2 0 { 0 2 3 1 } float-4-rep }
    }
] [
    {
        T{ ##shuffle-vector f 1 0 { 1 2 3 0 } float-4-rep }
        T{ ##shuffle-vector f 2 1 { 3 1 2 0 } float-4-rep }
    } value-numbering-step
] unit-test

[
    {
        T{ ##shuffle-vector f 1 0 { 1 2 3 0 } float-4-rep }
        T{ ##shuffle-vector f 2 1 { 1 0 } double-2-rep }
    }
] [
    {
        T{ ##shuffle-vector f 1 0 { 1 2 3 0 } float-4-rep }
        T{ ##shuffle-vector f 2 1 { 1 0 } double-2-rep }
    } value-numbering-step
] unit-test

[
    {
        T{ ##load-constant f 0 1.25 }
        T{ ##load-constant f 1 B{ 0 0 160 63 0 0 160 63 0 0 160 63 0 0 160 63 } }
        T{ ##copy f 2 1 any-rep }
    }
] [
    {
        T{ ##load-constant f 0 1.25 }
        T{ ##scalar>vector f 1 0 float-4-rep }
        T{ ##shuffle-vector f 2 1 { 0 0 0 0 } float-4-rep }
    } value-numbering-step
] unit-test

: test-branch-folding ( insns -- insns' n )
    <basic-block>
    [ V{ 0 1 } clone >>successors basic-block set value-numbering-step ] keep
    successors>> first ;

[
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##branch }
    }
    1
] [
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##compare-branch f 1 2 cc= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##compare-branch f 1 2 cc/= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##compare-branch f 1 2 cc< }
    } test-branch-folding
] unit-test

[
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##branch }
    }
    1
] [
    {
        T{ ##load-immediate f 1 1 }
        T{ ##load-immediate f 2 2 }
        T{ ##compare-branch f 2 1 cc< }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##branch }
    }
    1
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##compare-branch f 0 0 cc< }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##compare-branch f 0 0 cc<= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##branch }
    }
    1
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##compare-branch f 0 0 cc> }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##compare-branch f 0 0 cc>= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##compare-branch f 0 0 cc= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##branch }
    }
    1
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##compare-branch f 0 0 cc/= }
    } test-branch-folding
] unit-test

[
    {
        T{ ##peek f 0 D 0 }
        T{ ##load-constant f 1 t }
        T{ ##branch }
    }
    0
] [
    {
        T{ ##peek f 0 D 0 }
        T{ ##compare f 1 0 0 cc<= }
        T{ ##compare-imm-branch f 1 5 cc/= }
    } test-branch-folding
] unit-test

! More branch folding tests
V{ T{ ##branch } } 0 test-bb

V{
    T{ ##peek f 0 D 0 }
    T{ ##compare-branch f 0 0 cc< }
} 1 test-bb

V{
    T{ ##load-immediate f 1 1 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##load-immediate f 2 2 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##phi f 3 H{ { 2 1 } { 3 2 } } }
    T{ ##replace f 3 D 0 }
    T{ ##return }
} 4 test-bb

test-diamond

[ ] [
    cfg new 0 get >>entry dup cfg set
    value-numbering
    select-representations
    destruct-ssa drop
] unit-test

[ 1 ] [ 1 get successors>> length ] unit-test

[ t ] [ 1 get successors>> first 3 get eq? ] unit-test

[ 2 ] [ 4 get instructions>> length ] unit-test

V{
    T{ ##peek f 0 D 0 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 1 D 1 }
    T{ ##compare-branch f 1 1 cc< }
} 1 test-bb

V{
    T{ ##copy f 2 0 any-rep }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##phi f 3 V{ } }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace f 3 D 0 }
    T{ ##return }
} 4 test-bb

1 get 1 2array
2 get 0 2array 2array 3 get instructions>> first (>>inputs)

test-diamond

[ ] [
    cfg new 0 get >>entry
    value-numbering
    eliminate-dead-code
    drop
] unit-test

[ t ] [ 1 get successors>> first 3 get eq? ] unit-test

[ 1 ] [ 3 get instructions>> first inputs>> assoc-size ] unit-test

V{ T{ ##prologue } T{ ##branch } } 0 test-bb

V{
    T{ ##peek { dst 15 } { loc D 0 } }
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
        { src2 5 }
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
    T{ ##replace { src 25 } { loc D 0 } }
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
    T{ ##replace { src 28 } { loc D 0 } }
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

