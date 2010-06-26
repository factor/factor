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
CONSTANT: GDBM_SYNC   HEX: 20
CONSTANT: GDBM_NOLOCK HEX: 40

CONSTANT: GDBM_INSERT  0
CONSTANT: GDBM_REPLACE 1

CONSTANT: GDBM_CACHESIZE    1
CONSTANT: GDBM_SYNCMODE     3
CONSTANT: GDBM_CENTFREE     4
CONSTANT: GDBM_COALESCEBLKS 5

STRUCT: datum { dptr char* } { dsize int } ;

C-TYPE: _GDBM_FILE
TYPEDEF: _GDBM_FILE* GDBM_FILE

CALLBACK: void fatal_func_cb ;
FUNCTION: GDBM_FILE gdbm_open ( c-string name, int block_size, int read_write, int mode, fatal_func_cb fatal_func ) ;
FUNCTION-ALIAS: gdbm-close void gdbm_close ( GDBM_FILE dbf ) ;
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

ENUM: gdbm-error
    gdbm-no-error
    gdbm-malloc-error
    gdbm-block-size-error
    gdbm-file-open-error
    gdbm-file-write-error
    gdbm-file-seek-error
    gdbm-file-read-error
    gdbm-bad-magic-number
    gdbm-empty-database
    gdbm-cant-be-reader
    gdbm-cant-be-writer
    gdbm-reader-cant-delete
    gdbm-reader-cant-store
    gdbm-reader-cant-reorganize
    gdbm-unknown-update
    gdbm-item-not-found
    gdbm-reorganize-failed
    gdbm-cannot-replace
    gdbm-illegal-data
    gdbm-option-already-set
    gdbm-illegal-option ;

C-GLOBAL: gdbm-error gdbm_errno

FUNCTION: c-string gdbm_strerror ( gdbm-error errno ) ;
