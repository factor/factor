USING: accessors classes.tuple classes.tuple.private combinators
kernel sequences tools.test ;
IN: cpu.arm.64.tests

TUPLE: large-offset-tuple
    s1 s2 s3 s4 s5 s6 s7 s8 s9 s10
    s11 s12 s13 s14 s15 s16 s17 s18 s19 s20
    s21 s22 s23 s24 s25 s26 s27 s28 s29 s30
    s31 s32 s33 s34 s35 s36 s37 s38 s39 s40 ;

: raw-s40 ( obj -- value )
    dup tuple-slots 39 swap nth nip ;

{ 12345 12345 } [
    large-offset-tuple new 12345 >>s40
    [ s40>> ] [ raw-s40 ] bi
] unit-test
