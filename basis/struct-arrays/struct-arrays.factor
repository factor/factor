! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types byte-arrays kernel libc
math sequences sequences.private ;
IN: struct-arrays

: c-type-struct-class ( c-type -- class )
    c-type boxed-class>> ; foldable

TUPLE: struct-array
{ underlying c-ptr read-only }
{ length array-capacity read-only }
{ element-size array-capacity read-only }
{ class read-only } ;

M: struct-array length length>> ;
M: struct-array byte-length [ length>> ] [ element-size>> ] bi * ;

M: struct-array nth-unsafe
    [ element-size>> * ] [ underlying>> ] bi <displaced-alien> ;

M: struct-array set-nth-unsafe
    [ nth-unsafe swap ] [ element-size>> ] bi memcpy ;

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
