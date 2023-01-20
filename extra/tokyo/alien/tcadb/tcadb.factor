! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax tokyo.alien.tcbdb
tokyo.alien.tcutil ;
IN: tokyo.alien.tcadb

LIBRARY: tokyocabinet

TYPEDEF: void* TCADB

CONSTANT: ADBOVOID 0
CONSTANT: ADBOMDB 1
CONSTANT: ADBONDB 2
CONSTANT: ADBOHDB 3
CONSTANT: ADBOBDB 4
CONSTANT: ADBOFDB 5
CONSTANT: ADBOTDB 6
CONSTANT: ADBOSKEL 7

FUNCTION: TCADB* tcadbnew ( )
FUNCTION: void tcadbdel ( TCADB* adb )
FUNCTION: bool tcadbopen ( TCADB* adb, c-string name )
FUNCTION: bool tcadbclose ( TCADB* adb )
FUNCTION: bool tcadbput ( TCADB* adb, void* kbuf, int ksiz, void* vbuf, int vsiz )
FUNCTION: bool tcadbput2 ( TCADB* adb, c-string kstr, c-string vstr )
FUNCTION: bool tcadbputkeep ( TCADB* adb, void* kbuf, int ksiz, void* vbuf, int vsiz )
FUNCTION: bool tcadbputkeep2 ( TCADB* adb, c-string kstr, c-string vstr )
FUNCTION: bool tcadbputcat ( TCADB* adb, void* kbuf, int ksiz, void* vbuf, int vsiz )
FUNCTION: bool tcadbputcat2 ( TCADB* adb, c-string kstr, c-string vstr )
FUNCTION: bool tcadbout ( TCADB* adb, void* kbuf, int ksiz )
FUNCTION: bool tcadbout2 ( TCADB* adb, c-string kstr )
FUNCTION: void* tcadbget ( TCADB* adb, void* kbuf, int ksiz, int* sp )
FUNCTION: c-string tcadbget2 ( TCADB* adb, c-string kstr )
FUNCTION: int tcadbvsiz ( TCADB* adb, void* kbuf, int ksiz )
FUNCTION: int tcadbvsiz2 ( TCADB* adb, c-string kstr )
FUNCTION: bool tcadbiterinit ( TCADB* adb )
FUNCTION: void* tcadbiternext ( TCADB* adb, int* sp )
FUNCTION: c-string tcadbiternext2 ( TCADB* adb )
FUNCTION: TCLIST* tcadbfwmkeys ( TCADB* adb, void* pbuf, int psiz, int max )
FUNCTION: TCLIST* tcadbfwmkeys2 ( TCADB* adb, c-string pstr, int max )
FUNCTION: int tcadbaddint ( TCADB* adb, void* kbuf, int ksiz, int num )
FUNCTION: double tcadbadddouble ( TCADB* adb, void* kbuf, int ksiz, double num )
FUNCTION: bool tcadbsync ( TCADB* adb )
FUNCTION: bool tcadboptimize ( TCADB* adb, c-string params )
FUNCTION: bool tcadbvanish ( TCADB* adb )
FUNCTION: bool tcadbcopy ( TCADB* adb, c-string path )
FUNCTION: bool tcadbtranbegin ( TCADB* adb )
FUNCTION: bool tcadbtrancommit ( TCADB* adb )
FUNCTION: bool tcadbtranabort ( TCADB* adb )
FUNCTION: c-string tcadbpath ( TCADB* adb )
FUNCTION: ulonglong tcadbrnum ( TCADB* adb )
FUNCTION: ulonglong tcadbsize ( TCADB* adb )
FUNCTION: TCLIST* tcadbmisc ( TCADB* adb, c-string name, TCLIST* args )

! -----

TYPEDEF: void* ADBSKEL

TYPEDEF: void* ADBMAPPROC

FUNCTION: bool tcadbsetskel ( TCADB* adb, ADBSKEL* skel )
FUNCTION: int tcadbomode ( TCADB* adb )
FUNCTION: void* tcadbreveal ( TCADB* adb )
FUNCTION: bool tcadbputproc ( TCADB* adb, void* kbuf, int ksiz, void* vbuf, int vsiz, TCPDPROC proc, void* op )
FUNCTION: bool tcadbforeach ( TCADB* adb, TCITER iter, void* op )
FUNCTION: bool tcadbmapbdb ( TCADB* adb, TCLIST* keys, TCBDB* bdb, ADBMAPPROC proc, void* op, longlong csiz )
FUNCTION: bool tcadbmapbdbemit ( void* map, c-string kbuf, int ksiz, c-string vbuf, int vsiz )
