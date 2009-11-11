! (c)2009 Joe Groff bsd license
USING: accessors fry generalizations kernel locals math sequences
splitting words ;
IN: compiler.cfg.intrinsics.simd.backend

! Selection of implementation based on available CPU instructions

: can-has? ( quot -- ? )
    [ t \ can-has? ] dip '[ @ drop \ can-has? get ] with-variable ; inline

GENERIC: create-can-has-word ( word -- word' )

PREDICATE: vector-op-word
    {
        [ name>> { [ { [ "^" head? ] [ "##" head? ] } 1|| ] [ "-vector" swap subseq? ] } 1&& ]
        [ vocabulary>> { "compiler.cfg.intrinsics.simd" "cpu.architecture" } member? ]
    } 1&& ;

: reps-word ( word -- word' )
    name>> "^^" ?head drop "##" ?head drop
    "%" "-reps" surround "cpu.architecture" lookup ;

:: can-has-^^-quot ( word def effect -- def' )
    effect in>> { "rep" } split1 [ length ] bi@ 1 +
    word reps-word
    effect out>> length f <array> >quotation
    '[ [ _ ndrop ] _ ndip _ execute member? \ can-has? [ and ] change @ ] ;

:: can-has-^-quot ( word def effect -- def' )
    def create-can-has ;

M: object create-can-has ;

M: sequence create-can-has
    [ create-can-has-word ] map ;

: (create-can-has-word) ( word -- word' created? )
    name>> "can-has-" prepend "compiler.cfg.intrinsics.simd.backend"
    2dup lookup
    [ 2nip f ] [ create t ] if* ;

: (create-can-has-quot) ( word -- def effect )
    [ ] [ def>> ] [ stack-effect ] tri [
        {
            { [ pick "^^" head? ] [ can-has-^^-quot ] }
            { [ pick "##" head? ] [ can-has-^^-quot ] }
            { [ pick "^"  head? ] [ can-has-^-quot  ] }
        } cond
    ] keep ;

M: vector-op-word create-can-has
    [ (create-can-has-word) ] keep
    '[ _ (create-can-has-quot) define-declared ]
    [ nip ] if ;

GENERIC# >can-has-cond 2 ( quot #pick #dup -- quotpair )
M:: callable >can-has-cond
    #dup quot create-can-has '[ _ ndup _ can-has? ] quot 2array ;
    
M:: pair >can-has-cond ( pair #pick #dup -- quotpair )
    pair first2 :> ( class quot )
    #pick class #dup quot create-can-has
    '[ _ npick _ instance? [ _ ndup _ can-has? ] dip and ]
    quot 2array ;

MACRO: v-vector-op ( trials -- )
    [ 1 2 >can-has-cond ] map '[ _ cond ] ;
MACRO: vl-vector-op ( trials -- )
    [ 1 3 >can-has-cond ] map '[ _ cond ] ;
MACRO: vv-vector-op ( trials -- )
    [ 1 3 >can-has-cond ] map '[ _ cond ] ;
MACRO: vv-cc-vector-op ( trials -- )
    [ 2 4 >can-has-cond ] map '[ _ cond ] ;
MACRO: vvvv-vector-op ( trials -- )
    [ 1 5 >can-has-cond ] map '[ _ cond ] ;

! Special-case conditional instructions

: can-has-^(compare-vector) ( src1 src2 rep cc -- dst )
    [ 2drop ] 2dip %compare-vector-reps member?
    \ can-has? [ and ] change
    f ;

! Intrinsic code emission

MACRO: if-literals-match ( quots -- )
    [ length ] [ ] [ length ] tri
    ! n quots n
    '[
        ! node quot
        [
            dup node-input-infos
            _ tail-slice* [ literal>> ] map
            dup _ check-elements
        ] dip
        swap [
            ! node literals quot
            [ _ firstn ] dip call
            drop
        ] [ 2drop emit-primitive ] if
    ] ;

CONSTANT: [unary]       [ ds-drop  ds-pop ]
CONSTANT: [unary/param] [ [ -2 inc-d ds-pop ] dip ]
CONSTANT: [binary]      [ ds-drop 2inputs ]
CONSTANT: [quaternary]
    [
        ds-drop 
        D 3 peek-loc
        D 2 peek-loc
        D 1 peek-loc
        D 0 peek-loc
        -4 inc-d
    ]

:: [emit-vector-op] ( trials params-quot op-quot literal-preds -- quot ) ;
    params-quot trials op-quot literal-preds 
    '[ [ _ dip _ @ ds-push ] _ if-literals-match ] ;

MACRO: emit-v-vector-op ( trials -- )
    [unary] [ v-vector-op ] { [ representation? ] } [emit-vector-op] ;
MACRO: emit-vl-vector-op ( trials literal-pred -- )
    [ [unary/param] [ vl-vector-op ] { [ representation? ] } ] dip prefix [emit-vector-op] ;
MACRO: emit-vv-vector-op ( trials -- )
    [binary] [ vv-vector-op ] { [ representation? ] } [emit-vector-op] ;
MACRO: emit-vvvv-vector-op ( trials -- )
    [quaternary] [ vvvv-vector-op ] { [ representation? ] } [emit-vector-op] ;

MACRO:: emit-vv-or-vl-vector-op ( trials literal-pred -- )
    literal-pred trials literal-pred trials
    '[
        dup node-input-infos 2 tail-slice* first literal>> @
        [ _ _ emit-vl-vector-op ]
        [ _   emit-vv-vector-op ] if 
    ] ;
