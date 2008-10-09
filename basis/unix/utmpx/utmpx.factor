! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax combinators continuations
io.encodings.string io.encodings.utf8 kernel sequences strings
unix calendar system accessors unix.time calendar.unix
vocabs.loader ;
IN: unix.utmpx

: EMPTY 0 ; inline
: RUN_LVL 1 ; inline
: BOOT_TIME 2 ; inline
: OLD_TIME 3 ; inline
: NEW_TIME 4 ; inline
: INIT_PROCESS 5 ; inline
: LOGIN_PROCESS 6 ; inline
: USER_PROCESS 7 ; inline
: DEAD_PROCESS 8 ; inline
: ACCOUNTING 9 ; inline
: SIGNATURE 10 ; inline
: SHUTDOWN_TIME 11 ; inline

FUNCTION: void setutxent ( ) ;
FUNCTION: void endutxent ( ) ;
FUNCTION: utmpx* getutxent ( ) ;
FUNCTION: utmpx* getutxid ( utmpx* id ) ;
FUNCTION: utmpx* getutxline ( utmpx* line ) ;
FUNCTION: utmpx* pututxline ( utmpx* utx ) ;

TUPLE: utmpx-record user id line pid type timestamp host ;

HOOK: new-utmpx-record os ( -- utmpx-record )

HOOK: utmpx>utmpx-record os ( utmpx -- utmpx-record )

: memory>string ( alien n -- string )
    memory>byte-array utf8 decode [ 0 = ] trim-right ;

M: unix new-utmpx-record
    utmpx-record new ;
    
M: unix utmpx>utmpx-record ( utmpx -- utmpx-record )
    [ new-utmpx-record ] dip
    {
        [ utmpx-ut_user _UTX_USERSIZE memory>string >>user ]
        [ utmpx-ut_id _UTX_IDSIZE memory>string >>id ]
        [ utmpx-ut_line _UTX_LINESIZE memory>string >>line ]
        [ utmpx-ut_pid >>pid ]
        [ utmpx-ut_type >>type ]
        [ utmpx-ut_tv timeval>unix-time >>timestamp ]
        [ utmpx-ut_host _UTX_HOSTSIZE memory>string >>host ]
    } cleave ;

: with-utmpx ( quot -- )
    setutxent [ endutxent ] [ ] cleanup ; inline

: all-utmpx ( -- seq )
    [
        [ getutxent dup ]
        [ utmpx>utmpx-record ]
        [ drop ] produce
    ] with-utmpx ;
    
os {
    { macosx [ "unix.utmpx.macosx" require ] }
    { netbsd [ "unix.utmpx.netbsd" require ] }
} case
