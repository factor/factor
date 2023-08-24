USING: accessors alien alien.c-types alien.complex alien.data
ascii byte-arrays combinators.short-circuit functors kernel math
math.blas.ffi math.order parser prettyprint.custom sequences
specialized-arrays ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
SPECIALIZED-ARRAY: double
SPECIALIZED-ARRAY: complex-float
SPECIALIZED-ARRAY: complex-double
IN: math.blas.vectors

TUPLE: blas-vector-base underlying length inc ;

INSTANCE: blas-vector-base virtual-sequence

GENERIC: element-type ( v -- type )

GENERIC: n*V+V! ( alpha x y -- y=alpha*x+y )
GENERIC: n*V!   ( alpha x -- x=alpha*x )
GENERIC: V. ( x y -- x.y )
GENERIC: V.conj ( x y -- xconj.y )
GENERIC: Vnorm ( x -- norm )
GENERIC: Vasum ( x -- sum )
GENERIC: Vswap ( x y -- x=y y=x )
GENERIC: Viamax ( x -- max-i )

<PRIVATE

GENERIC: (blas-vector-like) ( data length inc exemplar -- vector )

GENERIC: (blas-direct-array) ( blas-vector -- direct-array )

: shorter-length ( v1 v2 -- length )
    [ length>> ] bi@ min ; inline
: data-and-inc ( v -- data inc )
    [ ] [ inc>> ] bi ; inline
: datas-and-incs ( v1 v2 -- v1-data v1-inc v2-data v2-inc )
    [ data-and-inc ] bi@ ; inline

:: (prepare-copy)
    ( v element-size -- length v-data v-inc v-dest-data v-dest-inc
                        copy-data copy-length copy-inc )
    v [ length>> ] [ data-and-inc ] bi
    v length>> element-size * <byte-array>
    1
    over v length>> 1 ;

: (prepare-swap)
    ( v1 v2 -- length v1-data v1-inc v2-data v2-inc
               v1 v2 )
    [ shorter-length ] [ datas-and-incs ] [ ] 2tri ;

:: (prepare-axpy)
    ( n v1 v2 -- length n v1-data v1-inc v2-data v2-inc
                 v2 )
    v1 v2 shorter-length
    n
    v1 v2 datas-and-incs
    v2 ;

:: (prepare-scal)
    ( n v -- length n v-data v-inc
             v )
    v length>>
    n
    v data-and-inc
    v ;

: (prepare-dot) ( v1 v2 -- length v1-data v1-inc v2-data v2-inc )
    [ shorter-length ] [ datas-and-incs ] 2bi ;

: (prepare-nrm2) ( v -- length data inc )
    [ length>> ] [ data-and-inc ] bi ;

PRIVATE>

: n*V+V ( alpha x y -- alpha*x+y ) clone n*V+V! ; inline
: n*V ( alpha x -- alpha*x ) clone n*V! ; inline

:: V+ ( x y -- x+y )
    1.0 x y n*V+V ; inline
:: V- ( x y -- x-y )
    -1.0 y x n*V+V ; inline

: Vneg ( x -- -x )
    -1.0 swap n*V ; inline

: V*n ( x alpha -- x*alpha )
    swap n*V ; inline
: V/n ( x alpha -- x/alpha )
    recip swap n*V ; inline

: Vamax ( x -- max )
    [ Viamax ] keep nth ; inline

:: Vsub ( v start length -- sub )
    v inc>> start * v element-type heap-size *
    v underlying>> <displaced-alien>
    length v inc>> v (blas-vector-like) ;

: <zero-vector> ( exemplar -- zero )
    [ element-type heap-size <byte-array> ]
    [ length>> 0 ]
    [ (blas-vector-like) ] tri ;

: <empty-vector> ( length exemplar -- vector )
    [ element-type heap-size * <byte-array> ]
    [ 1 swap ] 2bi
    (blas-vector-like) ;

M: blas-vector-base equal?
    {
        [ [ length ] same? ]
        [ [ = ] 2all? ]
    } 2&& ;

M: blas-vector-base length
    length>> ;
M: blas-vector-base virtual-exemplar
    (blas-direct-array) ;
