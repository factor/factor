! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
combinators system tokyo.alien.tcutil tokyo.alien.tctdb ;
IN: tokyo.alien.tcrdb

<< "tokyotyrant" {
    { [ os macosx? ] [ "libtokyotyrant.dylib" ] }
    { [ os unix? ] [ "libtokyotyrant.so" ] }
    { [ os windows? ] [ "tokyotyrant.dll" ] }
} cond cdecl add-library >>

LIBRARY: tokyotyrant

C-TYPE: TCRDB
! STRUCT: TCRDB
!     { mmtx pthread_mutex_t }
!     { eckey pthread_key_t }
!     { host c-string }
!     { port int }
!     { expr c-string }
!     { fd int }
!     { sock TTSOCK* }
!     { timeout double }
!     { opts int } ;

CONSTANT: TTESUCCESS 0
CONSTANT: TTEINVALID 1
CONSTANT: TTENOHOST  2
CONSTANT: TTEREFUSED 3
CONSTANT: TTESEND    4
CONSTANT: TTERECV    5
CONSTANT: TTEKEEP    6
CONSTANT: TTENOREC   7
CONSTANT: TTEMISC    9999

CONSTANT: RDBTRECON   1
CONSTANT: RDBXOLCKREC 1
CONSTANT: RDBXOLCKGLB 2
CONSTANT: RDBROCHKCON 1
CONSTANT: RDBMONOULOG 1

FUNCTION: c-string tcrdberrmsg ( int ecode )
FUNCTION: TCRDB* tcrdbnew ( )
FUNCTION: void tcrdbdel ( TCRDB* rdb )
FUNCTION: int tcrdbecode ( TCRDB* rdb )
FUNCTION: bool tcrdbtune ( TCRDB* rdb, double timeout, int opts )
FUNCTION: bool tcrdbopen ( TCRDB* rdb, c-string host, int port )
FUNCTION: bool tcrdbopen2 ( TCRDB* rdb, c-string expr )
FUNCTION: bool tcrdbclose ( TCRDB* rdb )
FUNCTION: bool tcrdbput ( TCRDB* rdb, void* kbuf, int ksiz, void* vbuf, int vsiz )
FUNCTION: bool tcrdbput2 ( TCRDB* rdb, c-string kstr, c-string vstr )
FUNCTION: bool tcrdbputkeep ( TCRDB* rdb, void* kbuf, int ksiz, void* vbuf, int vsiz )
FUNCTION: bool tcrdbputkeep2 ( TCRDB* rdb, c-string kstr, c-string vstr )
FUNCTION: bool tcrdbputcat ( TCRDB* rdb, void* kbuf, int ksiz, void* vbuf, int vsiz )
FUNCTION: bool tcrdbputcat2 ( TCRDB* rdb, c-string kstr, c-string vstr )
FUNCTION: bool tcrdbputshl ( TCRDB* rdb, void* kbuf, int ksiz, void* vbuf, int vsiz, int width )
FUNCTION: bool tcrdbputshl2 ( TCRDB* rdb, c-string kstr, c-string vstr, int width )
FUNCTION: bool tcrdbputnr ( TCRDB* rdb, void* kbuf, int ksiz, void* vbuf, int vsiz )
FUNCTION: bool tcrdbputnr2 ( TCRDB* rdb, c-string kstr, c-string vstr )
FUNCTION: bool tcrdbout ( TCRDB* rdb, void* kbuf, int ksiz )
FUNCTION: bool tcrdbout2 ( TCRDB* rdb, c-string kstr )
FUNCTION: void* tcrdbget ( TCRDB* rdb, void* kbuf, int ksiz, int* sp )
FUNCTION: c-string tcrdbget2 ( TCRDB* rdb, c-string kstr )
FUNCTION: bool tcrdbget3 ( TCRDB* rdb, TCMAP* recs )
FUNCTION: int tcrdbvsiz ( TCRDB* rdb, void* kbuf, int ksiz )
FUNCTION: int tcrdbvsiz2 ( TCRDB* rdb, c-string kstr )
FUNCTION: bool tcrdbiterinit ( TCRDB* rdb )
FUNCTION: void* tcrdbiternext ( TCRDB* rdb, int* sp )
FUNCTION: c-string tcrdbiternext2 ( TCRDB* rdb )
FUNCTION: TCLIST* tcrdbfwmkeys ( TCRDB* rdb, void* pbuf, int psiz, int max )
FUNCTION: TCLIST* tcrdbfwmkeys2 ( TCRDB* rdb, c-string pstr, int max )
FUNCTION: int tcrdbaddint ( TCRDB* rdb, void* kbuf, int ksiz, int num )
FUNCTION: double tcrdbadddouble ( TCRDB* rdb, void* kbuf, int ksiz, double num )
FUNCTION: void* tcrdbext ( TCRDB* rdb, c-string name, int opts, void* kbuf, int ksiz, void* vbuf, int vsiz, int* sp )
FUNCTION: c-string tcrdbext2 ( TCRDB* rdb, c-string name, int opts, c-string kstr, c-string vstr )
FUNCTION: bool tcrdbsync ( TCRDB* rdb )
FUNCTION: bool tcrdboptimize ( TCRDB* rdb, c-string params )
FUNCTION: bool tcrdbvanish ( TCRDB* rdb )
FUNCTION: bool tcrdbcopy ( TCRDB* rdb, c-string path )
FUNCTION: bool tcrdbrestore ( TCRDB* rdb, c-string path, ulonglong ts, int opts )
FUNCTION: bool tcrdbsetmst ( TCRDB* rdb, c-string host, int port, int opts )
FUNCTION: bool tcrdbsetmst2 ( TCRDB* rdb, c-string expr, int opts )
FUNCTION: c-string tcrdbexpr ( TCRDB* rdb )
FUNCTION: ulonglong tcrdbrnum ( TCRDB* rdb )
FUNCTION: ulonglong tcrdbsize ( TCRDB* rdb )
FUNCTION: c-string tcrdbstat ( TCRDB* rdb )
FUNCTION: TCLIST* tcrdbmisc ( TCRDB* rdb, c-string name, int opts, TCLIST* args )

