USING: accessors alien.c-types arrays byte-arrays classes combinators
cpu.architecture effects fry functors generalizations generic
generic.parser kernel lexer literals macros math math.functions
math.vectors math.vectors.private math.vectors.simd.intrinsics namespaces parser
prettyprint.custom quotations sequences sequences.private vocabs
vocabs.loader words ;
QUALIFIED-WITH: alien.c-types c
IN: math.vectors.simd

ERROR: bad-simd-length got expected ;

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

: vn->v-op ( a n rep quot: ( (a) n rep -- (c) ) fallback-quot -- c )
    drop [ simd-unbox ] 3dip 3curry make-underlying ; inline

: vn->n-op ( a n rep quot: ( (a) n rep -- n ) fallback-quot -- n )
    drop [ underlying>> ] 3dip call ; inline

: v->n-op ( a rep quot: ( (a) rep -- n ) fallback-quot -- n )
    drop [ underlying>> ] 2dip call ; inline

: (vv->v-op) ( a b rep quot: ( (a) (b) rep -- (c) ) -- c )
    [ [ simd-unbox ] [ underlying>> ] bi* ] 2dip 3curry make-underlying ; inline

: (vv->n-op) ( a b rep quot: ( (a) (b) rep -- n ) -- n )
    [ [ underlying>> ] bi@ ] 2dip 3curry call ; inline
    
: vv->v-op ( a b rep quot: ( (a) (b) rep -- (c) ) fallback-quot -- c )
    [ '[ _ (vv->v-op) ] ] [ '[ drop @ ] ] bi* if-both-vectors-match ; inline

: vv'->v-op ( a b rep quot: ( (a) (b) rep -- (c) ) fallback-quot -- c )
    [ '[ _ (vv->v-op) ] ] [ '[ drop @ ] ] bi* if-both-vectors ; inline

: vv->n-op ( a b rep quot: ( (a) (b) rep -- n ) fallback-quot -- n )
    [ '[ _ (vv->n-op) ] ] [ '[ drop @ ] ] bi* if-both-vectors-match ; inline

PRIVATE>
>>

<<
<PRIVATE

! SIMD concrete type functor

FUNCTOR: define-simd-128 ( T -- )

