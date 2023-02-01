USING: accessors arrays assocs compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stacks.padding compiler.cfg.utilities compiler.test kernel
sequences sorting vectors tools.test ;
IN: compiler.cfg.stacks.padding.tests

! classify-read: initialized locations
{ 0 0 0 } [
    { 3 { } } 2 classify-read
    ! Negative locations aren't tracked really.
    { 0 { } } -1 classify-read
    { 3 { } } -1 classify-read
] unit-test

! classify-read: over locations
{ 1 1 1 1 1 } [
    { 1 { 0 } } 1 classify-read
    { 0 { } } 0 classify-read
    { 3 { } } 4 classify-read
    { 0 { } } 4 classify-read
    { 1 { 0 } } 4 classify-read
] unit-test

! classify-read: vacant locations
{ 2 2 2 } [
    { 1 { 0 } } 0 classify-read
    { 2 { 0 1 2 } } 0 classify-read
    { 0 { 0 1 2 } } 0 classify-read
] unit-test

! all-live
{
    { { 0 { } } { 2 { } } }
    { { 0 { } } { 2 { } } }
} [
    { { 0 { } } { 2 { } } } all-live
    { { 0 { } } { 2 { 0 } } } all-live
] unit-test

! combine-states
{
    { { 4 { } } { 2 { 0 1 } } }
} [
    V{ { { 4 { } } { 2 { 0 1 } } } } combine-states
] unit-test

{
    { { 2 { 0 1 } } { 2 { 0 1 } } }
} [
    V{
        { { 2 { 0 1 } } { 2 { } } }
        { { 2 { } } { 2 { 0 1 } } }
    } combine-states
] unit-test

{
    { { 0 { } } { 0 { } } }
} [
    V{ } combine-states
] unit-test

! visit-insn ##inc

