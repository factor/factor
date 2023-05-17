! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.c-types alien.data byte-arrays
byte-vectors compression.zstd.ffi destructors generalizations io
kernel make math math.bitwise sequences ;

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

:: zstd-uncompress-stream-frame ( -- byte-array )
    ZSTD_DStreamInSize :> in-size
    ZSTD_DStreamOutSize :> out-size

    in-size <byte-vector> :> in
    out-size <byte-array> :> out

    out-size <byte-vector> :> accum

    [
        ZSTD_createDCtx &ZSTD_freeDCtx :> dctx
        0 size_t <ref> :> in-pos
        0 size_t <ref> :> out-pos

        in [ underlying>> read-into drop length ] [ set-length ] bi

        [
            dctx
            out out-size out-pos
            in in length in-pos
            ZSTD_decompressStream_simpleArgs check-zstd-error

            out out-pos size_t deref head-slice accum push-all

            in-pos size_t deref in-size = [
                in [ underlying>> read-into drop length ] [ set-length ] bi
                0 in-pos 0 size_t set-alien-value
            ] when

            zero? [
                ! 0 is only seen when a frame is fully
                ! decoded *and* fully flushed. But there may
                ! be extra input data
                f
            ] [
                ! We're not at the end of the frame *or*
                ! we're not fully flushed.
                in-pos size_t deref in-size =
                out-pos size_t deref out-size < and not

                0 out-pos 0 size_t set-alien-value
            ] if
        ] loop accum B{ } like
    ] with-destructors ;