CONSTANT: RDBITLEXICAL TDBITLEXICAL
CONSTANT: RDBITDECIMAL TDBITDECIMAL
CONSTANT: RDBITOPT     TDBITOPT
CONSTANT: RDBITVOID    TDBITVOID
CONSTANT: RDBITKEEP    TDBITKEEP

C-TYPE: RDBQRY
! STRUCT: RDBQRY
!     { rdb TCRDB* }
!     { args TCLIST* } ;

CONSTANT: RDBQCSTREQ   TDBQCSTREQ
CONSTANT: RDBQCSTRINC  TDBQCSTRINC
CONSTANT: RDBQCSTRBW   TDBQCSTRBW
CONSTANT: RDBQCSTREW   TDBQCSTREW
CONSTANT: RDBQCSTRAND  TDBQCSTRAND
CONSTANT: RDBQCSTROR   TDBQCSTROR
CONSTANT: RDBQCSTROREQ TDBQCSTROREQ
CONSTANT: RDBQCSTRRX   TDBQCSTRRX
CONSTANT: RDBQCNUMEQ   TDBQCNUMEQ
CONSTANT: RDBQCNUMGT   TDBQCNUMGT
CONSTANT: RDBQCNUMGE   TDBQCNUMGE
CONSTANT: RDBQCNUMLT   TDBQCNUMLT
CONSTANT: RDBQCNUMLE   TDBQCNUMLE
CONSTANT: RDBQCNUMBT   TDBQCNUMBT
CONSTANT: RDBQCNUMOREQ TDBQCNUMOREQ
CONSTANT: RDBQCNEGATE  TDBQCNEGATE
CONSTANT: RDBQCNOIDX   TDBQCNOIDX

CONSTANT: RDBQOSTRASC  TDBQOSTRASC
CONSTANT: RDBQOSTRDESC TDBQOSTRDESC
CONSTANT: RDBQONUMASC  TDBQONUMASC
CONSTANT: RDBQONUMDESC TDBQONUMDESC

FUNCTION: bool tcrdbtblput ( TCRDB* rdb, void* pkbuf, int pksiz, TCMAP* cols )
FUNCTION: bool tcrdbtblputkeep ( TCRDB* rdb, void* pkbuf, int pksiz, TCMAP* cols )
FUNCTION: bool tcrdbtblputcat ( TCRDB* rdb, void* pkbuf, int pksiz, TCMAP* cols )
FUNCTION: bool tcrdbtblout ( TCRDB* rdb, void* pkbuf, int pksiz )
FUNCTION: TCMAP* tcrdbtblget ( TCRDB* rdb, void* pkbuf, int pksiz )
FUNCTION: bool tcrdbtblsetindex ( TCRDB* rdb, c-string name, int type )
FUNCTION: longlong tcrdbtblgenuid ( TCRDB* rdb )
FUNCTION: RDBQRY* tcrdbqrynew ( TCRDB* rdb )
FUNCTION: void tcrdbqrydel ( RDBQRY* qry )
FUNCTION: void tcrdbqryaddcond ( RDBQRY* qry, c-string name, int op, c-string expr )
FUNCTION: void tcrdbqrysetorder ( RDBQRY* qry, c-string name, int type )
FUNCTION: void tcrdbqrysetlimit ( RDBQRY* qry, int max, int skip )
FUNCTION: TCLIST* tcrdbqrysearch ( RDBQRY* qry )
FUNCTION: bool tcrdbqrysearchout ( RDBQRY* qry )
FUNCTION: TCLIST* tcrdbqrysearchget ( RDBQRY* qry )
FUNCTION: TCMAP* tcrdbqryrescols ( TCLIST* res, int index )
FUNCTION: int tcrdbqrysearchcount ( RDBQRY* qry )

FUNCTION: void tcrdbsetecode ( TCRDB* rdb, int ecode )
