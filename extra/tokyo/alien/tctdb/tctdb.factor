! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax tokyo.alien.tchdb
tokyo.alien.tcutil ;
IN: tokyo.alien.tctdb

LIBRARY: tokyocabinet

C-TYPE: TDBIDX
C-TYPE: TCTDB
C-TYPE: TCMAP

CONSTANT: TDBFOPEN  HDBFOPEN
CONSTANT: TDBFFATAL HDBFFATAL

CONSTANT: TDBTLARGE   1
CONSTANT: TDBTDEFLATE 2
CONSTANT: TDBTBZIP    4
CONSTANT: TDBTTCBS    8
CONSTANT: TDBTEXCODEC 16

CONSTANT: TDBOREADER 1
CONSTANT: TDBOWRITER 2
CONSTANT: TDBOCREAT  4
CONSTANT: TDBOTRUNC  8
CONSTANT: TDBONOLCK  16
CONSTANT: TDBOLCKNB  32
CONSTANT: TDBOTSYNC  64

CONSTANT: TDBITLEXICAL 0
CONSTANT: TDBITDECIMAL 1

CONSTANT: TDBITOPT  9998
CONSTANT: TDBITVOID 9999
CONSTANT: TDBITKEEP 16777216

C-TYPE: TDBCOND
C-TYPE: TDBQRY

CONSTANT: TDBQCSTREQ   0
CONSTANT: TDBQCSTRINC  1
CONSTANT: TDBQCSTRBW   2
CONSTANT: TDBQCSTREW   3
CONSTANT: TDBQCSTRAND  4
CONSTANT: TDBQCSTROR   5
CONSTANT: TDBQCSTROREQ 6
CONSTANT: TDBQCSTRRX   7
CONSTANT: TDBQCNUMEQ   8
CONSTANT: TDBQCNUMGT   9
CONSTANT: TDBQCNUMGE   10
CONSTANT: TDBQCNUMLT   11
CONSTANT: TDBQCNUMLE   12
CONSTANT: TDBQCNUMBT   13
CONSTANT: TDBQCNUMOREQ 14

CONSTANT: TDBQCNEGATE 16777216
CONSTANT: TDBQCNOIDX  33554432

CONSTANT: TDBQOSTRASC  0
CONSTANT: TDBQOSTRDESC 1
CONSTANT: TDBQONUMASC  2
CONSTANT: TDBQONUMDESC 3

CONSTANT: TDBQPPUT  1
CONSTANT: TDBQPOUT  2
CONSTANT: TDBQPSTOP 16777216

! int (*)(const void *pkbuf, int pksiz, TCMAP *cols, void *op);
TYPEDEF: void* TDBQRYPROC

