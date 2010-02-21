! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data alien.syntax combinators
continuations io.encodings.string io.encodings.utf8 kernel
sequences strings calendar system accessors unix unix.time
unix.ffi calendar.unix vocabs.loader classes.struct ;
IN: unix.utmpx

CONSTANT: EMPTY 0
CONSTANT: RUN_LVL 1
CONSTANT: BOOT_TIME 2
CONSTANT: OLD_TIME 3
CONSTANT: NEW_TIME 4
CONSTANT: INIT_PROCESS 5
CONSTANT: LOGIN_PROCESS 6
CONSTANT: USER_PROCESS 7
CONSTANT: DEAD_PROCESS 8
CONSTANT: ACCOUNTING 9
CONSTANT: SIGNATURE 10
CONSTANT: SHUTDOWN_TIME 11

C-TYPE: utmpx

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
    memory>byte-array utf8 decode [ 0 = ] trim-tail ;

M: unix new-utmpx-record
    utmpx-record new ;
    
M: unix utmpx>utmpx-record ( utmpx -- utmpx-record )
    [ new-utmpx-record ] dip \ utmpx memory>struct
    {
        [ ut_user>> _UTX_USERSIZE memory>string >>user ]
        [ ut_id>>   _UTX_IDSIZE memory>string >>id ]
        [ ut_line>> _UTX_LINESIZE memory>string >>line ]
        [ ut_pid>>  >>pid ]
        [ ut_type>> >>type ]
        [ ut_tv>>   timeval>unix-time >>timestamp ]
        [ ut_host>> _UTX_HOSTSIZE memory>string >>host ]
    } cleave ;

: with-utmpx ( quot -- )
    setutxent [ endutxent ] [ ] cleanup ; inline

: all-utmpx ( -- seq )
    [
        [ getutxent dup ]
        [ utmpx>utmpx-record ]
        produce nip
    ] with-utmpx ;
    
os {
    { macosx [ "unix.utmpx.macosx" require ] }
    { netbsd [ "unix.utmpx.netbsd" require ] }
} case
