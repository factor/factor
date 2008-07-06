USING: accessors alien alien.c-types arrays byte-arrays combinators
combinators.short-circuit fry kernel macros math math.blas.cblas
math.complex math.functions math.order multi-methods qualified
sequences sequences.private shuffle ;
QUALIFIED: syntax
IN: math.blas.vectors

TUPLE: blas-vector-base data length inc ;
TUPLE: float-blas-vector < blas-vector-base ;
TUPLE: double-blas-vector < blas-vector-base ;
TUPLE: float-complex-blas-vector < blas-vector-base ;
TUPLE: double-complex-blas-vector < blas-vector-base ;

INSTANCE: float-blas-vector sequence
INSTANCE: double-blas-vector sequence
INSTANCE: float-complex-blas-vector sequence
INSTANCE: double-complex-blas-vector sequence

C: <float-blas-vector> float-blas-vector
C: <double-blas-vector> double-blas-vector
C: <float-complex-blas-vector> float-complex-blas-vector
C: <double-complex-blas-vector> double-complex-blas-vector

GENERIC: n*V+V-in-place ( alpha x y -- y=alpha*x+y )
GENERIC: n*V-in-place   ( alpha x -- x=alpha*x )

GENERIC: V. ( x y -- x.y )
GENERIC: V.conj ( x y -- xconj.y )
GENERIC: Vnorm ( x -- norm )
GENERIC: Vasum ( x -- sum )
GENERIC: Vswap ( x y -- x=y y=x )

GENERIC: Viamax ( x -- max-i )

GENERIC: element-type ( v -- type )

METHOD: element-type { float-blas-vector }
    drop "float" ;
METHOD: element-type { double-blas-vector }
    drop "double" ;
METHOD: element-type { float-complex-blas-vector }
    drop "CBLAS_C" ;
METHOD: element-type { double-complex-blas-vector }
    drop "CBLAS_Z" ;

<PRIVATE

GENERIC: (blas-vector-like) ( data length inc exemplar -- vector )

METHOD: (blas-vector-like) { object object object float-blas-vector }
    drop <float-blas-vector> ;
METHOD: (blas-vector-like) { object object object double-blas-vector }
    drop <double-blas-vector> ;
METHOD: (blas-vector-like) { object object object float-complex-blas-vector }
    drop <float-complex-blas-vector> ;
METHOD: (blas-vector-like) { object object object double-complex-blas-vector }
    drop <double-complex-blas-vector> ;

: (prepare-copy) ( v element-size -- length v-data v-inc v-dest-data v-dest-inc )
    [ [ length>> ] [ data>> ] [ inc>> ] tri ] dip
    4 npick * <byte-array>
    1 ;

MACRO: (do-copy) ( copy make-vector -- )
    '[ over 6 npick , 2dip 1 @ ] ;

: (prepare-swap) ( v1 v2 -- length v1-data v1-inc v2-data v2-inc v1 v2 )
    [
        [ [ length>> ] bi@ min ]
        [ [ [ data>> ] [ inc>> ] bi ] bi@ ] 2bi
    ] 2keep ;

: (prepare-axpy) ( n v1 v2 -- length n v1-data v1-inc v2-data v2-inc v2 )
    [
        [ [ length>> ] bi@ min swap ]
        [ [ [ data>> ] [ inc>> ] bi ] bi@ ] 2bi
    ] keep ;

: (prepare-scal) ( n v -- length n v-data v-inc v )
    [ [ length>> swap ] [ data>> ] [ inc>> ] tri ] keep ;

: (prepare-dot) ( v1 v2 -- length v1-data v1-inc v2-data v2-inc )
    [ [ length>> ] bi@ min ]
    [ [ [ data>> ] [ inc>> ] bi ] bi@ ] 2bi ;

: (prepare-nrm2) ( v -- length v1-data v1-inc )
    [ length>> ] [ data>> ] [ inc>> ] tri ;

: (flatten-complex-sequence) ( seq -- seq' )
    [ [ real-part ] [ imaginary-part ] bi 2array ] map concat ;

: (>c-complex) ( complex -- alien )
    [ real-part ] [ imaginary-part ] bi 2array >c-float-array ;
: (>z-complex) ( complex -- alien )
    [ real-part ] [ imaginary-part ] bi 2array >c-double-array ;

: (c-complex>) ( alien -- complex )
    2 c-float-array> first2 rect> ;
: (z-complex>) ( alien -- complex )
    2 c-double-array> first2 rect> ;

: (prepare-nth) ( n v -- n*inc v-data )
    [ inc>> ] [ data>> ] bi [ * ] dip ;

MACRO: (complex-nth) ( nth-quot -- )
    '[ 
        [ 2 * dup 1+ ] dip
        , curry bi@ rect>
    ] ;

