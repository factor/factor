USING: accessors alien alien.c-types alien.complex alien.data
arrays ascii byte-arrays combinators combinators.short-circuit
fry kernel math math.blas.ffi math.complex math.functions
math.order sequences sequences.private functors words locals
parser prettyprint.backend prettyprint.custom specialized-arrays
functors2 strings ;
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
INLINE-FUNCTOR: blas-vector ( type: name t: string -- ) [[
    TUPLE: ${type}-blas-vector < blas-vector-base ;

    : <${type}-blas-vector> ( underlying length inc -- vector ) ${type}-blas-vector boa ; inline
    <<
    : >${type}-blas-vector ( seq -- v )
        [ ${type} >c-array underlying>> ] [ length ] bi 1 <${type}-blas-vector> ;
    >>
    <<
    SYNTAX: \${t}vector{ \ \} [ >${type}-blas-vector ] parse-literal ;
    >>

    M: ${type}-blas-vector clone
        ${type} heap-size (prepare-copy)
        [ ${t}COPY ] 3dip <${type}-blas-vector> ;

    M: ${type}-blas-vector element-type
        drop ${type} ;
    M: ${type}-blas-vector Vswap
        (prepare-swap) [ ${t}SWAP ] 2dip ;
    M: ${type}-blas-vector Viamax
        (prepare-nrm2) I${t}AMAX 1 - ;

    M: ${type}-blas-vector (blas-vector-like)
        drop <${type}-blas-vector> ;

    M: ${type}-blas-vector (blas-direct-array)
        [ underlying>> ]
        [ [ length>> ] [ inc>> ] bi * ] bi
        <direct-${type}-array> ;

    M: ${type}-blas-vector n*V+V!
        (prepare-axpy) [ ${t}AXPY ] dip ;
    M: ${type}-blas-vector n*V!
        (prepare-scal) [ ${t}SCAL ] dip ;

    M: ${type}-blas-vector pprint-delims
        drop \ \${t}vector{ \ \} ;
]]
>>


<<
INLINE-FUNCTOR: real-blas-vector ( type: name t: string -- ) [[
    <<
    BLAS-VECTOR: ${type} "${t}"
    >>

    M: ${type}-blas-vector V.
        (prepare-dot) ${t}DOT ;
    M: ${type}-blas-vector V.conj
        (prepare-dot) ${t}DOT ;
    M: ${type}-blas-vector Vnorm
        (prepare-nrm2) ${t}NRM2 ;
    M: ${type}-blas-vector Vasum
        (prepare-nrm2) ${t}ASUM ;

]]
>>


<<
INLINE-FUNCTOR: complex-blas-vector ( type: name c: string s: string -- ) [[
    <<
    BLAS-VECTOR: ${type} "${c}"
    >>

    M: ${type}-blas-vector V.
        (prepare-dot) ${c}DOTU ;
    M: ${type}-blas-vector V.conj
        (prepare-dot) ${c}DOTC ;
    M: ${type}-blas-vector Vnorm
        (prepare-nrm2) ${s}${c}NRM2 ;
    M: ${type}-blas-vector Vasum
        (prepare-nrm2) ${s}${c}ASUM ;

]]
>>

COMPLEX-BLAS-VECTOR: complex-float  "C" "S"
COMPLEX-BLAS-VECTOR: complex-double "Z" "D"
REAL-BLAS-VECTOR: float  "S"
REAL-BLAS-VECTOR: double "D"

M: blas-vector-base >pprint-sequence ;
M: blas-vector-base pprint* pprint-object ;
