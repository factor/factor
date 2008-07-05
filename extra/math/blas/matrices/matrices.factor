USING: accessors alien alien.c-types arrays byte-arrays combinators
combinators.lib combinators.short-circuit fry kernel locals macros
math math.blas.cblas math.blas.vectors math.blas.vectors.private
math.complex math.functions math.order multi-methods qualified
sequences sequences.private shuffle symbols ;
QUALIFIED: syntax
IN: math.blas.matrices

TUPLE: blas-matrix-base data ld rows cols transpose ;
TUPLE: float-blas-matrix < blas-matrix-base ;
TUPLE: double-blas-matrix < blas-matrix-base ;
TUPLE: float-complex-blas-matrix < blas-matrix-base ;
TUPLE: double-complex-blas-matrix < blas-matrix-base ;

C: <float-blas-matrix> float-blas-matrix
C: <double-blas-matrix> double-blas-matrix
C: <float-complex-blas-matrix> float-complex-blas-matrix
C: <double-complex-blas-matrix> double-complex-blas-matrix

METHOD: element-type { float-blas-matrix }
    drop "float" ;
METHOD: element-type { double-blas-matrix }
    drop "double" ;
METHOD: element-type { float-complex-blas-matrix }
    drop "CBLAS_C" ;
METHOD: element-type { double-complex-blas-matrix }
    drop "CBLAS_Z" ;

: Mtransposed? ( matrix -- ? )
    transpose>> ; inline
: Mwidth ( matrix -- width )
    dup Mtransposed? [ rows>> ] [ cols>> ] if ; inline
: Mheight ( matrix -- height )
    dup Mtransposed? [ cols>> ] [ rows>> ] if ; inline

<PRIVATE

: (blas-transpose) ( matrix -- integer )
    transpose>> [ CblasTrans ] [ CblasNoTrans ] if ;

GENERIC: (blas-matrix-like) ( data ld rows cols transpose exemplar -- matrix )

METHOD: (blas-matrix-like) { object object object object object float-blas-matrix }
    drop <float-blas-matrix> ;
METHOD: (blas-matrix-like) { object object object object object double-blas-matrix }
    drop <double-blas-matrix> ;
METHOD: (blas-matrix-like) { object object object object object float-complex-blas-matrix }
    drop <float-complex-blas-matrix> ;
METHOD: (blas-matrix-like) { object object object object object double-complex-blas-matrix }
    drop <double-complex-blas-matrix> ;

METHOD: (blas-matrix-like) { object object object object object float-blas-vector }
    drop <float-blas-matrix> ;
METHOD: (blas-matrix-like) { object object object object object double-blas-vector }
    drop <double-blas-matrix> ;
METHOD: (blas-matrix-like) { object object object object object float-complex-blas-vector }
    drop <float-complex-blas-matrix> ;
METHOD: (blas-matrix-like) { object object object object object double-complex-blas-vector }
    drop <double-complex-blas-matrix> ;

METHOD: (blas-vector-like) { object object object float-blas-matrix }
    drop <float-blas-vector> ;
METHOD: (blas-vector-like) { object object object double-blas-matrix }
    drop <double-blas-vector> ;
METHOD: (blas-vector-like) { object object object float-complex-blas-matrix }
    drop <float-complex-blas-vector> ;
METHOD: (blas-vector-like) { object object object double-complex-blas-matrix }
    drop <double-complex-blas-vector> ;

: (validate-gemv) ( A x y -- )
    {
        [ drop [ Mwidth  ] [ length>> ] bi* = ]
        [ nip  [ Mheight ] [ length>> ] bi* = ]
    } 3&&
    [ "Mismatched matrix and vectors in matrix-vector multiplication" throw ] unless ;

:: (prepare-gemv) ( alpha A x beta y >c-arg -- order A-trans m n alpha A-data A-ld x-data x-inc beta y-data y-inc y )
    A x y (validate-gemv)
    CblasColMajor
    A (blas-transpose)
    A rows>>
    A cols>>
    alpha >c-arg call
    A data>>
    A ld>>
    x data>>
    x inc>>
    beta >c-arg call
    y data>>
    y inc>>
    y ; inline

: (validate-ger) ( x y A -- )
    {
        [ nip  [ length>> ] [ Mheight ] bi* = ]
        [ nipd [ length>> ] [ Mwidth  ] bi* = ]
    } 3&&
    [ "Mismatched vertices and matrix in vector outer product" throw ] unless ;

:: (prepare-ger) ( alpha x y A >c-arg -- order m n alpha x-data x-inc y-data y-inc A-data A-ld A )
    x y A (validate-ger)
    CblasColMajor
    A rows>>
    A cols>>
    alpha >c-arg call
    x data>>
    x inc>>
    y data>>
    y inc>>
    A data>>
    A ld>>
    A f >>transpose ; inline

