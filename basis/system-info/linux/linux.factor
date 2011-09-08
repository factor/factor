! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: unix alien alien.c-types kernel math sequences strings
io.backend.unix splitting io.encodings.utf8 io.encodings.string
specialized-arrays alien.syntax system-info ;
SPECIALIZED-ARRAY: char
IN: system-info.linux

FUNCTION-ALIAS: (uname)
    int uname ( c-string buf ) ;

: uname ( -- seq )
    65536 <char-array> [ (uname) io-error ] keep
    "\0" split harvest [ utf8 decode ] map
    6 "" pad-tail ;

: sysname ( -- string ) uname first ;
: nodename ( -- string ) uname second ;
: release ( -- string ) uname third ;
: version ( -- string ) uname fourth ;
: machine ( -- string ) uname 4 swap nth ;
: domainname ( -- string ) uname 5 swap nth ;

: kernel-version ( -- seq )
    release ".-" split harvest 5 "" pad-tail ;

M: linux os-version f ;