: (c-complex-nth) ( n alien -- complex )
    [ float-nth ] (complex-nth) ;
: (z-complex-nth) ( n alien -- complex )
    [ double-nth ] (complex-nth) ;

MACRO: (set-complex-nth) ( set-nth-quot -- )
    '[
        [
            [ [ real-part ] [ imaginary-part ] bi ]
            [ 2 * dup 1+ ] bi*
            swapd
        ] dip
        , curry 2bi@ 
    ] ;

: (set-c-complex-nth) ( complex n alien -- )
    [ set-float-nth ] (set-complex-nth) ;
: (set-z-complex-nth) ( complex n alien -- )
    [ set-double-nth ] (set-complex-nth) ;

PRIVATE>

: <zero-vector> ( exemplar -- zero )
    [ element-type <c-object> ]
    [ length>> 0 ]
    [ (blas-vector-like) ] tri ;

: <empty-vector> ( length exemplar -- vector )
    [ element-type <c-array> ]
    [ 1 swap ] 2bi
    (blas-vector-like) ;

syntax:M: blas-vector-base length
    length>> ;

syntax:M: float-blas-vector nth-unsafe
    (prepare-nth) float-nth ;
syntax:M: float-blas-vector set-nth-unsafe
    (prepare-nth) set-float-nth ;

syntax:M: double-blas-vector nth-unsafe
    (prepare-nth) double-nth ;
syntax:M: double-blas-vector set-nth-unsafe
    (prepare-nth) set-double-nth ;

syntax:M: float-complex-blas-vector nth-unsafe
    (prepare-nth) (c-complex-nth) ;
syntax:M: float-complex-blas-vector set-nth-unsafe
    (prepare-nth) (set-c-complex-nth) ;

syntax:M: double-complex-blas-vector nth-unsafe
    (prepare-nth) (z-complex-nth) ;
syntax:M: double-complex-blas-vector set-nth-unsafe
    (prepare-nth) (set-z-complex-nth) ;

syntax:M: blas-vector-base equal?
    {
        [ [ length ] bi@ = ]
        [ [ = ] 2all? ]
    } 2&& ;

: >float-blas-vector ( seq -- v )
    [ >c-float-array ] [ length ] bi 1 <float-blas-vector> ;
: >double-blas-vector ( seq -- v )
    [ >c-double-array ] [ length ] bi 1 <double-blas-vector> ;
: >float-complex-blas-vector ( seq -- v )
    [ (flatten-complex-sequence) >c-float-array ] [ length ] bi
    1 <float-complex-blas-vector> ;
: >double-complex-blas-vector ( seq -- v )
    [ (flatten-complex-sequence) >c-double-array ] [ length ] bi
    1 <double-complex-blas-vector> ;

syntax:M: float-blas-vector clone
    "float" heap-size (prepare-copy)
    [ cblas_scopy ] [ <float-blas-vector> ] (do-copy) ;
syntax:M: double-blas-vector clone
    "double" heap-size (prepare-copy)
    [ cblas_dcopy ] [ <double-blas-vector> ] (do-copy) ;
syntax:M: float-complex-blas-vector clone
    "CBLAS_C" heap-size (prepare-copy)
    [ cblas_ccopy ] [ <float-complex-blas-vector> ] (do-copy) ;
syntax:M: double-complex-blas-vector clone
    "CBLAS_Z" heap-size (prepare-copy)
    [ cblas_zcopy ] [ <double-complex-blas-vector> ] (do-copy) ;

METHOD: Vswap { float-blas-vector float-blas-vector }
    (prepare-swap) [ cblas_sswap ] 2dip ;
METHOD: Vswap { double-blas-vector double-blas-vector }
    (prepare-swap) [ cblas_dswap ] 2dip ;
METHOD: Vswap { float-complex-blas-vector float-complex-blas-vector }
    (prepare-swap) [ cblas_cswap ] 2dip ;
