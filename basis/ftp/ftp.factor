! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors io io.crlf kernel sequences ;
IN: ftp

SYMBOLS: +active+ +passive+ ;

TUPLE: ftp-response n strings parsed ;

: <ftp-response> ( -- ftp-response )
    ftp-response new
        V{ } clone >>strings ;

: add-response-line ( ftp-response string -- ftp-response )
    over strings>> push ;

: ftp-send ( string -- ) write crlf flush ;
