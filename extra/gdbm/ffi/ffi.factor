! Copyright (C) 2010 Dmitry Shubin.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax classes.struct
combinators system ;
IN: gdbm.ffi

<< "libgdbm" os {
    { [ unix?   ] [ "libgdbm.so"    ] }
    { [ winnt?  ] [ "gdbm.dll"      ] }
    { [ macosx? ] [ "libgdbm.dylib" ] }
} cond cdecl add-library >>

LIBRARY: libgdbm

C-GLOBAL: c-string gdbm_version

CONSTANT: GDBM_READER  0
CONSTANT: GDBM_WRITER  1
CONSTANT: GDBM_WRCREAT 2
CONSTANT: GDBM_NEWDB   3
CONSTANT: GDBM_FAST   HEX: 10
CONSTANT: GDBM_SYNC   HEX: 20
CONSTANT: GDBM_NOLOCK HEX: 40

CONSTANT: GDBM_INSERT  0
CONSTANT: GDBM_REPLACE 1

CONSTANT: GDBM_CACHESIZE    1
CONSTANT: GDBM_FASTMODE     2
CONSTANT: GDBM_SYNCMODE     3
CONSTANT: GDBM_CENTFREE     4
CONSTANT: GDBM_COALESCEBLKS 5

STRUCT: datum { dptr char* } { dsize int } ;

C-TYPE: _GDBM_FILE
TYPEDEF: _GDBM_FILE* GDBM_FILE

CALLBACK: void fatal_func_cb ;
FUNCTION: GDBM_FILE gdbm_open ( c-string name, int block_size, int read_write, int mode, fatal_func_cb fatal_func ) ;
FUNCTION: void gdbm_close ( GDBM_FILE dbf ) ;
FUNCTION: int gdbm_store ( GDBM_FILE dbf, datum key, datum content, int flag ) ;
FUNCTION: datum gdbm_fetch ( GDBM_FILE dbf, datum key ) ;
FUNCTION: int gdbm_delete ( GDBM_FILE dbf, datum key ) ;
FUNCTION: datum gdbm_firstkey ( GDBM_FILE dbf ) ;
FUNCTION: datum gdbm_nextkey ( GDBM_FILE dbf, datum key ) ;
FUNCTION: int gdbm_reorganize ( GDBM_FILE dbf ) ;
FUNCTION: void gdbm_sync ( GDBM_FILE dbf ) ;
FUNCTION: int gdbm_exists ( GDBM_FILE dbf, datum key ) ;
FUNCTION: int gdbm_setopt ( GDBM_FILE dbf, int option, int* value, int size ) ;
FUNCTION: int gdbm_fdesc ( GDBM_FILE dbf ) ;

CONSTANT: GDBM_NO_ERROR               0
CONSTANT: GDBM_MALLOC_ERROR           1
CONSTANT: GDBM_BLOCK_SIZE_ERROR       2
CONSTANT: GDBM_FILE_OPEN_ERROR        3
CONSTANT: GDBM_FILE_WRITE_ERROR       4
CONSTANT: GDBM_FILE_SEEK_ERROR        5
CONSTANT: GDBM_FILE_READ_ERROR        6
CONSTANT: GDBM_BAD_MAGIC_NUMBER       7
CONSTANT: GDBM_EMPTY_DATABASE         8
CONSTANT: GDBM_CANT_BE_READER         9
CONSTANT: GDBM_CANT_BE_WRITER         10
CONSTANT: GDBM_READER_CANT_DELETE     11
CONSTANT: GDBM_READER_CANT_STORE      12
CONSTANT: GDBM_READER_CANT_REORGANIZE 13
CONSTANT: GDBM_UNKNOWN_UPDATE         14
CONSTANT: GDBM_ITEM_NOT_FOUND         15
CONSTANT: GDBM_REORGANIZE_FAILED      16
CONSTANT: GDBM_CANNOT_REPLACE         17
CONSTANT: GDBM_ILLEGAL_DATA           18
CONSTANT: GDBM_OPT_ALREADY_SET        19
CONSTANT: GDBM_OPT_ILLEGAL            20

TYPEDEF: int gdbm_error
C-GLOBAL: gdbm_error gdbm_errno
