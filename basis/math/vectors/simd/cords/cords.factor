USING: accessors alien.c-types arrays byte-arrays
cpu.architecture effects functors generalizations kernel lexer
math math.vectors.simd math.vectors.simd.intrinsics parser
prettyprint.custom quotations sequences sequences.cords words
classes functors2 literals ;
IN: math.vectors.simd.cords

<<
INLINE-FUNCTOR: simd-128-cord ( type/2: existing-word type: name -- ) [[

    DEFER: ${type}
    <<
    SPECIALIZED-CORD: ${type/2} ${type}
    >>

    <<
    <c-type>
        byte-array >>class
        ${type} >>boxed-class
        [
            [      ${type/2}-rep alien-vector ${type/2} boa ]
            [ 16 + ${type/2}-rep alien-vector ${type/2} boa ] 2bi cord-append
        ] >>getter
        [
            [ [ head>> underlying>> ] 2dip      ${type/2}-rep set-alien-vector ]
            [ [ tail>> underlying>> ] 2dip 16 + ${type/2}-rep set-alien-vector ] 3bi
        ] >>setter
        32 >>size
        16 >>align
        ${type/2}-rep >>rep
    \ ${type} typedef
    >>

    : >${type} ( seq -- ${type} )
        [ $[ ${type/2}-rep rep-length ] head-slice >${type/2} ]
        [ $[ ${type/2}-rep rep-length ] tail-slice >${type/2} ] bi cord-append ;

    DEFER: ${type}-boa
    \ ${type}-boa
    { $[ ${type/2}-rep rep-length ] ndip ${type/2}-boa cord-append } { ${type/2}-boa } >quotation prefix >quotation
    $[ $[ ${type/2}-rep rep-length ] 2 * "n" <array> { "v" } <effect> ] define-inline

    : ${type}-with ( n -- v )
        [ ${type/2}-with ] [ ${type/2}-with ] bi cord-append ; inline

    : ${type}-cast ( v -- v' )
        [ ${type/2}-cast ] cord-map ; inline

    M: ${type} new-sequence
        2drop
        $[ ${type/2}-rep rep-length ] ${type/2} new new-sequence
        $[ ${type/2}-rep rep-length ] ${type/2} new new-sequence
        \ ${type} boa ;

    M: ${type} like
        over \ ${type} instance? [ drop ] [ call-next-method ] if ;

    M: ${type} >pprint-sequence ;
    M: ${type} pprint* pprint-object ;

    <<
    SYNTAX: \${type}{ \ \} [ >${type} ] parse-literal ;
    >>
    M: ${type} pprint-delims drop \ \${type}{ \ \} ;
]]
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
