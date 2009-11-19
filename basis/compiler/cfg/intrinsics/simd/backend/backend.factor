! (c)2009 Joe Groff bsd license
USING: accessors arrays assocs classes combinators
combinators.short-circuit compiler.cfg.builder.blocks
compiler.cfg.registers compiler.cfg.stacks
compiler.cfg.stacks.local compiler.tree.propagation.info
cpu.architecture effects fry generalizations
kernel locals macros math namespaces quotations sequences
splitting stack-checker words ;
IN: compiler.cfg.intrinsics.simd.backend

! Selection of implementation based on available CPU instructions

: can-has? ( quot -- ? )
    [ t \ can-has? ] dip '[ @ drop \ can-has? get ] with-variable ; inline

: can-has-rep? ( rep reps -- )
    member? \ can-has? [ and ] change ; inline

GENERIC: create-can-has ( word -- word' )

PREDICATE: hat-word < word
    {
        [ name>> { [ "^" head? ] [ "##" head? ] } 1|| ]
        [ vocabulary>> { "compiler.cfg.intrinsics.simd" "compiler.cfg.hats" } member? ]
    } 1&& ;

PREDICATE: vector-op-word < hat-word
    name>> "-vector" swap subseq? ;

: reps-word ( word -- word' )
    name>> "^^" ?head drop "##" ?head drop
    "%" "-reps" surround "cpu.architecture" lookup ;

SYMBOL: blub

:: can-has-^^-quot ( word def effect -- quot )
    effect in>> { "rep" } split1 [ length ] bi@ 1 +
    word reps-word 1quotation
    effect out>> length blub <array> >quotation
    '[ [ _ ndrop ] _ ndip @ can-has-rep? @ ] ;

:: can-has-^-quot ( word def effect -- quot )
    def create-can-has first ;

: map-concat-like ( seq quot -- seq' )
    '[ _ map ] [ concat-as ] bi ; inline

M: object create-can-has 1quotation ;

M: array create-can-has
    [ create-can-has ] map-concat-like 1quotation ;
M: callable create-can-has
    [ create-can-has ] map-concat-like 1quotation ;

: (can-has-word) ( word -- word' )
    name>> "can-has-" prepend "compiler.cfg.intrinsics.simd.backend" lookup ;

: (can-has-quot) ( word -- quot )
    [ ] [ def>> ] [ stack-effect ] tri {
        { [ pick name>> "^^" head? ] [ can-has-^^-quot ] }
        { [ pick name>> "##" head? ] [ can-has-^^-quot ] }
        { [ pick name>> "^"  head? ] [ can-has-^-quot  ] }
    } cond ;

: (can-has-nop-quot) ( word -- quot )
    stack-effect in>> length '[ _ ndrop blub ] ;

DEFER: can-has-words

M: word create-can-has
    can-has-words ?at drop 1quotation ;

M: hat-word create-can-has
    (can-has-nop-quot) ;

M: vector-op-word create-can-has
    dup (can-has-word) [ 1quotation ] [ (can-has-quot) ] ?if ;

GENERIC# >can-has-cond 2 ( quot #pick #dup -- quotpair )
M:: callable >can-has-cond ( quot #pick #dup -- quotpair )
    #dup quot create-can-has '[ _ ndup @ can-has? ] quot 2array ;

M:: pair >can-has-cond ( pair #pick #dup -- quotpair )
    pair first2 :> ( class quot )
    #pick class #dup quot create-can-has
    '[ _ npick _ instance? [ _ ndup @ can-has? ] dip and ]
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
    blub ;

: can-has-^^test-vector ( src rep vcc -- dst )
    [ drop ] 2dip drop %test-vector-reps member?
    \ can-has? [ and ] change
    blub ;

MACRO: can-has-case ( cases -- )
    dup first second infer in>> length 1 +
    '[ _ ndrop f ] suffix '[ _ case ] ;

GENERIC# >can-has-trial 1 ( obj #pick -- quot )

M: callable >can-has-trial
    drop '[ _ can-has? ] ;
M: pair >can-has-trial
    swap first2 dup infer in>> length
    '[ _ npick _ instance? [ _ can-has? ] [ _ ndrop blub ] if ] ; 

MACRO: can-has-vector-op ( trials #pick #dup -- )
    [ '[ _ >can-has-trial ] map ] dip '[ _ _ n|| \ can-has? [ and ] change blub ] ;

: can-has-v-vector-op ( trials -- ? )
    1 2 can-has-vector-op ; inline
: can-has-vv-vector-op ( trials -- ? )
    1 3 can-has-vector-op ; inline
: can-has-vv-cc-vector-op ( trials -- ? )
    2 4 can-has-vector-op ; inline
: can-has-vvvv-vector-op ( trials -- ? )
    1 5 can-has-vector-op ; inline

CONSTANT: can-has-words
    H{
        { case can-has-case }
        { v-vector-op     can-has-v-vector-op  }
        { vl-vector-op    can-has-vv-vector-op }
        { vv-vector-op    can-has-vv-vector-op }
        { vv-cc-vector-op can-has-vv-cc-vector-op }
        { vvvv-vector-op  can-has-vvvv-vector-op }
    }

! Intrinsic code emission

MACRO: check-elements ( quots -- )
    [ length '[ _ firstn ] ]
    [ '[ _ spread ] ]
    [ length 1 - \ and <repetition> [ ] like ]
    tri 3append ;

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

:: [emit-vector-op] ( trials params-quot op-quot literal-preds -- quot )
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

MACRO:: emit-vv-or-vl-vector-op ( var-trials imm-trials literal-pred -- )
    literal-pred imm-trials literal-pred var-trials
    '[
        dup node-input-infos 2 tail-slice* first literal>> @
        [ _ _ emit-vl-vector-op ]
        [ _   emit-vv-vector-op ] if 
    ] ;