METHOD: Vswap { double-complex-blas-vector double-complex-blas-vector }
    (prepare-swap) [ cblas_zswap ] 2dip ;

METHOD: n*V+V-in-place { real float-blas-vector float-blas-vector }
    (prepare-axpy) [ cblas_saxpy ] dip ;
METHOD: n*V+V-in-place { real double-blas-vector double-blas-vector }
    (prepare-axpy) [ cblas_daxpy ] dip ;
METHOD: n*V+V-in-place { number float-complex-blas-vector float-complex-blas-vector }
    [ (>c-complex) ] 2dip
    (prepare-axpy) [ cblas_caxpy ] dip ;
METHOD: n*V+V-in-place { number double-complex-blas-vector double-complex-blas-vector }
    [ (>z-complex) ] 2dip
    (prepare-axpy) [ cblas_zaxpy ] dip ;

METHOD: n*V-in-place { real float-blas-vector }
    (prepare-scal) [ cblas_sscal ] dip ;
METHOD: n*V-in-place { real double-blas-vector }
    (prepare-scal) [ cblas_dscal ] dip ;
METHOD: n*V-in-place { number float-complex-blas-vector }
    [ (>c-complex) ] dip
    (prepare-scal) [ cblas_cscal ] dip ;
METHOD: n*V-in-place { number double-complex-blas-vector }
    [ (>z-complex) ] dip
    (prepare-scal) [ cblas_zscal ] dip ;

: n*V+V ( alpha x y -- alpha*x+y ) clone n*V+V-in-place ; inline
: n*V ( alpha x -- alpha*x ) clone n*V-in-place ; inline

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

METHOD: V. { float-blas-vector float-blas-vector }
    (prepare-dot) cblas_sdot ;
METHOD: V. { double-blas-vector double-blas-vector }
    (prepare-dot) cblas_ddot ;
METHOD: V. { float-complex-blas-vector float-complex-blas-vector }
    (prepare-dot)
    "CBLAS_C" <c-object> [ cblas_cdotu_sub ] keep (c-complex>) ;
METHOD: V. { double-complex-blas-vector double-complex-blas-vector }
    (prepare-dot)
    "CBLAS_Z" <c-object> [ cblas_zdotu_sub ] keep (z-complex>) ;

METHOD: V.conj { float-complex-blas-vector float-complex-blas-vector }
    (prepare-dot)
    "CBLAS_C" <c-object> [ cblas_cdotc_sub ] keep (c-complex>) ;
METHOD: V.conj { double-complex-blas-vector double-complex-blas-vector }
    (prepare-dot)
    "CBLAS_Z" <c-object> [ cblas_zdotc_sub ] keep (z-complex>) ;

METHOD: Vnorm { float-blas-vector }
    (prepare-nrm2) cblas_snrm2 ;
METHOD: Vnorm { double-blas-vector }
    (prepare-nrm2) cblas_dnrm2 ;
METHOD: Vnorm { float-complex-blas-vector }
    (prepare-nrm2) cblas_scnrm2 ;
METHOD: Vnorm { double-complex-blas-vector }
    (prepare-nrm2) cblas_dznrm2 ;

METHOD: Vasum { float-blas-vector }
    (prepare-nrm2) cblas_sasum ;
METHOD: Vasum { double-blas-vector }
    (prepare-nrm2) cblas_dasum ;
METHOD: Vasum { float-complex-blas-vector }
    (prepare-nrm2) cblas_scasum ;
METHOD: Vasum { double-complex-blas-vector }
    (prepare-nrm2) cblas_dzasum ;

METHOD: Viamax { float-blas-vector }
    (prepare-nrm2) cblas_isamax ;
METHOD: Viamax { double-blas-vector }
    (prepare-nrm2) cblas_idamax ;
METHOD: Viamax { float-complex-blas-vector }
    (prepare-nrm2) cblas_icamax ;
METHOD: Viamax { double-complex-blas-vector }
    (prepare-nrm2) cblas_izamax ;

: Vamax ( x -- max )
    [ Viamax ] keep nth ; inline

: Vsub ( v start length -- vsub )
    rot [
        [
            nip [ inc>> ] [ element-type heap-size ] [ data>> ] tri
            [ * * ] dip <displaced-alien>
        ] [ swap 2nip ] [ 2nip inc>> ] 3tri
    ] keep (blas-vector-like) ;
