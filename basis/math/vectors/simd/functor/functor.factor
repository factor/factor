! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types assocs byte-arrays classes
effects fry functors generalizations kernel literals locals
math math.functions math.vectors math.vectors.simd.intrinsics
math.vectors.specialization parser prettyprint.custom sequences
sequences.private strings words definitions macros cpu.architecture ;
QUALIFIED-WITH: math m
IN: math.vectors.simd.functor

ERROR: bad-length got expected ;

MACRO: simd-boa ( rep class -- simd-array )
    [ rep-components ] [ new ] bi* '[ _ _ nsequence ] ;

:: define-boa-custom-inlining ( word rep class -- )
    word [
        drop
        rep rep rep-gather-word supported-simd-op? [
            [ rep (simd-boa) class boa ]
        ] [ word def>> ] if
    ] "custom-inlining" set-word-prop ;

: simd-with ( rep class x -- simd-array )
    [ rep-components ] [ new ] [ '[ _ ] ] tri* swap replicate-as ; inline

:: define-with-custom-inlining ( word rep class -- )
    word [
        drop
        rep \ (simd-broadcast) supported-simd-op? [
            [ rep rep-coerce rep (simd-broadcast) class boa ]
        ] [ word def>> ] if
    ] "custom-inlining" set-word-prop ;

: boa-effect ( rep n -- effect )
    [ rep-components ] dip *
    [ CHAR: a + 1string ] map
    { "simd-vector" } <effect> ;

: supported-simd-ops ( assoc rep -- assoc' )
    [
        {
            { v+ (simd-v+) }
            { vs+ (simd-vs+) }
            { v+- (simd-v+-) }
            { v- (simd-v-) }
            { vs- (simd-vs-) }
            { v* (simd-v*) }
            { vs* (simd-vs*) }
            { v/ (simd-v/) }
            { vmin (simd-vmin) }
            { vmax (simd-vmax) }
            { sum (simd-sum) }
        }
    ] dip 
    '[ nip _ swap supported-simd-op? ] assoc-filter
    '[ drop _ key? ] assoc-filter ;

:: high-level-ops ( ctor elt-class -- assoc )
    ! Some SIMD operations are defined in terms of others.
    {
        { vneg [ [ dup v- ] keep v- ] }
        { n+v [ [ ctor execute ] dip v+ ] }
        { v+n [ ctor execute v+ ] }
        { n-v [ [ ctor execute ] dip v- ] }
        { v-n [ ctor execute v- ] }
        { n*v [ [ ctor execute ] dip v* ] }
        { v*n [ ctor execute v* ] }
        { n/v [ [ ctor execute ] dip v/ ] }
        { v/n [ ctor execute v/ ] }
        { norm-sq [ dup v. assert-positive ] }
        { norm [ norm-sq sqrt ] }
        { normalize [ dup norm v/n ] }
    }
    ! To compute dot product and distance with integer vectors, we
    ! have to do things less efficiently, with integer overflow checks,
    ! in the general case.
    elt-class m:float = [
        {
            { distance [ v- norm ] }
            { v. [ v* sum ] }
        } append
    ] when ;

:: simd-vector-words ( class ctor rep assoc -- )
    rep rep-component-type c-type-boxed-class :> elt-class
    class
    elt-class
    assoc rep supported-simd-ops
    ctor elt-class high-level-ops assoc-union
    specialize-vector-words ;

:: define-simd-128-type ( class rep -- )
    <c-type>
        byte-array >>class
        class >>boxed-class
        [ rep alien-vector class boa ] >>getter
        [ [ underlying>> ] 2dip rep set-alien-vector ] >>setter
        16 >>size
        8 >>align
        rep >>rep
    class typedef ;

FUNCTOR: define-simd-128 ( T -- )

N            [ 16 T heap-size /i ]

A            DEFINES-CLASS ${T}-${N}
A-boa        DEFINES ${A}-boa
A-with       DEFINES ${A}-with
>A           DEFINES >${A}
A{           DEFINES ${A}{

NTH          [ T dup c-type-getter-boxer array-accessor ]
SET-NTH      [ T dup c-setter array-accessor ]

A-rep        [ A name>> "-rep" append "cpu.architecture" lookup ]
A-vv->v-op   DEFINES-PRIVATE ${A}-vv->v-op
A-v->n-op    DEFINES-PRIVATE ${A}-v->n-op

WHERE

TUPLE: A
{ underlying byte-array read-only initial: $[ 16 <byte-array> ] } ;

M: A clone underlying>> clone \ A boa ; inline

M: A length drop N ; inline

M: A nth-unsafe underlying>> NTH call ; inline

M: A set-nth-unsafe underlying>> SET-NTH call ; inline

: >A ( seq -- simd-array ) \ A new clone-like ;

M: A like drop dup \ A instance? [ >A ] unless ; inline

M: A new-sequence
    drop dup N =
    [ drop 16 <byte-array> \ A boa ]
    [ N bad-length ]
    if ; inline

M: A equal? over \ A instance? [ sequence= ] [ 2drop f ] if ;

M: A byte-length underlying>> length ; inline

M: A element-type drop A-rep rep-component-type ;

M: A pprint-delims drop \ A{ \ } ;

M: A >pprint-sequence ;

M: A pprint* pprint-object ;

SYNTAX: A{ \ } [ >A ] parse-literal ;

: A-with ( x -- simd-array ) [ A-rep A ] dip simd-with ;

\ A-with \ A-rep \ A define-with-custom-inlining

\ A-boa [ \ A-rep \ A simd-boa ] \ A-rep 1 boa-effect define-declared

\ A-rep rep-gather-word [
    \ A-boa \ A-rep \ A define-boa-custom-inlining
] when

INSTANCE: A sequence

<PRIVATE

: A-vv->v-op ( v1 v2 quot -- v3 )
    [ [ underlying>> ] bi@ A-rep ] dip call \ A boa ; inline

: A-v->n-op ( v quot -- n )
    [ underlying>> A-rep ] dip call ; inline

\ A \ A-with \ A-rep H{
    { v+ [ [ (simd-v+) ] \ A-vv->v-op execute ] }
    { vs+ [ [ (simd-vs+) ] \ A-vv->v-op execute ] }
    { v+- [ [ (simd-v+-) ] \ A-vv->v-op execute ] }
    { v- [ [ (simd-v-) ] \ A-vv->v-op execute ] }
    { vs- [ [ (simd-vs-) ] \ A-vv->v-op execute ] }
    { v* [ [ (simd-v*) ] \ A-vv->v-op execute ] }
    { vs* [ [ (simd-vs*) ] \ A-vv->v-op execute ] }
    { v/ [ [ (simd-v/) ] \ A-vv->v-op execute ] }
    { vmin [ [ (simd-vmin) ] \ A-vv->v-op execute ] }
    { vmax [ [ (simd-vmax) ] \ A-vv->v-op execute ] }
    { sum [ [ (simd-sum) ] \ A-v->n-op execute ] }
} simd-vector-words

\ A \ A-rep define-simd-128-type

PRIVATE>

;FUNCTOR

! Synthesize 256-bit vectors from a pair of 128-bit vectors
SLOT: underlying1
SLOT: underlying2

:: define-simd-256-type ( class rep -- )
    <c-type>
        class >>class
        class >>boxed-class
        [
            [ rep alien-vector ]
            [ 16 + >fixnum rep alien-vector ] 2bi
            class boa
        ] >>getter
        [
            [ [ underlying1>> ] 2dip rep set-alien-vector ]
            [ [ underlying2>> ] 2dip 16 + >fixnum rep set-alien-vector ]
            3bi
        ] >>setter
        32 >>size
        8 >>align
        rep >>rep
    class typedef ;

FUNCTOR: define-simd-256 ( T -- )

N            [ 32 T heap-size /i ]

N/2          [ N 2 / ]
A/2          IS ${T}-${N/2}
A/2-boa      IS ${A/2}-boa
A/2-with     IS ${A/2}-with

A            DEFINES-CLASS ${T}-${N}
A-boa        DEFINES ${A}-boa
A-with       DEFINES ${A}-with
>A           DEFINES >${A}
A{           DEFINES ${A}{

A-deref      DEFINES-PRIVATE ${A}-deref

A-rep        [ A/2 name>> "-rep" append "cpu.architecture" lookup ]
A-vv->v-op   DEFINES-PRIVATE ${A}-vv->v-op
A-v->n-op    DEFINES-PRIVATE ${A}-v->n-op

WHERE

SLOT: underlying1
SLOT: underlying2

TUPLE: A
{ underlying1 byte-array initial: $[ 16 <byte-array> ] read-only }
{ underlying2 byte-array initial: $[ 16 <byte-array> ] read-only } ;

M: A clone
    [ underlying1>> clone ] [ underlying2>> clone ] bi
    \ A boa ; inline

M: A length drop N ; inline

: A-deref ( n seq -- n' seq' )
    over N/2 < [ underlying1>> ] [ [ N/2 - ] dip underlying2>> ] if \ A/2 boa ; inline

M: A nth-unsafe A-deref nth-unsafe ; inline

M: A set-nth-unsafe A-deref set-nth-unsafe ; inline

: >A ( seq -- simd-array ) \ A new clone-like ;

M: A like drop dup \ A instance? [ >A ] unless ; inline

M: A new-sequence
    drop dup N =
    [ drop 16 <byte-array> 16 <byte-array> \ A boa ]
    [ N bad-length ]
    if ; inline

M: A equal? over \ A instance? [ sequence= ] [ 2drop f ] if ;

M: A byte-length drop 32 ; inline

M: A element-type drop A-rep rep-component-type ;

SYNTAX: A{ \ } [ >A ] parse-literal ;

M: A pprint-delims drop \ A{ \ } ;

M: A >pprint-sequence ;

M: A pprint* pprint-object ;

: A-with ( x -- simd-array )
    [ A/2-with ] [ A/2-with ] bi [ underlying>> ] bi@
    \ A boa ; inline

: A-boa ( ... -- simd-array )
    [ A/2-boa ] N/2 ndip A/2-boa [ underlying>> ] bi@
    \ A boa ; inline

\ A-rep 2 boa-effect \ A-boa set-stack-effect

INSTANCE: A sequence

: A-vv->v-op ( v1 v2 quot -- v3 )
    [ [ [ underlying1>> ] bi@ A-rep ] dip call ]
    [ [ [ underlying2>> ] bi@ A-rep ] dip call ] 3bi
    \ A boa ; inline

: A-v->n-op ( v1 combine-quot reduce-quot -- v2 )
    [ [ [ underlying1>> ] [ underlying2>> ] bi A-rep ] dip call A-rep ]
    dip call ; inline

\ A \ A-with \ A-rep H{
    { v+ [ [ (simd-v+) ] \ A-vv->v-op execute ] }
    { vs+ [ [ (simd-vs+) ] \ A-vv->v-op execute ] }
    { v- [ [ (simd-v-) ] \ A-vv->v-op execute ] }
    { vs- [ [ (simd-vs-) ] \ A-vv->v-op execute ] }
    { v+- [ [ (simd-v+-) ] \ A-vv->v-op execute ] }
    { v* [ [ (simd-v*) ] \ A-vv->v-op execute ] }
    { vs* [ [ (simd-vs*) ] \ A-vv->v-op execute ] }
    { v/ [ [ (simd-v/) ] \ A-vv->v-op execute ] }
    { vmin [ [ (simd-vmin) ] \ A-vv->v-op execute ] }
    { vmax [ [ (simd-vmax) ] \ A-vv->v-op execute ] }
    { sum [ [ (simd-v+) ] [ (simd-sum) ] \ A-v->n-op execute ] }
} simd-vector-words

\ A \ A-rep define-simd-256-type

;FUNCTOR
