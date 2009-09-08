! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.structs byte-arrays
classes classes.struct kernel libc math parser sequences
sequences.private words fry memoize compiler.units ;
IN: struct-arrays

TUPLE: struct-array
{ underlying c-ptr read-only }
{ length array-capacity read-only }
{ element-size array-capacity read-only }
{ class read-only }
{ ctor read-only } ;

<PRIVATE

: (nth-ptr) ( i struct-array -- alien )
    [ element-size>> * >fixnum ] [ underlying>> ] bi <displaced-alien> ; inline

: (struct-element-constructor) ( struct-class -- word )
    [
        "struct-array-ctor" f <word>
        [ swap '[ _ memory>struct ] (( alien -- object )) define-inline ] keep
    ] with-compilation-unit ;

! Foldable memo word. This is an optimization; by precompiling a
! constructor for array elements, we avoid memory>struct's slow path.
MEMO: struct-element-constructor ( struct-class -- word )
    (struct-element-constructor) ; foldable

PRIVATE>

M: struct-array length length>> ; inline

M: struct-array byte-length [ length>> ] [ element-size>> ] bi * ; inline

M: struct-array nth-unsafe
    [ (nth-ptr) ] [ ctor>> ] bi execute( alien -- object ) ; inline

M: struct-array set-nth-unsafe
    [ (nth-ptr) swap ] [ element-size>> ] bi memcpy ; inline

ERROR: not-a-struct-class struct-class ;

: <direct-struct-array> ( alien length struct-class -- struct-array )
    dup struct-class? [ not-a-struct-class ] unless
    [ heap-size ] [ ] [ struct-element-constructor ]
    tri struct-array boa ; inline

M: struct-array new-sequence
    [ element-size>> * (byte-array) ] [ class>> ] 2bi
    <direct-struct-array> ; inline

M: struct-array resize ( n seq -- newseq )
    [ [ element-size>> * ] [ underlying>> ] bi resize ] [ class>> ] 2bi
    <direct-struct-array> ; inline

: <struct-array> ( length struct-class -- struct-array )
    [ heap-size * <byte-array> ] 2keep <direct-struct-array> ; inline

ERROR: bad-byte-array-length byte-array ;

: byte-array>struct-array ( byte-array c-type -- struct-array )
    [
        heap-size
        [ dup length ] dip /mod 0 =
        [ drop bad-byte-array-length ] unless
    ] keep <direct-struct-array> ; inline

: struct-array-on ( struct length -- struct-array )
    [ [ >c-ptr ] [ class ] bi ] dip swap <direct-struct-array> ; inline    

: malloc-struct-array ( length c-type -- struct-array )
    [ heap-size calloc ] 2keep <direct-struct-array> ; inline

INSTANCE: struct-array sequence

M: struct-type <c-array> ( len c-type -- array )
    dup c-array-constructor
    [ execute( len -- array ) ]
    [ <struct-array> ] ?if ; inline

M: struct-type <c-direct-array> ( alien len c-type -- array )
    dup c-direct-array-constructor
    [ execute( alien len -- array ) ]
    [ <direct-struct-array> ] ?if ; inline

: >struct-array ( sequence class -- struct-array )
    [ dup length ] dip <struct-array>
    [ 0 swap copy ] keep ; inline

SYNTAX: struct-array{
    \ } scan-word [ >struct-array ] curry parse-literal ;

SYNTAX: struct-array@
    scan-word [ scan-object scan-object ] dip <direct-struct-array> parsed ;

USING: vocabs vocabs.loader ;

"prettyprint" vocab [ "struct-arrays.prettyprint" require ] when
