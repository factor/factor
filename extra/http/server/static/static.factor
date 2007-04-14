! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar html io io.files kernel math math.parser http
http.server namespaces parser sequences strings assocs
hashtables debugger http.mime sorting html.elements logging
calendar.format accessors io.encodings.binary
combinators.cleave fry ;
IN: http.server.static

! special maps mime types to quots with effect ( path -- )
TUPLE: file-responder root hook special ;

: file-http-date ( filename -- string )
    file-info file-info-modified timestamp>http-string ;

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
        swap
        [ file-info file-info-size "content-length" set-header ]
        [ file-http-date "last-modified" set-header ]
        [ '[ , binary <file-reader> stdio get stream-copy ] >>body ]
        tri
    ] <file-responder> ;

: serve-static ( filename mime-type -- response )
    over last-modified-matches?
    [ 2drop <304> ] [ file-responder get hook>> call ] if ;

: serving-path ( filename -- filename )
    file-responder get root>> right-trim-separators
    "/"
    rot "" or left-trim-separators 3append ;

: serve-file ( filename -- response )
    dup mime-type
    dup file-responder get special>> at
    [ call ] [ serve-static ] ?if ;

\ serve-file NOTICE add-input-logging

: file. ( name dirp -- )
    [ "/" append ] when
    dup <a =href a> write </a> ;

: directory. ( path -- )
    dup file-name [
        [ <h1> file-name write </h1> ]
        [
            <ul>
                directory sort-keys
                [ <li> file. </li> ] assoc-each
            </ul>
        ] bi
    ] simple-html-document ;

: list-directory ( directory -- response )
    "text/html" <content>
    swap '[ , directory. ] >>body ;

: find-index ( filename -- path )
    { "index.html" "index.fhtml" } [ append-path ] with map
    [ exists? ] find nip ;

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

M: file-responder call-responder ( path responder -- response )
    file-responder set
    dup [
        ".." over subseq? [
            drop <400>
        ] [
            serve-object
        ] if
    ] [
        drop redirect-with-/
    ] if ;