: (validate-gemm) ( A B C -- )
    {
        [ drop [ Mwidth  ] [ Mheight ] bi* = ]
        [ nip  [ Mheight ] bi@ = ]
        [ nipd [ Mwidth  ] bi@ = ]
    } 3&& [ "Mismatched matrices in matrix multiplication" throw ] unless ;

:: (prepare-gemm) ( alpha A B beta C >c-arg -- order A-trans B-trans m n k alpha A-data A-ld B-data B-ld beta C-data C-ld C )
    A B C (validate-gemm)
    CblasColMajor
    A (blas-transpose)
    B (blas-transpose)
    C rows>>
    C cols>>
    A Mwidth
    alpha >c-arg call
    A data>>
    A ld>>
    B data>>
    B ld>>
    beta >c-arg call
    C data>>
    C ld>>
    C f >>transpose ; inline

: (>matrix) ( arrays >c-array -- c-array ld rows cols transpose )
    [ flip ] dip
    '[ concat @ ] [ first length dup ] [ length ] tri f ; inline

PRIVATE>

: >float-blas-matrix ( arrays -- matrix )
    [ >c-float-array ] (>matrix) <float-blas-matrix> ;
: >double-blas-matrix ( arrays -- matrix )
    [ >c-double-array ] (>matrix) <double-blas-matrix> ;
: >float-complex-blas-matrix ( arrays -- matrix )
    [ (flatten-complex-sequence) >c-float-array ] (>matrix)
    <float-complex-blas-matrix> ;
: >double-complex-blas-matrix ( arrays -- matrix )
    [ (flatten-complex-sequence) >c-double-array ] (>matrix)
    <double-complex-blas-matrix> ;

GENERIC: n*M.V+n*V-in-place ( alpha A x beta y -- y=alpha*A.x+b*y )
GENERIC: n*V(*)V+M-in-place ( alpha x y A -- A=alpha*x(*)y+A )
GENERIC: n*V(*)Vconj+M-in-place ( alpha x y A -- A=alpha*x(*)yconj+A )
GENERIC: n*M.M+n*M-in-place ( alpha A B beta C -- C=alpha*A.B+beta*C )

METHOD: n*M.V+n*V-in-place { real float-blas-matrix float-blas-vector real float-blas-vector }
    [ ] (prepare-gemv) [ cblas_sgemv ] dip ;
METHOD: n*M.V+n*V-in-place { real double-blas-matrix double-blas-vector real double-blas-vector }
    [ ] (prepare-gemv) [ cblas_dgemv ] dip ;
METHOD: n*M.V+n*V-in-place { number float-complex-blas-matrix float-complex-blas-vector number float-complex-blas-vector }
    [ (>c-complex) ] (prepare-gemv) [ cblas_cgemv ] dip ;
METHOD: n*M.V+n*V-in-place { number double-complex-blas-matrix double-complex-blas-vector number double-complex-blas-vector }
    [ (>z-complex) ] (prepare-gemv) [ cblas_zgemv ] dip ;

METHOD: n*V(*)V+M-in-place { real float-blas-vector float-blas-vector float-blas-matrix }
    [ ] (prepare-ger) [ cblas_sger ] dip ;
METHOD: n*V(*)V+M-in-place { real double-blas-vector double-blas-vector double-blas-matrix }
    [ ] (prepare-ger) [ cblas_dger ] dip ;
METHOD: n*V(*)V+M-in-place { number float-complex-blas-vector float-complex-blas-vector float-complex-blas-matrix }
    [ (>c-complex) ] (prepare-ger) [ cblas_cgeru ] dip ;
METHOD: n*V(*)V+M-in-place { number double-complex-blas-vector double-complex-blas-vector double-complex-blas-matrix }
    [ (>z-complex) ] (prepare-ger) [ cblas_zgeru ] dip ;

METHOD: n*V(*)Vconj+M-in-place { number float-complex-blas-vector float-complex-blas-vector float-complex-blas-matrix }
    [ (>c-complex) ] (prepare-ger) [ cblas_cgerc ] dip ;
METHOD: n*V(*)Vconj+M-in-place { number double-complex-blas-vector double-complex-blas-vector double-complex-blas-matrix }
    [ (>z-complex) ] (prepare-ger) [ cblas_zgerc ] dip ;

METHOD: n*M.M+n*M-in-place { real float-blas-matrix float-blas-matrix real float-blas-matrix }
    [ ] (prepare-gemm) [ cblas_sgemm ] dip ;
METHOD: n*M.M+n*M-in-place { real double-blas-matrix double-blas-matrix real double-blas-matrix }
    [ ] (prepare-gemm) [ cblas_dgemm ] dip ;
METHOD: n*M.M+n*M-in-place { number float-complex-blas-matrix float-complex-blas-matrix number float-complex-blas-matrix }
    [ (>c-complex) ] (prepare-gemm) [ cblas_cgemm ] dip ;
