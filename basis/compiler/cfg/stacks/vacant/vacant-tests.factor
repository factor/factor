USING: accessors arrays assocs compiler.cfg
compiler.cfg.dataflow-analysis.private compiler.cfg.instructions
compiler.cfg.linearization compiler.cfg.registers
compiler.cfg.utilities compiler.cfg.stacks.vacant kernel math sequences sorting
tools.test vectors ;
IN: compiler.cfg.stacks.vacant.tests

! Utils
: output-stack-map ( cfg -- map )
    vacant-analysis run-dataflow-analysis
    nip [ [ number>> ] dip ] assoc-map >alist natural-sort last second ;

! Initially both the d and r stacks are empty.
{
    { { 0 { } } { 0 { } } }
} [ V{ } insns>cfg output-stack-map ] unit-test

! Raise d stack.
{
    { { 1 { } } { 0 { } } }
} [ V{ T{ ##inc-d f 1 } } insns>cfg output-stack-map ] unit-test

! Raise r stack.
{
    { { 0 { } } { 1 { } } }
} [ V{ T{ ##inc-r f 1 } } insns>cfg output-stack-map ] unit-test

! Uninitialized peeks
[
    V{
        T{ ##inc-d f 1 }
        T{ ##peek { dst 0 } { loc D 0 } }
    } insns>cfg
    compute-vacant-sets
] [ vacant-peek? ] must-fail-with

[
    V{
        T{ ##inc-r f 1 }
        T{ ##peek { dst 0 } { loc R 0 } }
    } insns>cfg
    compute-vacant-sets
] [ vacant-peek? ] must-fail-with


! Here the peek refers to a parameter of the word.
[ ] [
    V{
        T{ ##peek { dst 0 } { loc D 0 } }
    } insns>cfg
    compute-vacant-sets
] unit-test

! Replace -1 then peek is ok.
[ ] [
    V{
        T{ ##replace { src 10 } { loc D -1 } }
        T{ ##peek { dst 0 } { loc D -1 } }
    } insns>cfg
    compute-vacant-sets
] unit-test

! Replace -1, then gc. Peek is ok here because the -1 should be
! checked.
{ { 0 } } [
    V{
        T{ ##replace { src 10 } { loc D -1 } }
        T{ ##alien-invoke { gc-map T{ gc-map { scrub-d { } } } } }
        T{ ##peek { dst 0 } { loc D -1 } }
    }
    [ insns>cfg compute-vacant-sets ]
    [ second gc-map>> check-d>> ] bi
] unit-test

! Should be ok because the value was at 0 when the gc ran.
{ { -1 { -1 } } } [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##alien-invoke { gc-map T{ gc-map { scrub-d { } } } } }
        T{ ##inc-d f -1 }
        T{ ##peek { dst 0 } { loc D -1 } }
    } insns>cfg output-stack-map first
] unit-test

! Should not be ok because the value wasn't initialized when gc ran.
[
    V{
        T{ ##inc-d f 1 }
        T{ ##alien-invoke { gc-map T{ gc-map { scrub-d { } } } } }
        T{ ##peek { dst 0 } { loc D 0 } }
    } insns>cfg
    compute-vacant-sets
] [ vacant-peek? ] must-fail-with

! visit-insn should set the gc info.
{ { 0 0 } { } } [
    { { 2 { } } { 0 { } } }
    T{ ##alien-invoke { gc-map T{ gc-map } } }
    [ visit-insn drop ] keep gc-map>> [ scrub-d>> ] [ scrub-r>> ] bi
] unit-test

{
    { { 0 { } } { 0 { } } }
} [
    V{ T{ ##safepoint } T{ ##prologue } T{ ##branch } }
    insns>cfg output-stack-map
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
    { 0 { 0 -1 } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f 1 }
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f -1 }
    } insns>cfg output-stack-map first
] unit-test

{
    { 0 { -1 } }
} [
    V{
        T{ ##inc-d f 1 }
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f -1 }
    } insns>cfg output-stack-map first
] unit-test

{
    { { { } { 0 0 0 } } { { } { 0 } } }
} [
    { { 4 { 3 2 1 -3 0 -2 -1 } } { 0 { -1 } } } state>gc-data
] unit-test

! ##call clears the overinitialized slots.
{
    { -1 { } }
} [
    V{
        T{ ##replace { src 10 } { loc D 0 } }
        T{ ##inc-d f -1 }
        T{ ##call }
    } insns>cfg output-stack-map first
] unit-test

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

{ { 0 { -1 } } } [ cfg1 output-stack-map first ] unit-test

: connect-bbs ( from to -- )
    [ [ successors>> ] dip suffix! drop ]
    [ predecessors>> swap suffix! drop ] 2bi ;

: make-edges ( block-map edgelist -- )
    [ [ of ] with map first2 connect-bbs ] with each ;

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
    } [ over  insns>block ] assoc-map dup
    { { 0 1 } { 1 2 } { 2 3 } { 3 8 } { 8 10 } } make-edges 0 of block>cfg ;

{ { 4 { 3 2 1 -3 0 -2 -1 } } } [
    bug1021-cfg output-stack-map first
] unit-test