! We assume that overinitialized locations are always dead.
{
    { { 0 { } } { 0 { } } }
} [
    { { 3 { 0 } } { 0 { } } } T{ ##inc { loc D: -3 } } visit-insn
] unit-test

{
    { { 3 { 0 1 2 } } { 0 { } } }
} [
    { { 0 { } } { 0 { } } } T{ ##inc { loc D: 3 } } visit-insn
] unit-test

! visit-insn ##call
{
    { { 0 { } } { 0 { } } }
} [
    initial-state T{ ##call } visit-insn
] unit-test

! if any of the stack locations are uninitialized when ##call is
! visisted then something is wrong. ##call might gc and the
! uninitialized locations would cause a crash.
[
    { { 3 { 0 1 2 } } { 0 { } } } T{ ##call } visit-insn
] [ vacant-when-calling? ] must-fail-with

! visit-insn ##call-gc

! ##call-gc ofcourse fills all uninitialized locations. ##peek still
! shouldn't look at them, but if we gc again we don't need to exept ##them.
{
    { { 4 { } } { 0 { } } }
} [
    { { 4 { 0 1 2 3 } } { 0 { } } } T{ ##call-gc } visit-insn
] unit-test

! visit-insn ##peek
{
    { { 3 { 0 } } { 0 { } } }
} [
    { { 3 { 0 } } { 0 { } } } T{ ##peek { dst 1 } { loc D: 1 } } visit-insn
] unit-test

! After a ##peek that can cause a stack underflow, it is certain that
! all stack locations are initialized.
{
    { { 0 { } } { 2 { } } }
    { { 2 { } } { 0 { } } }
} [
    { { 0 { } } { 2 { 0 1 } } } T{ ##peek { dst 1 } { loc R: 2 } } visit-insn
    { { 2 { 0 1 } } { 0 { } } } T{ ##peek { dst 1 } { loc D: 2 } } visit-insn
] unit-test

! If the ##peek can't cause a stack underflow, then we don't have the
! same guarantees.
[
    { { 3 { 0 1 2 } } { 0 { } } } T{ ##peek { dst 1 } { loc D: 0 } } visit-insn
] [ vacant-peek? ] must-fail-with

: following-stack-state ( insns -- state )
    T{ ##branch } suffix insns>cfg trace-stack-state
    >alist [ first ] sort-by last second ;

! trace-stack-state
{
    H{
        {
            0
            { { 0 { } } { 0 { } } }
        }
        {
            1
            { { 2 { 0 1 } } { 0 { } } }
        }
        {
            2
            { { 2 { } } { 0 { } } }
        }
    }
} [
    {
        T{ ##inc f D: 2 }
        T{ ##peek f f D: 2 }
        T{ ##inc f D: 0 }
    } insns>cfg trace-stack-state
] unit-test

{
    H{
        { 0 { { 0 { } } { 0 { } } } }
        { 1 { { 0 { } } { 0 { } } } }
        { 2 { { 0 { } } { 0 { } } } }
    }
} [
    V{ T{ ##safepoint } T{ ##prologue } T{ ##branch } }
    insns>cfg trace-stack-state
] unit-test

! The peek "causes" the vacant locations to become populated.
{
    H{
        { 0 { { 0 { } } { 0 { } } } }
        { 1 { { 3 { 0 1 2 } } { 0 { } } } }
        { 2 { { 3 { } } { 0 { } } } }
    }
} [
    V{
        T{ ##inc f D: 3 }
        T{ ##peek { loc D: 3 } }
        T{ ##branch }
    }
    insns>cfg trace-stack-state
] unit-test

: cfg1 ( -- cfg )
    V{
        T{ ##inc f D: 1 }
        T{ ##replace { src 10 } { loc D: 0 } }
    } 0 insns>block
    V{
        T{ ##peek { dst 37 } { loc D: 0 } }
        T{ ##inc f D: -1 }
    } 1 insns>block
    1vector >>successors block>cfg ;

{
    H{
        { 0 { { 0 { } } { 0 { } } } }
        { 1 { { 1 { 0 } } { 0 { } } } }
        { 2 { { 1 { } } { 0 { } } } }
        { 3 { { 1 { } } { 0 { } } } }
    }
} [ cfg1 trace-stack-state ] unit-test

! Same cfg structure as the bug1021:run-test word but with
! non-datastack instructions mostly omitted.
: bug1021-cfg ( -- cfg )
    {
        { 0 V{ T{ ##safepoint } T{ ##prologue } T{ ##branch } } }
        {
            1 V{
                T{ ##inc f D: 2 }
                T{ ##replace { src 0 } { loc D: 1 } }
                T{ ##replace { src 0 } { loc D: 0 } }
            }
        }
        {
            2 V{
                T{ ##call { word <array> } }
            }
        }
        {
            3 V{
                T{ ##peek { dst 0 } { loc D: 0 } }
                T{ ##peek { dst 0 } { loc D: 1 } }
                T{ ##inc f D: 2 }
                T{ ##replace { src 0 } { loc D: 2 } }
                T{ ##replace { src 0 } { loc D: 3 } }
                T{ ##replace { src 0 } { loc D: 1 } }
            }
        }
        {
            8 V{
                T{ ##peek { dst 0 } { loc D: 2 } }
                T{ ##peek { dst 0 } { loc D: 1 } }
                T{ ##inc f D: 3 }
                T{ ##replace { src 0 } { loc D: 0 } }
                T{ ##replace { src 0 } { loc D: 1 } }
                T{ ##replace { src 0 } { loc D: 2 } }
                T{ ##replace { src 0 } { loc D: 3 } }
            }
        }
        {
            10 V{
                T{ ##inc f D: -3 }
                T{ ##peek { dst 0 } { loc D: 0 } }
                T{ ##alien-invoke { gc-map T{ gc-map } } }
            }
        }
    } [ over insns>block ] assoc-map dup
    { { 0 1 } { 1 2 } { 2 3 } { 3 8 } { 8 10 } } make-edges 0 of block>cfg ;

{
    H{
        { 0 { { 0 { } } { 0 { } } } }
        { 1 { { 0 { } } { 0 { } } } }
        { 2 { { 0 { } } { 0 { } } } }
        { 3 { { 0 { } } { 0 { } } } }
        { 4 { { 2 { 0 1 } } { 0 { } } } }
        { 5 { { 2 { 0 } } { 0 { } } } }
        { 6 { { 2 { } } { 0 { } } } }
        { 7 { { 2 { } } { 0 { } } } }
        { 8 { { 2 { } } { 0 { } } } }
        { 9 { { 2 { } } { 0 { } } } }
        { 10 { { 4 { 0 1 } } { 0 { } } } }
        { 11 { { 4 { 0 1 } } { 0 { } } } }
        { 12 { { 4 { 0 1 } } { 0 { } } } }
        { 13 { { 4 { 0 } } { 0 { } } } }
        { 14 { { 4 { 0 } } { 0 { } } } }
        { 15 { { 4 { 0 } } { 0 { } } } }
        { 16 { { 7 { 3 0 1 2 } } { 0 { } } } }
        { 17 { { 7 { 3 1 2 } } { 0 { } } } }
        { 18 { { 7 { 3 2 } } { 0 { } } } }
        { 19 { { 7 { 3 } } { 0 { } } } }
        { 20 { { 7 { } } { 0 { } } } }
        { 21 { { 4 { } } { 0 { } } } }
        ! gc-map here with nothing to scrub
        { 22 { { 4 { } } { 0 { } } } }
    }
} [
    bug1021-cfg trace-stack-state
] unit-test

! Same cfg structure as the bug1289:run-test word but with
! non-datastack instructions mostly omitted.
: bug1289-cfg ( -- cfg )
    {
        { 0 V{ } }
        {
            1 V{
                T{ ##inc f D: 3 }
                T{ ##replace { src 0 } { loc D: 2 } }
                T{ ##replace { src 0 } { loc D: 0 } }
                T{ ##replace { src 0 } { loc D: 1 } }
            }
        }
        {
            2 V{
                T{ ##call { word <array> } }
            }
        }
        {
            3 V{
                T{ ##peek { dst 0 } { loc D: 1 } }
                T{ ##peek { dst 0 } { loc D: 0 } }
                T{ ##inc f D: 1 }
                T{ ##inc f R: 1 }
                T{ ##replace { src 0 } { loc R: 0 } }
            }
        }
        {
            4 V{ }
        }
        {
            5 V{
                T{ ##inc f D: -2 }
                T{ ##inc f R: 5 }
                T{ ##replace { src 0 } { loc R: 3 } }
                T{ ##replace { src 0 } { loc D: 0 } }
                T{ ##replace { src 0 } { loc R: 4 } }
                T{ ##replace { src 0 } { loc R: 2 } }
                T{ ##replace { src 0 } { loc R: 1 } }
                T{ ##replace { src 0 } { loc R: 0 } }
            }
        }
        {
            6 V{
                T{ ##call { word f } }
            }
        }
        {
            7 V{
                T{ ##peek { dst 0 } { loc D: 0 } }
                T{ ##peek { dst 0 } { loc R: 3 } }
                T{ ##peek { dst 0 } { loc R: 2 } }
                T{ ##peek { dst 0 } { loc R: 1 } }
                T{ ##peek { dst 0 } { loc R: 0 } }
                T{ ##peek { dst 0 } { loc R: 4 } }
                T{ ##inc f D: 2 }
                T{ ##inc f R: -5 }
            }
        }
        { 8 V{ } }
        { 9 V{ } }
        { 10 V{ } }
        {
            11 V{
                T{ ##call-gc }
            }
        }
        {
            12 V{
                T{ ##peek { dst 0 } { loc R: 0 } }
                T{ ##inc f D: -3 }
                T{ ##inc f D: 1 }
                T{ ##inc f R: -1 }
                T{ ##replace { src 0 } { loc D: 0 } }
            }
        }
        {
            13 V{ }
        }
    } [ over insns>block ] assoc-map dup
    {
        { 0 1 }
        { 1 2 }
        { 2 3 }
        { 3 4 }
        { 4 9 }
        { 5 6 }
        { 6 7 }
        { 7 8 }
        { 8 9 }
        { 9 5 }
        { 9 10 }
        { 10 12 }
        { 10 11 }
        { 11 12 }
        { 12 13 }
    } make-edges 0 of block>cfg ;

{
    H{
        { 0 { { 0 { } } { 0 { } } } }
        { 1 { { 3 { 0 1 2 } } { 0 { } } } }
        { 2 { { 3 { 0 1 } } { 0 { } } } }
        { 3 { { 3 { 1 } } { 0 { } } } }
        { 4 { { 3 { } } { 0 { } } } }
        { 5 { { 3 { } } { 0 { } } } }
        { 6 { { 3 { } } { 0 { } } } }
        { 7 { { 3 { } } { 0 { } } } }
        { 8 { { 4 { 0 } } { 0 { } } } }
        { 9 { { 4 { 0 } } { 1 { 0 } } } }
        { 10 { { 4 { 0 1 } } { 1 { } } } }
        { 11 { { 2 { } } { 1 { } } } }
        { 12 { { 2 { } } { 6 { 0 1 2 3 4 } } } }
        { 13 { { 2 { } } { 6 { 0 1 2 4 } } } }
        { 14 { { 2 { } } { 6 { 0 1 2 4 } } } }
        { 15 { { 2 { } } { 6 { 0 1 2 } } } }
        { 16 { { 2 { } } { 6 { 0 1 } } } }
        { 17 { { 2 { } } { 6 { 0 } } } }
        { 18 { { 2 { } } { 6 { } } } }
        { 19 { { 2 { } } { 6 { } } } }
        { 20 { { 2 { } } { 6 { } } } }
        { 21 { { 2 { } } { 6 { } } } }
        { 22 { { 2 { } } { 6 { } } } }
        { 23 { { 2 { } } { 6 { } } } }
        { 24 { { 2 { } } { 6 { } } } }
        { 25 { { 2 { } } { 6 { } } } }
        { 26 { { 4 { 0 1 } } { 6 { } } } }
        { 27 { { 4 { 0 1 } } { 1 { } } } }
        ! gc-map here scrubbing D: 0 and D: 1
        { 28 { { 4 { 0 1 } } { 1 { } } } }
        { 29 { { 4 { 0 1 } } { 1 { } } } }
        { 30 { { 1 { } } { 1 { } } } }
        { 31 { { 2 { 0 } } { 1 { } } } }
        { 32 { { 2 { 0 } } { 0 { } } } }
    }
} [ bug1289-cfg trace-stack-state ] unit-test

: bug-benchmark-terrain-cfg ( -- cfg )
    H{
        { 0 V{ } }
        {
            1 V{
                T{ ##peek { loc D: 0 } }
                T{ ##peek { loc D: 1 } }
                T{ ##inc { loc D: -1 } }
            }
        }
        {
            2 V{
                T{ ##inc { loc D: -1 } }
                T{ ##replace { loc D: 1 } }
                T{ ##replace { loc D: 0 } }
                T{ ##inc { loc D: 1 } }
                T{ ##replace { loc D: 0 } }
            }
        }
        { 3 V{ T{ ##call } } }
        { 4 V{ } }
        { 5 V{ T{ ##call } } }
        { 6 V{ T{ ##peek { loc D: 0 } } } }
        { 7 V{ } }
        {
            8 V{
                T{ ##replace { loc D: 2 } }
                T{ ##replace { loc D: 1 } }
                T{ ##replace { loc D: 0 } }
            }
        }
        { 9 V{ T{ ##call } } }
        {
            10 V{
                T{ ##inc { loc D: 1 } }
                T{ ##replace { loc D: 0 } }
            }
        }
        { 11 V{ T{ ##call } } }
        { 12 V{ } }
        { 13 V{ T{ ##call } } }
        { 14 V{ T{ ##peek { loc D: 0 } } } }
        { 15 V{ } }
        {
            16 V{
                T{ ##inc { loc D: 1 } }
                T{ ##replace { loc D: 0 } }
            }
        }
        { 17 V{ T{ ##call } } }
        {
            18 V{
                T{ ##peek { loc D: 2 } }
                T{ ##peek { loc D: 1 } }
                T{ ##peek { loc D: 0 } }
                T{ ##inc { loc D: 1 } }
            }
        }
        { 19 V{ } }
        { 20 V{ } }
        {
            21 V{
                T{ ##inc { loc D: -3 } }
                T{ ##replace { loc D: 0 } }
            }
        }
        { 22 V{ T{ ##call } } }
        { 23 V{ } }
        { 24 V{ T{ ##call } } }
        {
            25 V{
                T{ ##peek { loc D: 0 } }
                T{ ##inc { loc D: 3 } }
            }
        }
        { 26 V{ } }
        { 27 V{ } }
        { 28 V{ } }
        { 29 V{ } }
        { 30 V{ T{ ##call-gc } } }
        { 31 V{ } }
        {
            32 V{
                T{ ##inc { loc D: -4 } }
                T{ ##inc { loc D: 1 } }
                T{ ##replace { loc D: 0 } }
            }
        }
        { 33 V{ } }
    } [ over insns>block ] assoc-map dup
    {
        { 0 1 }
        { 1 2 } { 1 8 }
        { 2 3 }
        { 3 4 }
        { 4 5 }
        { 5 6 }
        { 7 16 }
        { 8 9 }
        { 9 10 }
        { 10 11 }
        { 11 12 }
        { 12 13 }
        { 13 14 }
        { 14 15 }
        { 15 16 }
        { 16 17 }
        { 17 18 }
        { 18 19 }
        { 19 20 }
        { 20 27 }
        { 21 22 }
        { 22 23 }
        { 23 24 }
        { 24 25 }
        { 25 26 }
        { 26 27 }
        { 27 28 } { 27 32 }
        { 28 29 } { 28 30 }
        { 29 21 }
        { 20 31 }
        { 31 21 }
        { 32 33 }
    } make-edges 0 of block>cfg ;

{
    H{
        { 0 { { 0 { } } { 0 { } } } }
        { 1 { { 0 { } } { 0 { } } } }
        { 2 { { 0 { } } { 0 { } } } }
        { 3 { { -1 { } } { 0 { } } } }
        { 4 { { -1 { } } { 0 { } } } }
        { 5 { { -1 { } } { 0 { } } } }
        { 6 { { -1 { } } { 0 { } } } }
        { 7 { { -1 { } } { 0 { } } } }
        { 8 { { 0 { 0 } } { 0 { } } } }
        { 9 { { 0 { } } { 0 { } } } }
        { 10 { { 0 { } } { 0 { } } } }
        { 11 { { 0 { } } { 0 { } } } }
        { 12 { { 0 { } } { 0 { } } } }
        { 13 { { 1 { 0 } } { 0 { } } } }
        { 14 { { 1 { } } { 0 { } } } }
        { 15 { { 1 { } } { 0 { } } } }
        { 16 { { 1 { } } { 0 { } } } }
        { 17 { { 1 { } } { 0 { } } } }
        { 18 { { 1 { } } { 0 { } } } }
        { 19 { { 2 { 0 1 2 } } { 0 { } } } }
        { 20 { { -1 { } } { 0 { } } } }
        { 21 { { -1 { } } { 0 { } } } }
        { 22 { { -1 { } } { 0 { } } } }
        { 23 { { -1 { } } { 0 { } } } }
        { 24 { { -1 { } } { 0 { } } } }
        ! gc-map here scrubbing D: 0, D: 1 and D: 2
        { 25 { { 2 { 0 1 2 } } { 0 { } } } }
        { 26 { { 2 { 0 1 2 } } { 0 { } } } }
        { 27 { { -2 { } } { 0 { } } } }
        { 28 { { -1 { 0 } } { 0 { } } } }
        { 29 { { -1 { } } { 0 { } } } }
        { 30 { { -2 { } } { 0 { } } } }
        { 31 { { -2 { } } { 0 { } } } }
        { 32 { { -2 { } } { 0 { } } } }
        { 33 { { -1 { 0 } } { 0 { } } } }
        { 34 { { -1 { } } { 0 { } } } }
        { 35 { { -1 { } } { 0 { } } } }
        { 36 { { -1 { } } { 0 { } } } }
    }
} [
    bug-benchmark-terrain-cfg trace-stack-state
] unit-test


! following-stack-state
{
    { { 0 { } } { 0 { } } }
} [ V{ } following-stack-state ] unit-test

{
    { { 1 { 0 } } { 0 { } } }
} [ V{ T{ ##inc f D: 1 } } following-stack-state ] unit-test

{
    { { 0 { } } { 1 { 0 } } }
} [ V{ T{ ##inc f R: 1 } } following-stack-state ] unit-test

! Here the peek refers to a parameter of the word.
{
    { { 0 { } } { 0 { } } }
} [
    V{
        T{ ##peek { loc D: 25 } }
    } following-stack-state
] unit-test

{
    { { 0 { } } { 0 { } } }
} [
    V{
        T{ ##replace { src 10 } { loc D: 0 } }
        T{ ##replace { src 10 } { loc D: 1 } }
        T{ ##replace { src 10 } { loc D: 2 } }
    } following-stack-state
] unit-test

{
    { { 1 { } } { 0 { } } }
} [
    V{
        T{ ##replace { src 10 } { loc D: 0 } }
        T{ ##inc f D: 1 }
        T{ ##replace { src 10 } { loc D: 0 } }
    } following-stack-state
] unit-test

{
    { { 0 { } } { 0 { } } }
} [
    V{
        T{ ##replace { src 10 } { loc D: 0 } }
        T{ ##inc f D: 1 }
        T{ ##replace { src 10 } { loc D: 0 } }
        T{ ##inc f D: -1 }
    } following-stack-state
] unit-test

{
    { { 0 { } } { 0 { } } }
} [
    V{
        T{ ##inc f D: 1 }
        T{ ##replace { src 10 } { loc D: 0 } }
        T{ ##inc f D: -1 }
    } following-stack-state
] unit-test

! ##call clears the overinitialized slots.
{
    { { -1 { } } { 0 { } } }
} [
    V{
        T{ ##replace { src 10 } { loc D: 0 } }
        T{ ##inc f D: -1 }
        T{ ##call }
    } following-stack-state
] unit-test

! Should not be ok because the value wasn't initialized when gc ran.
[
    V{
        T{ ##inc f D: 1 }
        T{ ##alien-invoke { gc-map T{ gc-map } } }
        T{ ##peek { loc D: 0 } }
    } following-stack-state
] [ vacant-peek? ] must-fail-with

[
    V{
        T{ ##inc f D: 1 }
        T{ ##peek { loc D: 0 } }
    } following-stack-state
] [ vacant-peek? ] must-fail-with

[
    V{
        T{ ##inc f R: 1 }
        T{ ##peek { loc R: 0 } }
    } following-stack-state
] [ vacant-peek? ] must-fail-with
