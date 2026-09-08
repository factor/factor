USING: accessors alien alien.accessors arrays byte-arrays classes combinators
cpu.architecture effects functors generalizations kernel lexer
literals math math.floats.small.c-types math.bitwise math.functions math.order math.vectors
math.vectors.simd.intrinsics parser prettyprint.custom
quotations sequences sequences.generalizations sequences.private
words vocabs vocabs.loader ;
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

:: set-vector-element ( value index data type -- )
    type { half bfloat } member? value { t f } member? and
    [ value -1 0 ? data index 2 * set-alien-unsigned-2 ]
    [ value type boolean>element index data type c:set-alien-element ] if ; inline

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
    ! No lane is wider than 64 bits. Clamp before unboxing so that bignum
    ! counts cannot truncate to zero (or to a negative machine integer).
    drop [ [ simd-unbox ] [ 64 min >fixnum ] bi* ] 2dip 3curry make-underlying ; inline

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
        { half-8-rep      [ -1 shift ] }
        { bfloat-8-rep    [ -1 shift ] }
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
    over simd-rep [ (simd-hlshift) ] [ call-next-method ] vx->v-op ; inline
M: simd-128 hrshift
    over simd-rep [ (simd-hrshift) ] [ call-next-method ] vx->v-op ; inline
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
    underlying>> ELT set-vector-element ; inline

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

c:vector-c-type new
    byte-array >>class
    A >>boxed-class
    { A-rep alien-vector } >quotation >>getter
    { A boa } >quotation >>boxer-quot
    {
        dup simd-128? [ bad-simd-vector ] unless underlying>>
    } >quotation >>unboxer-quot
    { A-rep set-alien-vector } >quotation >>setter
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
SIMD-128: half-8
SIMD-128: bfloat-8

! misc

M: simd-128 vshuffle
    vshuffle-bytes ; inline

M: byte-array vshuffle
    dup length 16 = [ uchar-16 boa vshuffle-bytes ]
    [ bad-simd-vector ] if ; inline

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

M: simd-128 vfloor
    "floor" over simd-rep [ (simd-unary) ] [ call-next-method ] vx->v-op ; inline

M: simd-128 vceiling
    "ceiling" over simd-rep [ (simd-unary) ] [ call-next-method ] vx->v-op ; inline

M: simd-128 vtruncate
    "truncate" over simd-rep [ (simd-unary) ] [ call-next-method ] vx->v-op ; inline

M: simd-128 vround
    "round" over simd-rep [ (simd-unary) ] [ call-next-method ] vx->v-op ; inline

M: simd-128 vround-to-even
    "round-even" over simd-rep [ (simd-unary) ] [ call-next-method ] vx->v-op ; inline

M: simd-128 vbit-count
    "bit-count" over simd-rep [ (simd-unary) ] [ call-next-method ] vx->v-op ; inline

M: simd-128 vclz
    "clz" over simd-rep [ (simd-unary) ] [ call-next-method ] vx->v-op ; inline

M: simd-128 vctz
    "ctz" over simd-rep [ (simd-unary) ] [ call-next-method ] vx->v-op ; inline

M: simd-128 vbit-reverse
    "bit-reverse" over simd-rep [ (simd-unary) ] [ call-next-method ] vx->v-op ; inline

! Operations with a different output type have explicit typed methods. This
! keeps constructors and representations literal during inference.
M: simd-128 vfma 2drop bad-simd-vector ;
M: simd-128 vabsdiff drop bad-simd-vector ;
M: simd-128 vmul-wide drop bad-simd-vector ;
M: simd-128 vshift drop bad-simd-vector ;

M: simd-128 vmin-element
    "min-element" over simd-rep [ (simd-reduce) ] [ call-next-method ] vx->x-op ; inline
M: simd-128 vmax-element
    "max-element" over simd-rep [ (simd-reduce) ] [ call-next-method ] vx->x-op ; inline

M:: float-4 vfma ( a b c -- d )
    a float-4? b float-4? and [
        a underlying>> b underlying>> c underlying>> float-4-rep (simd-vfma) float-4 boa
    ] [ b bad-simd-vector ] if ; inline

M:: double-2 vfma ( a b c -- d )
    a double-2? b double-2? and [
        a underlying>> b underlying>> c underlying>> double-2-rep (simd-vfma) double-2 boa
    ] [ b bad-simd-vector ] if ; inline

M:: char-16 vabsdiff ( a b -- c )
    a char-16? [
        a underlying>> b underlying>> "absdiff" char-16-rep (simd-binary) uchar-16 boa
    ] [ a bad-simd-vector ] if ; inline

M:: uchar-16 vabsdiff ( a b -- c )
    a uchar-16? [
        a underlying>> b underlying>> "absdiff" uchar-16-rep (simd-binary) uchar-16 boa
    ] [ a bad-simd-vector ] if ; inline

M:: short-8 vabsdiff ( a b -- c )
    a short-8? [
        a underlying>> b underlying>> "absdiff" short-8-rep (simd-binary) ushort-8 boa
    ] [ a bad-simd-vector ] if ; inline

