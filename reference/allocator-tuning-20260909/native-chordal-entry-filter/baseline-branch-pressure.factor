USING: compiler.cfg.metrics kernel kernel.private math locals sequences prettyprint ;
IN: allocator.chordal.tuning
:: branch-pressure ( x -- value )
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
    y 16.0 < [ a1 a17 * ] [ a1 a17 + ] if
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
    a16 a32 * +
    ;
: branch-pressure-work ( -- )
    0.0 1000 [ 32 <iota> [ >float branch-pressure + ] each ] times
    530872000.0 assert= ;

