! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax tokyo.alien.tchdb
tokyo.alien.tcutil ;
IN: tokyo.alien.tcbdb

LIBRARY: tokyocabinet

TYPEDEF: void* TCBDB

CONSTANT: BDBFOPEN HDBFOPEN
CONSTANT: BDBFFATAL HDBFFATAL

CONSTANT: BDBTLARGE   1
CONSTANT: BDBTDEFLATE 2
CONSTANT: BDBTBZIP    4
CONSTANT: BDBTTCBS    8
CONSTANT: BDBTEXCODEC 16

CONSTANT: BDBOREADER 1
CONSTANT: BDBOWRITER 2
CONSTANT: BDBOCREAT  4
CONSTANT: BDBOTRUNC  8
CONSTANT: BDBONOLCK  16
CONSTANT: BDBOLCKNB  32
CONSTANT: BDBOTSYNC  64

TYPEDEF: void* BDBCUR

CONSTANT: BDBCPCURRENT 0
CONSTANT: BDBCPBEFORE 1
CONSTANT: BDBCPAFTER 2

FUNCTION: c-string tcbdberrmsg ( int ecode )
FUNCTION: TCBDB* tcbdbnew ( )
FUNCTION: void tcbdbdel ( TCBDB* bdb )
FUNCTION: int tcbdbecode ( TCBDB* bdb )
FUNCTION: bool tcbdbsetmutex ( TCBDB* bdb )
FUNCTION: bool tcbdbsetcmpfunc ( TCBDB* bdb, TCCMP cmp, void* cmpop )
FUNCTION: bool tcbdbtune ( TCBDB* bdb, int lmemb, int nmemb, longlong bnum, char apow, char fpow, uchar opts )
FUNCTION: bool tcbdbsetcache ( TCBDB* bdb, int lcnum, int ncnum )
FUNCTION: bool tcbdbsetxmsiz ( TCBDB* bdb, longlong xmsiz )
FUNCTION: bool tcbdbopen ( TCBDB* bdb, c-string path, int omode )
FUNCTION: bool tcbdbclose ( TCBDB* bdb )
FUNCTION: bool tcbdbput ( TCBDB* bdb, void* kbuf, int ksiz, void* vbuf, int vsiz )
FUNCTION: bool tcbdbput2 ( TCBDB* bdb, c-string kstr, c-string vstr )
FUNCTION: bool tcbdbputkeep ( TCBDB* bdb, void* kbuf, int ksiz, void* vbuf, int vsiz )
FUNCTION: bool tcbdbputkeep2 ( TCBDB* bdb, c-string kstr, c-string vstr )
FUNCTION: bool tcbdbputcat ( TCBDB* bdb, void* kbuf, int ksiz, void* vbuf, int vsiz )
FUNCTION: bool tcbdbputcat2 ( TCBDB* bdb, c-string kstr, c-string vstr )
FUNCTION: bool tcbdbputdup ( TCBDB* bdb, void* kbuf, int ksiz, void* vbuf, int vsiz )
FUNCTION: bool tcbdbputdup2 ( TCBDB* bdb, c-string kstr, c-string vstr )
FUNCTION: bool tcbdbputdup3 ( TCBDB* bdb, void* kbuf, int ksiz, TCLIST* vals )
FUNCTION: bool tcbdbout ( TCBDB* bdb, void* kbuf, int ksiz )
FUNCTION: bool tcbdbout2 ( TCBDB* bdb, c-string kstr )
FUNCTION: bool tcbdbout3 ( TCBDB* bdb, void* kbuf, int ksiz )
FUNCTION: void* tcbdbget ( TCBDB* bdb, void* kbuf, int ksiz, int* sp )
FUNCTION: c-string tcbdbget2 ( TCBDB* bdb, c-string kstr )
FUNCTION: void* tcbdbget3 ( TCBDB* bdb, void* kbuf, int ksiz, int* sp )
FUNCTION: TCLIST* tcbdbget4 ( TCBDB* bdb, void* kbuf, int ksiz )
FUNCTION: int tcbdbvnum ( TCBDB* bdb, void* kbuf, int ksiz )
FUNCTION: int tcbdbvnum2 ( TCBDB* bdb, c-string kstr )
FUNCTION: int tcbdbvsiz ( TCBDB* bdb, void* kbuf, int ksiz )
FUNCTION: int tcbdbvsiz2 ( TCBDB* bdb, c-string kstr )
FUNCTION: TCLIST* tcbdbrange ( TCBDB* bdb, void* bkbuf, int bksiz, bool binc, void* ekbuf, int eksiz, bool einc, int max )
FUNCTION: TCLIST* tcbdbrange2 ( TCBDB* bdb, c-string bkstr, bool binc, c-string ekstr, bool einc, int max )
FUNCTION: TCLIST* tcbdbfwmkeys ( TCBDB* bdb, void* pbuf, int psiz, int max )
FUNCTION: TCLIST* tcbdbfwmkeys2 ( TCBDB* bdb, c-string pstr, int max )
FUNCTION: int tcbdbaddint ( TCBDB* bdb, void* kbuf, int ksiz, int num )
FUNCTION: double tcbdbadddouble ( TCBDB* bdb, void* kbuf, int ksiz, double num )
FUNCTION: bool tcbdbsync ( TCBDB* bdb )
FUNCTION: bool tcbdboptimize ( TCBDB* bdb, int lmemb, int nmemb, longlong bnum, char apow, char fpow, uchar opts )
FUNCTION: bool tcbdbvanish ( TCBDB* bdb )
FUNCTION: bool tcbdbcopy ( TCBDB* bdb, c-string path )
FUNCTION: bool tcbdbtranbegin ( TCBDB* bdb )
FUNCTION: bool tcbdbtrancommit ( TCBDB* bdb )
FUNCTION: bool tcbdbtranabort ( TCBDB* bdb )
FUNCTION: c-string tcbdbpath ( TCBDB* bdb )
FUNCTION: ulonglong tcbdbrnum ( TCBDB* bdb )
FUNCTION: ulonglong tcbdbfsiz ( TCBDB* bdb )
FUNCTION: BDBCUR* tcbdbcurnew ( TCBDB* bdb )
FUNCTION: void tcbdbcurdel ( BDBCUR* cur )
FUNCTION: bool tcbdbcurfirst ( BDBCUR* cur )
FUNCTION: bool tcbdbcurlast ( BDBCUR* cur )
FUNCTION: bool tcbdbcurjump ( BDBCUR* cur, void* kbuf, int ksiz )
FUNCTION: bool tcbdbcurjump2 ( BDBCUR* cur, c-string kstr )
FUNCTION: bool tcbdbcurprev ( BDBCUR* cur )
FUNCTION: bool tcbdbcurnext ( BDBCUR* cur )
FUNCTION: bool tcbdbcurput ( BDBCUR* cur, void* vbuf, int vsiz, int cpmode )
FUNCTION: bool tcbdbcurput2 ( BDBCUR* cur, c-string vstr, int cpmode )
FUNCTION: bool tcbdbcurout ( BDBCUR* cur )
FUNCTION: void* tcbdbcurkey ( BDBCUR* cur, int* sp )
FUNCTION: c-string tcbdbcurkey2 ( BDBCUR* cur )
FUNCTION: void* tcbdbcurkey3 ( BDBCUR* cur, int* sp )
FUNCTION: void* tcbdbcurval ( BDBCUR* cur, int* sp )
FUNCTION: c-string tcbdbcurval2 ( BDBCUR* cur )
FUNCTION: void* tcbdbcurval3 ( BDBCUR* cur, int* sp )
FUNCTION: bool tcbdbcurrec ( BDBCUR* cur, TCXSTR* kxstr, TCXSTR* vxstr )