FUNCTION: c-string tctdberrmsg ( int ecode )
FUNCTION: TCTDB* tctdbnew ( )
FUNCTION: void tctdbdel ( TCTDB* tdb )
FUNCTION: int tctdbecode ( TCTDB* tdb )
FUNCTION: bool tctdbsetmutex ( TCTDB* tdb )
FUNCTION: bool tctdbtune ( TCTDB* tdb, longlong bnum, char apow, char fpow, uchar opts )
FUNCTION: bool tctdbsetcache ( TCTDB* tdb, int rcnum, int lcnum, int ncnum )
FUNCTION: bool tctdbsetxmsiz ( TCTDB* tdb, longlong xmsiz )
FUNCTION: bool tctdbopen ( TCTDB* tdb, c-string path, int omode )
FUNCTION: bool tctdbclose ( TCTDB* tdb )
FUNCTION: bool tctdbput ( TCTDB* tdb, void* pkbuf, int pksiz, TCMAP* cols )
FUNCTION: bool tctdbput2 ( TCTDB* tdb, void* pkbuf, int pksiz, void* cbuf, int csiz )
FUNCTION: bool tctdbput3 ( TCTDB* tdb, c-string pkstr, c-string cstr )
FUNCTION: bool tctdbputkeep ( TCTDB* tdb, void* pkbuf, int pksiz, TCMAP* cols )
FUNCTION: bool tctdbputkeep2 ( TCTDB* tdb, void* pkbuf, int pksiz, void* cbuf, int csiz )
FUNCTION: bool tctdbputkeep3 ( TCTDB* tdb, c-string pkstr, c-string cstr )
FUNCTION: bool tctdbputcat ( TCTDB* tdb, void* pkbuf, int pksiz, TCMAP* cols )
FUNCTION: bool tctdbputcat2 ( TCTDB* tdb, void* pkbuf, int pksiz, void* cbuf, int csiz )
FUNCTION: bool tctdbputcat3 ( TCTDB* tdb, c-string pkstr, c-string cstr )
FUNCTION: bool tctdbout ( TCTDB* tdb, void* pkbuf, int pksiz )
FUNCTION: bool tctdbout2 ( TCTDB* tdb, c-string pkstr )
FUNCTION: TCMAP* tctdbget ( TCTDB* tdb, void* pkbuf, int pksiz )
FUNCTION: c-string tctdbget2 ( TCTDB* tdb, void* pkbuf, int pksiz, int* sp )
FUNCTION: c-string tctdbget3 ( TCTDB* tdb, c-string pkstr )
FUNCTION: int tctdbvsiz ( TCTDB* tdb, void* pkbuf, int pksiz )
FUNCTION: int tctdbvsiz2 ( TCTDB* tdb, c-string pkstr )
FUNCTION: bool tctdbiterinit ( TCTDB* tdb )
FUNCTION: void* tctdbiternext ( TCTDB* tdb, int* sp )
FUNCTION: c-string tctdbiternext2 ( TCTDB* tdb )
FUNCTION: TCLIST* tctdbfwmkeys ( TCTDB* tdb, void* pbuf, int psiz, int max )
FUNCTION: TCLIST* tctdbfwmkeys2 ( TCTDB* tdb, c-string pstr, int max )
FUNCTION: int tctdbaddint ( TCTDB* tdb, void* pkbuf, int pksiz, int num )
FUNCTION: double tctdbadddouble ( TCTDB* tdb, void* pkbuf, int pksiz, double num )
FUNCTION: bool tctdbsync ( TCTDB* tdb )
FUNCTION: bool tctdboptimize ( TCTDB* tdb, longlong bnum, char apow, char fpow, uchar opts )
FUNCTION: bool tctdbvanish ( TCTDB* tdb )
FUNCTION: bool tctdbcopy ( TCTDB* tdb, c-string path )
FUNCTION: bool tctdbtranbegin ( TCTDB* tdb )
FUNCTION: bool tctdbtrancommit ( TCTDB* tdb )
FUNCTION: bool tctdbtranabort ( TCTDB* tdb )
FUNCTION: c-string tctdbpath ( TCTDB* tdb )
FUNCTION: ulonglong tctdbrnum ( TCTDB* tdb )
FUNCTION: ulonglong tctdbfsiz ( TCTDB* tdb )
FUNCTION: bool tctdbsetindex ( TCTDB* tdb, c-string name, int type )
FUNCTION: longlong tctdbgenuid ( TCTDB* tdb )
FUNCTION: TDBQRY* tctdbqrynew ( TCTDB* tdb )
FUNCTION: void tctdbqrydel ( TDBQRY* qry )
FUNCTION: void tctdbqryaddcond ( TDBQRY* qry, c-string name, int op, c-string expr )
FUNCTION: void tctdbqrysetorder ( TDBQRY* qry, c-string name, int type )
FUNCTION: void tctdbqrysetlimit ( TDBQRY* qry, int max, int skip )
FUNCTION: TCLIST* tctdbqrysearch ( TDBQRY* qry )
FUNCTION: bool tctdbqrysearchout ( TDBQRY* qry )
FUNCTION: bool tctdbqryproc ( TDBQRY* qry, TDBQRYPROC proc, void* op )
FUNCTION: c-string tctdbqryhint ( TDBQRY* qry )

! =======

FUNCTION: void tctdbsetecode ( TCTDB* tdb, int ecode, c-string filename, int line, c-string func )
FUNCTION: void tctdbsetdbgfd ( TCTDB* tdb, int fd )
FUNCTION: int tctdbdbgfd ( TCTDB* tdb )
FUNCTION: bool tctdbhasmutex ( TCTDB* tdb )
FUNCTION: bool tctdbmemsync ( TCTDB* tdb, bool phys )
FUNCTION: ulonglong tctdbbnum ( TCTDB* tdb )
FUNCTION: uint tctdbalign ( TCTDB* tdb )
FUNCTION: uint tctdbfbpmax ( TCTDB* tdb )
FUNCTION: ulonglong tctdbinode ( TCTDB* tdb )
FUNCTION: tokyo_time_t tctdbmtime ( TCTDB* tdb )
FUNCTION: uchar tctdbflags ( TCTDB* tdb )
FUNCTION: uchar tctdbopts ( TCTDB* tdb )
FUNCTION: c-string tctdbopaque ( TCTDB* tdb )
FUNCTION: ulonglong tctdbbnumused ( TCTDB* tdb )
FUNCTION: int tctdbinum ( TCTDB* tdb )
FUNCTION: longlong tctdbuidseed ( TCTDB* tdb )
FUNCTION: bool tctdbsetuidseed ( TCTDB* tdb, longlong seed )
FUNCTION: bool tctdbsetcodecfunc ( TCTDB* tdb, TCCODEC enc, void* encop, TCCODEC dec, void* decop )
FUNCTION: bool tctdbputproc ( TCTDB* tdb, void* pkbuf, int pksiz, void* cbuf, int csiz, TCPDPROC proc, void* op )
FUNCTION: bool tctdbforeach ( TCTDB* tdb, TCITER iter, void* op )
FUNCTION: bool tctdbqryproc2 ( TDBQRY* qry, TDBQRYPROC proc, void* op )
FUNCTION: bool tctdbqrysearchout2 ( TDBQRY* qry )
FUNCTION: int tctdbstrtoindextype ( c-string str )
FUNCTION: int tctdbqrycount ( TDBQRY* qry )
FUNCTION: int tctdbqrystrtocondop ( c-string str )
FUNCTION: int tctdbqrystrtoordertype ( c-string str )
