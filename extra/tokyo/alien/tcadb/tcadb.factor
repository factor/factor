! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
combinators kernel tokyo.alien.tchdb tokyo.alien.tcutil
tokyo.alien.tcbdb tokyo.alien.tcfdb tokyo.alien.tctdb ;
IN: tokyo.alien.tcrdb

LIBRARY: tokyocabinet

TYPEDEF: void* TCADB

C-ENUM:
    ADBOVOID
    ADBOMDB
    ADBONDB
    ADBOHDB
    ADBOBDB
    ADBOFDB
    ADBOTDB
    ADBOSKEL ;

FUNCTION: TCADB* tcadbnew ( ) ;
FUNCTION: void tcadbdel ( TCADB* adb ) ;
FUNCTION: bool tcadbopen ( TCADB* adb, char* name ) ;
FUNCTION: bool tcadbclose ( TCADB* adb ) ;
FUNCTION: bool tcadbput ( TCADB* adb, void* kbuf, int ksiz, void* vbuf, int vsiz ) ;
FUNCTION: bool tcadbput2 ( TCADB* adb, char* kstr, char* vstr ) ;
FUNCTION: bool tcadbputkeep ( TCADB* adb, void* kbuf, int ksiz, void* vbuf, int vsiz ) ;
FUNCTION: bool tcadbputkeep2 ( TCADB* adb, char* kstr, char* vstr ) ;
FUNCTION: bool tcadbputcat ( TCADB* adb, void* kbuf, int ksiz, void* vbuf, int vsiz ) ;
FUNCTION: bool tcadbputcat2 ( TCADB* adb, char* kstr, char* vstr ) ;
FUNCTION: bool tcadbout ( TCADB* adb, void* kbuf, int ksiz ) ;
FUNCTION: bool tcadbout2 ( TCADB* adb, char* kstr ) ;
FUNCTION: void* tcadbget ( TCADB* adb, void* kbuf, int ksiz, int* sp ) ;
FUNCTION: char* tcadbget2 ( TCADB* adb, char* kstr ) ;
FUNCTION: int tcadbvsiz ( TCADB* adb, void* kbuf, int ksiz ) ;
FUNCTION: int tcadbvsiz2 ( TCADB* adb, char* kstr ) ;
FUNCTION: bool tcadbiterinit ( TCADB* adb ) ;
FUNCTION: void* tcadbiternext ( TCADB* adb, int* sp ) ;
FUNCTION: char* tcadbiternext2 ( TCADB* adb ) ;
FUNCTION: TCLIST* tcadbfwmkeys ( TCADB* adb, void* pbuf, int psiz, int max ) ;
FUNCTION: TCLIST* tcadbfwmkeys2 ( TCADB* adb, char* pstr, int max ) ;
FUNCTION: int tcadbaddint ( TCADB* adb, void* kbuf, int ksiz, int num ) ;
FUNCTION: double tcadbadddouble ( TCADB* adb, void* kbuf, int ksiz, double num ) ;
FUNCTION: bool tcadbsync ( TCADB* adb ) ;
FUNCTION: bool tcadboptimize ( TCADB* adb, char* params ) ;
FUNCTION: bool tcadbvanish ( TCADB* adb ) ;
FUNCTION: bool tcadbcopy ( TCADB* adb, char* path ) ;
FUNCTION: bool tcadbtranbegin ( TCADB* adb ) ;
FUNCTION: bool tcadbtrancommit ( TCADB* adb ) ;
FUNCTION: bool tcadbtranabort ( TCADB* adb ) ;
FUNCTION: char* tcadbpath ( TCADB* adb ) ;
FUNCTION: ulonglong tcadbrnum ( TCADB* adb ) ;
FUNCTION: ulonglong tcadbsize ( TCADB* adb ) ;
FUNCTION: TCLIST* tcadbmisc ( TCADB* adb, char* name, TCLIST* args ) ;

! -----

TYPEDEF: void* ADBSKEL

TYPEDEF: void* ADBMAPPROC

FUNCTION: bool tcadbsetskel ( TCADB* adb, ADBSKEL* skel ) ;
FUNCTION: int tcadbomode ( TCADB* adb ) ;
FUNCTION: void* tcadbreveal ( TCADB* adb ) ;
FUNCTION: bool tcadbputproc ( TCADB* adb, void* kbuf, int ksiz, void* vbuf, int vsiz, TCPDPROC proc, void* op ) ;
FUNCTION: bool tcadbforeach ( TCADB* adb, TCITER iter, void* op ) ;
FUNCTION: bool tcadbmapbdb ( TCADB* adb, TCLIST* keys, TCBDB* bdb, ADBMAPPROC proc, void* op, longlong csiz ) ;
FUNCTION: bool tcadbmapbdbemit ( void* map, char* kbuf, int ksiz, char* vbuf, int vsiz ) ;
