USE: vocabs.refresh
<< "compiler" refresh >>
USING: accessors arrays assocs combinators compiler.cfg.metrics
compiler.cfg.register-allocation compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.backtracking compiler.cfg.register-allocation.chordal
compiler.cfg.linear-scan.allocation.state compiler.test continuations generalizations
io json kernel kernel.private locals math math.private namespaces prettyprint sequences words ;
IN: compiler-allocator-pressure-comparison
:: pressure-kernel ( x -- value )
    x { float } declare :> y
    y 1.0 + :> a1
    y 2.0 + :> a2
    y 3.0 + :> a3
    y 4.0 + :> a4
    y 5.0 + :> a5
    y 6.0 + :> a6
    y 7.0 + :> a7
    y 8.0 + :> a8
    y 9.0 + :> a9
    y 10.0 + :> a10
    y 11.0 + :> a11
    y 12.0 + :> a12
    y 13.0 + :> a13
    y 14.0 + :> a14
    y 15.0 + :> a15
    y 16.0 + :> a16
    y 17.0 + :> a17
    y 18.0 + :> a18
    y 19.0 + :> a19
    y 20.0 + :> a20
    y 21.0 + :> a21
    y 22.0 + :> a22
    y 23.0 + :> a23
    y 24.0 + :> a24
    y 25.0 + :> a25
    y 26.0 + :> a26
    y 27.0 + :> a27
    y 28.0 + :> a28
    y 29.0 + :> a29
    y 30.0 + :> a30
    y 31.0 + :> a31
    y 32.0 + :> a32
    a1 a17 *
    a2 a18 * +
    a3 a19 * +
    a4 a20 * +
    a5 a21 * +
    a6 a22 * +
    a7 a23 * +
    a8 a24 * +
    a9 a25 * +
    a10 a26 * +
    a11 a27 * +
    a12 a28 * +
    a13 a29 * +
    a14 a30 * +
    a15 a31 * +
    a16 a32 * + ;
: pressure-quotation ( -- quot )
    [
        {
            [ 1 fixnum+fast ]
            [ 2 fixnum+fast ]
            [ 3 fixnum+fast ]
            [ 4 fixnum+fast ]
            [ 5 fixnum+fast ]
            [ 6 fixnum+fast ]
            [ 7 fixnum+fast ]
            [ 8 fixnum+fast ]
            [ 9 fixnum+fast ]
            [ 10 fixnum+fast ]
            [ 11 fixnum+fast ]
            [ 12 fixnum+fast ]
            [ 13 fixnum+fast ]
            [ 14 fixnum+fast ]
            [ 15 fixnum+fast ]
            [ 16 fixnum+fast ]
            [ 17 fixnum+fast ]
            [ 18 fixnum+fast ]
            [ 19 fixnum+fast ]
            [ 20 fixnum+fast ]
            [ 21 fixnum+fast ]
            [ 22 fixnum+fast ]
            [ 23 fixnum+fast ]
            [ 24 fixnum+fast ]
            [ 25 fixnum+fast ]
            [ 26 fixnum+fast ]
            [ 27 fixnum+fast ]
            [ 28 fixnum+fast ]
            [ 29 fixnum+fast ]
            [ 30 fixnum+fast ]
            [ 31 fixnum+fast ]
            [ 32 fixnum+fast ]
            [ 33 fixnum+fast ]
            [ 34 fixnum+fast ]
            [ 35 fixnum+fast ]
            [ 36 fixnum+fast ]
            [ 37 fixnum+fast ]
            [ 38 fixnum+fast ]
            [ 39 fixnum+fast ]
            [ 40 fixnum+fast ]
        } cleave
        fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast
        fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast
        fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast
        fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast
        fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast fixnum+fast
    ] ;
:: measure-pressure ( input quot expected allocator kind -- )
    allocator register-allocator [
        quot measure-compilation :> metrics
        input 1array [ quot compile-call ] with-datastack :> result
        result expected 1array assert=
        allocator unparse :> name
        H{ { "allocator" name } { "kind" kind } { "result" result }
           { "metrics" metrics } } >json print flush
    ] with-variable ;
check-allocation? on
{ linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator } [
    [ 2.5 \ pressure-kernel def>> 5092.0 ] dip "float32" measure-pressure
] each
{ linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator } [
    [ 10 pressure-quotation 1220 ] dip "int40" measure-pressure
] each
