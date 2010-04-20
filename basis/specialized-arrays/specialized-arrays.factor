! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.parser
assocs byte-arrays classes compiler.units functors kernel lexer
libc math math.vectors math.vectors.private namespaces
parser prettyprint.custom sequences sequences.private strings
summary vocabs vocabs.loader vocabs.parser vocabs.generated
words fry combinators make ;
IN: specialized-arrays

MIXIN: specialized-array

INSTANCE: specialized-array sequence

GENERIC: direct-array-syntax ( obj -- word )

ERROR: bad-byte-array-length byte-array type ;

M: bad-byte-array-length summary
    drop "Byte array length doesn't divide type width" ;

ERROR: not-a-byte-array alien ;

M: not-a-byte-array summary
    drop "Not a byte array" ;

: (underlying) ( n c-type -- array )
    heap-size * (byte-array) ; inline

: <underlying> ( n type -- array )
    heap-size * <byte-array> ; inline

<PRIVATE

FUNCTOR: define-array ( T -- )

A            DEFINES-CLASS ${T}-array
<A>          DEFINES <${A}>
(A)          DEFINES (${A})
<direct-A>   DEFINES <direct-${A}>
malloc-A     DEFINES malloc-${A}
>A           DEFINES >${A}
byte-array>A DEFINES byte-array>${A}

A{           DEFINES ${A}{
A@           DEFINES ${A}@

NTH          [ T dup c-type-getter-boxer array-accessor ]
SET-NTH      [ T dup c-setter array-accessor ]

WHERE

TUPLE: A
{ underlying c-ptr read-only }
{ length array-capacity read-only } ; final

: <direct-A> ( alien len -- specialized-array ) A boa ; inline

: <A> ( n -- specialized-array )
    [ \ T <underlying> ] keep <direct-A> ; inline

: (A) ( n -- specialized-array )
    [ \ T (underlying) ] keep <direct-A> ; inline

: malloc-A ( len -- specialized-array )
    [ \ T heap-size calloc ] keep <direct-A> ; inline

: byte-array>A ( byte-array -- specialized-array )
    >c-ptr dup byte-array? [
        dup length \ T heap-size /mod 0 =
        [ <direct-A> ]
        [ drop \ T bad-byte-array-length ] if
    ] [ not-a-byte-array ] if ; inline

M: A clone [ underlying>> clone ] [ length>> ] bi <direct-A> ; inline

M: A length length>> ; inline

M: A nth-unsafe underlying>> NTH call ; inline

M: A set-nth-unsafe underlying>> SET-NTH call ; inline

: >A ( seq -- specialized-array ) A new clone-like ;

M: A like drop dup A instance? [ >A ] unless ; inline

M: A new-sequence drop (A) ; inline

M: A equal? over A instance? [ sequence= ] [ 2drop f ] if ;

M: A resize
    [
        [ \ T heap-size * ] [ underlying>> ] bi*
        resize-byte-array
    ] [ drop ] 2bi
    <direct-A> ; inline

M: A element-size drop \ T heap-size ; inline

M: A direct-array-syntax drop \ A@ ;

M: A pprint-delims drop \ A{ \ } ;

M: A >pprint-sequence ;

SYNTAX: A{ \ } [ >A ] parse-literal ;
SYNTAX: A@ scan-object scan-object <direct-A> suffix! ;

INSTANCE: A specialized-array

M: A vs+ [ + \ T c-type-clamp ] 2map ; inline
M: A vs- [ - \ T c-type-clamp ] 2map ; inline
M: A vs* [ * \ T c-type-clamp ] 2map ; inline

M: A v*high [ * \ T heap-size neg shift ] 2map ; inline

;FUNCTOR

GENERIC: underlying-type ( c-type -- c-type' )

M: c-type-word underlying-type
    dup "c-type" word-prop {
        { [ dup not ] [ drop no-c-type ] }
        { [ dup pointer? ] [ 2drop void* ] }
        { [ dup c-type-word? ] [ nip underlying-type ] }
        [ drop ]
    } cond ;

M: pointer underlying-type
    drop void* ;

: specialized-array-vocab ( c-type -- vocab )
    [
        "specialized-arrays.instances." %
        [ vocabulary>> % "." % ]
        [ name>> % ]
        bi
    ] "" make ;

PRIVATE>

: define-array-vocab ( type -- vocab )
    underlying-type
    [ specialized-array-vocab ] [ '[ _ define-array ] ] bi
    generate-vocab ;

ERROR: specialized-array-vocab-not-loaded c-type ;

M: c-type-word c-array-constructor
    underlying-type
    dup [ name>> "<" "-array>" surround ] [ specialized-array-vocab ] bi lookup
    [ ] [ specialized-array-vocab-not-loaded ] ?if ; foldable

M: pointer c-array-constructor drop void* c-array-constructor ;

M: c-type-word c-(array)-constructor
    underlying-type
    dup [ name>> "(" "-array)" surround ] [ specialized-array-vocab ] bi lookup
    [ ] [ specialized-array-vocab-not-loaded ] ?if ; foldable

M: pointer c-(array)-constructor drop void* c-(array)-constructor ;

M: c-type-word c-direct-array-constructor
    underlying-type
    dup [ name>> "<direct-" "-array>" surround ] [ specialized-array-vocab ] bi lookup
    [ ] [ specialized-array-vocab-not-loaded ] ?if ; foldable

M: pointer c-direct-array-constructor drop void* c-direct-array-constructor ;

SYNTAX: SPECIALIZED-ARRAYS:
    ";" [ parse-c-type define-array-vocab use-vocab ] each-token ;

SYNTAX: SPECIALIZED-ARRAY:
    scan-c-type define-array-vocab use-vocab ;

{ "specialized-arrays" "prettyprint" } "specialized-arrays.prettyprint" require-when

{ "specialized-arrays" "mirrors" } "specialized-arrays.mirrors" require-when
