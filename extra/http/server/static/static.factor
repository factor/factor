! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar io io.files kernel math math.order
math.parser http http.server namespaces parser sequences strings
assocs hashtables debugger http.mime sorting html.elements
html.templates.fhtml logging calendar.format accessors
io.encodings.binary fry xml.entities destructors ;
IN: http.server.static

! special maps mime types to quots with effect ( path -- )
TUPLE: file-responder root hook special allow-listings ;

: modified-since? ( filename -- ? )
    request get "if-modified-since" header dup [
        [ file-info modified>> ] [ rfc822>timestamp ] bi* after?
    ] [
        2drop t
    ] if ;

: <304> ( -- response )
    304 "Not modified" <trivial-response> ;

: <403> ( -- response )
    403 "Forbidden" <trivial-response> ;

: <file-responder> ( root hook -- responder )
    file-responder new
        swap >>hook
        swap >>root
        H{ } clone >>special ;

: (serve-static) ( path mime-type -- response )
    [ [ binary <file-reader> &dispose ] dip <content> ]
    [ drop file-info [ size>> ] [ modified>> ] bi ] 2bi
    [ "content-length" set-header ]
    [ "last-modified" set-header ] bi* ;

: <static> ( root -- responder )
    [ (serve-static) ] <file-responder> ;

: serve-static ( filename mime-type -- response )
    over modified-since?
    [ file-responder get hook>> call ] [ 2drop <304> ] if ;

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
    dup <a =href a> escape-string write </a> ;

: directory. ( path -- )
    dup file-name [
        [ <h1> file-name escape-string write </h1> ]
        [
            <ul>
                directory sort-keys
                [ <li> file. </li> ] assoc-each
            </ul>
        ] bi
    ] simple-page ;

: list-directory ( directory -- response )
    file-responder get allow-listings>> [
        '[ , directory. ] <html-content>
    ] [
        drop <403>
    ] if ;

: find-index ( filename -- path )
    "index.html" append-path dup exists? [ drop f ] unless ;

: serve-directory ( filename -- response )
    request get path>> "/" tail? [
        dup
        find-index [ serve-file ] [ list-directory ] ?if
    ] [
        drop
        request get path>> "/" append f <standard-redirect>
    ] if ;

: serve-object ( filename -- response )
    serving-path dup exists?
    [ dup file-info directory? [ serve-directory ] [ serve-file ] if ]
    [ drop <404> ]
    if ;

M: file-responder call-responder* ( path responder -- response )
    file-responder set
    ".." over member?
    [ drop <400> ] [ "/" join serve-object ] if ;

! file responder integration
: enable-fhtml ( responder -- responder )
    [ <fhtml> <html-content> ]
    "application/x-factor-server-page"
    pick special>> set-at ;
