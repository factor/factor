! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes.singleton combinators continuations
io io.encodings.binary io.encodings.ascii io.files io.sockets
kernel math math.parser sequences splitting namespaces strings ;
IN: ftp.client

TUPLE: ftp-client host port stream user password mode ;
TUPLE: ftp-response n strings ;

SINGLETON: active
SINGLETON: passive

: <ftp-response> ( -- ftp-response )
    ftp-response new
        V{ } clone >>strings ;

: <ftp-client> ( host -- ftp-client )
    ftp-client new
        swap >>host
        21 >>port
        "anonymous" >>user
        "factor-ftp@factorcode.org" >>password ;

: add-response-line ( ftp-response string -- ftp-response )
    over strings>> push ;

: (ftp-response-code) ( str -- n )
    3 head string>number ;

: ftp-response-code ( string -- n/f )
    dup fourth CHAR: - = [ drop f ] [ (ftp-response-code) ] if ;

: last-code ( ftp-response -- n )
    strings>> peek (ftp-response-code) ;

: read-response-until ( stream ftp-response n -- ftp-response )
    >r over stream-readln
    [ add-response-line ] [ ftp-response-code ] bi
    r> tuck = [ drop nip ] [ read-response-until ] if ;

: read-response ( stream -- ftp-response )
    <ftp-response>
    over stream-readln
    [ add-response-line ] [ fourth CHAR: - = ] bi
    [ dup last-code read-response-until ]
    [ nip ] if dup last-code >>n ;

: ftp-read ( ftp-client -- ftp-response )
    stream>> read-response ;

: ftp-send ( str ftp-client -- )
    stream>>
    [ stream-write ]
    [ "\r\n" swap stream-write ]
    [ stream-flush ] tri ;

: ftp-command ( ftp-client string -- ftp-response )
    swap
    [ ftp-send ] [ ftp-read ] bi ;

: ftp-user ( ftp-client -- ftp-response )
    dup user>> "USER " prepend ftp-command ;

: ftp-password ( ftp-client -- ftp-response )
    dup password>> "PASS " prepend ftp-command ;

: ftp-set-binary ( ftp-client -- ftp-response ) "TYPE I" ftp-command ;

: ftp-pwd ( ftp-client -- ftp-response )
    "PWD" ftp-command ;

: ftp-list ( ftp-client -- ftp-response )
    "LIST" ftp-command ;

: ftp-quit ( ftp-client -- ftp-response )
    "QUIT" ftp-command ;

: ftp-cwd ( ftp-client directory -- ftp-response )
    "CWD " prepend ftp-command ;

: ftp-retr ( ftp-client filename -- ftp-response )
    "RETR " prepend ftp-command ;

: parse-epsv ( ftp-response -- port )
    strings>> first
    "|" split 2 tail* first string>number ;

: ftp-epsv ( ftp-client -- ftp-response ) "EPSV" ftp-command ;

M: ftp-client dispose ( ftp-client -- )
    [ "QUIT" ftp-command drop ] [ stream>> dispose ] bi ;

ERROR: ftp-error got expected ;
: ftp-assert ( ftp-response n -- )
    2dup >r n>> r> = [ 2drop ] [ ftp-error ] if ;

: ftp-connect ( ftp-client -- )
    dup
    [ host>> ] [ port>> ] bi <inet> ascii <client>
    >>stream drop ;

: ftp-login ( ftp-client -- )
    {
        [ ftp-connect ]
        [ ftp-read 220 ftp-assert ]
        [ ftp-user 331 ftp-assert ]
        [ ftp-password 230 ftp-assert ]
        [ ftp-set-binary 200 ftp-assert ]
    } cleave ;

: list ( ftp-client -- ftp-response )
    dup ftp-epsv dup 229 ftp-assert
    >r dup host>> r> parse-epsv <inet> ascii <client>
    over ftp-list 150 ftp-assert
    lines <ftp-response> swap >>strings
    >r ftp-read 226 ftp-assert r> ;

: ftp-get ( ftp-client filename -- ftp-response )
    over ftp-epsv dup 229 ftp-assert
    pick host>> swap parse-epsv <inet> binary <client>
    swap tuck
    [ dupd ftp-retr 150 ftp-assert ]
    [ binary <file-writer> stream-copy ] 2bi*
    ftp-read dup 226 ftp-assert ;

GENERIC# ftp-download 1 ( obj path -- )

M: ftp-client ftp-download ( ftp-client path -- )
    >r dup ftp-login r>
    [ parent-directory ftp-cwd drop ]
    [ file-name ftp-get drop ]
    [ drop dispose ] 2tri ;

M: string ftp-download ( string path -- )
    >r <ftp-client> r> ftp-download ;
