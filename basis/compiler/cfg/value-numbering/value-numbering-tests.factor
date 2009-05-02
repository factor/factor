IN: compiler.cfg.value-numbering.tests
USING: compiler.cfg.value-numbering compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.debugger cpu.architecture
tools.test kernel math combinators.short-circuit accessors
sequences ;

: trim-temps ( insns -- insns )
    [
        dup {
            [ ##compare? ]
            [ ##compare-imm? ]
            [ ##compare-float? ]
        } 1|| [ f >>temp ] when
    ] map ;

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
    } value-numbering
] unit-test

[
    {
        T{ ##load-immediate f V int-regs 2 8 }
        T{ ##peek f V int-regs 3 D 0 }
        T{ ##slot-imm f V int-regs 4 V int-regs 3 1 3 }
        T{ ##replace f V int-regs 4 D 0 }
    }
] [
    {
        T{ ##load-immediate f V int-regs 2 8 }
        T{ ##peek f V int-regs 3 D 0 }
        T{ ##slot-imm f V int-regs 4 V int-regs 3 1 3 }
        T{ ##replace f V int-regs 4 D 0 }
    } value-numbering
] unit-test

[ t ] [
    {
        T{ ##peek f V int-regs 1 D 0 }
        T{ ##dispatch f V int-regs 1 V int-regs 2 0 }
    } dup value-numbering =
] unit-test

[ t ] [
    {
        T{ ##peek f V int-regs 16 D 0 }
        T{ ##peek f V int-regs 17 D -1 }
        T{ ##sar-imm f V int-regs 18 V int-regs 17 3 }
        T{ ##add-imm f V int-regs 19 V int-regs 16 13 }
        T{ ##add f V int-regs 21 V int-regs 18 V int-regs 19 }
        T{ ##alien-unsigned-1 f V int-regs 22 V int-regs 21 }
        T{ ##shl-imm f V int-regs 23 V int-regs 22 3 }
        T{ ##replace f V int-regs 23 D 0 }
    } dup value-numbering =
] unit-test

[
    {
        T{ ##peek f V int-regs 1 D 0 }
        T{ ##shl-imm f V int-regs 2 V int-regs 1 3 }
        T{ ##shr-imm f V int-regs 3 V int-regs 2 3 }
        T{ ##replace f V int-regs 1 D 0 }
    }
] [
    {
        T{ ##peek f V int-regs 1 D 0 }
        T{ ##mul-imm f V int-regs 2 V int-regs 1 8 }
        T{ ##shr-imm f V int-regs 3 V int-regs 2 3 }
        T{ ##replace f V int-regs 3 D 0 }
    } value-numbering
] unit-test

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
    } value-numbering trim-temps
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
    } value-numbering trim-temps
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
    } value-numbering trim-temps
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
    } value-numbering trim-temps
] unit-test
