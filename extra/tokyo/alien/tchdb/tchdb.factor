! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
combinators kernel tokyo.alien.tcutil ;
IN: tokyo.alien.tchdb

LIBRARY: tokyocabinet

TYPEDEF: void* TCXSTR*
TYPEDEF: void* TCHDB*

CONSTANT: HDBFOPEN  1
CONSTANT: HDBFFATAL 2

CONSTANT: HDBTLARGE   1
CONSTANT: HDBTDEFLATE 2
CONSTANT: HDBTBZIP    4
CONSTANT: HDBTTCBS    8
CONSTANT: HDBTEXCODEC 16

CONSTANT: HDBOREADER 1
CONSTANT: HDBOWRITER 2
CONSTANT: HDBOCREAT  4
CONSTANT: HDBOTRUNC  8
CONSTANT: HDBONOLCK  16
CONSTANT: HDBOLCKNB  32
CONSTANT: HDBOTSYNC  64

FUNCTION: char* tchdberrmsg ( int ecode ) ;
FUNCTION: TCHDB* tchdbnew ( ) ;
FUNCTION: void tchdbdel ( TCHDB* hdb ) ;
FUNCTION: int tchdbecode ( TCHDB* hdb ) ;
FUNCTION: bool tchdbsetmutex ( TCHDB* hdb ) ;
FUNCTION: bool tchdbtune ( TCHDB* hdb, longlong bnum, char apow, char fpow, uchar opts ) ;
FUNCTION: bool tchdbsetcache ( TCHDB* hdb, int rcnum ) ;
FUNCTION: bool tchdbsetxmsiz ( TCHDB* hdb, longlong xmsiz ) ;
FUNCTION: bool tchdbopen ( TCHDB* hdb, char* path, int omode ) ;
FUNCTION: bool tchdbclose ( TCHDB* hdb ) ;
FUNCTION: bool tchdbput ( TCHDB* hdb, void* kbuf, int ksiz, void* vbuf, int vsiz ) ;
FUNCTION: bool tchdbput2 ( TCHDB* hdb, char* kstr, char* vstr ) ;
FUNCTION: bool tchdbputkeep ( TCHDB* hdb, void* kbuf, int ksiz, void* vbuf, int vsiz ) ;
FUNCTION: bool tchdbputkeep2 ( TCHDB* hdb, char* kstr, char* vstr ) ;
FUNCTION: bool tchdbputcat ( TCHDB* hdb, void* kbuf, int ksiz, void* vbuf, int vsiz ) ;
FUNCTION: bool tchdbputcat2 ( TCHDB* hdb, char* kstr, char* vstr ) ;
FUNCTION: bool tchdbputasync ( TCHDB* hdb, void* kbuf, int ksiz, void* vbuf, int vsiz ) ;
FUNCTION: bool tchdbputasync2 ( TCHDB* hdb, char* kstr, char* vstr ) ;
FUNCTION: bool tchdbout ( TCHDB* hdb, void* kbuf, int ksiz ) ;
FUNCTION: bool tchdbout2 ( TCHDB* hdb, char* kstr ) ;
FUNCTION: void* tchdbget ( TCHDB* hdb, void* kbuf, int ksiz, int* sp ) ;
FUNCTION: char* tchdbget2 ( TCHDB* hdb, char* kstr ) ;
FUNCTION: int tchdbget3 ( TCHDB* hdb, void* kbuf, int ksiz, void* vbuf, int max ) ;
FUNCTION: int tchdbvsiz ( TCHDB* hdb, void* kbuf, int ksiz ) ;
FUNCTION: int tchdbvsiz2 ( TCHDB* hdb, char* kstr ) ;
FUNCTION: bool tchdbiterinit ( TCHDB* hdb ) ;
FUNCTION: void* tchdbiternext ( TCHDB* hdb, int* sp ) ;
FUNCTION: char* tchdbiternext2 ( TCHDB* hdb ) ;
FUNCTION: bool tchdbiternext3 ( TCHDB* hdb, TCXSTR* kxstr, TCXSTR* vxstr ) ;
FUNCTION: TCLIST* tchdbfwmkeys ( TCHDB* hdb, void* pbuf, int psiz, int max ) ;
FUNCTION: TCLIST* tchdbfwmkeys2 ( TCHDB* hdb, char* pstr, int max ) ;
FUNCTION: int tchdbaddint ( TCHDB* hdb, void* kbuf, int ksiz, int num ) ;
FUNCTION: double tchdbadddouble ( TCHDB* hdb, void* kbuf, int ksiz, double num ) ;
FUNCTION: bool tchdbsync ( TCHDB* hdb ) ;
FUNCTION: bool tchdboptimize ( TCHDB* hdb, longlong bnum, char apow, char fpow, uchar opts ) ;
FUNCTION: bool tchdbvanish ( TCHDB* hdb ) ;
FUNCTION: bool tchdbcopy ( TCHDB* hdb, char* path ) ;
FUNCTION: bool tchdbtranbegin ( TCHDB* hdb ) ;
FUNCTION: bool tchdbtrancommit ( TCHDB* hdb ) ;
FUNCTION: bool tchdbtranabort ( TCHDB* hdb ) ;
FUNCTION: char* tchdbpath ( TCHDB* hdb ) ;
FUNCTION: ulonglong tchdbrnum ( TCHDB* hdb ) ;
FUNCTION: ulonglong tchdbfsiz ( TCHDB* hdb ) ;

