! Copyright (C) 2021 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types byte-arrays compression.zstd.ffi
generalizations kernel math math.bitwise sequences ;
IN: compression.zstd

ERROR: zstd-error n str ;

: check-zstd-error ( n -- n )
    dup ZSTD_isError 0 > [
        size_t heap-size 8 * >signed
        dup ZSTD_getErrorName
        zstd-error
    ] when ;

: zstd-uncompress-size ( byte-array -- n )
    dup byte-length ZSTD_getFrameContentSize check-zstd-error ;

<PRIVATE

: zstd-setup-compress-buffers ( byte-array -- dst dstlen src srclen )
    [ length 64 + [ <byte-array> ] keep ]
    [ dup length ] bi ; inline

: zstd-setup-uncompress-buffers ( byte-array -- dst dstlen src srclen )
    [ zstd-uncompress-size <byte-array> dup byte-length ]
    [ dup length ] bi ; inline

PRIVATE>

: zstd-compress-level ( byte-array level -- compressed )
    [ zstd-setup-compress-buffers ] dip
    [ ZSTD_compress check-zstd-error ] 5 nkeep 4drop swap head ;

: zstd-compress ( byte-array -- compressed )
    1 zstd-compress-level ;

: zstd-uncompress ( compressed -- byte-array )
    zstd-setup-uncompress-buffers
    [ ZSTD_decompress check-zstd-error ] 4keep 3drop swap head ;
