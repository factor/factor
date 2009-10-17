! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs byte-arrays classes classes.algebra effects fry
functors generalizations kernel literals locals math math.functions
math.vectors math.vectors.private math.vectors.simd.intrinsics
math.vectors.conversion.backend
math.vectors.specialization parser prettyprint.custom sequences
sequences.private strings words definitions macros cpu.architecture
namespaces arrays quotations combinators combinators.short-circuit sets
layouts ;
QUALIFIED-WITH: alien.c-types c
QUALIFIED: math.private
IN: math.vectors.simd.functor

ERROR: bad-length got expected ;

: vector-true-value ( class -- value )
    {
        { [ dup integer class<= ] [ drop -1 ] }
        { [ dup float   class<= ] [ drop -1 bits>double ] }
    } cond ; foldable

: vector-false-value ( class -- value )
    {
        { [ dup integer class<= ] [ drop 0   ] }
        { [ dup float   class<= ] [ drop 0.0 ] }
    } cond ; foldable

: boolean>element ( bool/elt class -- elt )
    swap {
        { t [ vector-true-value  ] }
        { f [ vector-false-value ] }
        [ nip ]
    } case ; inline

MACRO: simd-boa ( rep class -- simd-array )
    [ rep-components ] [ new ] bi* '[ _ _ nsequence ] ;

: can-be-unboxed? ( type -- ? )
    {
        { c:float [ \ math.private:float+ "intrinsic" word-prop ] }
        { c:double [ \ math.private:float+ "intrinsic" word-prop ] }
        [ c:heap-size cell < ]
    } case ;

: simd-boa-fast? ( rep -- ? )
    [ dup rep-gather-word supported-simd-op? ]
    [ rep-component-type can-be-unboxed? ]
    bi and ;

:: define-boa-custom-inlining ( word rep class -- )
    word [
        drop
        rep simd-boa-fast? [
            [ rep (simd-boa) class boa ]
        ] [ word def>> ] if
    ] "custom-inlining" set-word-prop ;

: simd-with ( rep class x -- simd-array )
    [ rep-components ] [ new ] [ '[ _ ] ] tri* swap replicate-as ; inline

: simd-with/nth-fast? ( rep -- ? )
    [ \ (simd-vshuffle-elements) supported-simd-op? ]
    [ rep-component-type can-be-unboxed? ]
    bi and ;

:: define-with-custom-inlining ( word rep class -- )
    word [
        drop
        rep simd-with/nth-fast? [
            [ rep rep-coerce rep (simd-with) class boa ]
        ] [ word def>> ] if
    ] "custom-inlining" set-word-prop ;

: simd-nth-fast ( rep -- quot )
    [ rep-components ] keep
    '[ swap _ '[ _ _ (simd-select) ] 2array ] map-index
    '[ swap >fixnum _ case ] ;

: simd-nth-slow ( rep -- quot )
    rep-component-type dup c:c-type-getter-boxer c:array-accessor ;

MACRO: simd-nth ( rep -- x )
    dup simd-with/nth-fast? [ simd-nth-fast ] [ simd-nth-slow ] if ;

: boa-effect ( rep n -- effect )
    [ rep-components ] dip *
    [ CHAR: a + 1string ] map
    { "simd-vector" } <effect> ;

