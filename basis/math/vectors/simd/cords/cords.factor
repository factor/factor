USING: accessors alien.c-types arrays byte-arrays
cpu.architecture effects functors generalizations kernel lexer
math math.vectors.simd math.vectors.simd.intrinsics parser
prettyprint.custom quotations sequences sequences.cords words
classes ;
IN: math.vectors.simd.cords

<<
<PRIVATE

<FUNCTOR: (define-simd-128-cord) ( A/2 A -- )

A-rep    IS            ${A/2}-rep
>A/2     IS            >${A/2}
A/2-boa  IS            ${A/2}-boa
A/2-with IS            ${A/2}-with
A/2-cast IS            ${A/2}-cast

>A     DEFINES       >${A}
A-boa  DEFINES       ${A}-boa
A-with DEFINES       ${A}-with
A-cast DEFINES       ${A}-cast
A{     DEFINES       ${A}{

N       [ A-rep rep-length ]
BOA-EFFECT [ N 2 * "n" <array> { "v" } <effect> ]

WHERE

: >A ( seq -- A )
    [ N head-slice >A/2 ]
    [ N tail-slice >A/2 ] bi cord-append ;

\ A-boa
{ N ndip A/2-boa cord-append } { A/2-boa } >quotation prefix >quotation
BOA-EFFECT define-inline

: A-with ( n -- v )
    [ A/2-with ] [ A/2-with ] bi cord-append ; inline

: A-cast ( v -- v' )
    [ A/2-cast ] cord-map ; inline

M: A new-sequence
    2drop
    N A/2 new new-sequence
    N A/2 new new-sequence
    \ A boa ;

M: A like
    over \ A instance? [ drop ] [ call-next-method ] if ;

M: A >pprint-sequence ;
M: A pprint* pprint-object ;

M: A pprint-delims drop \ A{ \ } ;
SYNTAX: A{ \ } [ >A ] parse-literal ;

<c-type>
    byte-array >>class
    A >>boxed-class
    [
        [      A-rep alien-vector A/2 boa ]
        [ 16 + A-rep alien-vector A/2 boa ] 2bi cord-append
    ] >>getter
    [
        [ [ head>> underlying>> ] 2dip      A-rep set-alien-vector ]
        [ [ tail>> underlying>> ] 2dip 16 + A-rep set-alien-vector ] 3bi
    ] >>setter
    32 >>size
    16 >>align
    A-rep >>rep
\ A typedef

;FUNCTOR>

: define-simd-128-cord ( A/2 T -- )
    [ define-specialized-cord ]
    [ create-word-in (define-simd-128-cord) ] 2bi ;

SYNTAX: SIMD-128-CORD:
    scan-word scan-token define-simd-128-cord ;

PRIVATE>
>>

SIMD-128-CORD: char-16     char-32
SIMD-128-CORD: uchar-16    uchar-32
SIMD-128-CORD: short-8     short-16
SIMD-128-CORD: ushort-8    ushort-16
SIMD-128-CORD: int-4       int-8
SIMD-128-CORD: uint-4      uint-8
SIMD-128-CORD: longlong-2  longlong-4
SIMD-128-CORD: ulonglong-2 ulonglong-4
SIMD-128-CORD: float-4     float-8
SIMD-128-CORD: double-2    double-4