! -----------

FUNCTION: void tcbdbsetecode ( TCBDB* bdb, int ecode, c-string filename, int line, c-string func )
FUNCTION: void tcbdbsetdbgfd ( TCBDB* bdb, int fd )
FUNCTION: int tcbdbdbgfd ( TCBDB* bdb )
FUNCTION: bool tcbdbhasmutex ( TCBDB* bdb )
FUNCTION: bool tcbdbmemsync ( TCBDB* bdb, bool phys )
FUNCTION: bool tcbdbcacheclear ( TCBDB* bdb )
FUNCTION: TCCMP tcbdbcmpfunc ( TCBDB* bdb )
FUNCTION: void* tcbdbcmpop ( TCBDB* bdb )
FUNCTION: uint tcbdblmemb ( TCBDB* bdb )
FUNCTION: uint tcbdbnmemb ( TCBDB* bdb )
FUNCTION: ulonglong tcbdblnum ( TCBDB* bdb )
FUNCTION: ulonglong tcbdbnnum ( TCBDB* bdb )
FUNCTION: ulonglong tcbdbbnum ( TCBDB* bdb )
FUNCTION: uint tcbdbalign ( TCBDB* bdb )
FUNCTION: uint tcbdbfbpmax ( TCBDB* bdb )
FUNCTION: ulonglong tcbdbinode ( TCBDB* bdb )
FUNCTION: tokyo_time_t tcbdbmtime ( TCBDB* bdb )
FUNCTION: uchar tcbdbflags ( TCBDB* bdb )
FUNCTION: uchar tcbdbopts ( TCBDB* bdb )
FUNCTION: c-string tcbdbopaque ( TCBDB* bdb )
FUNCTION: ulonglong tcbdbbnumused ( TCBDB* bdb )
FUNCTION: bool tcbdbsetlsmax ( TCBDB* bdb, uint lsmax )
FUNCTION: bool tcbdbsetcapnum ( TCBDB* bdb, ulonglong capnum )
FUNCTION: bool tcbdbsetcodecfunc ( TCBDB* bdb, TCCODEC enc, void* encop, TCCODEC dec, void* decop )
FUNCTION: bool tcbdbputdupback ( TCBDB* bdb, void* kbuf, int ksiz, void* vbuf, int vsiz )
FUNCTION: bool tcbdbputdupback2 ( TCBDB* bdb, c-string kstr, c-string vstr )
FUNCTION: bool tcbdbputproc ( TCBDB* bdb, void* kbuf, int ksiz, void* vbuf, int vsiz, TCPDPROC proc, void* op )
FUNCTION: bool tcbdbcurjumpback ( BDBCUR* cur, void* kbuf, int ksiz )
FUNCTION: bool tcbdbcurjumpback2 ( BDBCUR* cur, c-string kstr )
FUNCTION: bool tcbdbforeach ( TCBDB* bdb, TCITER iter, void* op )
