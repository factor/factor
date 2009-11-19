USING: accessors alien.c-types arrays byte-arrays classes combinators
cpu.architecture effects fry functors generalizations generic
generic.parser kernel lexer literals macros math math.functions
math.vectors math.vectors.private namespaces parser
prettyprint.custom quotations sequences sequences.private vocabs
vocabs.loader words ;
QUALIFIED-WITH: alien.c-types c
IN: math.vectors.simd

DEFER: vconvert
DEFER: simd-with
DEFER: simd-boa
DEFER: simd-cast

ERROR: bad-simd-call word ;
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

! SIMD intrinsics

: (simd-v+)                ( a b rep -- c ) \ v+ bad-simd-call ;
: (simd-v-)                ( a b rep -- c ) \ v- bad-simd-call ;
: (simd-vneg)              ( a   rep -- c ) \ vneg bad-simd-call ;
: (simd-v+-)               ( a b rep -- c ) \ v+- bad-simd-call ;
: (simd-vs+)               ( a b rep -- c ) \ vs+ bad-simd-call ;
: (simd-vs-)               ( a b rep -- c ) \ vs- bad-simd-call ;
: (simd-vs*)               ( a b rep -- c ) \ vs* bad-simd-call ;
: (simd-v*)                ( a b rep -- c ) \ v* bad-simd-call ;
: (simd-v/)                ( a b rep -- c ) \ v/ bad-simd-call ;
: (simd-vmin)              ( a b rep -- c ) \ vmin bad-simd-call ;
: (simd-vmax)              ( a b rep -- c ) \ vmax bad-simd-call ;
: (simd-v.)                ( a b rep -- n ) \ v. bad-simd-call ;
: (simd-vsqrt)             ( a   rep -- c ) \ vsqrt bad-simd-call ;
: (simd-sum)               ( a   rep -- n ) \ sum bad-simd-call ;
: (simd-vabs)              ( a   rep -- c ) \ vabs bad-simd-call ;
: (simd-vbitand)           ( a b rep -- c ) \ vbitand bad-simd-call ;
: (simd-vbitandn)          ( a b rep -- c ) \ vbitandn bad-simd-call ;
: (simd-vbitor)            ( a b rep -- c ) \ vbitor bad-simd-call ;
: (simd-vbitxor)           ( a b rep -- c ) \ vbitxor bad-simd-call ;
: (simd-vbitnot)           ( a   rep -- c ) \ vbitnot bad-simd-call ;
: (simd-vand)              ( a b rep -- c ) \ vand bad-simd-call ;
: (simd-vandn)             ( a b rep -- c ) \ vandn bad-simd-call ;
: (simd-vor)               ( a b rep -- c ) \ vor bad-simd-call ;
: (simd-vxor)              ( a b rep -- c ) \ vxor bad-simd-call ;
: (simd-vnot)              ( a   rep -- c ) \ vnot bad-simd-call ;
: (simd-vlshift)           ( a n rep -- c ) \ vlshift bad-simd-call ;
: (simd-vrshift)           ( a n rep -- c ) \ vrshift bad-simd-call ;
: (simd-hlshift)           ( a n rep -- c ) \ hlshift bad-simd-call ;
: (simd-hrshift)           ( a n rep -- c ) \ hrshift bad-simd-call ;
: (simd-vshuffle-elements) ( a n rep -- c ) \ vshuffle-elements bad-simd-call ;
: (simd-vshuffle-bytes)    ( a b rep -- c ) \ vshuffle-bytes bad-simd-call ;
: (simd-vmerge-head)       ( a b rep -- c ) \ (vmerge-head) bad-simd-call ;
: (simd-vmerge-tail)       ( a b rep -- c ) \ (vmerge-tail) bad-simd-call ;
: (simd-v<=)               ( a b rep -- c ) \ v<= bad-simd-call ;
: (simd-v<)                ( a b rep -- c ) \ v< bad-simd-call ;
: (simd-v=)                ( a b rep -- c ) \ v= bad-simd-call ;
: (simd-v>)                ( a b rep -- c ) \ v> bad-simd-call ;
: (simd-v>=)               ( a b rep -- c ) \ v>= bad-simd-call ;
: (simd-vunordered?)       ( a b rep -- c ) \ vunordered? bad-simd-call ;
: (simd-vany?)             ( a   rep -- ? ) \ vany? bad-simd-call ;
: (simd-vall?)             ( a   rep -- ? ) \ vall? bad-simd-call ;
: (simd-vnone?)            ( a   rep -- ? ) \ vnone? bad-simd-call ;
: (simd-v>float)           ( a   rep -- c ) \ vconvert bad-simd-call ;
: (simd-v>integer)         ( a   rep -- c ) \ vconvert bad-simd-call ;
: (simd-vpack-signed)      ( a b rep -- c ) \ vconvert bad-simd-call ;
: (simd-vpack-unsigned)    ( a b rep -- c ) \ vconvert bad-simd-call ;
: (simd-vunpack-head)      ( a   rep -- c ) \ vconvert bad-simd-call ;
: (simd-vunpack-tail)      ( a   rep -- c ) \ vconvert bad-simd-call ;
: (simd-with)              (   n rep -- v ) \ simd-with bad-simd-call ;
: (simd-gather-2)          ( m n rep -- v ) \ simd-boa bad-simd-call ;
: (simd-gather-4)          ( m n o p rep -- v ) \ simd-boa bad-simd-call ;
: (simd-select)            ( a n rep -- n ) \ nth bad-simd-call ;

