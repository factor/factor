! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays compression.zstd compression.zstd.ffi destructors
kernel locals sequences tools.test ;
IN: compression.zstd.tests

! Exercise the DLL entry points directly, including the context API.
{ B{ 1 2 3 4 } } [
    [ [let
        B{ 1 2 3 4 } :> source
        source length ZSTD_compressBound <byte-array> :> compressed
        ZSTD_createCCtx &ZSTD_freeCCtx :> cctx
        cctx compressed compressed length source source length 1
        ZSTD_compressCCtx check-zstd-error :> size
        compressed size head :> frame
        frame frame length ZSTD_findFrameCompressedSize check-zstd-error
        frame length assert=
        ZSTD_createDCtx &ZSTD_freeDCtx :> dctx
        source length <byte-array> :> output
        dctx output output length frame frame length
        ZSTD_decompressDCtx check-zstd-error source length assert=
        output
    ] ] with-destructors
] unit-test

{ B{ 1 2 3 4 } } [
    B{ 1 2 3 4 } 5 zstd-compress-level zstd-uncompress
] unit-test

{ B{ 1 2 3 4 } } [
    B{ 1 2 3 4 } zstd-compress zstd-uncompress
] unit-test

! bad compressed buffer, should fail
[
    B{ 1 2 3 4 } zstd-uncompress-size
] [ zstd-error? ] must-fail-with

