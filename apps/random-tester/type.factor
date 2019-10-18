USING: errors generic io kernel lazy-lists math memory namespaces
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
        V{ 1 0 65536 }
        ""
        SBUF" "
        [ ]
        ! DLL" libm.dylib"
        ! ALIEN: 1
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

TUPLE: success quot inputs outputs ;

SYMBOL: err
SYMBOL: type-error
SYMBOL: params
SYMBOL: last-time
SYMBOL: quot
: throws? ( data... quot -- ? )
    dup quot set
    err off type-error off
    >r
        dup clone params set
        maybe-explode
    r>
    ! .s flush
    dup last-time get = [ dup . flush dup last-time set ] unless
    [ call ] [ err on ] recover
    err get [
        dup type-error? dup [
            ! .s
        ] unless
        type-error set
    ] [
        datastack clone >r quot get params get r> <success>
        ,
    ] if clear type-error get ;

: test-inputs ( word -- seq )
    [
        [ word-inputs ] keep
        unit [
            throws? not clear
        ] curry each-permutation
    ] { } make ;

: (test1)
    [
        [ stack-effect effect-in length ] catch [ 4 < ] unless
    ! ] subset [ [ [ test-inputs , full-gc ] { } make , ] each ] { } make ;
    ! ] subset [ [ [ test-inputs , ] { } make , ] each ] { } make ;
    ] subset [ test-inputs clear ] each ;

: test1
    wordbank get (test1) ;

! full-gc finds corrupted memory faster
