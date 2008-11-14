! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators io io.files kernel
math.parser sequences strings ls ;
IN: ftp

SINGLETON: active
SINGLETON: passive

TUPLE: ftp-client host port user password mode state
command-promise ;

: <ftp-client> ( host -- ftp-client )
    ftp-client new
        swap >>host
        21 >>port
        "anonymous" >>user
        "ftp@my.org" >>password ;

: reset-ftp-client ( ftp-client -- )
    f >>user
    f >>password
    drop ;

TUPLE: ftp-response n strings parsed ;

: <ftp-response> ( -- ftp-response )
    ftp-response new
        V{ } clone >>strings ;

: add-response-line ( ftp-response string -- ftp-response )
    over strings>> push ;

: ftp-send ( string -- ) write "\r\n" write flush ;
: ftp-ipv4 1 ; inline
: ftp-ipv6 2 ; inline

: directory-list ( -- seq ) "" ls ;
