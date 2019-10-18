USING: alien alien.c-types kernel math sequences strings
io.unix.backend splitting ;
IN: hardware-info.linux

: (uname) ( buf -- int )
    "int" f "uname" { "char*" } alien-invoke ;

: uname ( -- seq )
    65536 "char" <c-array> [ (uname) io-error ] keep
    "\0" split [ empty? not ] subset [ >string ] map
    6 "" pad-right ;

: sysname ( -- string ) uname first ;
: nodename ( -- string ) uname second ;
: release ( -- string ) uname third ;
: version ( -- string ) uname fourth ;
: machine ( -- string ) uname 4 swap nth ;
: domainname ( -- string ) uname 5 swap nth ;

: kernel-version ( -- seq )
    release ".-" split [ ] subset 5 "" pad-right ;
