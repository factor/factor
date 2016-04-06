! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.syntax
byte-arrays byte-vectors classes.struct combinators
compression.zlib.ffi continuations destructors fry kernel libc
math math.functions math.ranges sequences system ;
IN: compression.zlib

ERROR: zlib-failed n string ;

: zlib-error-message ( n -- * )
    dup compression.zlib.ffi:Z_ERRNO = [
        drop errno "native libc error"
    ] [
        dup
        neg ! zlib error codes are negative
        {
            "no error" "libc_error"
            "stream error" "data error"
            "memory error" "buffer error" "zlib version error"
        } ?nth
    ] if zlib-failed ;

: zlib-error ( n -- )
    dup {
        { compression.zlib.ffi:Z_OK [ drop ] }
        { compression.zlib.ffi:Z_STREAM_END [ drop ] }
        [ dup zlib-error-message zlib-failed ]
    } case ;

: compressed-size ( byte-array -- n )
    length 1001/1000 * ceiling 12 + ;

: compress ( byte-array -- byte-array' )
    [
        compressed-size
        [ <byte-vector> dup underlying>> ] keep ulong <ref>
    ] keep [
        dup length compression.zlib.ffi:compress zlib-error
    ] 2keep drop ulong deref >>length B{ } like ;

: (uncompress) ( length byte-array -- byte-array )
    [
        [ drop [ malloc &free ] [ ulong <ref> ] bi ]
        [ nip dup length ] 2bi
        [ compression.zlib.ffi:uncompress zlib-error ] 4keep
        2drop ulong deref memory>byte-array
    ] with-destructors ;

: uncompress ( byte-array -- byte-array' )
    [ length 5 [0,b) [ 2^ * ] with map ] keep
    '[ _ (uncompress) ] attempt-all ;


: zlib-inflate-init ( -- z_stream_s )
    z_stream <struct> ZLIB_VERSION over byte-length [
        inflateInit_ zlib-error
    ] 3keep 2drop  ;

! window can be 0, 15, 32, 47 (others?)
: zlib-inflate-init2 ( window -- z_stream_s )
    [ z_stream <struct> ] dip ZLIB_VERSION pick byte-length [
        inflateInit2_ zlib-error
    ] 4keep 3drop  ;

: zlib-inflate-end ( z_stream -- )
    inflateEnd zlib-error ;

: zlib-inflate-reset ( z_stream -- )
    inflateReset zlib-error ;

: zlib-inflate ( z_stream flush -- )
    inflate zlib-error ;

: zlib-inflate-get-header ( z_stream -- gz_header )
    gz_header <struct> [
        inflateGetHeader zlib-error
    ] keep ;
