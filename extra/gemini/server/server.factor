! Copyright (C) 2021 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors calendar combinators combinators.short-circuit
command-line formatting io io.directories io.encodings.binary
io.encodings.string io.encodings.utf8 io.files io.files.info
io.files.types io.pathnames io.servers io.sockets.secure kernel
math mime.types namespaces sequences sorting splitting strings
urls urls.encoding ;

IN: gemini.server

TUPLE: gemini-server < threaded-server
    { serving-directory string } ;

<PRIVATE

: send-file ( path -- )
    binary [ [ write ] each-block ] with-file-reader ;

: write-utf8 ( string -- )
    utf8 encode write ;

: send-status ( path file-info -- )
    type>> {
        { +directory+ [ drop "text/gemini" ] }
        { +regular-file+ [ mime-type ] }
        [ 2drop f ]
    } case "application/octet-stream" or
    "20 %s\r\n" sprintf write-utf8 ;

: file-modified ( entry -- string )
    modified>> "%Y-%b-%d %H:%M" strftime ;

: file-size ( entry -- string )
    dup directory? [
        drop "-  "
    ] [
        size>> {
            { [ dup 40 2^ >= ] [ 40 2^ /f "TB" ] }
            { [ dup 30 2^ >= ] [ 30 2^ /f "GB" ] }
            { [ dup 20 2^ >= ] [ 20 2^ /f "MB" ] }
            [ 10 2^ /f "KB" ]
        } cond "%.1f %s" sprintf
    ] if ;

:: list-directory ( server path -- )
    path server serving-directory>> ?head drop [
        "# [%s]\r\n\r\n" sprintf write-utf8
    ] [
        dup "/" = [ drop ] [
            parent-directory ".."
            "=> %s %-69s\r\n" sprintf
            write-utf8
        ] if
    ] bi

    path [
        [ name>> "." head? ] reject
        [ { [ directory? ] [ regular-file? ] } 1|| ] filter
        [ name>> ] sort-by
        [
            [ name>> ] [ directory? [ "/" append ] when ] bi
            [
                url-encode
            ] [
                dup file-info [ file-modified ] [ file-size ] bi
                "%-40s %s %10s" sprintf
            ] bi
            "=> %s %s\r\n" sprintf
            write-utf8
        ] each
    ] with-directory-entries ;

: send-directory ( server path -- )
    dup ".geminimap" append-path [
        send-file 2drop
    ] [
        drop dup ".geminihead" append-path
        [ send-file ] when-file-exists
        list-directory
    ] if-file-exists ;

: read-gemini-path ( -- path )
    readln utf8 decode "\r" ?tail drop >url path>> ;

M: gemini-server handle-client*
    dup serving-directory>> read-gemini-path append
    dup file-info [ send-status ] 2keep type>> {
        { +directory+ [ send-directory ] }
        { +regular-file+ [ nip send-file ] }
        [ 3drop ]
    } case flush ;

PRIVATE>

: <gemini-secure-config> ( -- secure-config )
    <secure-config>
        "key-file" get absolute-path >>key-file
        "dh-file" get absolute-path >>dh-file
        "key-password" get >>password ;

: <gemini-server> ( directory port -- server )
    utf8 gemini-server new-threaded-server
        <gemini-secure-config> >>secure-config
        f >>insecure
        swap >>secure
        swap resolve-symlinks >>serving-directory
        "gemini.server" >>name
        binary >>encoding
        5 minutes >>timeout ;

: gemini-server-main ( -- )
    command-line get ?first "." or
    1965 <gemini-server> start-server wait-for-server ;

MAIN: gemini-server-main

! ./factor -key-file=cert.pem -dh-file=dh2048.pem -key-password=password -run=gemini.server
