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

: alien-vector     ( c-ptr n rep -- value ) \ alien-vector bad-simd-call ;
: set-alien-vector ( c-ptr n rep -- value ) \ set-alien-vector bad-simd-call ;

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
: rep-length ( rep -- n )
    16 swap rep-component-type heap-size /i ; foldable

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
M: A length            drop N ; inline

M: A set-nth-unsafe
    [ ELT boolean>element ] 2dip
    underlying>> SET-NTH call ; inline

: >A ( seq -- simd ) \ A new clone-like ; inline

M: A like drop dup \ A instance? [ >A ] unless ; inline

: A-with ( n -- v ) \ A new simd-with ; inline
: A-cast ( v -- v' ) \ A new simd-cast ; inline

\ A-boa { \ A simd-boa } >quotation BOA-EFFECT define-inline

! M: A pprint-delims drop \ A{ \ } ;
! SYNTAX: A{ \ } [ >A ] parse-literal ;

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

: assert-positive ( x -- y ) ;

! SIMD vectors as sequences

M: simd-128 hashcode* underlying>> hashcode* ; inline
M: simd-128 clone [ clone ] change-underlying ; inline
M: simd-128 length simd-rep rep-length ; inline
M: simd-128 nth-unsafe [ nip ] 2keep simd-rep (simd-select) ; inline
M: simd-128 c:byte-length drop 16 ; inline

M: simd-128 new-sequence
    2dup length =
    [ nip [ 16 (byte-array) ] make-underlying ]
    [ length bad-simd-length ] if ; inline

! M: simd-128 >pprint-sequence ;
! M: simd-128 pprint* pprint-object ;

INSTANCE: simd-128 sequence

! Unboxers for SIMD operations
<<
<PRIVATE

: if-both-vectors ( a b t f -- )
    [ 2dup [ simd-128? ] both? ] 2dip if ; inline

: if-both-vectors-match ( a b t f -- )
    [ 2dup [ [ simd-128? ] both? ] [ [ simd-rep ] bi@ eq? ] 2bi and ]
    2dip if ; inline

: simd-construct-op ( exemplar quot: ( rep -- v ) -- v )
    [ dup simd-rep ] dip curry make-underlying ; inline

: simd-unbox ( a -- a (a) a-rep )
    [ ] [ underlying>> ] [ simd-rep ] tri ; inline

: simd-v->v-op ( a quot: ( (a) rep -- (c) ) -- c )
    [ simd-unbox ] dip 2curry make-underlying ; inline

: simd-vn->v-op ( a n quot: ( (a) n rep -- (c) ) -- c )
    [ simd-unbox ] [ swap ] [ 3curry ] tri* make-underlying ; inline

: simd-v->n-op ( a quot: ( (a) rep -- n ) -- n )
    [ [ underlying>> ] [ simd-rep ] bi ] dip call ; inline

: ((simd-vv->v-op)) ( a b quot: ( (a) (b) rep -- (c) ) -- c )
    [ simd-unbox ] [ underlying>> swap ] [ 3curry ] tri* make-underlying ; inline

: ((simd-vv->n-op)) ( a b quot: ( (a) (b) rep -- n ) -- n )
    [ [ underlying>> ] [ simd-rep ] bi ]
    [ underlying>> swap ] [ ] tri* call ; inline
    
: (simd-vv->v-op) ( a b quot: ( (a) (b) rep -- (c) ) fallback-quot -- c )
    [ '[ _ ((simd-vv->v-op)) ] ] dip if-both-vectors-match ; inline

: (simd-vv'->v-op) ( a b quot: ( (a) (b) rep -- (c) ) fallback-quot -- c )
    [ '[ _ ((simd-vv->v-op)) ] ] dip if-both-vectors ; inline

: (simd-vv->n-op) ( a b quot: ( (a) (b) rep -- n ) fallback-quot -- n )
    [ '[ _ ((simd-vv->n-op)) ] ] dip if-both-vectors-match ; inline

: (simd-method-fallback) ( accum word -- accum )
    [ current-method get literalize \ (call-next-method) [ ] 2sequence suffix! ]
    dip suffix! ; 

SYNTAX: simd-vv->v-op
    \ (simd-vv->v-op) (simd-method-fallback) ; 
SYNTAX: simd-vv'->v-op
    \ (simd-vv'->v-op) (simd-method-fallback) ;
SYNTAX: simd-vv->n-op
    \ (simd-vv->n-op) (simd-method-fallback) ; 

PRIVATE>
>>

M: simd-128 equal?
    [ v= vall? ] [ 2drop f ] if-both-vectors-match ; inline

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

! SIMD primitive operations

M: simd-128 v+                 [ (simd-v+)                 ] simd-vv->v-op ; inline
M: simd-128 v-                 [ (simd-v-)                 ] simd-vv->v-op ; inline
M: simd-128 vneg               [ (simd-vneg)               ] simd-v->v-op  ; inline
M: simd-128 v+-                [ (simd-v+-)                ] simd-vv->v-op ; inline
M: simd-128 vs+                [ (simd-vs+)                ] simd-vv->v-op ; inline
M: simd-128 vs-                [ (simd-vs-)                ] simd-vv->v-op ; inline
M: simd-128 vs*                [ (simd-vs*)                ] simd-vv->v-op ; inline
M: simd-128 v*                 [ (simd-v*)                 ] simd-vv->v-op ; inline
M: simd-128 v/                 [ (simd-v/)                 ] simd-vv->v-op ; inline
M: simd-128 vmin               [ (simd-vmin)               ] simd-vv->v-op ; inline
M: simd-128 vmax               [ (simd-vmax)               ] simd-vv->v-op ; inline
M: simd-128 v.                 [ (simd-v.)                 ] simd-vv->n-op ; inline
M: simd-128 vsqrt              [ (simd-vsqrt)              ] simd-v->v-op  ; inline
M: simd-128 sum                [ (simd-sum)                ] simd-v->n-op  ; inline
M: simd-128 vabs               [ (simd-vabs)               ] simd-v->v-op  ; inline
M: simd-128 vbitand            [ (simd-vbitand)            ] simd-vv->v-op ; inline
M: simd-128 vbitandn           [ (simd-vbitandn)           ] simd-vv->v-op ; inline
M: simd-128 vbitor             [ (simd-vbitor)             ] simd-vv->v-op ; inline
M: simd-128 vbitxor            [ (simd-vbitxor)            ] simd-vv->v-op ; inline
M: simd-128 vbitnot            [ (simd-vbitnot)            ] simd-v->v-op  ; inline
M: simd-128 vand               [ (simd-vand)               ] simd-vv->v-op ; inline
M: simd-128 vandn              [ (simd-vandn)              ] simd-vv->v-op ; inline
M: simd-128 vor                [ (simd-vor)                ] simd-vv->v-op ; inline
M: simd-128 vxor               [ (simd-vxor)               ] simd-vv->v-op ; inline
M: simd-128 vnot               [ (simd-vnot)               ] simd-v->v-op  ; inline
M: simd-128 vlshift            [ (simd-vlshift)            ] simd-vn->v-op ; inline
M: simd-128 vrshift            [ (simd-vrshift)            ] simd-vn->v-op ; inline
M: simd-128 hlshift            [ (simd-hlshift)            ] simd-vn->v-op ; inline
M: simd-128 hrshift            [ (simd-hrshift)            ] simd-vn->v-op ; inline
M: simd-128 vshuffle-elements  [ (simd-vshuffle-elements)  ] simd-vn->v-op ; inline
M: simd-128 vshuffle-bytes     [ (simd-vshuffle-bytes)     ] simd-vv->v-op ; inline
M: simd-128 (vmerge-head)      [ (simd-vmerge-head)        ] simd-vv->v-op ; inline
M: simd-128 (vmerge-tail)      [ (simd-vmerge-tail)        ] simd-vv->v-op ; inline
M: simd-128 v<=                [ (simd-v<=)                ] simd-vv->v-op ; inline
M: simd-128 v<                 [ (simd-v<)                 ] simd-vv->v-op ; inline
M: simd-128 v=                 [ (simd-v=)                 ] simd-vv->v-op ; inline
M: simd-128 v>                 [ (simd-v>)                 ] simd-vv->v-op ; inline
M: simd-128 v>=                [ (simd-v>=)                ] simd-vv->v-op ; inline
M: simd-128 vunordered?        [ (simd-vunordered?)        ] simd-vv->v-op ; inline
M: simd-128 vany?              [ (simd-vany?)              ] simd-v->n-op  ; inline
M: simd-128 vall?              [ (simd-vall?)              ] simd-v->n-op  ; inline
M: simd-128 vnone?             [ (simd-vnone?)             ] simd-v->n-op  ; inline

! SIMD high-level specializations

M: simd-128 vbroadcast [ swap nth ] keep simd-with ; inline
M: simd-128 n+v [ simd-with ] keep v+ ; inline
M: simd-128 n-v [ simd-with ] keep v- ; inline
M: simd-128 n*v [ simd-with ] keep v* ; inline
M: simd-128 n/v [ simd-with ] keep v/ ; inline
M: simd-128 v+n over simd-with v+ ; inline
M: simd-128 v-n over simd-with v- ; inline
M: simd-128 v*n over simd-with v* ; inline
M: simd-128 v/n over simd-with v/ ; inline
M: simd-128 norm-sq dup v. assert-positive ; inline
M: simd-128 norm      norm-sq sqrt ; inline
M: simd-128 distance  v- norm ; inline

! misc

M: simd-128 vshuffle ( u perm -- v )
    vshuffle-bytes ; inline

"compiler.tree.propagation.simd" require
"compiler.cfg.intrinsics.simd" require
"compiler.cfg.value-numbering.simd" require

"mirrors" vocab [
    "math.vectors.simd.mirrors" require
] when
