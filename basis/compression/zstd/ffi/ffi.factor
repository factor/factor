! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax classes.struct combinators system ;

IN: compression.zstd.ffi

<< "zstd" {
    { [ os windows? ] [ "zstd-1.dll" ] }
    { [ os macos? ] [ "libzstd.dylib" ] }
    { [ os unix? ] [ "libzstd.so" ] }
} cond cdecl add-library >>

LIBRARY: zstd

FUNCTION: uint ZSTD_versionNumber ( )

FUNCTION: c-string ZSTD_versionString ( )

! Simple API

FUNCTION: size_t ZSTD_compress ( void* dst, size_t dstCapacity,
                                 void* src, size_t srcSize,
                                 int compressionLevel )

FUNCTION: size_t ZSTD_decompress ( void* dst, size_t dstCapacity,
                               void* src, size_t compressedSize )

FUNCTION: ulonglong ZSTD_getFrameContentSize ( void *src, size_t srcSize )

FUNCTION: size_t ZSTD_findFrameContentSize ( void *src, size_t srcSize )

! Helper functions

FUNCTION: size_t ZSTD_compressBounds ( size_t srcSize )

FUNCTION: uint ZSTD_isError ( size_t code )

FUNCTION: c-string ZSTD_getErrorName ( size_t code )

FUNCTION: int ZSTD_minCLevel ( )

FUNCTION: int ZSTD_maxCLevel ( )

FUNCTION: int ZSTD_defaultCLevel ( )

! Explicit context

TYPEDEF: void ZSTD_CCtx
FUNCTION: ZSTD_CCtx* ZSTD_createCCtx ( )
FUNCTION: size_t ZSTD_freeCCtx ( ZSTD_CCtx* cctx )
DESTRUCTOR: ZSTD_freeCCtx

FUNCTION: size_t ZSTD_compressCCtx ( ZSTD_CCtx* cctx, void* dst, size_t dstCapacity, void* src, size_t srcSize, int compressionLevel )

TYPEDEF: void ZSTD_DCtx
FUNCTION: ZSTD_DCtx* ZSTD_createDCtx ( )
FUNCTION: size_t ZSTD_freeDCtx ( ZSTD_DCtx* dctx )
DESTRUCTOR: ZSTD_freeDCtx

FUNCTION: size_t ZSTD_decompressCCtx ( ZSTD_DCtx* dctx, void* dst, size_t dstCapacity, void* src, size_t srcSize )
FUNCTION: size_t ZSTD_decompressStream_simpleArgs ( ZSTD_DCtx* dctx, void* dst, size_t dstCapacity, size_t* dstPos, void* src, size_t srcSize, size_t* srcPos )

! Streaming

STRUCT: ZSTD_inBuffer
    { src void* }
    { size size_t }
    { pos size_t }
;

STRUCT: ZSTD_outBuffer
    { dst void* }
    { size size_t }
    { pos size_t }
;

! Streaming compression

TYPEDEF: void ZSTD_CStream

FUNCTION: ZSTD_CStream* ZSTD_createCStream ( )
FUNCTION: size_t ZSTD_freeCStream ( ZSTD_CStream* zcs )

ENUM: ZSTD_EndDirective
    ZSTD_e_continue
    ZSTD_e_flush
    ZSTD_e_end ;

FUNCTION: size_t ZSTD_compressStream2 ( ZSTD_CCtx* cctx, ZSTD_outBuffer* output, ZSTD_inBuffer* input, ZSTD_EndDirective endOp )
FUNCTION: size_t ZSTD_CStreamInSize ( )
FUNCTION: size_t ZSTD_CStreamOutSize ( )

FUNCTION: size_t ZSTD_initCStream ( ZSTD_CStream* zcs, int compressionLevel )
FUNCTION: size_t ZSTD_compressStream ( ZSTD_CStream* zcs, ZSTD_outBuffer* output, ZSTD_inBuffer* input )
FUNCTION: size_t ZSTD_flushStream ( ZSTD_CStream* zcs, ZSTD_outBuffer* output )
FUNCTION: size_t ZSTD_endStream ( ZSTD_CStream* zcs, ZSTD_outBuffer* output )

! Streaming decompression

TYPEDEF: void ZSTD_DStream

FUNCTION: ZSTD_DStream* ZSTD_createDStream ( )
FUNCTION: size_t ZSTD_freeDStream ( ZSTD_DStream* zds )
FUNCTION: size_t ZSTD_initDStream ( ZSTD_DStream* zds )
FUNCTION: size_t ZSTD_decompressStream ( ZSTD_DStream* zds, ZSTD_outBuffer* output, ZSTD_inBuffer* input )
FUNCTION: size_t ZSTD_DStreamInSize ( )
FUNCTION: size_t ZSTD_DStreamOutSize ( )

DESTRUCTOR: ZSTD_freeDStream
