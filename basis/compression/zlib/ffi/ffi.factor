! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax combinators system alien.libraries ;
IN: compression.zlib.ffi

<< "zlib" {
    { [ os winnt? ] [ "zlib1.dll" ] }
    { [ os macosx? ] [ "libz.dylib" ] }
    { [ os unix? ] [ "libz.so" ] }
} cond "cdecl" add-library >>

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
