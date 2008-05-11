! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators continuations io io.encodings.binary
io.encodings.ascii io.files io.sockets kernel math
math.parser sequences splitting namespaces ;
IN: ftp.client

TUPLE: ftp-client host port stream user password ;
TUPLE: ftp-response n strings ;

: <ftp-response> ( -- ftp-response )
    ftp-response new
        V{ } clone >>strings ;

: <ftp-client> ( host -- ftp-client )
    ftp-client new
        swap >>host
        21 >>port
        "anonymous" >>user
        "lol@test.com" >>password ;

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

: ftp-command ( ftp-client string -- n )
    swap
    [ ftp-send ] [ ftp-read ] bi ;

: ftp-user ( ftp-client -- n ) dup user>> "USER " prepend ftp-command ;
: ftp-password ( ftp-client -- n ) dup password>> "PASS " prepend ftp-command ;
: ftp-set-binary ( ftp-client -- n ) "TYPE I" ftp-command ;
! : ftp-set-ascii ( ftp-client -- n ) "TYPE A" ftp-command ;
: ftp-system ( ftp-client -- n ) "SYST" ftp-command ;
: ftp-features ( ftp-client -- n ) "FEAT" ftp-command ;
: ftp-pwd ( ftp-client -- n ) "PWD" ftp-command ;
: ftp-list ( ftp-client -- n ) "LIST" ftp-command ;
: ftp-quit ( ftp-client -- n ) "QUIT" ftp-command ;
: ftp-cwd ( ftp-client directory -- n ) "CWD " prepend ftp-command ;
: ftp-retr ( ftp-client filename -- n ) "RETR " prepend ftp-command ;

: parse-epsv ( ftp-response -- port )
    strings>> first
    "|" split 2 tail* first string>number ;

: ftp-epsv ( ftp-client -- n ) "EPSV" ftp-command ;

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
