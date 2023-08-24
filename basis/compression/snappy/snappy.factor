! Copyright (C) 2014 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data byte-arrays compression.snappy.ffi
kernel sequences ;
IN: compression.snappy

ERROR: snappy-error error ;

<PRIVATE

: check-snappy ( ret -- )
    dup SNAPPY_OK = [ drop ] [ snappy-error ] if ;

: n>outs ( n -- byte-array size_t* )
    [ <byte-array> ] [ size_t <ref> ] bi ;

PRIVATE>

: snappy-compress ( byte-array -- compressed )
    dup length
    dup snappy_max_compressed_length
    n>outs
    [ snappy_compress check-snappy ] 2keep size_t deref head ;

: snappy-uncompress ( compressed -- byte-array )
    dup length
    over
    dup length 0 size_t <ref>
    [ snappy_uncompressed_length check-snappy ] keep
    size_t deref
    n>outs
    [ snappy_uncompress check-snappy ] keepd >byte-array ;
