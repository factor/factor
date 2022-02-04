! Copyright (C) 2021 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
combinators system ;
IN: compression.zstd.ffi

LIBRARY-UNIX: zstd cdecl "libzstd.so"
LIBRARY-MACOSX: zstd cdecl "libzstd.dylib"
LIBRARY-WINDOWS: zstd cdecl "libzstd.dll"

LIBRARY: zstd

FUNCTION: size_t ZSTD_compress ( void* dst, size_t dstCapacity,
                                 void* src, size_t srcSize,
                                 int compressionLevel )

FUNCTION: size_t ZSTD_decompress ( void* dst, size_t dstCapacity,
                               void* src, size_t compressedSize )

FUNCTION: ulonglong ZSTD_getFrameContentSize ( void *src, size_t srcSize )

FUNCTION: uint ZSTD_isError ( size_t code )

FUNCTION: c-string ZSTD_getErrorName ( size_t code )

! There are many more api calls but this is enough for basic payloads