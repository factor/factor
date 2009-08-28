! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.structs byte-arrays
classes.struct kernel libc math parser sequences sequences.private ;
IN: struct-arrays

: c-type-struct-class ( c-type -- class )
    c-type boxed-class>> ; foldable

TUPLE: struct-array
{ underlying c-ptr read-only }
{ length array-capacity read-only }
{ element-size array-capacity read-only }
{ class read-only } ;

M: struct-array length length>> ; inline
M: struct-array byte-length [ length>> ] [ element-size>> ] bi * ; inline

: (nth-ptr) ( i struct-array -- alien )
    [ element-size>> * ] [ underlying>> ] bi <displaced-alien> ; inline

M: struct-array nth-unsafe
    [ (nth-ptr) ] [ class>> dup struct-class? ] bi [ memory>struct ] [ drop ] if ; inline

M: struct-array set-nth-unsafe
    [ (nth-ptr) swap ] [ element-size>> ] bi memcpy ; inline

M: struct-array new-sequence
    [ element-size>> [ * <byte-array> ] 2keep ]
    [ class>> ] bi struct-array boa ; inline

M: struct-array resize ( n seq -- newseq )
    [ [ element-size>> * ] [ underlying>> ] bi resize ]
    [ [ element-size>> ] [ class>> ] bi ] 2bi
    struct-array boa ;

: <struct-array> ( length c-type -- struct-array )
    [ heap-size [ * <byte-array> ] 2keep ]
    [ c-type-struct-class ] bi struct-array boa ; inline

ERROR: bad-byte-array-length byte-array ;

: byte-array>struct-array ( byte-array c-type -- struct-array )
    [ heap-size [
        [ dup length ] dip /mod 0 =
        [ drop bad-byte-array-length ] unless
    ] keep ] [ c-type-struct-class ] bi struct-array boa ; inline

: <direct-struct-array> ( alien length c-type -- struct-array )
    [ heap-size ] [ c-type-struct-class ] bi struct-array boa ; inline

: malloc-struct-array ( length c-type -- struct-array )
    [ heap-size calloc ] 2keep <direct-struct-array> ; inline

INSTANCE: struct-array sequence

M: struct-type <c-type-array> ( len c-type -- array )
    dup c-type-array-constructor
    [ execute( len -- array ) ]
    [ <struct-array> ] ?if ; inline

M: struct-type <c-type-direct-array> ( alien len c-type -- array )
    dup c-type-direct-array-constructor
    [ execute( alien len -- array ) ]
    [ <direct-struct-array> ] ?if ; inline

: >struct-array ( sequence class -- struct-array )
    [ dup length ] dip <struct-array>
    [ 0 swap copy ] keep ; inline

SYNTAX: struct-array{
    \ } scan-word [ >struct-array ] curry parse-literal ;

USING: vocabs vocabs.loader ;

"prettyprint" vocab [ "struct-arrays.prettyprint" require ] when
