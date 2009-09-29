! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types assocs byte-arrays classes effects fry
functors generalizations kernel literals locals math math.functions
math.vectors math.vectors.private math.vectors.simd.intrinsics
math.vectors.specialization parser prettyprint.custom sequences
sequences.private strings words definitions macros cpu.architecture
namespaces arrays quotations combinators sets ;
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
        rep \ (simd-vshuffle) supported-simd-op? [
            [ rep rep-coerce rep (simd-broadcast) class boa ]
        ] [ word def>> ] if
    ] "custom-inlining" set-word-prop ;

: simd-nth-fast ( rep -- quot )
    [ rep-components ] keep
    '[ swap _ '[ _ _ (simd-select) ] 2array ] map-index
    '[ swap >fixnum _ case ] ;

: simd-nth-slow ( rep -- quot )
    rep-component-type dup c-type-getter-boxer array-accessor ;

MACRO: simd-nth ( rep -- x )
    dup \ (simd-vshuffle) supported-simd-op?
    [ simd-nth-fast ] [ simd-nth-slow ] if ;

: boa-effect ( rep n -- effect )
    [ rep-components ] dip *
    [ CHAR: a + 1string ] map
    { "simd-vector" } <effect> ;

: supported-simd-ops ( assoc rep -- assoc' )
    [ simd-ops get ] dip 
    '[ nip _ swap supported-simd-op? ] assoc-filter
    '[ drop _ key? ] assoc-filter ;

ERROR: bad-schema schema ;

: low-level-ops ( simd-ops alist -- alist' )
    '[
        1quotation
        over word-schema _ ?at [ bad-schema ] unless
        [ ] 2sequence
    ] assoc-map ;

:: high-level-ops ( ctor elt-class -- assoc )
    ! Some SIMD operations are defined in terms of others.
    {
        { vneg [ [ dup vbitxor ] keep v- ] }
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
    elt-class m:float = [ { distance [ v- norm ] } suffix ] when ;

TUPLE: simd class elt-class ops wrappers ctor rep ;

: define-simd ( simd -- )
    dup rep>> rep-component-type c-type-boxed-class >>elt-class
    {
        [ class>> ]
        [ elt-class>> ]
        [ [ ops>> ] [ wrappers>> ] bi low-level-ops ]
        [ rep>> supported-simd-ops ]
        [ [ ctor>> ] [ elt-class>> ] bi high-level-ops assoc-union ]
    } cleave
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

: (define-simd-128) ( simd -- )
    simd-ops get >>ops
    [ define-simd ]
    [ [ class>> ] [ rep>> ] bi define-simd-128-type ] bi ;

FUNCTOR: define-simd-128 ( T -- )

N            [ 16 T heap-size /i ]

A            DEFINES-CLASS ${T}-${N}
A-boa        DEFINES ${A}-boa
A-with       DEFINES ${A}-with
A-cast       DEFINES ${A}-cast
>A           DEFINES >${A}
A{           DEFINES ${A}{

SET-NTH      [ T dup c-setter array-accessor ]

A-rep        [ A name>> "-rep" append "cpu.architecture" lookup ]
A-vv->v-op   DEFINES-PRIVATE ${A}-vv->v-op
A-vn->v-op   DEFINES-PRIVATE ${A}-vn->v-op
A-vv->n-op   DEFINES-PRIVATE ${A}-vv->n-op
A-v->v-op    DEFINES-PRIVATE ${A}-v->v-op
A-v->n-op    DEFINES-PRIVATE ${A}-v->n-op

WHERE

TUPLE: A
{ underlying byte-array read-only initial: $[ 16 <byte-array> ] } ;

M: A clone underlying>> clone \ A boa ; inline

M: A length drop N ; inline

M: A nth-unsafe underlying>> A-rep simd-nth ; inline

M: A set-nth-unsafe underlying>> SET-NTH call ; inline

: >A ( seq -- simd-array ) \ A new clone-like ;

M: A like drop dup \ A instance? [ >A ] unless ; inline

M: A new-underlying drop \ A boa ; inline

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

: A-cast ( simd-array -- simd-array' )
    underlying>> \ A boa ; inline

INSTANCE: A sequence

<PRIVATE

: A-vv->v-op ( v1 v2 quot -- v3 )
    [ [ underlying>> ] bi@ A-rep ] dip call \ A boa ; inline

: A-vn->v-op ( v1 v2 quot -- v3 )
    [ [ underlying>> ] dip A-rep ] dip call \ A boa ; inline

: A-vv->n-op ( v1 v2 quot -- n )
    [ [ underlying>> ] bi@ A-rep ] dip call ; inline

: A-v->v-op ( v1 quot -- v2 )
    [ underlying>> A-rep ] dip call \ A boa ; inline

: A-v->n-op ( v quot -- n )
    [ underlying>> A-rep ] dip call ; inline

simd new
    \ A >>class
    \ A-with >>ctor
    \ A-rep >>rep
    {
        { { +vector+ +vector+ -> +vector+ } A-vv->v-op }
        { { +vector+ +scalar+ -> +vector+ } A-vn->v-op }
        { { +vector+ +literal+ -> +vector+ } A-vn->v-op }
        { { +vector+ +vector+ -> +scalar+ } A-vv->n-op }
        { { +vector+ -> +vector+ } A-v->v-op }
        { { +vector+ -> +scalar+ } A-v->n-op }
        { { +vector+ -> +nonnegative+ } A-v->n-op }
    } >>wrappers
(define-simd-128)

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

: (define-simd-256) ( simd -- )
    simd-ops get { vshuffle hlshift hrshift } unique assoc-diff >>ops
    [ define-simd ]
    [ [ class>> ] [ rep>> ] bi define-simd-256-type ] bi ;

FUNCTOR: define-simd-256 ( T -- )

N            [ 32 T heap-size /i ]

N/2          [ N 2 / ]
A/2          IS ${T}-${N/2}
A/2-boa      IS ${A/2}-boa
A/2-with     IS ${A/2}-with

A            DEFINES-CLASS ${T}-${N}
A-boa        DEFINES ${A}-boa
A-with       DEFINES ${A}-with
A-cast       DEFINES ${A}-cast
>A           DEFINES >${A}
A{           DEFINES ${A}{

A-deref      DEFINES-PRIVATE ${A}-deref

A-rep        [ A/2 name>> "-rep" append "cpu.architecture" lookup ]
A-vv->v-op   DEFINES-PRIVATE ${A}-vv->v-op
A-vn->v-op   DEFINES-PRIVATE ${A}-vn->v-op
A-vv->n-op   DEFINES-PRIVATE ${A}-vv->n-op
A-v->v-op    DEFINES-PRIVATE ${A}-v->v-op
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

: A-cast ( simd-array -- simd-array' )
    [ underlying1>> ] [ underlying2>> ] bi \ A boa ; inline

INSTANCE: A sequence

: A-vv->v-op ( v1 v2 quot -- v3 )
    [ [ [ underlying1>> ] bi@ A-rep ] dip call ]
    [ [ [ underlying2>> ] bi@ A-rep ] dip call ] 3bi
    \ A boa ; inline

: A-vn->v-op ( v1 v2 quot -- v3 )
    [ [ [ underlying1>> ] dip A-rep ] dip call ]
    [ [ [ underlying2>> ] dip A-rep ] dip call ] 3bi
    \ A boa ; inline

: A-vv->n-op ( v1 v2 quot -- v3 )
    [ [ [ underlying1>> ] bi@ A-rep ] dip call ]
    [ [ [ underlying2>> ] bi@ A-rep ] dip call ] 3bi
    + ; inline

: A-v->v-op ( v1 combine-quot -- v2 )
    [ [ underlying1>> A-rep ] dip call ]
    [ [ underlying2>> A-rep ] dip call ] 2bi
    \ A boa ; inline

: A-v->n-op ( v1 combine-quot -- v2 )
    [ [ underlying1>> ] [ underlying2>> ] bi A-rep (simd-v+) A-rep ] dip call ; inline

simd new
    \ A >>class
    \ A-with >>ctor
    \ A-rep >>rep
    {
        { { +vector+ +vector+ -> +vector+ } A-vv->v-op }
        { { +vector+ +scalar+ -> +vector+ } A-vn->v-op }
        { { +vector+ +literal+ -> +vector+ } A-vn->v-op }
        { { +vector+ +vector+ -> +scalar+ } A-vv->n-op }
        { { +vector+ -> +vector+ } A-v->v-op }
        { { +vector+ -> +scalar+ } A-v->n-op }
        { { +vector+ -> +nonnegative+ } A-v->n-op }
    } >>wrappers
(define-simd-256)

;FUNCTOR
