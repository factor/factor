! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
combinators kernel tokyo.alien.tchdb tokyo.alien.tcutil ;
IN: tokyo.alien.tctdb

LIBRARY: tokyocabinet

TYPEDEF: void* TDBIDX*
TYPEDEF: void* TCTDB*

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

C-ENUM:
  TDBITLEXICAL
  TDBITDECIMAL ;

CONSTANT: TDBITOPT  9998
CONSTANT: TDBITVOID 9999
CONSTANT: TDBITKEEP 16777216

TYPEDEF: void* TDBCOND*
TYPEDEF: void* TDBQRY*

C-ENUM:
    TDBQCSTREQ
    TDBQCSTRINC
    TDBQCSTRBW
    TDBQCSTREW
    TDBQCSTRAND
    TDBQCSTROR
    TDBQCSTROREQ
    TDBQCSTRRX
    TDBQCNUMEQ
    TDBQCNUMGT
    TDBQCNUMGE
    TDBQCNUMLT
    TDBQCNUMLE
    TDBQCNUMBT
    TDBQCNUMOREQ ;

CONSTANT: TDBQCNEGATE 16777216
CONSTANT: TDBQCNOIDX  33554432

C-ENUM:
    TDBQOSTRASC
    TDBQOSTRDESC
    TDBQONUMASC
    TDBQONUMDESC ;

CONSTANT: TDBQPPUT  1
CONSTANT: TDBQPOUT  2
CONSTANT: TDBQPSTOP 16777216

! int (*)(const void *pkbuf, int pksiz, TCMAP *cols, void *op);
TYPEDEF: void* TDBQRYPROC

FUNCTION: char* tctdberrmsg ( int ecode ) ;
FUNCTION: TCTDB* tctdbnew ( ) ;
FUNCTION: void tctdbdel ( TCTDB* tdb ) ;
FUNCTION: int tctdbecode ( TCTDB* tdb ) ;
FUNCTION: bool tctdbsetmutex ( TCTDB* tdb ) ;
FUNCTION: bool tctdbtune ( TCTDB* tdb, longlong bnum, char apow, char fpow, uchar opts ) ;
FUNCTION: bool tctdbsetcache ( TCTDB* tdb, int rcnum, int lcnum, int ncnum ) ;
FUNCTION: bool tctdbsetxmsiz ( TCTDB* tdb, longlong xmsiz ) ;
FUNCTION: bool tctdbopen ( TCTDB* tdb, char* path, int omode ) ;
FUNCTION: bool tctdbclose ( TCTDB* tdb ) ;
FUNCTION: bool tctdbput ( TCTDB* tdb, void* pkbuf, int pksiz, TCMAP* cols ) ;
FUNCTION: bool tctdbput2 ( TCTDB* tdb, void* pkbuf, int pksiz, void* cbuf, int csiz ) ;
FUNCTION: bool tctdbput3 ( TCTDB* tdb, char* pkstr, char* cstr ) ;
FUNCTION: bool tctdbputkeep ( TCTDB* tdb, void* pkbuf, int pksiz, TCMAP* cols ) ;
FUNCTION: bool tctdbputkeep2 ( TCTDB* tdb, void* pkbuf, int pksiz, void* cbuf, int csiz ) ;
FUNCTION: bool tctdbputkeep3 ( TCTDB* tdb, char* pkstr, char* cstr ) ;
FUNCTION: bool tctdbputcat ( TCTDB* tdb, void* pkbuf, int pksiz, TCMAP* cols ) ;
FUNCTION: bool tctdbputcat2 ( TCTDB* tdb, void* pkbuf, int pksiz, void* cbuf, int csiz ) ;
FUNCTION: bool tctdbputcat3 ( TCTDB* tdb, char* pkstr, char* cstr ) ;
FUNCTION: bool tctdbout ( TCTDB* tdb, void* pkbuf, int pksiz ) ;
FUNCTION: bool tctdbout2 ( TCTDB* tdb, char* pkstr ) ;
FUNCTION: TCMAP* tctdbget ( TCTDB* tdb, void* pkbuf, int pksiz ) ;
FUNCTION: char* tctdbget2 ( TCTDB* tdb, void* pkbuf, int pksiz, int* sp ) ;
FUNCTION: char* tctdbget3 ( TCTDB* tdb, char* pkstr ) ;
FUNCTION: int tctdbvsiz ( TCTDB* tdb, void* pkbuf, int pksiz ) ;
FUNCTION: int tctdbvsiz2 ( TCTDB* tdb, char* pkstr ) ;
FUNCTION: bool tctdbiterinit ( TCTDB* tdb ) ;
FUNCTION: void* tctdbiternext ( TCTDB* tdb, int* sp ) ;
FUNCTION: char* tctdbiternext2 ( TCTDB* tdb ) ;
FUNCTION: TCLIST* tctdbfwmkeys ( TCTDB* tdb, void* pbuf, int psiz, int max ) ;
FUNCTION: TCLIST* tctdbfwmkeys2 ( TCTDB* tdb, char* pstr, int max ) ;
FUNCTION: int tctdbaddint ( TCTDB* tdb, void* pkbuf, int pksiz, int num ) ;
FUNCTION: double tctdbadddouble ( TCTDB* tdb, void* pkbuf, int pksiz, double num ) ;
FUNCTION: bool tctdbsync ( TCTDB* tdb ) ;
FUNCTION: bool tctdboptimize ( TCTDB* tdb, longlong bnum, char apow, char fpow, uchar opts ) ;
FUNCTION: bool tctdbvanish ( TCTDB* tdb ) ;
FUNCTION: bool tctdbcopy ( TCTDB* tdb, char* path ) ;
FUNCTION: bool tctdbtranbegin ( TCTDB* tdb ) ;
FUNCTION: bool tctdbtrancommit ( TCTDB* tdb ) ;
FUNCTION: bool tctdbtranabort ( TCTDB* tdb ) ;
FUNCTION: char* tctdbpath ( TCTDB* tdb ) ;
FUNCTION: ulonglong tctdbrnum ( TCTDB* tdb ) ;
FUNCTION: ulonglong tctdbfsiz ( TCTDB* tdb ) ;
FUNCTION: bool tctdbsetindex ( TCTDB* tdb, char* name, int type ) ;
FUNCTION: longlong tctdbgenuid ( TCTDB* tdb ) ;
FUNCTION: TDBQRY* tctdbqrynew ( TCTDB* tdb ) ;
FUNCTION: void tctdbqrydel ( TDBQRY* qry ) ;
FUNCTION: void tctdbqryaddcond ( TDBQRY* qry, char* name, int op, char* expr ) ;
FUNCTION: void tctdbqrysetorder ( TDBQRY* qry, char* name, int type ) ;
FUNCTION: void tctdbqrysetlimit ( TDBQRY* qry, int max, int skip ) ;
FUNCTION: TCLIST* tctdbqrysearch ( TDBQRY* qry ) ;
FUNCTION: bool tctdbqrysearchout ( TDBQRY* qry ) ;
FUNCTION: bool tctdbqryproc ( TDBQRY* qry, TDBQRYPROC proc, void* op ) ;
FUNCTION: char* tctdbqryhint ( TDBQRY* qry ) ;

