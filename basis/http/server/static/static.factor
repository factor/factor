! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar kernel math math.order math.parser namespaces
parser sequences strings assocs hashtables debugger mime.types
sorting logging calendar.format accessors splitting io io.files
io.files.info io.directories io.pathnames io.encodings.binary
fry xml.entities destructors urls html.elements
html.templates.fhtml http http.server http.server.responses
http.server.redirection ;
IN: http.server.static

TUPLE: file-responder root hook special allow-listings ;

: modified-since ( request -- date )
    "if-modified-since" header ";" split1 drop
    dup [ rfc822>timestamp ] when ;

: modified-since? ( filename -- ? )
    request get modified-since dup [
        [ file-info modified>> ] dip after?
    ] [
        2drop t
    ] if ;

: <file-responder> ( root hook -- responder )
    file-responder new
        swap >>hook
        swap >>root
        H{ } clone >>special ;

: (serve-static) ( path mime-type -- response )
    [
        [ binary <file-reader> &dispose ] dip
        <content> binary >>content-charset
    ]
    [ drop file-info [ size>> ] [ modified>> ] bi ] 2bi
    [ "content-length" set-header ]
    [ "last-modified" set-header ] bi* ;

: <static> ( root -- responder )
    [ (serve-static) ] <file-responder> ;

: serve-static ( filename mime-type -- response )
    over modified-since?
    [ file-responder get hook>> call ] [ 2drop <304> ] if ;

: serving-path ( filename -- filename )
    file-responder get root>> trim-right-separators
    "/"
    rot "" or trim-left-separators 3append ;

: serve-file ( filename -- response )
    dup mime-type
    dup file-responder get special>> at
    [ call ] [ serve-static ] ?if ;

\ serve-file NOTICE add-input-logging

: file. ( name -- )
    dup link-info directory? [ "/" append ] when
    dup <a =href a> escape-string write </a> ;

: directory. ( path -- )
    dup file-name [ ] [
        [ <h1> file-name escape-string write </h1> ]
        [
            <ul>
                directory-files [ <li> file. </li> ] each
            </ul>
        ] bi
    ] simple-page ;

: list-directory ( directory -- response )
    file-responder get allow-listings>> [
        '[ _ directory. ] "text/html" <content>
    ] [
        drop <403>
    ] if ;

: find-index ( filename -- path )
    "index.html" append-path dup exists? [ drop f ] unless ;

: serve-directory ( filename -- response )
    url get path>> "/" tail? [
        dup
        find-index [ serve-file ] [ list-directory ] ?if
    ] [
        drop
        url get clone [ "/" append ] change-path <permanent-redirect>
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
    [ <fhtml> "text/html" <content> ]
    "application/x-factor-server-page"
    pick special>> set-at ;
