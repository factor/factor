! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax combinators literals system ;

IN: magic.ffi

C-LIBRARY: magic cdecl {
    { macos "libmagic.dylib" }
    { unix "libmagic.so" }
}

LIBRARY: magic

CONSTANT: MAGIC_NONE 0x000000
CONSTANT: MAGIC_DEBUG 0x000001
CONSTANT: MAGIC_SYMLINK 0x000002
CONSTANT: MAGIC_COMPRESS 0x000004
CONSTANT: MAGIC_DEVICES 0x000008
CONSTANT: MAGIC_MIME_TYPE 0x000010
CONSTANT: MAGIC_CONTINUE 0x000020
CONSTANT: MAGIC_CHECK 0x000040
CONSTANT: MAGIC_PRESERVE_ATIME 0x000080
CONSTANT: MAGIC_RAW 0x000100
CONSTANT: MAGIC_ERROR 0x000200
CONSTANT: MAGIC_MIME_ENCODING 0x000400
CONSTANT: MAGIC_MIME flags{ MAGIC_MIME_TYPE MAGIC_MIME_ENCODING }
CONSTANT: MAGIC_NO_CHECK_COMPRESS 0x001000
CONSTANT: MAGIC_NO_CHECK_TAR 0x002000
CONSTANT: MAGIC_NO_CHECK_SOFT 0x004000
CONSTANT: MAGIC_NO_CHECK_APPTYPE 0x008000
CONSTANT: MAGIC_NO_CHECK_ELF 0x010000
CONSTANT: MAGIC_NO_CHECK_ASCII 0x020000
CONSTANT: MAGIC_NO_CHECK_TROFF 0x040000
CONSTANT: MAGIC_NO_CHECK_FORTRAN 0x080000
CONSTANT: MAGIC_NO_CHECK_TOKENS 0x100000

TYPEDEF: void* magic_t
FUNCTION: magic_t magic_open ( int flags )
FUNCTION: void magic_close ( magic_t magic )

FUNCTION: c-string magic_file ( magic_t magic, c-string path )
FUNCTION: c-string magic_descriptor ( magic_t magic, int fd )
FUNCTION: c-string magic_buffer ( magic_t magic, void* buffer, size_t size )

FUNCTION: c-string magic_error ( magic_t magic )
FUNCTION: int magic_setflags ( magic_t magic, int flags )

FUNCTION: int magic_load ( magic_t magic, c-string path )
FUNCTION: int magic_compile ( magic_t magic, c-string path )
FUNCTION: int magic_check ( magic_t magic, c-string path )
FUNCTION: int magic_errno ( magic_t magic )

DESTRUCTOR: magic_close
