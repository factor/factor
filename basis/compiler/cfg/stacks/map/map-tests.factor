USING: accessors arrays assocs compiler.cfg
compiler.cfg.dataflow-analysis.private compiler.cfg.instructions
compiler.cfg.linearization compiler.cfg.registers
compiler.cfg.utilities compiler.cfg.stacks.map kernel math namespaces
sequences sorting tools.test vectors ;
IN: compiler.cfg.stacks.map.tests

! classify-read: vacant locations
{ 2 2 2 } [
    { 3 { } } 2 classify-read
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

! classify-read: initialized locations
{ 0 0 0 } [
    { 1 { 0 } } 0 classify-read
    { 2 { 0 1 2 } } 0 classify-read
    { 0 { 0 1 2 } } 0 classify-read
] unit-test

! fill-vacancies
{
    { { 0 { } } { 2 { 0 1 } } }
    { { 0 { } } { 2 { 0 1 } } }
    { { 0 { -1 -2 } } { 2 { 0 1 } } }
} [
    { { 0 { } } { 2 { } } } fill-vacancies
    { { 0 { } } { 2 { 0 } } } fill-vacancies
    { { 0 { -1 -2 } } { 2 { 0 } } } fill-vacancies
] unit-test

! visit-insn

! After a ##peek that can cause a stack underflow, it is certain that
! all stack locations are initialized.
{
    { { 2 { 0 1 2 } } { 0 { } } }
} [
    { { 2 { } } { 0 { } } } T{ ##peek f f D 2 } visit-insn
] unit-test

! If the ##peek can't cause a stack underflow, then we don't have the
! same guarantees.
[
    { { 2 { } } { 0 { } } } T{ ##peek f f D 0 } visit-insn
] [ vacant-peek? ] must-fail-with

! verboten peek
[
    { { 1 { } } { 0 { } } } T{ ##peek { loc D 0 } } visit-insn
] [ vacant-peek? ] must-fail-with


! trace-stack-state
{
    H{
        {
            T{ ##inc-d { n 2 } }
            { { 0 { } } { 0 { } } }
        }
        {
            T{ ##peek { loc D 2 } }
            { { 2 { } } { 0 { } } }
        }
        {
            T{ ##inc-d { n 0 } }
            { { 2 { 0 1 2 } } { 0 { } } }
        }
    }
} [
    {
        T{ ##inc-d f 2 }
        T{ ##peek f f D 2 }
        T{ ##inc-d f 0 }
    } insns>cfg trace-stack-state
] unit-test

! Runs the analysis and check what the resulting stack map becomes.

: output-stack-map ( cfg -- map )
    H{ } clone stack-record set
    map-analysis run-dataflow-analysis
    nip [ [ number>> ] dip ] assoc-map >alist natural-sort last second ;

! Initially both the d and r stacks are empty.
{
    { { 0 { } } { 0 { } } }
} [ V{ } insns>cfg output-stack-map ] unit-test

{
    { { 0 { } } { 0 { } } }
} [
    V{ T{ ##safepoint } T{ ##prologue } T{ ##branch } }
    insns>cfg output-stack-map
] unit-test

{
    { { 1 { } } { 0 { } } }
} [ V{ T{ ##inc-d f 1 } } insns>cfg output-stack-map ] unit-test

{
    { { 0 { } } { 1 { } } }
} [ V{ T{ ##inc-r f 1 } } insns>cfg output-stack-map ] unit-test

! Here the peek refers to a parameter of the word.
{
    { { 0 { 25 } } { 0 { } } }
} [
    V{
        T{ ##peek { loc D 25 } }
    } insns>cfg output-stack-map
] unit-test

! The peek "causes" the vacant locations to become populated.
{
    { { 3 { 0 1 2 3 } } { 0 { } } }
} [
    V{
        T{ ##inc-d f 3 }
        T{ ##peek { loc D 3 } }
    } insns>cfg output-stack-map
] unit-test

! Replace -1 then peek is ok.
{
    { { 0 { -1 } } { 0 { } } }
} [
    V{
        T{ ##replace { src 10 } { loc D -1 } }
        T{ ##peek { loc D -1 } }
    } insns>cfg output-stack-map
] unit-test

! Should be ok because the value was at 0 when the gc ran.
{
    { { -1 { -1 } } { 0 { } } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##alien-invoke { gc-map T{ gc-map { scrub-d { } } } } }
        T{ ##inc-d f -1 }
        T{ ##peek { loc D -1 } }
    } insns>cfg output-stack-map
] unit-test

{
    { { 0 { 0 1 2 } } { 0 { } } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##replace { src 10 } { loc D 1 } }
        T{ ##replace { src 10 } { loc D 2 } }
    } insns>cfg output-stack-map
] unit-test

{
    { { 1 { 1 0 } } { 0 { } } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f 1 }
        T{ ##replace { src 10 } { loc D 0 } }
    } insns>cfg output-stack-map
] unit-test

{
    { { 0 { 0 -1 } } { 0 { } } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f 1 }
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f -1 }
    } insns>cfg output-stack-map
] unit-test

{
    { { 0 { -1 } } { 0 { } } }
} [
    V{
        T{ ##inc-d f 1 }
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f -1 }
    } insns>cfg output-stack-map
] unit-test

! ##call clears the overinitialized slots.
{
    { { -1 { } } { 0 { } } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f -1 }
        T{ ##call }
    } insns>cfg output-stack-map
] unit-test

! Should not be ok because the value wasn't initialized when gc ran.
[
    V{
        T{ ##inc-d f 1 }
        T{ ##alien-invoke { gc-map T{ gc-map { scrub-d { } } } } }
        T{ ##peek { loc D 0 } }
    } insns>cfg output-stack-map
] [ vacant-peek? ] must-fail-with

[
    V{
        T{ ##inc-d f 1 }
        T{ ##peek { loc D 0 } }
    } insns>cfg output-stack-map
] [ vacant-peek? ] must-fail-with

[
    V{
        T{ ##inc-r f 1 }
        T{ ##peek { loc R 0 } }
    } insns>cfg output-stack-map
] [ vacant-peek? ] must-fail-with

: cfg1 ( -- cfg )
    V{
        T{ ##inc-d f 1 }
        T{ ##replace { src 10 } { loc D 0 } }
    } 0 insns>block
    V{
        T{ ##peek { dst 37 } { loc D 0 } }
        T{ ##inc-d f -1 }
    } 1 insns>block
    1vector >>successors block>cfg ;

{
    { { 0 { -1 } } { 0 { } } }
} [ cfg1 output-stack-map ] unit-test

! Same cfg structure as the bug1021:run-test word but with
! non-datastack instructions mostly omitted.
: bug1021-cfg ( -- cfg )
    {
        { 0 V{ T{ ##safepoint } T{ ##prologue } T{ ##branch } } }
        {
            1 V{
                T{ ##inc-d f 2 }
                T{ ##replace { src 0 } { loc D 1 } }
                T{ ##replace { src 0 } { loc D 0 } }
            }
        }
        {
            2 V{
                T{ ##call { word <array> } }
            }
        }
        {
            3 V{
                T{ ##inc-d f 2 }
                T{ ##peek { dst 0 } { loc D 2 } }
                T{ ##peek { dst 0 } { loc D 3 } }
                T{ ##replace { src 0 } { loc D 2 } }
                T{ ##replace { src 0 } { loc D 3 } }
                T{ ##replace { src 0 } { loc D 1 } }
            }
        }
        {
            8 V{
                T{ ##inc-d f 3 }
                T{ ##peek { dst 0 } { loc D 5 } }
                T{ ##replace { src 0 } { loc D 0 } }
                T{ ##replace { src 0 } { loc D 3 } }
                T{ ##peek { dst 0 } { loc D 4 } }
                T{ ##replace { src 0 } { loc D 1 } }
                T{ ##replace { src 0 } { loc D 2 } }
            }
        }
        {
            10 V{
                T{ ##inc-d f -3 }
                T{ ##peek { dst 0 } { loc D -3 } }
                T{ ##alien-invoke { gc-map T{ gc-map { scrub-d { } } } } }
            }
        }
    } [ over insns>block ] assoc-map dup
    { { 0 1 } { 1 2 } { 2 3 } { 3 8 } { 8 10 } } make-edges 0 of block>cfg ;

{ { 4 { 3 2 1 -3 0 -2 -1 } } } [
    bug1021-cfg output-stack-map first
] unit-test
