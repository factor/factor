! Copyright (C) 2010 Dmitry Shubin.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.libraries.finder
alien.syntax classes.struct combinators kernel system ;
IN: gdbm.ffi

<< "libgdbm"
{ "gdbm" "gdbm3" "libgdbm-3" } find-library-from-list
cdecl add-library >>

LIBRARY: libgdbm

C-GLOBAL: c-string gdbm_version

CONSTANT: GDBM_SYNC   0x20
CONSTANT: GDBM_NOLOCK 0x40

CONSTANT: GDBM_INSERT  0
CONSTANT: GDBM_REPLACE 1

CONSTANT: GDBM_CACHESIZE    1
CONSTANT: GDBM_SYNCMODE     3
CONSTANT: GDBM_CENTFREE     4
CONSTANT: GDBM_COALESCEBLKS 5

STRUCT: datum { dptr char* } { dsize int } ;

C-TYPE: _GDBM_FILE
TYPEDEF: _GDBM_FILE* GDBM_FILE

CALLBACK: void fatal_func_cb ( )
FUNCTION: GDBM_FILE gdbm_open ( c-string name, int block_size, int read_write, int mode, fatal_func_cb fatal_func )
FUNCTION-ALIAS: gdbm-close void gdbm_close ( GDBM_FILE dbf )
FUNCTION: int gdbm_store ( GDBM_FILE dbf, datum key, datum content, int flag )
FUNCTION: datum gdbm_fetch ( GDBM_FILE dbf, datum key )
FUNCTION: int gdbm_delete ( GDBM_FILE dbf, datum key )
FUNCTION: datum gdbm_firstkey ( GDBM_FILE dbf )
FUNCTION: datum gdbm_nextkey ( GDBM_FILE dbf, datum key )
FUNCTION: int gdbm_reorganize ( GDBM_FILE dbf )
FUNCTION: void gdbm_sync ( GDBM_FILE dbf )
FUNCTION: int gdbm_exists ( GDBM_FILE dbf, datum key )
FUNCTION: int gdbm_setopt ( GDBM_FILE dbf, int option, int* value, int size )
FUNCTION: int gdbm_fdesc ( GDBM_FILE dbf )

! Removed in gdbm 1.14
C-GLOBAL: int gdbm_errno
! Added in gdbm 1.14
FUNCTION: int *gdbm_errno_location ( )

FUNCTION: c-string gdbm_strerror ( int errno )