PRIVATE>

: alien-vector     (       c-ptr n rep -- value ) \ alien-vector bad-simd-call ;
: set-alien-vector ( value c-ptr n rep --       ) \ set-alien-vector bad-simd-call ;

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

<<
: assert-positive ( x -- y ) ;

: rep-length ( rep -- n )
    16 swap rep-component-type heap-size /i ; foldable
>>

<<
<PRIVATE

DEFER: simd-construct-op

! Unboxers for SIMD operations
: if-both-vectors ( a b rep t f -- )
    [ 2over [ simd-128? ] both? ] 2dip if ; inline

: if-both-vectors-match ( a b rep t f -- )
    [ 3dup [ drop [ simd-128? ] both? ] [ '[ simd-rep _ eq? ] both? ] 3bi and ]
    2dip if ; inline

: simd-construct-op ( exemplar quot: ( rep -- v ) -- v )
    [ dup simd-rep ] dip curry make-underlying ; inline

: simd-unbox ( a -- a (a) )
    [ ] [ underlying>> ] bi ; inline

: v->v-op ( a rep quot: ( (a) rep -- (c) ) fallback-quot -- c )
    drop [ simd-unbox ] 2dip 2curry make-underlying ; inline

: vn->v-op ( a n rep quot: ( (a) n rep -- (c) ) fallback-quot -- c )
    drop [ simd-unbox ] 3dip 3curry make-underlying ; inline

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

ELT   [ A-rep rep-component-type ]
N     [ A-rep rep-length ]

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

: A-with ( n -- v ) \ A new simd-with ; inline
: A-cast ( v -- v' ) \ A new simd-cast ; inline

! SIMD vectors as sequences

M: A hashcode* underlying>> hashcode* ; inline
M: A clone [ clone ] change-underlying ; inline
M: A length drop N ; inline
M: A nth-unsafe swap \ A-rep (simd-select) ; inline
M: A c:byte-length drop 16 ; inline

M: A new-sequence
    2dup length =
    [ nip [ 16 (byte-array) ] make-underlying ]
    [ length bad-simd-length ] if ; inline

M: A equal?
    \ A [ drop v= vall? ] [ 3drop f ] if-both-vectors-match ; inline

! SIMD primitive operations

M: A v+                \ A [ (simd-v+)                ] [ call-next-method ] vv->v-op ; inline
M: A v-                \ A [ (simd-v-)                ] [ call-next-method ] vv->v-op ; inline
M: A vneg              \ A [ (simd-vneg)              ] [ call-next-method ] v->v-op  ; inline
M: A v+-               \ A [ (simd-v+-)               ] [ call-next-method ] vv->v-op ; inline
M: A vs+               \ A [ (simd-vs+)               ] [ call-next-method ] vv->v-op ; inline
M: A vs-               \ A [ (simd-vs-)               ] [ call-next-method ] vv->v-op ; inline
M: A vs*               \ A [ (simd-vs*)               ] [ call-next-method ] vv->v-op ; inline
M: A v*                \ A [ (simd-v*)                ] [ call-next-method ] vv->v-op ; inline
M: A v/                \ A [ (simd-v/)                ] [ call-next-method ] vv->v-op ; inline
M: A vmin              \ A [ (simd-vmin)              ] [ call-next-method ] vv->v-op ; inline
M: A vmax              \ A [ (simd-vmax)              ] [ call-next-method ] vv->v-op ; inline
M: A v.                \ A [ (simd-v.)                ] [ call-next-method ] vv->n-op ; inline
M: A vsqrt             \ A [ (simd-vsqrt)             ] [ call-next-method ] v->v-op  ; inline
M: A sum               \ A [ (simd-sum)               ] [ call-next-method ] v->n-op  ; inline
M: A vabs              \ A [ (simd-vabs)              ] [ call-next-method ] v->v-op  ; inline
M: A vbitand           \ A [ (simd-vbitand)           ] [ call-next-method ] vv->v-op ; inline
M: A vbitandn          \ A [ (simd-vbitandn)          ] [ call-next-method ] vv->v-op ; inline
M: A vbitor            \ A [ (simd-vbitor)            ] [ call-next-method ] vv->v-op ; inline
M: A vbitxor           \ A [ (simd-vbitxor)           ] [ call-next-method ] vv->v-op ; inline
M: A vbitnot           \ A [ (simd-vbitnot)           ] [ call-next-method ] v->v-op  ; inline
M: A vand              \ A [ (simd-vand)              ] [ call-next-method ] vv->v-op ; inline
M: A vandn             \ A [ (simd-vandn)             ] [ call-next-method ] vv->v-op ; inline
M: A vor               \ A [ (simd-vor)               ] [ call-next-method ] vv->v-op ; inline
M: A vxor              \ A [ (simd-vxor)              ] [ call-next-method ] vv->v-op ; inline
M: A vnot              \ A [ (simd-vnot)              ] [ call-next-method ] v->v-op  ; inline
M: A vlshift           \ A [ (simd-vlshift)           ] [ call-next-method ] vn->v-op ; inline
M: A vrshift           \ A [ (simd-vrshift)           ] [ call-next-method ] vn->v-op ; inline
M: A hlshift           \ A [ (simd-hlshift)           ] [ call-next-method ] vn->v-op ; inline
M: A hrshift           \ A [ (simd-hrshift)           ] [ call-next-method ] vn->v-op ; inline
M: A vshuffle-elements \ A [ (simd-vshuffle-elements) ] [ call-next-method ] vn->v-op ; inline
M: A vshuffle-bytes    \ A [ (simd-vshuffle-bytes)    ] [ call-next-method ] vv->v-op ; inline
M: A (vmerge-head)     \ A [ (simd-vmerge-head)       ] [ call-next-method ] vv->v-op ; inline
M: A (vmerge-tail)     \ A [ (simd-vmerge-tail)       ] [ call-next-method ] vv->v-op ; inline
M: A v<=               \ A [ (simd-v<=)               ] [ call-next-method ] vv->v-op ; inline
M: A v<                \ A [ (simd-v<)                ] [ call-next-method ] vv->v-op ; inline
M: A v=                \ A [ (simd-v=)                ] [ call-next-method ] vv->v-op ; inline
M: A v>                \ A [ (simd-v>)                ] [ call-next-method ] vv->v-op ; inline
M: A v>=               \ A [ (simd-v>=)               ] [ call-next-method ] vv->v-op ; inline
M: A vunordered?       \ A [ (simd-vunordered?)       ] [ call-next-method ] vv->v-op ; inline
M: A vany?             \ A [ (simd-vany?)             ] [ call-next-method ] v->n-op  ; inline
M: A vall?             \ A [ (simd-vall?)             ] [ call-next-method ] v->n-op  ; inline
M: A vnone?            \ A [ (simd-vnone?)            ] [ call-next-method ] v->n-op  ; inline

! SIMD high-level specializations

M: A vbroadcast [ swap nth ] keep simd-with ; inline
M: A n+v [ simd-with ] keep v+ ; inline
M: A n-v [ simd-with ] keep v- ; inline
M: A n*v [ simd-with ] keep v* ; inline
M: A n/v [ simd-with ] keep v/ ; inline
M: A v+n over simd-with v+ ; inline
M: A v-n over simd-with v- ; inline
M: A v*n over simd-with v* ; inline
M: A v/n over simd-with v/ ; inline
M: A norm-sq dup v. assert-positive ; inline
M: A norm      norm-sq sqrt ; inline
M: A distance  v- norm ; inline

! M: simd-128 >pprint-sequence ;
! M: simd-128 pprint* pprint-object ;

\ A-boa \ A new N {
    { 2 [ '[ _ [ (simd-gather-2) ] simd-construct-op ] ] }
    { 4 [ '[ _ [ (simd-gather-4) ] simd-construct-op ] ] }
    [ swap '[ _ _ nsequence ] ]
} case BOA-EFFECT define-inline

M: A pprint-delims drop \ A{ \ } ;
SYNTAX: A{ \ } [ >A ] parse-literal ;

c:<c-type>
    byte-array >>class
    A >>boxed-class
    [ A-rep alien-vector \ A boa ] >>getter
    [ [ underlying>> ] 2dip A-rep set-alien-vector ] >>setter
    16 >>size
    16 >>align
    A-rep >>rep
\ A c:typedef

;FUNCTOR

SYNTAX: SIMD-128:
    scan define-simd-128 ;

PRIVATE>

>>

INSTANCE: simd-128 sequence

! SIMD constructors

: simd-with ( n seq -- v )
    [ (simd-with) ] simd-construct-op ; inline

MACRO: simd-boa ( class -- )
    new dup length {
        { 2 [ '[ _ [ (simd-gather-2) ] simd-construct-op ] ] }
        { 4 [ '[ _ [ (simd-gather-4) ] simd-construct-op ] ] }
        [ swap '[ _ _ nsequence ] ]
    } case ;

: simd-cast ( v seq -- v' )
    [ underlying>> ] dip new-underlying ; inline

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

"compiler.tree.propagation.simd" require
"compiler.cfg.intrinsics.simd" require
"compiler.cfg.value-numbering.simd" require

"mirrors" vocab [
    "math.vectors.simd.mirrors" require
] when
