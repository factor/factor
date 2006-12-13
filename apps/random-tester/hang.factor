USING: errors generic io kernel lazy-lists math namespaces
prettyprint random-tester2 sequences tools words ;
IN: random-tester

: inputs-exhaustive ( -- seq )
    {
        -100000000000000000
        -1
        0
        1
        100000000000000000

        -29/2
         100000000000000000/999999999999999999

        -1/0.
        -3.14
        0.0
        3.14
        1/0.
        0/0.

        C{ 1 -1 }
    } ;


: inert ;
TUPLE: inert-object ;

: inputs ( -- seq )
    {
        0
        ! -268435457
        inert
        T{ inert-object f }
        -29/2
        -3.14
        C{ 1 -1 }
        W{ 55 }
        { }
        f
        H{ }
        V{ }
        ""
        SBUF" "
        [ ]
        DLL" libm.dylib"
        ALIEN: 1
        T{ inert-object f }
    } ;

: cartesian-inputs ( n -- list )
    >r inputs >list r>
    1- [ drop inputs >list lcartesian-product ] each ;

: word-inputs ( word -- seq )
    stack-effect [ effect-in length ] [ drop 2 ] recover
    cartesian-inputs list>array ;
    
: type-error? ( exception -- ? )
    [ swap execute or ] curry
    >r { no-method? no-math-method? } f r> reduce ;

: maybe-explode
    dup sequence? [ [ ] each ] when ;

SYMBOL: err
SYMBOL: type-error
SYMBOL: params
: throws? ( data... quot -- ? )
    err off type-error off
    >r
        dup clone params set
        maybe-explode
    r>
     "<<<<<testing" .
     .s
        3dup . . .
     "-----" . flush
    [ call ] [ err on ] recover
     .s
     ">>>>>tested" .
    err get [
        dup type-error? dup [
            .s
        ] unless
        type-error set
    ] when clear type-error get
    ;

: test-inputs ( word -- seq )
    [ word-inputs ] keep
    unit [
        throws? not
    ] curry map ;

