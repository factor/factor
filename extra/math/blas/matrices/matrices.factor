USING: accessors alien alien.c-types alien.complex alien.data
ascii byte-arrays combinators combinators.short-circuit functors
kernel math math.blas.ffi math.blas.vectors
math.blas.vectors.private parser prettyprint.custom sequences
sequences.merged sequences.private specialized-arrays ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
SPECIALIZED-ARRAY: double
SPECIALIZED-ARRAY: complex-float
SPECIALIZED-ARRAY: complex-double
IN: math.blas.matrices

TUPLE: blas-matrix-base underlying ld rows cols transpose ;

: Mtransposed? ( matrix -- ? )
    transpose>> ; inline
: Mwidth ( matrix -- width )
    dup Mtransposed? [ rows>> ] [ cols>> ] if ; inline
: Mheight ( matrix -- height )
    dup Mtransposed? [ cols>> ] [ rows>> ] if ; inline

GENERIC: n*M.V+n*V! ( alpha A x beta y -- y=alpha*A.x+b*y )
GENERIC: n*V(*)V+M! ( alpha x y A -- A=alpha*x(*)y+A )
GENERIC: n*V(*)Vconj+M! ( alpha x y A -- A=alpha*x(*)yconj+A )
GENERIC: n*M.M+n*M! ( alpha A B beta C -- C=alpha*A.B+beta*C )

<PRIVATE

: (blas-transpose) ( matrix -- integer )
    transpose>> [ "T" ] [ "N" ] if ;

GENERIC: (blas-matrix-like) ( data ld rows cols transpose exemplar -- matrix )

: (validate-gemv) ( A x y -- )
    {
        [ drop [ Mwidth  ] [ length>> ] bi* = ]
        [ nip  [ Mheight ] [ length>> ] bi* = ]
    } 3&&
    [ "Mismatched matrix and vectors in matrix-vector multiplication" throw ]
    unless ;

:: (prepare-gemv)
    ( alpha A x beta y -- A-trans m n alpha A-data A-ld x-data x-inc beta y-data y-inc
                          y )
    A x y (validate-gemv)
    A (blas-transpose)
    A rows>>
    A cols>>
    alpha
    A
    A ld>>
    x
    x inc>>
    beta
    y
    y inc>>
    y ; inline

: (validate-ger) ( x y A -- )
    {
        [ [ length>> ] [ drop     ] [ Mheight ] tri* = ]
        [ [ drop     ] [ length>> ] [ Mwidth  ] tri* = ]
    } 3&&
    [ "Mismatched vertices and matrix in vector outer product" throw ]
    unless ;

:: (prepare-ger)
    ( alpha x y A -- m n alpha x-data x-inc y-data y-inc A-data A-ld
                     A )
    x y A (validate-ger)
    A rows>>
    A cols>>
    alpha
    x
    x inc>>
    y
    y inc>>
    A
    A ld>>
    A f >>transpose ; inline

: (validate-gemm) ( A B C -- )
    {
        [ [ Mwidth  ] [ Mheight ] [ drop    ] tri* = ]
        [ [ Mheight ] [ drop    ] [ Mheight ] tri* = ]
        [ [ drop    ] [ Mwidth  ] [ Mwidth  ] tri* = ]
    } 3&&
    [ "Mismatched matrices in matrix multiplication" throw ]
    unless ;

:: (prepare-gemm)
    ( alpha A B beta C -- A-trans B-trans m n k alpha A-data A-ld B-data B-ld beta C-data C-ld
                          C )
    A B C (validate-gemm)
    A (blas-transpose)
    B (blas-transpose)
    C rows>>
    C cols>>
    A Mwidth
    alpha
    A
    A ld>>
    B
    B ld>>
    beta
    C
    C ld>>
    C f >>transpose ; inline

: (>matrix) ( arrays >c-array -- c-array ld rows cols transpose )
    '[ <merged> @ ] [ length dup ] [ first length ] tri f ; inline

PRIVATE>

! XXX should do a dense clone
M: blas-matrix-base clone
    [
        [ {
            [ underlying>> ]
            [ ld>> ]
            [ cols>> ]
            [ element-type heap-size ]
        } cleave * * memory>byte-array ]
        [ {
            [ ld>> ]
            [ rows>> ]
            [ cols>> ]
            [ transpose>> ]
        } cleave ]
        bi
    ] keep (blas-matrix-like) ;

! XXX try rounding stride to next 128 bit bound for better vectorizin'
: <empty-matrix> ( rows cols exemplar -- matrix )
    [ element-type heap-size * * <byte-array> ]
    [ 2drop ]
    [ [ f ] dip (blas-matrix-like) ] 3tri ;

: n*M.V+n*V ( alpha A x beta y -- alpha*A.x+b*y )
    clone n*M.V+n*V! ;
: n*V(*)V+M ( alpha x y A -- alpha*x(*)y+A )
    clone n*V(*)V+M! ;
: n*V(*)Vconj+M ( alpha x y A -- alpha*x(*)yconj+A )
    clone n*V(*)Vconj+M! ;
: n*M.M+n*M ( alpha A B beta C -- alpha*A.B+beta*C )
    clone n*M.M+n*M! ;

: n*M.V ( alpha A x -- alpha*A.x )
    1.0 2over [ Mheight ] dip <empty-vector>
    n*M.V+n*V! ; inline

: M.V ( A x -- A.x )
    [ 1.0 ] 2dip n*M.V ; inline

: n*V(*)V ( alpha x y -- alpha*x(*)y )
    2dup [ length>> ] bi@ pick <empty-matrix>
    n*V(*)V+M! ;