M:: ushort-8 vabsdiff ( a b -- c )
    a ushort-8? [
        a underlying>> b underlying>> "absdiff" ushort-8-rep (simd-binary) ushort-8 boa
    ] [ a bad-simd-vector ] if ; inline

M:: int-4 vabsdiff ( a b -- c )
    a int-4? [
        a underlying>> b underlying>> "absdiff" int-4-rep (simd-binary) uint-4 boa
    ] [ a bad-simd-vector ] if ; inline

M:: uint-4 vabsdiff ( a b -- c )
    a uint-4? [
        a underlying>> b underlying>> "absdiff" uint-4-rep (simd-binary) uint-4 boa
    ] [ a bad-simd-vector ] if ; inline

M:: longlong-2 vabsdiff ( a b -- c )
    a longlong-2? [
        a underlying>> b underlying>> "absdiff" longlong-2-rep (simd-binary) ulonglong-2 boa
    ] [ a bad-simd-vector ] if ; inline

M:: ulonglong-2 vabsdiff ( a b -- c )
    a ulonglong-2? [
        a underlying>> b underlying>> "absdiff" ulonglong-2-rep (simd-binary) ulonglong-2 boa
    ] [ a bad-simd-vector ] if ; inline

M:: char-16 vshift ( a counts -- b )
    a char-16? [ a underlying>> counts underlying>> "shift" char-16-rep (simd-binary) char-16 boa ] [
        a uchar-16? [ a underlying>> counts underlying>> "shift" uchar-16-rep (simd-binary) uchar-16 boa ]
        [ a bad-simd-vector ] if
    ] if ; inline

M:: short-8 vshift ( a counts -- b )
    a short-8? [ a underlying>> counts underlying>> "shift" short-8-rep (simd-binary) short-8 boa ] [
        a ushort-8? [ a underlying>> counts underlying>> "shift" ushort-8-rep (simd-binary) ushort-8 boa ]
        [ a bad-simd-vector ] if
    ] if ; inline

M:: int-4 vshift ( a counts -- b )
    a int-4? [ a underlying>> counts underlying>> "shift" int-4-rep (simd-binary) int-4 boa ] [
        a uint-4? [ a underlying>> counts underlying>> "shift" uint-4-rep (simd-binary) uint-4 boa ]
        [ a bad-simd-vector ] if
    ] if ; inline

M:: longlong-2 vshift ( a counts -- b )
    a longlong-2? [ a underlying>> counts underlying>> "shift" longlong-2-rep (simd-binary) longlong-2 boa ] [
        a ulonglong-2? [ a underlying>> counts underlying>> "shift" ulonglong-2-rep (simd-binary) ulonglong-2 boa ]
        [ a bad-simd-vector ] if
    ] if ; inline

M:: char-16 vmul-wide ( a b -- lo hi )
    a char-16? [
        a underlying>> b underlying>> char-16-rep (simd-mul-wide-head) short-8 boa
        a underlying>> b underlying>> char-16-rep (simd-mul-wide-tail) short-8 boa
    ] [ a bad-simd-vector ] if ; inline

M:: uchar-16 vmul-wide ( a b -- lo hi )
    a uchar-16? [
        a underlying>> b underlying>> uchar-16-rep (simd-mul-wide-head) ushort-8 boa
        a underlying>> b underlying>> uchar-16-rep (simd-mul-wide-tail) ushort-8 boa
    ] [ a bad-simd-vector ] if ; inline

M:: short-8 vmul-wide ( a b -- lo hi )
    a short-8? [
        a underlying>> b underlying>> short-8-rep (simd-mul-wide-head) int-4 boa
        a underlying>> b underlying>> short-8-rep (simd-mul-wide-tail) int-4 boa
    ] [ a bad-simd-vector ] if ; inline

M:: ushort-8 vmul-wide ( a b -- lo hi )
    a ushort-8? [
        a underlying>> b underlying>> ushort-8-rep (simd-mul-wide-head) uint-4 boa
        a underlying>> b underlying>> ushort-8-rep (simd-mul-wide-tail) uint-4 boa
    ] [ a bad-simd-vector ] if ; inline

M:: int-4 vmul-wide ( a b -- lo hi )
    a int-4? [
        a underlying>> b underlying>> int-4-rep (simd-mul-wide-head) longlong-2 boa
        a underlying>> b underlying>> int-4-rep (simd-mul-wide-tail) longlong-2 boa
    ] [ a bad-simd-vector ] if ; inline

M:: uint-4 vmul-wide ( a b -- lo hi )
    a uint-4? [
        a underlying>> b underlying>> uint-4-rep (simd-mul-wide-head) ulonglong-2 boa
        a underlying>> b underlying>> uint-4-rep (simd-mul-wide-tail) ulonglong-2 boa
    ] [ a bad-simd-vector ] if ; inline

"math.vectors.simd.extensions" require
