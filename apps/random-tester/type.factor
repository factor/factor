USING: errors generic io kernel lazy-lists math namespaces
prettyprint random-tester2 sequences tools words ;
IN: random-tester

: inert ;
TUPLE: inert-object ;

: inputs ( -- seq )
    {
        0 -1 -1000000000000000000000000
        ! -268435457
        inert
            ! T{ inert-object f }
        -29/2 1000000000000000000000000000000/1111111111111111111111111111111111111111111
        3/4
            -1000000000000000000000000/111111111111111111
        -3.14 1/0. 0.0 -1/0. 3.14 0/0.
        C{ 1 -1 }
        W{ 55 }
        { }
        f  t
        H{ }
        V{ 65536 0 0 0 65536 }
        ""
        SBUF" "
        [ ]
        ! DLL" libm.dylib"
        ALIEN: 1
        T{ inert-object f }
    } ;

: word-inputs ( word -- seq )
    [ stack-effect effect-in length ] [ drop 0 ] recover
    inputs swap ;
    
: type-error? ( exception -- ? )
    [ swap execute or ] curry
    >r { no-method? no-math-method? } f r> reduce ;

: maybe-explode
    dup sequence? [ [ ] each ] when ; inline

SYMBOL: err
SYMBOL: type-error
SYMBOL: params
SYMBOL: last-time
: throws? ( data... quot -- ? )
    err off type-error off
    >r
        dup clone params set
        maybe-explode
    r>
    ! .s
    dup last-time get = [ dup . flush dup last-time set ] unless
    [ call ] [ err on ] recover
    err get [
        dup type-error? dup [
            ! .s
        ] unless
        type-error set
    ] when clear type-error get ;

: test-inputs ( word -- seq )
    [ word-inputs ] keep
    unit [
        throws? not clear
    ] curry each-permutation ;

: test1
    wordbank get [
        [ stack-effect effect-in length ] catch [ 4 < ] unless
    ] subset [ test-inputs ] each ;
