USING: accessors alien alien.c-types arrays byte-arrays combinators
combinators.short-circuit fry kernel locals macros
math math.blas.cblas math.blas.vectors math.blas.vectors.private
math.complex math.functions math.order functors words
sequences sequences.merged sequences.private shuffle
specialized-arrays.direct.float specialized-arrays.direct.double
specialized-arrays.float specialized-arrays.double
parser prettyprint.backend prettyprint.custom ;
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
    transpose>> [ CblasTrans ] [ CblasNoTrans ] if ;

GENERIC: (blas-matrix-like) ( data ld rows cols transpose exemplar -- matrix )

: (validate-gemv) ( A x y -- )
    {
        [ drop [ Mwidth  ] [ length>> ] bi* = ]
        [ nip  [ Mheight ] [ length>> ] bi* = ]
    } 3&&
    [ "Mismatched matrix and vectors in matrix-vector multiplication" throw ]
    unless ;

:: (prepare-gemv)
    ( alpha A x beta y >c-arg -- order A-trans m n alpha A-data A-ld x-data x-inc beta y-data y-inc
                                 y )
    A x y (validate-gemv)
    CblasColMajor
    A (blas-transpose)
    A rows>>
    A cols>>
    alpha >c-arg call
    A underlying>>
    A ld>>
    x underlying>>
    x inc>>
    beta >c-arg call
    y underlying>>
    y inc>>
    y ; inline

: (validate-ger) ( x y A -- )
    {
        [ nip  [ length>> ] [ Mheight ] bi* = ]
        [ nipd [ length>> ] [ Mwidth  ] bi* = ]
    } 3&&
    [ "Mismatched vertices and matrix in vector outer product" throw ]
    unless ;

:: (prepare-ger)
    ( alpha x y A >c-arg -- order m n alpha x-data x-inc y-data y-inc A-data A-ld
                            A )
    x y A (validate-ger)
    CblasColMajor
    A rows>>
    A cols>>
    alpha >c-arg call
    x underlying>>
    x inc>>
    y underlying>>
    y inc>>
    A underlying>>
    A ld>>
    A f >>transpose ; inline

: (validate-gemm) ( A B C -- )
    {
        [ drop [ Mwidth  ] [ Mheight ] bi* = ]
        [ nip  [ Mheight ] bi@ = ]
        [ nipd [ Mwidth  ] bi@ = ]
    } 3&&
    [ "Mismatched matrices in matrix multiplication" throw ]
    unless ;

:: (prepare-gemm)
    ( alpha A B beta C >c-arg -- order A-trans B-trans m n k alpha A-data A-ld B-data B-ld beta C-data C-ld
                                 C )
    A B C (validate-gemm)
    CblasColMajor
    A (blas-transpose)
    B (blas-transpose)
    C rows>>
    C cols>>
    A Mwidth
    alpha >c-arg call
    A underlying>>
    A ld>>
    B underlying>>
    B ld>>
    beta >c-arg call
    C underlying>>
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
    [ element-type [ * ] dip <c-array> ]
    [ 2drop ]
    [ f swap (blas-matrix-like) ] 3tri ;

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
    1.0 -rot n*M.V ; inline

: n*V(*)V ( alpha x y -- alpha*x(*)y )
    2dup [ length>> ] bi@ pick <empty-matrix>
    n*V(*)V+M! ;
: n*V(*)Vconj ( alpha x y -- alpha*x(*)yconj )
    2dup [ length>> ] bi@ pick <empty-matrix>
    n*V(*)Vconj+M! ;

: V(*) ( x y -- x(*)y )
    1.0 -rot n*V(*)V ; inline
: V(*)conj ( x y -- x(*)yconj )
    1.0 -rot n*V(*)Vconj ; inline

: n*M.M ( alpha A B -- alpha*A.B )
    2dup [ Mheight ] [ Mwidth ] bi* pick <empty-matrix> 
    1.0 swap n*M.M+n*M! ;

: M. ( A B -- A.B )
    1.0 -rot n*M.M ; inline

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
        [ [ Mwidth ] bi@ = ]
        [ [ Mcols ] bi@ [ = ] 2all? ]
    } 2&& ;

<<

FUNCTOR: (define-blas-matrix) ( TYPE T U C -- )

VECTOR      IS ${TYPE}-blas-vector
<VECTOR>    IS <${TYPE}-blas-vector>
>ARRAY      IS >${TYPE}-array
TYPE>ARG    IS ${TYPE}>arg
XGEMV       IS cblas_${T}gemv
XGEMM       IS cblas_${T}gemm
XGERU       IS cblas_${T}ger${U}
XGERC       IS cblas_${T}ger${C}

MATRIX      DEFINES ${TYPE}-blas-matrix
<MATRIX>    DEFINES <${TYPE}-blas-matrix>
>MATRIX     DEFINES >${TYPE}-blas-matrix
XMATRIX{    DEFINES ${T}matrix{

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
    [ >ARRAY underlying>> ] (>matrix)
    <MATRIX> ;

M: VECTOR n*M.V+n*V!
    [ TYPE>ARG ] (prepare-gemv)
    [ XGEMV ] dip ;
M: MATRIX n*M.M+n*M!
    [ TYPE>ARG ] (prepare-gemm)
    [ XGEMM ] dip ;
M: MATRIX n*V(*)V+M!
    [ TYPE>ARG ] (prepare-ger)
    [ XGERU ] dip ;
M: MATRIX n*V(*)Vconj+M!
    [ TYPE>ARG ] (prepare-ger)
    [ XGERC ] dip ;

: XMATRIX{ \ } [ >MATRIX ] parse-literal ; parsing

M: MATRIX pprint-delims
    drop \ XMATRIX{ \ } ;

;FUNCTOR


: define-real-blas-matrix ( TYPE T -- )
    "" "" (define-blas-matrix) ;
: define-complex-blas-matrix ( TYPE T -- )
    "u" "c" (define-blas-matrix) ;

"float"          "s" define-real-blas-matrix
"double"         "d" define-real-blas-matrix
"float-complex"  "c" define-complex-blas-matrix
"double-complex" "z" define-complex-blas-matrix

>>

M: blas-matrix-base >pprint-sequence Mrows ;
M: blas-matrix-base pprint* pprint-object ;
