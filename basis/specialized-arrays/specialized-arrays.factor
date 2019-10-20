! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.parser
arrays byte-arrays classes combinators fry functors2
kernel lexer locals make math math.parser math.vectors parser
prettyprint.custom sequences sequences.private vocabs.generated
vocabs.loader vocabs.parser words ;
IN: specialized-arrays

MIXIN: specialized-array-mixin
MIXIN: specialized-array2

INSTANCE: specialized-array-mixin sequence
INSTANCE: specialized-array2 sequence

: (underlying) ( n c-type -- array )
    heap-size * (byte-array) ; inline

: <underlying> ( n type -- array )
    heap-size * <byte-array> ; inline

GENERIC: underlying-type ( c-type -- c-type' )

M: c-type-word underlying-type
    dup "c-type" word-prop {
        { [ dup not ] [ drop no-c-type ] }
        { [ dup pointer? ] [ 2drop void* ] }
        { [ dup c-type-word? ] [ nip underlying-type ] }
        [ drop ]
    } cond ;

M: pointer underlying-type drop void* ;

<PRIVATE

GENERIC: nth-c-ptr ( n seq -- displaced-alien )
GENERIC: direct-like ( alien len exemplar -- seq )

M: byte-array nth-c-ptr <displaced-alien> ; inline
M: byte-array direct-like drop uchar <c-direct-array> ; inline

PRIVATE>

VARIABLES-FUNCTOR: specialized-array ( type: existing-word -- ) {
    { "A" "${type}-array" }
    { "<A>" "<${A}>" }
    { "(A)" "(${A})" }
    { "<direct-A>" "<direct-${A}>" }
} [[
USING: accessors alien alien.c-types alien.data byte-arrays
classes kernel math math.vectors parser prettyprint.custom
sequences sequences.private specialized-arrays
specialized-arrays.private ;

<<
TUPLE: ${A}
{ underlying c-ptr read-only }
{ length array-capacity read-only } ; final

INSTANCE: ${A} specialized-array-mixin

: ${<direct-A>} ( alien len -- specialized-array ) ${A} boa ; inline

: ${<A>} ( n -- specialized-array )
    [ \ ${type} <underlying> ] keep ${<direct-A>} ; inline

: ${(A)} ( n -- specialized-array )
    [ \ ${type} (underlying) ] keep ${<direct-A>} ; inline
>>

SYNTAX: \${A}{ \ \} [ \ ${type} >c-array ] parse-literal ;

M: ${A} direct-like drop ${<direct-A>} ; inline

M: ${A} clone [ underlying>> clone ] [ length>> ] bi ${<direct-A>} ; inline

M: ${A} length length>> ; inline
M: ${A} nth-unsafe [ integer>fixnum ] dip underlying>> \ ${type} alien-element ; inline

M: ${A} nth-c-ptr underlying>> \ ${type} array-accessor drop swap <displaced-alien> ; inline

M: ${A} set-nth-unsafe [ integer>fixnum ] dip underlying>> \ ${type} set-alien-element ; inline

M: ${A} like drop dup ${A} instance? [ \ ${type} >c-array ] unless ; inline

M: ${A} new-sequence drop ${(A)} ; inline

M: ${A} equal? over ${A} instance? [ sequence= ] [ 2drop f ] if ;

M: ${A} resize
    [
        [ \ ${type} heap-size * ] [ underlying>> ] bi*
        resize-byte-array
    ] [ drop ] 2bi
    ${<direct-A>} ; inline

M: ${A} element-size drop \ ${type} heap-size ; inline

M: ${A} underlying-type drop \ ${type} ;

M: ${A} pprint-delims drop \ \${A}{ \ \} ;

M: ${A} >pprint-sequence ;

M: ${A} vs+ [ + \ ${type} c-type-clamp ] 2map ; inline
M: ${A} vs- [ - \ ${type} c-type-clamp ] 2map ; inline
M: ${A} vs* [ * \ ${type} c-type-clamp ] 2map ; inline

M: ${A} v*high [ * \ ${type} heap-size neg shift ] 2map ; inline
]]

<PRIVATE
: specialized-array-vocab ( c-type -- vocab )
    [
        "specialized-arrays:functors:specialized-array:" %
        ! [ vocabulary>> % "." % ]
        ! [ name>> % ":" % ]
        [ drop ]
        [ 1array hashcode number>string % ] bi
    ] "" make ;

:: direct-slice-unsafe ( from to seq -- seq' )
    from seq nth-c-ptr to from - seq direct-like ; inline
PRIVATE>

: direct-slice ( from to seq -- seq' )
    check-slice direct-slice-unsafe ; inline

: direct-head ( seq n -- seq' ) (head) direct-slice ; inline
: direct-tail ( seq n -- seq' ) (tail) direct-slice ; inline
: direct-head* ( seq n -- seq' ) from-end direct-head ; inline
: direct-tail* ( seq n -- seq' ) from-end direct-tail ; inline

ERROR: specialized-array-vocab-not-loaded c-type ;

M: c-type-word c-array-constructor
    underlying-type
    dup [ name>> "<" "-array>" surround ] [ specialized-array-vocab ] bi lookup-word
    [ ] [ specialized-array-vocab-not-loaded ] ?if ; foldable

M: pointer c-array-constructor drop void* c-array-constructor ;

M: c-type-word c-(array)-constructor
    underlying-type
    dup [ name>> "(" "-array)" surround ] [ specialized-array-vocab ] bi lookup-word
    [ ] [ specialized-array-vocab-not-loaded ] ?if ; foldable

M: pointer c-(array)-constructor drop void* c-(array)-constructor ;

M: c-type-word c-direct-array-constructor
    underlying-type
    dup [ name>> "<direct-" "-array>" surround ] [ specialized-array-vocab ] bi lookup-word
    [ ] [ specialized-array-vocab-not-loaded ] ?if ; foldable

M: pointer c-direct-array-constructor drop void* c-direct-array-constructor ;

M: c-type-word c-array-type
    underlying-type
    dup [ name>> "-array" append ] [ specialized-array-vocab ] bi lookup-word
    [ ] [ specialized-array-vocab-not-loaded ] ?if ; foldable

M: pointer c-array-type drop void* c-array-type ;

M: c-type-word c-array-type?
    underlying-type
    dup [ name>> "-array?" append ] [ specialized-array-vocab ] bi lookup-word
    [ ] [ specialized-array-vocab-not-loaded ] ?if ; foldable

M: pointer c-array-type? drop void* c-array-type? ;

SYNTAX: \SPECIALIZED-ARRAYS:
    ";" [ parse-c-type define-specialized-array ] each-token ;

! { "specialized-arrays" "prettyprint" } "specialized-arrays.prettyprint" require-when

! { "specialized-arrays" "mirrors" } "specialized-arrays.mirrors" require-when

uchar define-specialized-array
