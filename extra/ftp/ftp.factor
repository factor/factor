! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators io io.files kernel
math.parser sequences strings ;
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


: ch>type ( ch -- type )
    {
        { CHAR: d [ +directory+ ] }
        { CHAR: l [ +symbolic-link+ ] }
        { CHAR: - [ +regular-file+ ] }
        [ drop +unknown+ ]
    } case ;

: type>ch ( type -- string )
    {   
        { +directory+ [ CHAR: d ] }
        { +symbolic-link+ [ CHAR: l ] }
        { +regular-file+ [ CHAR: - ] }
        [ drop CHAR: - ]
    } case ;

: file-info>string ( file-info name -- string )
    >r [ [ type>> type>ch 1string ] [ drop "rwx------" append ] bi ]
    [ size>> number>string 15 CHAR: \s pad-left ] bi r>
    3array " " join ;

: directory-list ( -- seq )
    "" directory keys
    [ [ link-info ] keep file-info>string ] map ;