! --------

FUNCTION: void tchdbsetecode ( TCHDB* hdb, int ecode, char* filename, int line, char* func ) ;
FUNCTION: void tchdbsettype ( TCHDB* hdb, uchar type ) ;
FUNCTION: void tchdbsetdbgfd ( TCHDB* hdb, int fd ) ;
FUNCTION: int tchdbdbgfd ( TCHDB* hdb ) ;
FUNCTION: bool tchdbhasmutex ( TCHDB* hdb ) ;
FUNCTION: bool tchdbmemsync ( TCHDB* hdb, bool phys ) ;
FUNCTION: bool tchdbcacheclear ( TCHDB* hdb ) ;
FUNCTION: ulonglong tchdbbnum ( TCHDB* hdb ) ;
FUNCTION: uint tchdbalign ( TCHDB* hdb ) ;
FUNCTION: uint tchdbfbpmax ( TCHDB* hdb ) ;
FUNCTION: ulonglong tchdbxmsiz ( TCHDB* hdb ) ;
FUNCTION: ulonglong tchdbinode ( TCHDB* hdb ) ;
FUNCTION: tokyo_time_t tchdbmtime ( TCHDB* hdb ) ;
FUNCTION: int tchdbomode ( TCHDB* hdb ) ;
FUNCTION: uchar tchdbtype ( TCHDB* hdb ) ;
FUNCTION: uchar tchdbflags ( TCHDB* hdb ) ;
FUNCTION: uchar tchdbopts ( TCHDB* hdb ) ;
FUNCTION: char* tchdbopaque ( TCHDB* hdb ) ;
FUNCTION: ulonglong tchdbbnumused ( TCHDB* hdb ) ;
FUNCTION: bool tchdbsetcodecfunc ( TCHDB* hdb, TCCODEC enc, void* encop, TCCODEC dec, void* decop ) ;
FUNCTION: void tchdbcodecfunc ( TCHDB* hdb, TCCODEC* ep, void* *eop, TCCODEC* dp, void* *dop ) ;
FUNCTION: bool tchdbputproc ( TCHDB* hdb, void* kbuf, int ksiz, void* vbuf, int vsiz, TCPDPROC proc, void* op ) ;
FUNCTION: void* tchdbgetnext ( TCHDB* hdb, void* kbuf, int ksiz, int* sp ) ;
FUNCTION: char* tchdbgetnext2 ( TCHDB* hdb, char* kstr ) ;
FUNCTION: char* tchdbgetnext3 ( TCHDB* hdb, char* kbuf, int ksiz, int* sp, char* *vbp, int* vsp ) ;
FUNCTION: bool tchdbforeach ( TCHDB* hdb, TCITER iter, void* op ) ;
FUNCTION: bool tchdbtranvoid ( TCHDB* hdb ) ;
