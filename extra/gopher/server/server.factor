! Copyright (C) 2016 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors calendar combinators combinators.short-circuit
command-line formatting io io.directories io.encodings.binary
io.encodings.string io.encodings.utf8 io.files io.files.info
io.files.types io.pathnames io.servers kernel math mime.types
namespaces sequences sorting splitting strings urls.encoding ;

IN: gopher.server

TUPLE: gopher-server < threaded-server
    { serving-hostname string }
    { serving-directory string } ;

<PRIVATE

: send-file ( path -- )
    binary [ [ write ] each-block ] with-file-reader ;

: gopher-type ( entry -- type )
    dup type>> {
        { +directory+ [ drop "1" ] }
        { +regular-file+ [
            name>> mime-type {
                { [ dup "text/" head? ] [ drop "0" ] }
                { [ dup "image/gif" = ] [ drop "g" ] }
                { [ dup "image/" head? ] [ drop "I" ] }
                [ drop "9" ]
            } cond ] }
        [ 2drop f ]
    } case ;

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
        [ "/" ] when-empty
        "i[%s]\t\terror.host\t1\r\n\r\n" sprintf
        utf8 encode write
    ] [
        [
            ".." swap parent-directory
            server serving-hostname>>
            server insecure>>
            "1%-69s\t%s\t%s\t%d\r\n" sprintf
            utf8 encode write
        ] unless-empty
    ] bi

    path [
        [ name>> "." head? ] reject
        [ { [ directory? ] [ regular-file? ] } 1|| ] filter
        [ name>> ] sort-by
        [
            [ gopher-type ] [ name>> ] [ directory? [ "/" append ] when ] tri
            [
                dup file-info [ file-modified ] [ file-size ] bi
                "%-40s %s %10s" sprintf
            ] [
                path prepend-path
                server serving-directory>> ?head drop
                url-encode
            ] bi
            server serving-hostname>>
            server insecure>>
            "%s%s\t%s\t%s\t%d\r\n" sprintf
            utf8 encode write
        ] each
    ] with-directory-entries ;

: send-directory ( server path -- )
    dup ".gophermap" append-path [
        send-file 2drop
    ] [
        drop dup ".gopherhead" append-path
        [ send-file ] when-file-exists
        list-directory
    ] if-file-exists ;

: read-gopher-path ( -- path )
    readln dup [ "\t\r\n" member? ] find drop [ head ] when*
    trim-tail-separators url-decode ;

M: gopher-server handle-client*
    dup serving-directory>> read-gopher-path append-path
    dup file-info type>> {
        { +directory+ [ send-directory ] }
        { +regular-file+ [ nip send-file ] }
        [ 3drop ]
    } case flush ;

PRIVATE>

: <gopher-server> ( directory port -- server )
    utf8 gopher-server new-threaded-server
        swap >>insecure
        "localhost" >>serving-hostname
        swap resolve-symlinks >>serving-directory
        "gopher.server" >>name
        binary >>encoding
        5 minutes >>timeout ;

: start-gopher-server ( directory port -- server )
    <gopher-server> start-server ;

: gopher-server-main ( -- )
    command-line get ?first "." or
    70 <gopher-server> start-server wait-for-server ;

MAIN: gopher-server-main
