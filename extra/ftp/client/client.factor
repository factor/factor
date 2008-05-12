! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.singleton combinators
continuations io io.encodings.binary io.encodings.ascii
io.files io.sockets kernel math math.parser sequences
splitting namespaces strings ;
IN: ftp.client

TUPLE: ftp-client host port stream user password mode ;
TUPLE: ftp-response n strings parsed ;

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

: ftp-command ( string ftp-client -- ftp-response )
    [ ftp-send ] [ ftp-read ] bi ;

: ftp-user ( ftp-client -- ftp-response )
    [ user>> "USER " prepend ] [ ftp-command ] bi ;

: ftp-password ( ftp-client -- ftp-response )
    [ password>> "PASS " prepend ] [ ftp-command ] bi ;

: ftp-set-binary ( ftp-client -- ftp-response )
    >r "TYPE I" r> ftp-command ;

: ftp-pwd ( ftp-client -- ftp-response )
    >r "PWD" r> ftp-command ;

: ftp-list ( ftp-client -- ftp-response )
    >r "LIST" r> ftp-command ;

: ftp-quit ( ftp-client -- ftp-response )
    >r "QUIT" r> ftp-command ;

: ftp-cwd ( directory ftp-client -- ftp-response )
    >r "CWD " prepend r> ftp-command ;

: ftp-retr ( filename ftp-client -- ftp-response )
    >r "RETR " prepend r> ftp-command ;

: parse-epsv ( ftp-response -- port )
    strings>> first
    "|" split 2 tail* first string>number ;

: ch>attribute ( ch -- symbol )
    {
        { CHAR: d [ +directory+ ] }
        { CHAR: l [ +symbolic-link+ ] }
        { CHAR: - [ +regular-file+ ] }
        [ drop +unknown+ ]
    } case ;

TUPLE: remote-file
    type permissions links owner group size month day time year name ;

: <remote-file> ( -- remote-file ) remote-file new ;

: parse-permissions ( remote-file str -- remote-file )
    [ first ch>attribute >>type ] [ rest >>permissions ] bi ;

: parse-list-9 ( lines -- seq )
    [
        <remote-file> swap {
            [ 0 swap nth parse-permissions ]
            [ 1 swap nth string>number >>links ]
            [ 2 swap nth >>owner ]
            [ 3 swap nth >>group ]
            [ 4 swap nth string>number >>size ]
            [ 5 swap nth >>month ]
            [ 6 swap nth >>day ]
            [ 7 swap nth >>time ]
            [ 8 swap nth >>name ]
        } cleave
    ] map ;

: parse-list-8 ( lines -- seq )
    [
        <remote-file> swap {
            [ 0 swap nth parse-permissions ]
            [ 1 swap nth string>number >>links ]
            [ 2 swap nth >>owner ]
            [ 3 swap nth >>size ]
            [ 4 swap nth >>month ]
            [ 5 swap nth >>day ]
            [ 6 swap nth >>time ]
            [ 7 swap nth >>name ]
        } cleave
    ] map ;

: parse-list-3 ( lines -- seq )
    [
        <remote-file> swap {
            [ 0 swap nth parse-permissions ]
            [ 1 swap nth string>number >>links ]
            [ 2 swap nth >>name ]
        } cleave
    ] map ;

: parse-list ( ftp-response -- ftp-response )
    dup strings>>
    [ " " split [ empty? not ] filter ] map
    dup length {
        { 9 [ parse-list-9 ] }
        { 8 [ parse-list-8 ] }
        { 3 [ parse-list-3 ] }
        [ drop ]
    } case >>parsed ;

: ftp-epsv ( ftp-client -- ftp-response )
    >r "EPSV" r> ftp-command ;

M: ftp-client dispose ( ftp-client -- )
    [ ftp-quit drop ] [ stream>> dispose ] bi ;

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

: start-2nd ( ftp-client -- port )
    ftp-epsv [ 229 ftp-assert ] [ parse-epsv ] bi ;

: list ( ftp-client -- ftp-response )
    dup [ host>> ] [ start-2nd ] bi <inet> ascii <client>
    over ftp-list 150 ftp-assert
    lines <ftp-response> swap >>strings
    >r ftp-read 226 ftp-assert r>
    parse-list ;

: ftp-get ( filename ftp-client -- ftp-response )
    dup [ host>> ] [ start-2nd ] bi <inet> binary <client>
    rot tuck
    [ over ftp-retr 150 ftp-assert ]
    [ binary <file-writer> stream-copy ] 2bi*
    ftp-read dup 226 ftp-assert ;

GENERIC: ftp-download ( path obj -- )

M: ftp-client ftp-download ( path ftp-client -- )
    dup ftp-login
    [ >r parent-directory r> ftp-cwd drop ]
    [ >r file-name r> ftp-get drop ]
    [ dispose drop ] 2tri ;

M: string ftp-download ( path string -- )
    <ftp-client> ftp-download ;