: n*V(*)Vconj ( alpha x y -- alpha*x(*)yconj )
    2dup [ length>> ] bi@ pick <empty-matrix>
    n*V(*)Vconj+M! ;

: V(*) ( x y -- x(*)y )
    [ 1.0 ] 2dip n*V(*)V ; inline
: V(*)conj ( x y -- x(*)yconj )
    [ 1.0 ] 2dip n*V(*)Vconj ; inline

: n*M.M ( alpha A B -- alpha*A.B )
    2dup [ Mheight ] [ Mwidth ] bi* pick <empty-matrix>
    [ 1.0 ] dip n*M.M+n*M! ;

: M. ( A B -- A.B )
    [ 1.0 ] 2dip n*M.M ; inline

:: (Msub) ( matrix row col height width -- data ld rows cols )
    matrix ld>> col * row + matrix element-type heap-size *
    matrix underlying>> <displaced-alien>
    matrix ld>>
    height
    width ;

:: Msub ( matrix row col height width -- sub )
    matrix dup transpose>>
    [ col row width height ]
    [ row col height width ] if (Msub)
    matrix transpose>> matrix (blas-matrix-like) ;

TUPLE: blas-matrix-rowcol-sequence
    parent inc rowcol-length rowcol-jump length ;
C: <blas-matrix-rowcol-sequence> blas-matrix-rowcol-sequence

INSTANCE: blas-matrix-rowcol-sequence sequence

M: blas-matrix-rowcol-sequence length
    length>> ;
M: blas-matrix-rowcol-sequence nth-unsafe
    {
        [
            [ rowcol-jump>> ]
            [ parent>> element-type heap-size ]
            [ parent>> underlying>> ] tri
            [ * * ] dip <displaced-alien>
        ]
        [ rowcol-length>> ]
        [ inc>> ]
        [ parent>> ]
    } cleave (blas-vector-like) ;

: (Mcols) ( A -- columns )
    { [ ] [ drop 1 ] [ rows>> ] [ ld>> ] [ cols>> ] }
    cleave <blas-matrix-rowcol-sequence> ;
: (Mrows) ( A -- rows )
    { [ ] [ ld>> ] [ cols>> ] [ drop 1 ] [ rows>> ] }
    cleave <blas-matrix-rowcol-sequence> ;

: Mrows ( A -- rows )
    dup transpose>> [ (Mcols) ] [ (Mrows) ] if ;
: Mcols ( A -- cols )
    dup transpose>> [ (Mrows) ] [ (Mcols) ] if ;

: n*M! ( n A -- A=n*A )
    [ (Mcols) [ n*V! drop ] with each ] keep ;

: n*M ( n A -- n*A )
    clone n*M! ; inline

: M*n ( A n -- A*n )
    swap n*M ; inline
: M/n ( A n -- A/n )
    recip swap n*M ; inline

: Mtranspose ( matrix -- matrix^T )
    [ {
        [ underlying>> ]
        [ ld>> ] [ rows>> ]
        [ cols>> ]
        [ transpose>> not ]
    } cleave ] keep (blas-matrix-like) ;

M: blas-matrix-base equal?
    {
        [ and ]
        [ [ Mwidth ] bi@ = ]
        [ [ Mcols ] bi@ [ = ] 2all? ]
    } 2&& ;

<<

<FUNCTOR: (define-blas-matrix) ( TYPE T U C -- )

VECTOR      IS ${TYPE}-blas-vector
<VECTOR>    IS <${TYPE}-blas-vector>
XGEMV       IS ${T}GEMV
XGEMM       IS ${T}GEMM
XGERU       IS ${T}GER${U}
XGERC       IS ${T}GER${C}

MATRIX      DEFINES-CLASS ${TYPE}-blas-matrix
<MATRIX>    DEFINES <${TYPE}-blas-matrix>
>MATRIX     DEFINES >${TYPE}-blas-matrix

t           [ T >lower ]

XMATRIX{    DEFINES ${t}matrix{

WHERE

TUPLE: MATRIX < blas-matrix-base ;
: <MATRIX> ( underlying ld rows cols transpose -- matrix )
    MATRIX boa ; inline

M: MATRIX element-type
    drop TYPE ;
M: MATRIX (blas-matrix-like)
    drop <MATRIX> ;
M: VECTOR (blas-matrix-like)
    drop <MATRIX> ;
M: MATRIX (blas-vector-like)
    drop <VECTOR> ;

: >MATRIX ( arrays -- matrix )
    [ TYPE >c-array underlying>> ] (>matrix) <MATRIX> ;

M: VECTOR n*M.V+n*V!
    (prepare-gemv) [ XGEMV ] dip ;
M: MATRIX n*M.M+n*M!
    (prepare-gemm) [ XGEMM ] dip ;
M: MATRIX n*V(*)V+M!
    (prepare-ger) [ XGERU ] dip ;
M: MATRIX n*V(*)Vconj+M!
    (prepare-ger) [ XGERC ] dip ;

SYNTAX: XMATRIX{ \ } [ >MATRIX ] parse-literal ;

M: MATRIX pprint-delims
    drop \ XMATRIX{ \ } ;

;FUNCTOR>


: define-real-blas-matrix ( TYPE T -- )
    "" "" (define-blas-matrix) ;
: define-complex-blas-matrix ( TYPE T -- )
    "U" "C" (define-blas-matrix) ;

float          "S" define-real-blas-matrix
double         "D" define-real-blas-matrix
complex-float  "C" define-complex-blas-matrix
complex-double "Z" define-complex-blas-matrix

>>

M: blas-matrix-base >pprint-sequence Mrows ;
M: blas-matrix-base pprint* pprint-object ;
