IN: multi-methods.tests
USING: multi-methods tools.test math sequences namespaces system
kernel strings ;

[ { POSTPONE: f integer } ] [ { f integer } canonicalize-specializer-0 ] unit-test

: setup-canon-test ( -- )
    0 args set
    V{ } clone hooks set ;

: canon-test-1 ( -- seq )
    { integer { cpu x86 } sequence } canonicalize-specializer-1 ;

[ { { -2 integer } { -1 sequence } { cpu x86 } } ] [
    [
        setup-canon-test
        canon-test-1
    ] with-scope
] unit-test

[ { { 0 integer } { 1 sequence } { 2 x86 } } ] [
    [
        setup-canon-test
        canon-test-1
        canonicalize-specializer-2
    ] with-scope
] unit-test

[ { integer sequence x86 } ] [
    [
        setup-canon-test
        canon-test-1
        canonicalize-specializer-2
        args get hooks get length + total set
        canonicalize-specializer-3
    ] with-scope
] unit-test

CONSTANT: example-1
    {
        { { { cpu x86 } { os linux } } "a" }
        { { { cpu ppc } } "b" }
        { { string { os windows } } "c" }
    }

[
    {
        { { object x86 linux } "a"  }
        { { object ppc object } "b" }
        { { string object windows } "c" }
    }
    { cpu os }
] [
    example-1 canonicalize-specializers
] unit-test

[
    {
        { { object x86 linux } [ drop drop "a" ] }
        { { object ppc object } [ drop drop "b" ] }
        { { string object windows } [ drop drop "c" ] }
    }
    [ \ cpu get \ os get ]
] [
    example-1 prepare-methods
] unit-test