! =======

FUNCTION: void tctdbsetecode ( TCTDB* tdb, int ecode, char* filename, int line, char* func ) ;
FUNCTION: void tctdbsetdbgfd ( TCTDB* tdb, int fd ) ;
FUNCTION: int tctdbdbgfd ( TCTDB* tdb ) ;
FUNCTION: bool tctdbhasmutex ( TCTDB* tdb ) ;
FUNCTION: bool tctdbmemsync ( TCTDB* tdb, bool phys ) ;
FUNCTION: ulonglong tctdbbnum ( TCTDB* tdb ) ;
FUNCTION: uint tctdbalign ( TCTDB* tdb ) ;
FUNCTION: uint tctdbfbpmax ( TCTDB* tdb ) ;
FUNCTION: ulonglong tctdbinode ( TCTDB* tdb ) ;
FUNCTION: tokyo_time_t tctdbmtime ( TCTDB* tdb ) ;
FUNCTION: uchar tctdbflags ( TCTDB* tdb ) ;
FUNCTION: uchar tctdbopts ( TCTDB* tdb ) ;
FUNCTION: char* tctdbopaque ( TCTDB* tdb ) ;
FUNCTION: ulonglong tctdbbnumused ( TCTDB* tdb ) ;
FUNCTION: int tctdbinum ( TCTDB* tdb ) ;
FUNCTION: longlong tctdbuidseed ( TCTDB* tdb ) ;
FUNCTION: bool tctdbsetuidseed ( TCTDB* tdb, longlong seed ) ;
FUNCTION: bool tctdbsetcodecfunc ( TCTDB* tdb, TCCODEC enc, void* encop, TCCODEC dec, void* decop ) ;
FUNCTION: bool tctdbputproc ( TCTDB* tdb, void* pkbuf, int pksiz, void* cbuf, int csiz, TCPDPROC proc, void* op ) ;
FUNCTION: bool tctdbforeach ( TCTDB* tdb, TCITER iter, void* op ) ;
FUNCTION: bool tctdbqryproc2 ( TDBQRY* qry, TDBQRYPROC proc, void* op ) ;
FUNCTION: bool tctdbqrysearchout2 ( TDBQRY* qry ) ;
FUNCTION: int tctdbstrtoindextype ( char* str ) ;
FUNCTION: int tctdbqrycount ( TDBQRY* qry ) ;
FUNCTION: int tctdbqrystrtocondop ( char* str ) ;
FUNCTION: int tctdbqrystrtoordertype ( char* str ) ;
