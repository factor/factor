! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax tokyo.alien.tchdb
tokyo.alien.tcutil ;
IN: tokyo.alien.tctdb

TYPEDEF: void* TCFDB

CONSTANT: FDBFOPEN  1
CONSTANT: FDBFFATAL 2

CONSTANT: FDBOREADER 1
CONSTANT: FDBOWRITER 2
CONSTANT: FDBOCREAT  4
CONSTANT: FDBOTRUNC  8
CONSTANT: FDBONOLCK  16
CONSTANT: FDBOLCKNB  32
CONSTANT: FDBOTSYNC  64

CONSTANT: FDBIDMIN  -1
CONSTANT: FDBIDPREV -2
CONSTANT: FDBIDMAX  -3
CONSTANT: FDBIDNEXT -4

FUNCTION: c-string tcfdberrmsg ( int ecode )
FUNCTION: TCFDB* tcfdbnew ( )
FUNCTION: void tcfdbdel ( TCFDB* fdb )
FUNCTION: int tcfdbecode ( TCFDB* fdb )
FUNCTION: bool tcfdbsetmutex ( TCFDB* fdb )
FUNCTION: bool tcfdbtune ( TCFDB* fdb, int width, longlong limsiz )
FUNCTION: bool tcfdbopen ( TCFDB* fdb, c-string path, int omode )
FUNCTION: bool tcfdbclose ( TCFDB* fdb )
FUNCTION: bool tcfdbput ( TCFDB* fdb, longlong id, void* vbuf, int vsiz )
FUNCTION: bool tcfdbput2 ( TCFDB* fdb, void* kbuf, int ksiz, void* vbuf, int vsiz )
FUNCTION: bool tcfdbput3 ( TCFDB* fdb, c-string kstr, void* vstr )
FUNCTION: bool tcfdbputkeep ( TCFDB* fdb, longlong id, void* vbuf, int vsiz )
FUNCTION: bool tcfdbputkeep2 ( TCFDB* fdb, void* kbuf, int ksiz, void* vbuf, int vsiz )
FUNCTION: bool tcfdbputkeep3 ( TCFDB* fdb, c-string kstr, void* vstr )
FUNCTION: bool tcfdbputcat ( TCFDB* fdb, longlong id, void* vbuf, int vsiz )
FUNCTION: bool tcfdbputcat2 ( TCFDB* fdb, void* kbuf, int ksiz, void* vbuf, int vsiz )
FUNCTION: bool tcfdbputcat3 ( TCFDB* fdb, c-string kstr, void* vstr )
FUNCTION: bool tcfdbout ( TCFDB* fdb, longlong id )
FUNCTION: bool tcfdbout2 ( TCFDB* fdb, void* kbuf, int ksiz )
FUNCTION: bool tcfdbout3 ( TCFDB* fdb, c-string kstr )
FUNCTION: void* tcfdbget ( TCFDB* fdb, longlong id, int* sp )
FUNCTION: void* tcfdbget2 ( TCFDB* fdb, void* kbuf, int ksiz, int* sp )
FUNCTION: c-string tcfdbget3 ( TCFDB* fdb, c-string kstr )
FUNCTION: int tcfdbget4 ( TCFDB* fdb, longlong id, void* vbuf, int max )
FUNCTION: int tcfdbvsiz ( TCFDB* fdb, longlong id )
FUNCTION: int tcfdbvsiz2 ( TCFDB* fdb, void* kbuf, int ksiz )
FUNCTION: int tcfdbvsiz3 ( TCFDB* fdb, c-string kstr )
FUNCTION: bool tcfdbiterinit ( TCFDB* fdb )
FUNCTION: ulonglong tcfdbiternext ( TCFDB* fdb )
FUNCTION: void* tcfdbiternext2 ( TCFDB* fdb, int* sp )
FUNCTION: c-string tcfdbiternext3 ( TCFDB* fdb )
FUNCTION: ulonglong* tcfdbrange ( TCFDB* fdb, longlong lower, longlong upper, int max, int* np )
FUNCTION: TCLIST* tcfdbrange2 ( TCFDB* fdb, void* lbuf, int lsiz, void* ubuf, int usiz, int max )
FUNCTION: TCLIST* tcfdbrange3 ( TCFDB* fdb, c-string lstr, c-string ustr, int max )
FUNCTION: TCLIST* tcfdbrange4 ( TCFDB* fdb, void* ibuf, int isiz, int max )
FUNCTION: TCLIST* tcfdbrange5 ( TCFDB* fdb, void* istr, int max )
FUNCTION: int tcfdbaddint ( TCFDB* fdb, longlong id, int num )
FUNCTION: double tcfdbadddouble ( TCFDB* fdb, longlong id, double num )
FUNCTION: bool tcfdbsync ( TCFDB* fdb )
FUNCTION: bool tcfdboptimize ( TCFDB* fdb, int width, longlong limsiz )
FUNCTION: bool tcfdbvanish ( TCFDB* fdb )
FUNCTION: bool tcfdbcopy ( TCFDB* fdb, c-string path )
FUNCTION: bool tcfdbtranbegin ( TCFDB* fdb )
FUNCTION: bool tcfdbtrancommit ( TCFDB* fdb )
FUNCTION: bool tcfdbtranabort ( TCFDB* fdb )
FUNCTION: c-string tcfdbpath ( TCFDB* fdb )
FUNCTION: ulonglong tcfdbrnum ( TCFDB* fdb )
FUNCTION: ulonglong tcfdbfsiz ( TCFDB* fdb )

! --------

FUNCTION: void tcfdbsetecode ( TCFDB* fdb, int ecode, c-string filename, int line, c-string func )
FUNCTION: void tcfdbsetdbgfd ( TCFDB* fdb, int fd )
FUNCTION: int tcfdbdbgfd ( TCFDB* fdb )
FUNCTION: bool tcfdbhasmutex ( TCFDB* fdb )
FUNCTION: bool tcfdbmemsync ( TCFDB* fdb, bool phys )
FUNCTION: ulonglong tcfdbmin ( TCFDB* fdb )
FUNCTION: ulonglong tcfdbmax ( TCFDB* fdb )
FUNCTION: uint tcfdbwidth ( TCFDB* fdb )
FUNCTION: ulonglong tcfdblimsiz ( TCFDB* fdb )
FUNCTION: ulonglong tcfdblimid ( TCFDB* fdb )
FUNCTION: ulonglong tcfdbinode ( TCFDB* fdb )
FUNCTION: tokyo_time_t tcfdbmtime ( TCFDB* fdb )
FUNCTION: int tcfdbomode ( TCFDB* fdb )
FUNCTION: uchar tcfdbtype ( TCFDB* fdb )
FUNCTION: uchar tcfdbflags ( TCFDB* fdb )
FUNCTION: c-string tcfdbopaque ( TCFDB* fdb )
FUNCTION: bool tcfdbputproc ( TCFDB* fdb, longlong id, void* vbuf, int vsiz, TCPDPROC proc, void* op )
FUNCTION: bool tcfdbforeach ( TCFDB* fdb, TCITER iter, void* op )
FUNCTION: longlong tcfdbkeytoid ( c-string kbuf, int ksiz )