M: blas-vector-base virtual@
    [ inc>> * ] [ nip (blas-direct-array) ] 2bi ;

: float>arg ( f -- f ) ; inline
: double>arg ( f -- f ) ; inline
: arg>float ( f -- f ) ; inline
: arg>double ( f -- f ) ; inline

<<

<FUNCTOR: (define-blas-vector) ( TYPE T -- )

<DIRECT-ARRAY> IS <direct-${TYPE}-array>
XCOPY          IS ${T}COPY
XSWAP          IS ${T}SWAP
IXAMAX         IS I${T}AMAX

VECTOR         DEFINES-CLASS ${TYPE}-blas-vector
<VECTOR>       DEFINES <${TYPE}-blas-vector>
>VECTOR        DEFINES >${TYPE}-blas-vector

t              [ T >lower ]

XVECTOR{       DEFINES ${t}vector{

XAXPY          IS ${T}AXPY
XSCAL          IS ${T}SCAL

WHERE

TUPLE: VECTOR < blas-vector-base ;
: <VECTOR> ( underlying length inc -- vector ) VECTOR boa ; inline

: >VECTOR ( seq -- v )
    [ TYPE >c-array underlying>> ] [ length ] bi 1 <VECTOR> ;

M: VECTOR clone
    TYPE heap-size (prepare-copy)
    [ XCOPY ] 3dip <VECTOR> ;

M: VECTOR element-type
    drop TYPE ;
M: VECTOR Vswap
    (prepare-swap) [ XSWAP ] 2dip ;
M: VECTOR Viamax
    (prepare-nrm2) IXAMAX 1 - ;

M: VECTOR (blas-vector-like)
    drop <VECTOR> ;

M: VECTOR (blas-direct-array)
    [ underlying>> ]
    [ [ length>> ] [ inc>> ] bi * ] bi
    <DIRECT-ARRAY> ;

M: VECTOR n*V+V!
    (prepare-axpy) [ XAXPY ] dip ;
M: VECTOR n*V!
    (prepare-scal) [ XSCAL ] dip ;

SYNTAX: XVECTOR{ \ } [ >VECTOR ] parse-literal ;

M: VECTOR pprint-delims
    drop \ XVECTOR{ \ } ;

;FUNCTOR>


<FUNCTOR: (define-real-blas-vector) ( TYPE T -- )

VECTOR         IS ${TYPE}-blas-vector
XDOT           IS ${T}DOT
XNRM2          IS ${T}NRM2
XASUM          IS ${T}ASUM

WHERE

M: VECTOR V.
    (prepare-dot) XDOT ;
M: VECTOR V.conj
    (prepare-dot) XDOT ;
M: VECTOR Vnorm
    (prepare-nrm2) XNRM2 ;
M: VECTOR Vasum
    (prepare-nrm2) XASUM ;

;FUNCTOR>


<FUNCTOR: (define-complex-blas-vector) ( TYPE C S -- )

VECTOR         IS ${TYPE}-blas-vector
XDOTU          IS ${C}DOTU
XDOTC          IS ${C}DOTC
XXNRM2         IS ${S}${C}NRM2
XXASUM         IS ${S}${C}ASUM

WHERE

M: VECTOR V.
    (prepare-dot) XDOTU ;
M: VECTOR V.conj
    (prepare-dot) XDOTC ;
M: VECTOR Vnorm
    (prepare-nrm2) XXNRM2 ;
M: VECTOR Vasum
    (prepare-nrm2) XXASUM ;

;FUNCTOR>


: define-real-blas-vector ( TYPE T -- )
    [ (define-blas-vector) ]
    [ (define-real-blas-vector) ] 2bi ;
: define-complex-blas-vector ( TYPE C S -- )
    [ drop (define-blas-vector) ]
    [ (define-complex-blas-vector) ] 3bi ;

float  "S" define-real-blas-vector
double "D" define-real-blas-vector
complex-float  "C" "S" define-complex-blas-vector
complex-double "Z" "D" define-complex-blas-vector

>>

M: blas-vector-base >pprint-sequence ;
M: blas-vector-base pprint* pprint-object ;
