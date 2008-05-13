! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io kernel math.parser sequences ;
IN: ftp

SINGLETON: active
SINGLETON: passive

TUPLE: ftp-client host port user password mode state ;

: <ftp-client> ( host -- ftp-client )
    ftp-client new
        swap >>host
        21 >>port
        "anonymous" >>user
        "ftp@my.org" >>password ;

TUPLE: ftp-response n strings parsed ;

: <ftp-response> ( -- ftp-response )
    ftp-response new
        V{ } clone >>strings ;

: add-response-line ( ftp-response string -- ftp-response )
    over strings>> push ;

: ftp-send ( string -- ) write "\r\n" write flush ;
