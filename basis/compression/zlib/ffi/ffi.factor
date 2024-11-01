! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
classes.struct combinators system ;
IN: compression.zlib.ffi

C-LIBRARY: zlib cdecl {
    { windows "zlib1.dll" }
    { macos "libz.dylib" }
    { unix "libz.so" }
}

LIBRARY: zlib

TYPEDEF: void Bytef
TYPEDEF: ulong uLongf
TYPEDEF: ulong uLong
TYPEDEF: uint uInt

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
CONSTANT: Z_NO_FLUSH      0
CONSTANT: Z_PARTIAL_FLUSH 1
CONSTANT: Z_SYNC_FLUSH    2
CONSTANT: Z_FULL_FLUSH    3
CONSTANT: Z_FINISH        4
CONSTANT: Z_BLOCK         5
CONSTANT: Z_TREES         6

CONSTANT: Z_OK             0
CONSTANT: Z_STREAM_END     1
CONSTANT: Z_NEED_DICT      2
CONSTANT: Z_ERRNO         -1
CONSTANT: Z_STREAM_ERROR  -2
CONSTANT: Z_DATA_ERROR    -3
CONSTANT: Z_MEM_ERROR     -4
CONSTANT: Z_BUF_ERROR     -5
CONSTANT: Z_VERSION_ERROR -6

CONSTANT: Z_NO_COMPRESSION       0
CONSTANT: Z_BEST_SPEED           1
CONSTANT: Z_BEST_COMPRESSION     9
CONSTANT: Z_DEFAULT_COMPRESSION -1

CONSTANT: Z_FILTERED         1
CONSTANT: Z_HUFFMAN_ONLY     2
CONSTANT: Z_RLE              3
CONSTANT: Z_FIXED            4
CONSTANT: Z_DEFAULT_STRATEGY 0

CONSTANT: Z_BINARY 0
CONSTANT: Z_TEXT 1
CONSTANT: Z_UNKNOWN 2

CONSTANT: Z_DEFLATED 8

CONSTANT: ZLIB_VERSION "1.2.5"

FUNCTION: c-string zlibVersion ( )

FUNCTION: int deflate ( z_streamp strm, int flush )
FUNCTION: int deflateEnd ( z_streamp strm )

FUNCTION: int inflate ( z_streamp strm, int flush )
FUNCTION: int inflateEnd ( z_streamp strm )

FUNCTION: int deflateSetDictionary ( z_streamp strm, Bytef* dictionary, uInt dictLength )
FUNCTION: int deflateCopy ( z_streamp dest, z_streamp source )
FUNCTION: int deflateReset ( z_streamp strm )
FUNCTION: int deflateParams ( z_streamp strm, int level, int strategy )
FUNCTION: int deflateTune ( z_streamp strm, int good_length, int max_lazy, int nice_length, int max_chain )
FUNCTION: uLong deflateBound ( z_streamp strm, uLong sourceLen )
FUNCTION: int deflatePrime ( z_streamp strm, int bits, int value )
FUNCTION: int deflateSetHeader ( z_streamp strm, gz_headerp head )

FUNCTION: int inflateSetDictionary ( z_streamp strm, Bytef* dictionary, uInt dictLength )
FUNCTION: int inflateSync ( z_streamp strm )
FUNCTION: int inflateCopy ( z_streamp dest, z_streamp source )
FUNCTION: int inflateReset ( z_streamp strm )
FUNCTION: int inflateReset2 ( z_streamp strm, int windowBits )
FUNCTION: int inflatePrime ( z_streamp strm, int bits, int value )
FUNCTION: long inflateMark ( z_streamp strm )
FUNCTION: int inflateGetHeader ( z_streamp strm, gz_headerp head )

FUNCTION: uLong zlibCompileFlags ( )

FUNCTION: int compress ( Bytef* dest, uLongf* destLen, Bytef* source, uLong sourceLen )
FUNCTION: int compress2 ( Bytef* dest, uLongf* destLen, Bytef* source, uLong sourceLen, int level )
FUNCTION: uLong compressBound ( uLong sourceLen )

FUNCTION: int uncompress ( Bytef* dest, uLongf* destLen, Bytef* source, uLong sourceLen )

TYPEDEF: void* gzFile

FUNCTION: gzFile gzdopen ( int fd, c-string mode )
FUNCTION: int gzbuffer ( gzFile file, uint size )
FUNCTION: int gzsetparams ( gzFile file, int level, int strategy )
FUNCTION: int gzread ( gzFile file, void* buf, uint len )
FUNCTION: int gzwrite ( gzFile file, void* buf, uint len )
FUNCTION: int gzputs ( gzFile file, char* s )
FUNCTION: c-string gzgets ( gzFile file, char* buf, int len )
FUNCTION: int gzputc ( gzFile file, int c )
FUNCTION: int gzgetc ( gzFile file )
FUNCTION: int gzungetc ( int c, gzFile file )
FUNCTION: int gzflush ( gzFile file, int flush )
FUNCTION: int gzrewind ( gzFile file )
FUNCTION: int gzeof ( gzFile file )
FUNCTION: int gzdirect ( gzFile file )
FUNCTION: int gzclose ( gzFile file )
FUNCTION: int gzclose_r ( gzFile file )
FUNCTION: int gzclose_w ( gzFile file )
FUNCTION: c-string gzerror ( gzFile file, int* errnum )
FUNCTION: void gzclearerr ( gzFile file )

FUNCTION: uLong adler32 ( uLong adler, Bytef* buf, uInt len )
FUNCTION: uLong crc32 ( uLong crc Bytef* buf, uInt len )

FUNCTION: int deflateInit_ ( z_streamp strm, int level, c-string version, int stream_size )
FUNCTION: int inflateInit_ ( z_streamp strm, c-string version, int stream_size )

FUNCTION: int deflateInit2_ ( z_streamp strm, int level, int method, int windowBits, int memLevel, int strategy, c-string version, int stream_size )
FUNCTION: int inflateInit2_ ( z_streamp strm, int windowBits, c-string version, int stream_size )
