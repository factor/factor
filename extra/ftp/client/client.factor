! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.singleton combinators
continuations io io.encodings.binary io.encodings.ascii
io.files io.sockets kernel io.streams.duplex math
math.parser sequences splitting namespaces strings fry ftp ;
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

: ftp-command ( string -- ftp-response )
    ftp-send read-response ;


: ftp-user ( ftp-client -- ftp-response )
    user>> "USER " prepend ftp-command ;

: ftp-password ( ftp-client -- ftp-response )
    password>> "PASS " prepend ftp-command ;

: ftp-set-binary ( -- ftp-response )
    "TYPE I" ftp-command ;

: ftp-pwd ( -- ftp-response )
    "PWD" ftp-command ;

: ftp-list ( -- ftp-response )
    "LIST" ftp-command ;

: ftp-quit ( -- ftp-response )
    "QUIT" ftp-command ;

: ftp-cwd ( directory -- ftp-response )
    "CWD " prepend ftp-command ;

: ftp-retr ( filename -- ftp-response )
    "RETR " prepend ftp-command ;

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

: ftp-epsv ( -- ftp-response )
    "EPSV" ftp-command ;

ERROR: ftp-error got expected ;
: ftp-assert ( ftp-response n -- )
    2dup >r n>> r> = [ 2drop ] [ ftp-error ] if ;

: ftp-login ( ftp-client -- )
    read-response 220 ftp-assert
    [ ftp-user 331 ftp-assert ]
    [ ftp-password 230 ftp-assert ] bi
    ftp-set-binary 200 ftp-assert ;

: open-remote-port ( -- port )
    ftp-epsv
    [ 229 ftp-assert ] [ parse-epsv ] bi ;

: list ( ftp-client -- ftp-response )
    host>> open-remote-port <inet> ascii <client>
    ftp-list 150 ftp-assert
    lines
    <ftp-response> swap >>strings
    read-response 226 ftp-assert
    parse-list ;

: ftp-get ( filename ftp-client -- ftp-response )
    host>> open-remote-port <inet> binary <client>
    swap
    [ ftp-retr 150 ftp-assert drop ]
    [ binary <file-writer> stream-copy ] 2bi
    read-response dup 226 ftp-assert ;

: ftp-connect ( ftp-client -- stream )
    [ host>> ] [ port>> ] bi <inet> ascii <client> ;

GENERIC: ftp-download ( path obj -- )

: with-ftp-client ( ftp-client quot -- )
    dupd '[
        , [ ftp-login ] [ @ ] bi
        ftp-quit drop
    ] >r ftp-connect r> with-stream ; inline

M: ftp-client ftp-download ( path ftp-client -- )
    [
        [ drop parent-directory ftp-cwd drop ]
        [ >r file-name r> ftp-get drop ] 2bi
    ] with-ftp-client ;

M: string ftp-download ( path string -- )
    <ftp-client> ftp-download ;
