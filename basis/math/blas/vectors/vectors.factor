USING: accessors alien alien.c-types arrays byte-arrays combinators
combinators.short-circuit fry kernel math math.blas.cblas
math.complex math.functions math.order sequences.complex
sequences.complex-components sequences sequences.private
functors words locals parser prettyprint.backend prettyprint.custom
specialized-arrays.float specialized-arrays.double
specialized-arrays.direct.float specialized-arrays.direct.double ;
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
    [ underlying>> ] [ inc>> ] bi ; inline
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

: V+ ( x y -- x+y )
    1.0 -rot n*V+V ; inline
: V- ( x y -- x-y )
    -1.0 spin n*V+V ; inline

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
    [ element-type <c-object> ]
    [ length>> 0 ]
    [ (blas-vector-like) ] tri ;

: <empty-vector> ( length exemplar -- vector )
    [ element-type <c-array> ]
    [ 1 swap ] 2bi
    (blas-vector-like) ;

M: blas-vector-base equal?
    {
        [ [ length ] bi@ = ]
        [ [ = ] 2all? ]
    } 2&& ;

M: blas-vector-base length
    length>> ;
M: blas-vector-base virtual-seq
    (blas-direct-array) ;
M: blas-vector-base virtual@
    [ inc>> * ] [ nip (blas-direct-array) ] 2bi ;

: float>arg ( f -- f ) ; inline
: double>arg ( f -- f ) ; inline
: arg>float ( f -- f ) ; inline
: arg>double ( f -- f ) ; inline

<<

FUNCTOR: (define-blas-vector) ( TYPE T -- )

<DIRECT-ARRAY> IS <direct-${TYPE}-array>
>ARRAY         IS >${TYPE}-array
XCOPY          IS cblas_${T}copy
XSWAP          IS cblas_${T}swap
IXAMAX         IS cblas_i${T}amax

VECTOR         DEFINES-CLASS ${TYPE}-blas-vector
<VECTOR>       DEFINES <${TYPE}-blas-vector>
>VECTOR        DEFINES >${TYPE}-blas-vector

XVECTOR{       DEFINES ${T}vector{

WHERE

TUPLE: VECTOR < blas-vector-base ;
: <VECTOR> ( underlying length inc -- vector ) VECTOR boa ; inline

: >VECTOR ( seq -- v )
    [ >ARRAY underlying>> ] [ length ] bi 1 <VECTOR> ;

M: VECTOR clone
    TYPE heap-size (prepare-copy)
    [ XCOPY ] 3dip <VECTOR> ;

M: VECTOR element-type
    drop TYPE ;
M: VECTOR Vswap
    (prepare-swap) [ XSWAP ] 2dip ;
M: VECTOR Viamax
    (prepare-nrm2) IXAMAX ;

M: VECTOR (blas-vector-like)
    drop <VECTOR> ;

M: VECTOR (blas-direct-array)
    [ underlying>> ]
    [ [ length>> ] [ inc>> ] bi * ] bi
    <DIRECT-ARRAY> ;

: XVECTOR{ \ } [ >VECTOR ] parse-literal ; parsing

M: VECTOR pprint-delims
    drop \ XVECTOR{ \ } ;

;FUNCTOR


FUNCTOR: (define-real-blas-vector) ( TYPE T -- )

VECTOR         IS ${TYPE}-blas-vector
XDOT           IS cblas_${T}dot
XNRM2          IS cblas_${T}nrm2
XASUM          IS cblas_${T}asum
XAXPY          IS cblas_${T}axpy
XSCAL          IS cblas_${T}scal

WHERE

M: VECTOR V.
    (prepare-dot) XDOT ;
M: VECTOR V.conj
    (prepare-dot) XDOT ;
M: VECTOR Vnorm
    (prepare-nrm2) XNRM2 ;
M: VECTOR Vasum
    (prepare-nrm2) XASUM ;
M: VECTOR n*V+V!
    (prepare-axpy) [ XAXPY ] dip ;
M: VECTOR n*V!
    (prepare-scal) [ XSCAL ] dip ;

;FUNCTOR


FUNCTOR: (define-complex-helpers) ( TYPE -- )

<DIRECT-COMPLEX-ARRAY> DEFINES <direct-${TYPE}-complex-array>
>COMPLEX-ARRAY         DEFINES >${TYPE}-complex-array
ARG>COMPLEX            DEFINES arg>${TYPE}-complex
COMPLEX>ARG            DEFINES ${TYPE}-complex>arg
<DIRECT-ARRAY>         IS      <direct-${TYPE}-array>
>ARRAY                 IS      >${TYPE}-array

WHERE

: <DIRECT-COMPLEX-ARRAY> ( alien len -- sequence )
    1 shift <DIRECT-ARRAY> <complex-sequence> ;
: >COMPLEX-ARRAY ( sequence -- sequence )
    <complex-components> >ARRAY ;
: COMPLEX>ARG ( complex -- alien )
    >rect 2array >ARRAY underlying>> ;
: ARG>COMPLEX ( alien -- complex )
    2 <DIRECT-ARRAY> first2 rect> ;

;FUNCTOR


FUNCTOR: (define-complex-blas-vector) ( TYPE C S -- )

VECTOR         IS ${TYPE}-blas-vector
XDOTU_SUB      IS cblas_${C}dotu_sub
XDOTC_SUB      IS cblas_${C}dotc_sub
XXNRM2         IS cblas_${S}${C}nrm2
XXASUM         IS cblas_${S}${C}asum
XAXPY          IS cblas_${C}axpy
XSCAL          IS cblas_${C}scal
TYPE>ARG       IS ${TYPE}>arg
ARG>TYPE       IS arg>${TYPE}

WHERE

M: VECTOR V.
    (prepare-dot) TYPE <c-object>
    [ XDOTU_SUB ] keep
    ARG>TYPE ;
M: VECTOR V.conj
    (prepare-dot) TYPE <c-object>
    [ XDOTC_SUB ] keep
    ARG>TYPE ;
M: VECTOR Vnorm
    (prepare-nrm2) XXNRM2 ;
M: VECTOR Vasum
    (prepare-nrm2) XXASUM ;
M: VECTOR n*V+V!
    [ TYPE>ARG ] 2dip
    (prepare-axpy) [ XAXPY ] dip ;
M: VECTOR n*V!
    [ TYPE>ARG ] dip
    (prepare-scal) [ XSCAL ] dip ;

;FUNCTOR


: define-real-blas-vector ( TYPE T -- )
    [ (define-blas-vector) ]
    [ (define-real-blas-vector) ] 2bi ;
:: define-complex-blas-vector ( TYPE C S -- )
    TYPE (define-complex-helpers)
    TYPE "-complex" append
    [ C (define-blas-vector) ]
    [ C S (define-complex-blas-vector) ] bi ;

"float"  "s" define-real-blas-vector
"double" "d" define-real-blas-vector
"float"  "c" "s" define-complex-blas-vector
"double" "z" "d" define-complex-blas-vector

>>

M: blas-vector-base >pprint-sequence ;
M: blas-vector-base pprint* pprint-object ;