METHOD: n*M.M+n*M-in-place { number double-complex-blas-matrix double-complex-blas-matrix number double-complex-blas-matrix }
    [ (>z-complex) ] (prepare-gemm) [ cblas_zgemm ] dip ;

! XXX should do a dense clone
syntax:M: blas-matrix-base clone
    [ 
        [
            { data>> ld>> cols>> element-type } get-slots
            heap-size * * memory>byte-array
        ] [ { ld>> rows>> cols>> transpose>> } get-slots ] bi
    ] keep (blas-matrix-like) ;

! XXX try rounding stride to next 128 bit bound for better vectorizin'
: empty-matrix ( rows cols exemplar -- matrix )
    [ element-type [ * ] dip <c-array> ]
    [ 2drop ]
    [ f swap (blas-matrix-like) ] 3tri ;

: n*M.V+n*V ( alpha A x beta y -- alpha*A.x+b*y )
    clone n*M.V+n*V-in-place ;
: n*V(*)V+M ( alpha x y A -- alpha*x(*)y+A )
    clone n*V(*)V+M-in-place ;
: n*V(*)Vconj+M ( alpha x y A -- alpha*x(*)yconj+A )
    clone n*V(*)Vconj+M-in-place ;
: n*M.M+n*M ( alpha A B beta C -- alpha*A.B+beta*C )
    clone n*M.M+n*M-in-place ;

: n*M.V ( alpha A x -- alpha*A.x )
    1.0 2over [ Mheight ] dip empty-vector
    n*M.V+n*V-in-place ; inline

: M.V ( A x -- A.x )
    1.0 -rot n*M.V ; inline

: n*V(*)V ( n x y -- n*x(*)y )
    2dup [ length>> ] bi@ pick empty-matrix
    n*V(*)V+M-in-place ;
: n*V(*)Vconj ( n x y -- n*x(*)yconj )
    2dup [ length>> ] bi@ pick empty-matrix
    n*V(*)Vconj+M-in-place ;

: V(*) ( x y -- x(*)y )
    1.0 -rot n*V(*)V ; inline
: V(*)conj ( x y -- x(*)yconj )
    1.0 -rot n*V(*)Vconj ; inline

: n*M.M ( n A B -- n*A.B )
    2dup [ Mheight ] [ Mwidth ] bi* pick empty-matrix 
    1.0 swap n*M.M+n*M-in-place ;

: M. ( A B -- A.B )
    1.0 -rot n*M.M ; inline

:: (Msub) ( matrix row col height width -- data ld rows cols )
    matrix ld>> col * row + matrix element-type heap-size *
    matrix data>> <displaced-alien>
    matrix ld>>
    height
    width ;

: Msub ( matrix row col height width -- submatrix )
    5 npick dup transpose>>
    [ nip [ [ swap ] 2dip swap ] when (Msub) ] 2keep
    swap (blas-matrix-like) ;

TUPLE: blas-matrix-rowcol-sequence parent inc rowcol-length rowcol-jump length ;
C: <blas-matrix-rowcol-sequence> blas-matrix-rowcol-sequence

INSTANCE: blas-matrix-rowcol-sequence sequence

syntax:M: blas-matrix-rowcol-sequence length
    length>> ;
syntax:M: blas-matrix-rowcol-sequence nth-unsafe
    {
        [
            [ rowcol-jump>> ]
            [ parent>> element-type heap-size ]
            [ parent>> data>> ] tri
            [ * * ] dip <displaced-alien>
        ]
        [ rowcol-length>> ]
        [ inc>> ]
        [ parent>> ]
    } cleave (blas-vector-like) ;

: (Mcols) ( A -- columns )
    { [ ] [ drop 1 ] [ rows>> ] [ ld>> ] [ cols>> ] } cleave
    <blas-matrix-rowcol-sequence> ;
: (Mrows) ( A -- rows )
    { [ ] [ ld>> ] [ cols>> ] [ drop 1 ] [ rows>> ] } cleave
    <blas-matrix-rowcol-sequence> ;

: Mrows ( A -- rows )
    dup transpose>> [ (Mcols) ] [ (Mrows) ] if ;
: Mcols ( A -- rows )
    dup transpose>> [ (Mrows) ] [ (Mcols) ] if ;

: n*M-in-place ( n A -- A=n*A )
    [ (Mcols) [ n*V-in-place drop ] with each ] keep ;

: n*M ( n A -- n*A )
    clone n*M-in-place ; inline

: M*n ( A n -- A*n )
    swap n*M ; inline
: M/n ( A n -- A/n )
    recip swap n*M ; inline

: Mtranspose ( matrix -- matrix^T )
    [ { data>> ld>> rows>> cols>> transpose>> } get-slots not ] keep (blas-matrix-like) ;

syntax:M: blas-matrix-base equal?
    {
        [ [ Mwidth ] bi@ = ]
        [ [ Mcols ] bi@ [ = ] 2all? ]
    } 2&& ;

