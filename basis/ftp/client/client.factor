! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.singleton combinators
continuations io io.encodings.binary io.encodings.utf8
io.files io.pathnames io.sockets kernel io.streams.duplex math
math.parser sequences splitting namespaces strings fry ftp
ftp.client.listing-parser urls ;
IN: ftp.client

: (ftp-response-code) ( str -- n )
    3 head string>number ;

: ftp-response-code ( string -- n/f )
    dup fourth CHAR: - = [ drop f ] [ (ftp-response-code) ] if ;

: read-response-loop ( ftp-response -- ftp-response )
    readln
    [ add-response-line ] [ ftp-response-code ] bi
    over n>> = [ read-response-loop ] unless ;

: read-response ( -- ftp-response )
    <ftp-response> readln
    [ (ftp-response-code) >>n ]
    [ add-response-line ]
    [ fourth CHAR: - = ] tri
    [ read-response-loop ] when ;

ERROR: ftp-error got expected ;

: ftp-assert ( ftp-response n -- )
    2dup [ n>> ] dip = [ 2drop ] [ ftp-error ] if ;

: ftp-command ( string -- ftp-response )
    ftp-send read-response ;

: ftp-user ( url -- ftp-response )
    username>> "USER " prepend ftp-command ;

: ftp-password ( url -- ftp-response )
    password>> "PASS " prepend ftp-command ;

: ftp-cwd ( directory -- ftp-response )
    "CWD " prepend ftp-command ;

: ftp-retr ( filename -- ftp-response )
    "RETR " prepend ftp-command ;

: ftp-set-binary ( -- ftp-response ) "TYPE I" ftp-command ;

: ftp-pwd ( -- ftp-response ) "PWD" ftp-command ;

: ftp-list ( -- )
    "LIST" ftp-command 150 ftp-assert ;

: ftp-quit ( -- ftp-response ) "QUIT" ftp-command ;

: ftp-epsv ( -- ftp-response )
    "EPSV" ftp-command dup 229 ftp-assert ;

: parse-epsv ( ftp-response -- port )
    strings>> first "|" split 2 tail* first string>number ;

: open-passive-client ( url protocol -- stream )
    [ host>> ftp-epsv parse-epsv <inet> ] dip <client> drop ;

: list ( url -- ftp-response )
    utf8 open-passive-client
    ftp-list
    stream-lines
    <ftp-response> swap >>strings
    read-response 226 ftp-assert
    parse-list ;

: (ftp-get) ( url path -- )
    [ binary open-passive-client ] dip
    [ ftp-retr 150 ftp-assert drop ]
    [ binary <file-writer> stream-copy ] 2bi
    read-response 226 ftp-assert ;

: ftp-login ( url -- )
    read-response 220 ftp-assert
    [ ftp-user 331 ftp-assert ]
    [ ftp-password 230 ftp-assert ] bi
    ftp-set-binary 200 ftp-assert ;

: ftp-connect ( url -- stream )
    [ host>> ] [ port>> ] bi <inet> utf8 <client> drop ;

: with-ftp-client ( url quot -- )
    [ [ ftp-connect ] keep ] dip
    '[ _ [ ftp-login ] _ bi ftp-quit drop ] with-stream ; inline

: ensure-login ( url -- url )
    dup username>> [
        "anonymous" >>username
        "ftp-client@factorcode.org" >>password
    ] unless ;

: >ftp-url ( url -- url' ) >url ensure-port ensure-login ;

: ftp-get ( url -- )
    >ftp-url [
        dup path>>
        [ nip parent-directory ftp-cwd drop ]
        [ file-name (ftp-get) ] 2bi
    ] with-ftp-client ;
