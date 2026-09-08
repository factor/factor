USING: accessors arrays assocs compiler.cfg.copy-prop compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.utilities compiler.test
cpu.architecture kernel namespaces sequences tools.test ;
IN: compiler.cfg.copy-prop.tests

: test-copy-propagation ( -- )
    0 get block>cfg copy-propagation ;

! Simple example
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 0 D: 0 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##peek f 1 D: 1 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##copy f 2 0 any-rep }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##phi f 3 H{ { 2 0 } { 3 2 } } }
    T{ ##phi f 4 H{ { 2 1 } { 3 2 } } }
    T{ ##phi f 5 H{ { 2 1 } { 3 0 } } }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##copy f 6 4 any-rep }
    T{ ##replace f 3 D: 0 }
    T{ ##replace f 5 D: 1 }
    T{ ##replace f 6 D: 2 }
    T{ ##branch }
} 5 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 6 test-bb

0 1 edge
1 { 2 3 } edges
2 4 edge
3 4 edge
4 5 edge

{ } [ test-copy-propagation ] unit-test

{
    V{
        T{ ##replace f 0 D: 0 }
        T{ ##replace f 4 D: 1 }
        T{ ##replace f 4 D: 2 }
        T{ ##branch }
    }
} [ 5 get instructions>> ] unit-test

! Test optimistic assumption
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 0 D: 0 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##phi f 1 H{ { 1 0 } { 2 2 } } }
    T{ ##copy f 2 1 any-rep }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace f 2 D: 1 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 4 test-bb

0 1 edge
1 2 edge
2 { 2 3 } edges
3 4 edge

{ } [ test-copy-propagation ] unit-test

{
    V{
        T{ ##replace f 0 D: 1 }
        T{ ##branch }
    }
} [ 3 get instructions>> ] unit-test

! Association iteration order is not phi input order. These first two
! phis select different values; the third has the same mapping as the first.
{ 3 { 2 3 2 } } [
    V{ T{ ##peek { dst 0 } { loc D: 0 } }
       T{ ##peek { dst 1 } { loc D: 1 } } T{ ##branch } } 0 test-bb
    V{ T{ ##branch } } 1 test-bb
    V{ T{ ##branch } } 2 test-bb
    V{ T{ ##phi { dst 2 } { inputs { { 1 0 } { 2 1 } } } }
       T{ ##phi { dst 3 } { inputs { { 2 0 } { 1 1 } } } }
       T{ ##phi { dst 4 } { inputs { { 2 1 } { 1 0 } } } }
       T{ ##replace { src 2 } { loc D: 0 } }
       T{ ##replace { src 3 } { loc D: 1 } }
       T{ ##replace { src 4 } { loc D: 2 } }
       T{ ##branch } } 3 test-bb
    0 { 1 2 } edges 1 3 edge 2 3 edge
    test-copy-propagation
    3 get instructions>> [ [ ##phi? ] count ]
    [ [ ##replace? ] filter [ src>> ] map >array ] bi
] unit-test
