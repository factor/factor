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
        ! T{ inert-object f }
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

: make-inputs
    [
        0 ,
        ! ! -268435457 ,
        \ inert ,
        ! ! T{ inert-object f } ,
        -29/2 ,
        -3.14 ,
        C{ 1 -1 } ,
        W{ 55 } clone ,
        { } clone ,
        f ,
        H{ } clone ,
        V{ } clone ,
        "" ,
        SBUF" " clone ,
        [ ] clone ,
        DLL" libm.dylib" clone ,
        ALIEN: 1 ,
        T{ inert-object f } ,
    ] { } make ;

! : cartesian-inputs ( n -- list )
    ! >r make-inputs >list r>
    ! 1- [ drop make-inputs >list lcartesian-product ] each ;

: cartesian-inputs ( n -- list )
    dup 2 > [
        drop { } >list
    ] [
        >r make-inputs >list r>
        1- [ drop make-inputs >list lcartesian-product ] each
    ] if ;


: word-inputs ( word -- seq )
    [ stack-effect effect-in length ] [ drop 0 ] recover
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

