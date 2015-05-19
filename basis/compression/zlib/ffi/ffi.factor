! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
classes.struct combinators system ;
IN: compression.zlib.ffi

<< "zlib" {
    { [ os windows? ] [ "zlib1.dll" ] }
    { [ os macosx? ] [ "libz.dylib" ] }
    { [ os unix? ] [ "libz.so" ] }
} cond cdecl add-library >>

LIBRARY: zlib

CONSTANT: Z_OK 0
CONSTANT: Z_STREAM_END 1
CONSTANT: Z_NEED_DICT 2
CONSTANT: Z_ERRNO -1
CONSTANT: Z_STREAM_ERROR -2
CONSTANT: Z_DATA_ERROR -3
CONSTANT: Z_MEM_ERROR -4
CONSTANT: Z_BUF_ERROR -5
CONSTANT: Z_VERSION_ERROR -6

TYPEDEF: void Bytef
TYPEDEF: ulong uLongf
TYPEDEF: ulong uLong

FUNCTION: int compress ( Bytef* dest, uLongf* destLen, Bytef* source, uLong sourceLen ) ;
FUNCTION: int compress2 ( Bytef* dest, uLongf* destLen, Bytef* source, uLong sourceLen, int level ) ;
FUNCTION: int uncompress ( Bytef* dest, uLongf* destLen, Bytef* source, uLong sourceLen ) ;

STRUCT: z_stream
    { next_in uchar* }
    { avail_in uint }
    { total_in ulong }

    { next_out uchar* }
    { avail_out uint }
    { total_out ulong }

    { msg char* }
    { state void* }

    { zalloc void* }
    { zfree void* }
    { opaque void* }

    { data_type int }
    { adler ulong }
    { reserved ulong } ;

TYPEDEF: z_stream* z_streamp

STRUCT: gz_header
    { text int }
    { time ulong }
    { xflags int }
    { os int }
    { extra uchar* }
    { extra_len uint }
    { extra_max uint }
    { name uchar* }
    { name_max uint }
    { comment uchar* }
    { comm_max uint }
    { hcrc int }
    { done int } ;

TYPEDEF: gz_header* gz_headerp

CONSTANT: ZLIB_VERSION "1.2.5"

FUNCTION: int inflateInit_ ( z_streamp strm, c-string version, int stream_size ) ;
FUNCTION: int inflateInit2_ ( z_streamp strm, int windowBits, c-string version, int stream_size ) ;
FUNCTION: int inflateReset ( z_streamp strm ) ;
FUNCTION: int inflateEnd ( z_streamp strm ) ;

CONSTANT: Z_NO_FLUSH      0
CONSTANT: Z_PARTIAL_FLUSH 1
CONSTANT: Z_SYNC_FLUSH    2
CONSTANT: Z_FULL_FLUSH    3
CONSTANT: Z_FINISH        4
CONSTANT: Z_BLOCK         5
CONSTANT: Z_TREES         6

FUNCTION: int inflate ( z_streamp strm, int flush ) ;
FUNCTION: int inflateGetHeader ( z_streamp strm, gz_headerp head ) ;