A      DEFINES-CLASS ${T}
A-rep  IS            ${T}-rep
>A     DEFINES       >${T}
A-boa  DEFINES       ${T}-boa
A-with DEFINES       ${T}-with
A-cast DEFINES       ${T}-cast
A{     DEFINES       ${T}{

ELT     [ A-rep rep-component-type ]
N       [ A-rep rep-length ]
COERCER [ ELT c-type-class "coercer" word-prop [ ] or ]

SET-NTH [ ELT dup c:c-setter c:array-accessor ]

BOA-EFFECT [ N "n" <repetition> >array { "v" } <effect> ]

WHERE

TUPLE: A < simd-128 ;

M: A new-underlying    drop \ A boa ; inline
M: A simd-rep          drop A-rep ; inline
M: A simd-element-type drop ELT ; inline

M: A set-nth-unsafe
    [ ELT boolean>element ] 2dip
    underlying>> SET-NTH call ; inline

: >A ( seq -- simd ) \ A new clone-like ; inline

M: A like drop dup \ A instance? [ >A ] unless ; inline

: A-with ( n -- v ) COERCER call \ A-rep (simd-with) \ A boa ; inline
: A-cast ( v -- v' ) underlying>> \ A boa ; inline

! SIMD vectors as sequences

M: A hashcode* underlying>> hashcode* ; inline
M: A clone [ clone ] change-underlying ; inline
M: A length drop N ; inline
M: A nth-unsafe
    swap \ A-rep [ (simd-select) ] [ call-next-method ] vn->n-op ; inline
M: A c:byte-length drop 16 ; inline

M: A new-sequence
    2dup length =
    [ nip [ 16 (byte-array) ] make-underlying ]
    [ length bad-simd-length ] if ; inline

M: A equal?
    \ A-rep [ drop v= vall? ] [ 3drop f ] if-both-vectors-match ; inline

! SIMD primitive operations

M: A v+                \ A-rep [ (simd-v+)                ] [ call-next-method ] vv->v-op ; inline
M: A v-                \ A-rep [ (simd-v-)                ] [ call-next-method ] vv->v-op ; inline
M: A vneg              \ A-rep [ (simd-vneg)              ] [ call-next-method ] v->v-op  ; inline
M: A v+-               \ A-rep [ (simd-v+-)               ] [ call-next-method ] vv->v-op ; inline
M: A vs+               \ A-rep [ (simd-vs+)               ] [ call-next-method ] vv->v-op ; inline
M: A vs-               \ A-rep [ (simd-vs-)               ] [ call-next-method ] vv->v-op ; inline
M: A vs*               \ A-rep [ (simd-vs*)               ] [ call-next-method ] vv->v-op ; inline
M: A v*                \ A-rep [ (simd-v*)                ] [ call-next-method ] vv->v-op ; inline
M: A v*high            \ A-rep [ (simd-v*high)            ] [ call-next-method ] vv->v-op ; inline
M: A v/                \ A-rep [ (simd-v/)                ] [ call-next-method ] vv->v-op ; inline
M: A vavg              \ A-rep [ (simd-vavg)              ] [ call-next-method ] vv->v-op ; inline
M: A vmin              \ A-rep [ (simd-vmin)              ] [ call-next-method ] vv->v-op ; inline
M: A vmax              \ A-rep [ (simd-vmax)              ] [ call-next-method ] vv->v-op ; inline
M: A v.                \ A-rep [ (simd-v.)                ] [ call-next-method ] vv->n-op ; inline
M: A vsad              \ A-rep [ (simd-vsad)              ] [ call-next-method ] vv->n-op ; inline
M: A vsqrt             \ A-rep [ (simd-vsqrt)             ] [ call-next-method ] v->v-op  ; inline
M: A sum               \ A-rep [ (simd-sum)               ] [ call-next-method ] v->n-op  ; inline
M: A vabs              \ A-rep [ (simd-vabs)              ] [ call-next-method ] v->v-op  ; inline
M: A vbitand           \ A-rep [ (simd-vbitand)           ] [ call-next-method ] vv->v-op ; inline
M: A vbitandn          \ A-rep [ (simd-vbitandn)          ] [ call-next-method ] vv->v-op ; inline
M: A vbitor            \ A-rep [ (simd-vbitor)            ] [ call-next-method ] vv->v-op ; inline
M: A vbitxor           \ A-rep [ (simd-vbitxor)           ] [ call-next-method ] vv->v-op ; inline
M: A vbitnot           \ A-rep [ (simd-vbitnot)           ] [ call-next-method ] v->v-op  ; inline
M: A vand              \ A-rep [ (simd-vand)              ] [ call-next-method ] vv->v-op ; inline
M: A vandn             \ A-rep [ (simd-vandn)             ] [ call-next-method ] vv->v-op ; inline
M: A vor               \ A-rep [ (simd-vor)               ] [ call-next-method ] vv->v-op ; inline
M: A vxor              \ A-rep [ (simd-vxor)              ] [ call-next-method ] vv->v-op ; inline
M: A vnot              \ A-rep [ (simd-vnot)              ] [ call-next-method ] v->v-op  ; inline
M: A vlshift           \ A-rep [ (simd-vlshift)           ] [ call-next-method ] vn->v-op ; inline
M: A vrshift           \ A-rep [ (simd-vrshift)           ] [ call-next-method ] vn->v-op ; inline
M: A hlshift           \ A-rep [ (simd-hlshift)           ] [ call-next-method ] vn->v-op ; inline
M: A hrshift           \ A-rep [ (simd-hrshift)           ] [ call-next-method ] vn->v-op ; inline
M: A vshuffle-elements \ A-rep [ (simd-vshuffle-elements) ] [ call-next-method ] vn->v-op ; inline
M: A vshuffle-bytes    \ A-rep [ (simd-vshuffle-bytes)    ] [ call-next-method ] vv'->v-op ; inline
M: A (vmerge-head)     \ A-rep [ (simd-vmerge-head)       ] [ call-next-method ] vv->v-op ; inline
M: A (vmerge-tail)     \ A-rep [ (simd-vmerge-tail)       ] [ call-next-method ] vv->v-op ; inline
M: A v<=               \ A-rep [ (simd-v<=)               ] [ call-next-method ] vv->v-op ; inline
M: A v<                \ A-rep [ (simd-v<)                ] [ call-next-method ] vv->v-op ; inline
M: A v=                \ A-rep [ (simd-v=)                ] [ call-next-method ] vv->v-op ; inline
M: A v>                \ A-rep [ (simd-v>)                ] [ call-next-method ] vv->v-op ; inline
M: A v>=               \ A-rep [ (simd-v>=)               ] [ call-next-method ] vv->v-op ; inline
M: A vunordered?       \ A-rep [ (simd-vunordered?)       ] [ call-next-method ] vv->v-op ; inline
M: A vany?             \ A-rep [ (simd-vany?)             ] [ call-next-method ] v->n-op  ; inline
M: A vall?             \ A-rep [ (simd-vall?)             ] [ call-next-method ] v->n-op  ; inline
M: A vnone?            \ A-rep [ (simd-vnone?)            ] [ call-next-method ] v->n-op  ; inline

! SIMD high-level specializations

M: A vbroadcast swap nth A-with ; inline
M: A n+v [ A-with ] dip v+ ; inline
M: A n-v [ A-with ] dip v- ; inline
M: A n*v [ A-with ] dip v* ; inline
M: A n/v [ A-with ] dip v/ ; inline
M: A v+n A-with v+ ; inline
M: A v-n A-with v- ; inline
M: A v*n A-with v* ; inline
M: A v/n A-with v/ ; inline
M: A norm-sq dup v. assert-positive ; inline
M: A distance v- norm ; inline

M: A >pprint-sequence ;
M: A pprint* pprint-object ;

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
    { [ underlying>> ] 2dip A-rep set-alien-vector } >quotation >>setter
    16 >>size
    16 >>align
    A-rep >>rep
\ A c:typedef

;FUNCTOR

SYNTAX: SIMD-128:
    scan define-simd-128 ;

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

M: simd-128 vshuffle ( u perm -- v )
    vshuffle-bytes ; inline

M: uchar-16 v*hs+
    uchar-16-rep [ (simd-v*hs+) ] [ call-next-method ] vv->v-op ushort-8-cast ; inline
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

"mirrors" vocab [
    "math.vectors.simd.mirrors" require
] when
