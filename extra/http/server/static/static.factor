! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar html io io.files kernel math math.parser http
http.server namespaces parser sequences strings assocs
hashtables debugger http.mime sorting html.elements logging
calendar.format new-slots accessors ;
IN: http.server.static

SYMBOL: responder

! special maps mime types to quots with effect ( path -- )
TUPLE: file-responder root hook special ;

: unix-time>timestamp ( n -- timestamp )
    >r unix-1970 r> seconds time+ ;

: file-http-date ( filename -- string )
    file-modified unix-time>timestamp timestamp>http-string ;

: last-modified-matches? ( filename -- ? )
    file-http-date dup [
        request get "if-modified-since" header =
    ] when ;

: <304> ( -- response )
    304 "Not modified" <trivial-response> ;

: <file-responder> ( root hook -- responder )
    H{ } clone file-responder construct-boa ;

: <static> ( root -- responder )
    [
        <content>
        over file-length "content-length" set-header
        over file-http-date "last-modified" set-header
        swap [ <file-reader> stdio get stream-copy ] curry >>body
    ] <file-responder> ;

: serve-static ( filename mime-type -- response )
    over last-modified-matches?
    [ 2drop <304> ] [ responder get hook>> call ] if ;

: serving-path ( filename -- filename )
    "" or responder get root>> swap path+ ;

: serve-file ( filename -- response )
    dup mime-type
    dup responder get special>> at
    [ call ] [ serve-static ] ?if ;

\ serve-file NOTICE add-input-logging

: file. ( name dirp -- )
    [ "/" append ] when
    dup <a =href a> write </a> ;

: directory. ( path -- )
    dup file-name [
        <h1> dup file-name write </h1>
        <ul>
            directory sort-keys
            [ <li> file. </li> ] assoc-each
        </ul>
    ] simple-html-document ;

: list-directory ( directory -- response )
    "text/html" <content>
    swap [ directory. ] curry >>body ;

: find-index ( filename -- path )
    { "index.html" "index.fhtml" }
    [ dupd path+ exists? ] find nip
    dup [ path+ ] [ nip ] if ;

: serve-directory ( filename -- response )
    dup "/" tail? [
        dup find-index
        [ serve-file ] [ list-directory ] ?if
    ] [
        drop request get redirect-with-/
    ] if ;

: serve-object ( filename -- response )
    serving-path dup exists? [
        dup directory? [ serve-directory ] [ serve-file ] if
    ] [
        drop <404>
    ] if ;

: <400> 400 "Bad request" <trivial-response> ;

M: file-responder call-responder ( request path responder -- response )
    over [
        ".." pick subseq? [
            3drop <400>
        ] [
            responder set
            swap request set
            serve-object
        ] if
    ] [
        2drop redirect-with-/
    ] if ;
