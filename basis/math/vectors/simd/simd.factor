USING: accessors alien arrays byte-arrays classes combinators
cpu.architecture effects functors generalizations kernel lexer
literals math math.bitwise math.vectors
math.vectors.simd.intrinsics parser prettyprint.custom
quotations sequences sequences.generalizations sequences.private
words ;
QUALIFIED-WITH: alien.c-types c
IN: math.vectors.simd

ERROR: bad-simd-length got expected ;
ERROR: bad-simd-vector obj ;

<<
<PRIVATE
! Primitive SIMD constructors

GENERIC: new-underlying ( underlying seq -- seq' )

: make-underlying ( seq quot -- seq' )
    dip new-underlying ; inline
: change-underlying ( seq quot -- seq' )
    '[ underlying>> @ ] keep new-underlying ; inline
PRIVATE>
>>

<PRIVATE

! Helper for boolean vector literals

: vector-true-value ( class -- value )
    { c:float c:double } member? [ -1 bits>double ] [ -1 ] if ; foldable

: vector-false-value ( type -- value )
    { c:float c:double } member? [ 0.0 ] [ 0 ] if ; foldable

: boolean>element ( bool/elt type -- elt )
    swap {
        { t [ vector-true-value  ] }
        { f [ vector-false-value ] }
        [ nip ]
    } case ; inline

PRIVATE>

! SIMD base type

TUPLE: simd-128
    { underlying byte-array read-only initial: $[ 16 <byte-array> ] } ;

GENERIC: simd-element-type ( obj -- c-type )
GENERIC: simd-rep ( simd -- rep )
GENERIC: simd-with ( n exemplar -- v )

M: object simd-element-type drop f ;
M: object simd-rep drop f ;

<<
<PRIVATE

DEFER: simd-construct-op

! Unboxers for SIMD operations
: if-both-vectors ( a b rep t f -- )
    [ 2over [ simd-128? ] both? ] 2dip if ; inline

: if-both-vectors-match ( a b rep t f -- )
    [ 3dup [ drop [ simd-128? ] both? ] [ '[ simd-rep _ eq? ] both? ] 3bi and ]
    2dip if ; inline

: simd-unbox ( a -- a (a) )
    [ ] [ underlying>> ] bi ; inline

: v->v-op ( a rep quot: ( (a) rep -- (c) ) fallback-quot -- c )
    drop [ simd-unbox ] 2dip 2curry make-underlying ; inline

: vx->v-op ( a obj rep quot: ( (a) obj rep -- (c) ) fallback-quot -- c )
    drop [ simd-unbox ] 3dip 3curry make-underlying ; inline

: vn->v-op ( a n rep quot: ( (a) n rep -- (c) ) fallback-quot -- c )
    drop [ [ simd-unbox ] [ >fixnum ] bi* ] 2dip 3curry make-underlying ; inline

: vx->x-op ( a obj rep quot: ( (a) obj rep -- obj ) fallback-quot -- obj )
    drop [ underlying>> ] 3dip call ; inline

: v->x-op ( a rep quot: ( (a) rep -- obj ) fallback-quot -- obj )
    drop [ underlying>> ] 2dip call ; inline

: (vv->v-op) ( a b rep quot: ( (a) (b) rep -- (c) ) -- c )
    [ [ simd-unbox ] [ underlying>> ] bi* ] 2dip 3curry make-underlying ; inline

: (vv->x-op) ( a b rep quot: ( (a) (b) rep -- n ) -- n )
    [ [ underlying>> ] bi@ ] 2dip 3curry call ; inline

: (vvx->v-op) ( a b obj rep quot: ( (a) (b) obj rep -- (c) ) -- c )
    [ [ simd-unbox ] [ underlying>> ] bi* ] 3dip 2curry 2curry make-underlying ; inline

: vv->v-op ( a b rep quot: ( (a) (b) rep -- (c) ) fallback-quot -- c )
    [ '[ _ (vv->v-op) ] ] [ '[ drop @ ] ] bi* if-both-vectors-match ; inline

:: vvx->v-op ( a b obj rep quot: ( (a) (b) obj rep -- (c) ) fallback-quot -- c )
    a b rep
    [ obj swap quot (vvx->v-op) ]
    [ drop obj fallback-quot call ] if-both-vectors-match ; inline

: vv'->v-op ( a b rep quot: ( (a) (b) rep -- (c) ) fallback-quot -- c )
    [ '[ _ (vv->v-op) ] ] [ '[ drop @ ] ] bi* if-both-vectors ; inline

: vv->x-op ( a b rep quot: ( (a) (b) rep -- obj ) fallback-quot -- obj )
    [ '[ _ (vv->x-op) ] ] [ '[ drop @ ] ] bi* if-both-vectors-match ; inline

: mask>count ( n rep -- n' )
    [ bit-count ] dip {
        { float-4-rep     [ ] }
        { double-2-rep    [ -1 shift ] }
        { uchar-16-rep    [ ] }
        { char-16-rep     [ ] }
        { ushort-8-rep    [ -1 shift ] }
        { short-8-rep     [ -1 shift ] }
        { ushort-8-rep    [ -1 shift ] }
        { int-4-rep       [ -2 shift ] }
        { uint-4-rep      [ -2 shift ] }
        { longlong-2-rep  [ -3 shift ] }
        { ulonglong-2-rep [ -3 shift ] }
    } case ; inline

PRIVATE>
>>

<<

! SIMD vectors as sequences

M: simd-128 hashcode* underlying>> hashcode* ; inline
M: simd-128 clone [ clone ] change-underlying ; inline
M: simd-128 byte-length drop 16 ; inline

M: simd-128 new-sequence
    2dup length =
    [ nip [ 16 (byte-array) ] make-underlying ]
    [ length bad-simd-length ] if ; inline

M: simd-128 equal?
    dup simd-rep [ drop v= vall? ] [ 3drop f ] if-both-vectors-match ; inline

! SIMD primitive operations

M: simd-128 v+
    dup simd-rep [ (simd-v+) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 v-
    dup simd-rep [ (simd-v-) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vneg
    dup simd-rep [ (simd-vneg) ] [ call-next-method ] v->v-op  ; inline
M: simd-128 v+-
    dup simd-rep [ (simd-v+-) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vs+
    dup simd-rep [ (simd-vs+) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vs-
    dup simd-rep [ (simd-vs-) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vs*
    dup simd-rep [ (simd-vs*) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 v*
    dup simd-rep [ (simd-v*) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 v*high
    dup simd-rep [ (simd-v*high) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 v/
    dup simd-rep [ (simd-v/) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vavg
    dup simd-rep [ (simd-vavg) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vmin
    dup simd-rep [ (simd-vmin) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vmax
    dup simd-rep [ (simd-vmax) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vdot
    dup simd-rep [ (simd-vdot) ] [ call-next-method ] vv->x-op ; inline
M: simd-128 vsad
    dup simd-rep [ (simd-vsad) ] [ call-next-method ] vv->x-op ; inline
M: simd-128 vsqrt
    dup simd-rep [ (simd-vsqrt) ] [ call-next-method ] v->v-op  ; inline
M: simd-128 sum
    dup simd-rep [ (simd-sum) ] [ call-next-method ] v->x-op  ; inline
M: simd-128 vabs
    dup simd-rep [ (simd-vabs) ] [ call-next-method ] v->v-op  ; inline
M: simd-128 vbitand
    dup simd-rep [ (simd-vbitand) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vbitandn
    dup simd-rep [ (simd-vbitandn) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vbitor
    dup simd-rep [ (simd-vbitor) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vbitxor
    dup simd-rep [ (simd-vbitxor) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vbitnot
    dup simd-rep [ (simd-vbitnot) ] [ call-next-method ] v->v-op  ; inline
M: simd-128 vand
    dup simd-rep [ (simd-vand) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vandn
    dup simd-rep [ (simd-vandn) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vor
    dup simd-rep [ (simd-vor) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vxor
    dup simd-rep [ (simd-vxor) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vnot
    dup simd-rep [ (simd-vnot) ] [ call-next-method ] v->v-op  ; inline
M: simd-128 vlshift
    over simd-rep [ (simd-vlshift) ] [ call-next-method ] vn->v-op ; inline
M: simd-128 vrshift
    over simd-rep [ (simd-vrshift) ] [ call-next-method ] vn->v-op ; inline
M: simd-128 hlshift
    over simd-rep [ (simd-hlshift) ] [ call-next-method ] vn->v-op ; inline
M: simd-128 hrshift
    over simd-rep [ (simd-hrshift) ] [ call-next-method ] vn->v-op ; inline
M: simd-128 vshuffle-elements
    over simd-rep [ (simd-vshuffle-elements) ] [ call-next-method ] vx->v-op ; inline
M: simd-128 vshuffle2-elements
    over simd-rep [ (simd-vshuffle2-elements) ] [ call-next-method ] vvx->v-op ; inline
M: simd-128 vshuffle-bytes
    dup simd-rep [ (simd-vshuffle-bytes) ] [ call-next-method ] vv'->v-op ; inline
M: simd-128 (vmerge-head)
    dup simd-rep [ (simd-vmerge-head) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 (vmerge-tail)
    dup simd-rep [ (simd-vmerge-tail) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 v<=
    dup simd-rep [ (simd-v<=) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 v<
    dup simd-rep [ (simd-v<) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 v=
    dup simd-rep [ (simd-v=) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 v>
    dup simd-rep [ (simd-v>) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 v>=
    dup simd-rep [ (simd-v>=) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vunordered?
    dup simd-rep [ (simd-vunordered?) ] [ call-next-method ] vv->v-op ; inline
M: simd-128 vany?
    dup simd-rep [ (simd-vany?) ] [ call-next-method ] v->x-op  ; inline
M: simd-128 vall?
    dup simd-rep [ (simd-vall?) ] [ call-next-method ] v->x-op  ; inline
M: simd-128 vnone?
    dup simd-rep [ (simd-vnone?) ] [ call-next-method ] v->x-op  ; inline
M: simd-128 vcount
    dup simd-rep
    [ [ (simd-vgetmask) (simd-positive) ] [ call-next-method ] v->x-op ]
    [ mask>count ] bi ; inline

! SIMD high-level specializations

M: simd-128 vbroadcast swap [ nth ] [ simd-with ] bi ; inline
M: simd-128 n+v [ simd-with ] keep v+ ; inline
M: simd-128 n-v [ simd-with ] keep v- ; inline
M: simd-128 n*v [ simd-with ] keep v* ; inline
M: simd-128 n/v [ simd-with ] keep v/ ; inline
M: simd-128 v+n over simd-with v+ ; inline
M: simd-128 v-n over simd-with v- ; inline
M: simd-128 v*n over simd-with v* ; inline
M: simd-128 v/n over simd-with v/ ; inline
M: simd-128 norm-sq dup vdot (simd-positive) ; inline
M: simd-128 distance v- norm ; inline

M: simd-128 >pprint-sequence ;
M: simd-128 pprint* pprint-object ;

<PRIVATE

! SIMD concrete type functor

<FUNCTOR: define-simd-128 ( T -- )

A      DEFINES-CLASS ${T}
A-rep  IS            ${T}-rep
>A     DEFINES       >${T}
A-boa  DEFINES       ${T}-boa
A-with DEFINES       ${T}-with
A-cast DEFINES       ${T}-cast
A{     DEFINES       ${T}{

ELT     [ A-rep rep-component-type ]
N       [ A-rep rep-length ]
COERCER [ ELT c:c-type-class "coercer" word-prop [ ] or ]

BOA-EFFECT [ N "n" <array> { "v" } <effect> ]

WHERE

TUPLE: A < simd-128 ; final

M: A new-underlying    drop \ A boa ; inline
M: A simd-rep          drop A-rep ; inline
M: A simd-element-type drop ELT ; inline
M: A simd-with         drop A-with ; inline

M: A nth-unsafe
    swap \ A-rep [ (simd-select) ] [ call-next-method ] vx->x-op ; inline
M: A set-nth-unsafe
    [ ELT boolean>element ] 2dip
    underlying>> ELT c:set-alien-element ; inline

: >A ( seq -- simd ) \ A new clone-like ; inline

M: A like drop dup \ A instance? [ >A ] unless ; inline

: A-with ( n -- v ) COERCER call \ A-rep (simd-with) \ A boa ; inline
: A-cast ( v -- v' ) underlying>> \ A boa ; inline

M: A length drop N ; inline

\ A-boa
[ COERCER N napply ] N {
    { 2 [ [ A-rep (simd-gather-2) A boa ] ] }
    { 4 [ [ A-rep (simd-gather-4) A boa ] ] }
    [ \ A new '[ _ _ nsequence ] ]
} case compose
BOA-EFFECT define-inline

M: A pprint-delims drop \ A{ \ } ;
SYNTAX: A{ \ } [ >A ] parse-literal ;

INSTANCE: A sequence

c:<c-type>
    byte-array >>class
    A >>boxed-class
    { A-rep alien-vector A boa } >quotation >>getter
    {
        [ dup simd-128? [ bad-simd-vector ] unless underlying>> ] 2dip
        A-rep set-alien-vector
    } >quotation >>setter
    16 >>size
    16 >>align
    A-rep >>rep
\ A c:typedef

;FUNCTOR>

SYNTAX: SIMD-128:
    scan-token define-simd-128 ;

PRIVATE>

>>

! SIMD instances

SIMD-128: char-16
SIMD-128: uchar-16
SIMD-128: short-8
SIMD-128: ushort-8
SIMD-128: int-4
SIMD-128: uint-4
SIMD-128: longlong-2
SIMD-128: ulonglong-2
SIMD-128: float-4
SIMD-128: double-2

! misc

M: simd-128 vshuffle
    vshuffle-bytes ; inline

M: uchar-16 v*hs+
    uchar-16-rep [ (simd-v*hs+) ] [ call-next-method ] vv->v-op short-8-cast ; inline
M: ushort-8 v*hs+
    ushort-8-rep [ (simd-v*hs+) ] [ call-next-method ] vv->v-op uint-4-cast ; inline
M: uint-4 v*hs+
    uint-4-rep [ (simd-v*hs+) ] [ call-next-method ] vv->v-op ulonglong-2-cast ; inline
M: char-16 v*hs+
    char-16-rep [ (simd-v*hs+) ] [ call-next-method ] vv->v-op short-8-cast ; inline
M: short-8 v*hs+
    short-8-rep [ (simd-v*hs+) ] [ call-next-method ] vv->v-op int-4-cast ; inline
M: int-4 v*hs+
    int-4-rep [ (simd-v*hs+) ] [ call-next-method ] vv->v-op longlong-2-cast ; inline