: supported-simd-ops ( assoc rep -- assoc' )
    [ simd-ops get ] dip 
    '[ nip _ swap supported-simd-op? ] assoc-filter
    '[ drop _ key? ] assoc-filter ;

ERROR: bad-schema op schema ;

:: op-wrapper ( op specials schemas -- wrapper )
    op {
        [ specials at ]
        [ word-schema schemas at ]
        [ dup word-schema bad-schema ]
    } 1|| ;

: low-level-ops ( simd-ops specials schemas -- alist )
    '[ 1quotation over _ _ op-wrapper [ ] 2sequence ] assoc-map ;

:: high-level-ops ( ctor elt-class -- assoc )
    ! Some SIMD operations are defined in terms of others.
    {
        { vbroadcast [ swap nth ctor execute ] }
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
    elt-class float = [ { distance [ v- norm ] } suffix ] when ;

TUPLE: simd class elt-class ops special-wrappers schema-wrappers ctor rep ;

: define-simd ( simd -- )
    dup rep>> rep-component-type c:c-type-boxed-class >>elt-class
    {
        [ class>> ]
        [ elt-class>> ]
        [ [ ops>> ] [ special-wrappers>> ] [ schema-wrappers>> ] tri low-level-ops ]
        [ rep>> supported-simd-ops ]
        [ [ ctor>> ] [ elt-class>> ] bi high-level-ops assoc-union ]
    } cleave
    specialize-vector-words ;

:: define-simd-128-type ( class rep -- )
    c:<c-type>
        byte-array >>class
        class >>boxed-class
        [ rep alien-vector class boa ] >>getter
        [ [ underlying>> ] 2dip rep set-alien-vector ] >>setter
        16 >>size
        8 >>align
        rep >>rep
    class c:typedef ;

: (define-simd-128) ( simd -- )
    simd-ops get >>ops
    [ define-simd ]
    [ [ class>> ] [ rep>> ] bi define-simd-128-type ] bi ;

FUNCTOR: define-simd-128 ( T -- )

N            [ 16 T c:heap-size /i ]

A            DEFINES-CLASS ${T}-${N}
A-boa        DEFINES ${A}-boa
A-with       DEFINES ${A}-with
A-cast       DEFINES ${A}-cast
>A           DEFINES >${A}
A{           DEFINES ${A}{

SET-NTH      [ T dup c:c-setter c:array-accessor ]

A-rep        [ A name>> "-rep" append "cpu.architecture" lookup ]
A-vv->v-op   DEFINES-PRIVATE ${A}-vv->v-op
A-vn->v-op   DEFINES-PRIVATE ${A}-vn->v-op
A-vv->n-op   DEFINES-PRIVATE ${A}-vv->n-op
A-v->v-op    DEFINES-PRIVATE ${A}-v->v-op
A-v->n-op    DEFINES-PRIVATE ${A}-v->n-op
A-v-conversion-op DEFINES-PRIVATE ${A}-v-conversion-op
A-vv-conversion-op DEFINES-PRIVATE ${A}-vv-conversion-op

A-element-class [ A-rep rep-component-type c:c-type-boxed-class ]

WHERE

TUPLE: A
{ underlying byte-array read-only initial: $[ 16 <byte-array> ] } ;

INSTANCE: A simd-128

M: A clone underlying>> clone \ A boa ; inline

M: A length drop N ; inline

M: A equal?
    over \ A instance? [ v= vall? ] [ 2drop f ] if ;

M: A nth-unsafe underlying>> A-rep simd-nth ; inline

M: A set-nth-unsafe
    [ A-element-class boolean>element ] 2dip
    underlying>> SET-NTH call ; inline

: >A ( seq -- simd-array ) \ A new clone-like ;

M: A like drop dup \ A instance? [ >A ] unless ; inline

M: A new-underlying drop \ A boa ; inline

M: A new-sequence
    drop dup N =
    [ drop 16 <byte-array> \ A boa ]
    [ N bad-length ]
    if ; inline

M: A c:byte-length underlying>> length ; inline

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

: A-v-conversion-op ( v1 to-type quot -- v2 )
    swap [ underlying>> A-rep ] [ call ] [ '[ _ boa ] call( u -- v ) ] tri* ; inline

: A-vv-conversion-op ( v1 v2 to-type quot -- v2 )
    swap {
        [ underlying>> ]
        [ underlying>> A-rep ]
        [ call ]
        [ '[ _ boa ] call( u -- v ) ]
    } spread ; inline

simd new
    \ A >>class
    \ A-with >>ctor
    \ A-rep >>rep
    {
        { (v>float) A-v-conversion-op }
        { (v>integer) A-v-conversion-op }
        { (vpack-signed) A-vv-conversion-op }
        { (vpack-unsigned) A-vv-conversion-op }
        { (vunpack-head) A-v-conversion-op }
        { (vunpack-tail) A-v-conversion-op }
    } >>special-wrappers
    {
        { { +vector+ +vector+ -> +vector+ } A-vv->v-op }
        { { +vector+ +scalar+ -> +vector+ } A-vn->v-op }
        { { +vector+ +literal+ -> +vector+ } A-vn->v-op }
        { { +vector+ +vector+ -> +scalar+ } A-vv->n-op }
        { { +vector+ -> +vector+ } A-v->v-op }
        { { +vector+ -> +scalar+ } A-v->n-op }
        { { +vector+ -> +nonnegative+ } A-v->n-op }
    } >>schema-wrappers
(define-simd-128)

PRIVATE>

;FUNCTOR

! Synthesize 256-bit vectors from a pair of 128-bit vectors
SLOT: underlying1
SLOT: underlying2

:: define-simd-256-type ( class rep -- )
    c:<c-type>
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
    class c:typedef ;

: (define-simd-256) ( simd -- )
    simd-ops get { vshuffle-elements vshuffle-bytes hlshift hrshift } unique assoc-diff >>ops
    [ define-simd ]
    [ [ class>> ] [ rep>> ] bi define-simd-256-type ] bi ;

FUNCTOR: define-simd-256 ( T -- )

N            [ 32 T c:heap-size /i ]

N/2          [ N 2 /i ]
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
A-v->v-op    DEFINES-PRIVATE ${A}-v->v-op
A-v.-op      DEFINES-PRIVATE ${A}-v.-op
(A-v->n-op)  DEFINES-PRIVATE (${A}-v->v-op)
A-sum-op     DEFINES-PRIVATE ${A}-sum-op
A-vany-op    DEFINES-PRIVATE ${A}-vany-op
A-vall-op    DEFINES-PRIVATE ${A}-vall-op
A-vmerge-head-op    DEFINES-PRIVATE ${A}-vmerge-head-op
A-vmerge-tail-op    DEFINES-PRIVATE ${A}-vmerge-tail-op
A-v-conversion-op   DEFINES-PRIVATE ${A}-v-conversion-op
A-vpack-op          DEFINES-PRIVATE ${A}-vpack-op
A-vunpack-head-op   DEFINES-PRIVATE ${A}-vunpack-head-op
A-vunpack-tail-op   DEFINES-PRIVATE ${A}-vunpack-tail-op

WHERE

SLOT: underlying1
SLOT: underlying2

TUPLE: A
{ underlying1 byte-array initial: $[ 16 <byte-array> ] read-only }
{ underlying2 byte-array initial: $[ 16 <byte-array> ] read-only } ;

INSTANCE: A simd-256

M: A clone
    [ underlying1>> clone ] [ underlying2>> clone ] bi
    \ A boa ; inline

M: A length drop N ; inline

M: A equal?
    over \ A instance? [ v= vall? ] [ 2drop f ] if ;

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

M: A c:byte-length drop 32 ; inline

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

: A-v->v-op ( v1 combine-quot -- v2 )
    [ [ underlying1>> A-rep ] dip call ]
    [ [ underlying2>> A-rep ] dip call ] 2bi
    \ A boa ; inline

: A-v.-op ( v1 v2 quot -- n )
    [ [ [ underlying1>> ] bi@ A-rep ] dip call ]
    [ [ [ underlying2>> ] bi@ A-rep ] dip call ] 3bi
    + ; inline

: (A-v->n-op) ( v1 quot reduce-quot -- n )
    '[ [ underlying1>> ] [ underlying2>> ] bi A-rep @ A-rep ] dip call ; inline

: A-sum-op ( v1 quot -- n )
    [ (simd-v+) ] (A-v->n-op) ; inline

: A-vany-op ( v1 quot -- n )
    [ (simd-vbitor) ] (A-v->n-op) ; inline
: A-vall-op ( v1 quot -- n )
    [ (simd-vbitand) ] (A-v->n-op) ; inline

: A-vmerge-head-op ( v1 v2 quot -- v )
    drop
    [ underlying1>> ] bi@
    [ A-rep (simd-(vmerge-head)) ]
    [ A-rep (simd-(vmerge-tail)) ] 2bi
    \ A boa ; inline
    
: A-vmerge-tail-op ( v1 v2 quot -- v )
    drop
    [ underlying2>> ] bi@
    [ A-rep (simd-(vmerge-head)) ]
    [ A-rep (simd-(vmerge-tail)) ] 2bi
    \ A boa ; inline

: A-v-conversion-op ( v1 to-type quot -- v )
    swap [ 
        [ [ underlying1>> A-rep ] dip call ]
        [ [ underlying2>> A-rep ] dip call ] 2bi
    ] dip '[ _ boa ] call( u1 u2 -- v ) ; inline

: A-vpack-op ( v1 v2 to-type quot -- v )
    swap [ 
        '[ [ underlying1>> ] [ underlying2>> ] bi A-rep @ ] bi*
    ] dip '[ _ boa ] call( u1 u2 -- v ) ; inline

: A-vunpack-head-op ( v1 to-type quot -- v )
    '[
        underlying1>>
        [ A-rep @ ]
        [ A-rep (simd-(vunpack-tail)) ] bi
    ] dip '[ _ boa ] call( u1 u2 -- v ) ; inline

: A-vunpack-tail-op ( v1 to-type quot -- v )
    '[
        underlying2>>
        [ A-rep (simd-(vunpack-head)) ]
        [ A-rep @ ] bi
    ] dip '[ _ boa ] call( u1 u2 -- v ) ; inline

simd new
    \ A >>class
    \ A-with >>ctor
    \ A-rep >>rep
    {
        { v.     A-v.-op   }
        { sum    A-sum-op  }
        { vnone? A-vany-op }
        { vany?  A-vany-op }
        { vall?  A-vall-op }
        { (vmerge-head) A-vmerge-head-op }
        { (vmerge-tail) A-vmerge-tail-op }
        { (v>integer) A-v-conversion-op }
        { (v>float) A-v-conversion-op }
        { (vpack-signed) A-vpack-op }
        { (vpack-unsigned) A-vpack-op }
        { (vunpack-head) A-vunpack-head-op }
        { (vunpack-tail) A-vunpack-tail-op }
    } >>special-wrappers
    {
        { { +vector+ +vector+ -> +vector+ } A-vv->v-op }
        { { +vector+ +scalar+ -> +vector+ } A-vn->v-op }
        { { +vector+ +literal+ -> +vector+ } A-vn->v-op }
        { { +vector+ -> +vector+ } A-v->v-op }
    } >>schema-wrappers
(define-simd-256)

;FUNCTOR
