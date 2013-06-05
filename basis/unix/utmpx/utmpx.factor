! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data alien.syntax combinators
continuations io.encodings.string io.encodings.utf8 kernel
sequences strings calendar system accessors unix unix.time
unix.ffi calendar.unix vocabs classes.struct ;
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
    { linux [ "unix.utmpx.linux" require ] }
} case
