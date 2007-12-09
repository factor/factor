! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar html io io.files kernel math math.parser
http.server.responders http.server.templating namespaces parser
sequences strings assocs hashtables debugger http.mime sorting
html.elements ;

IN: webapps.file

: serving-path ( filename -- filename )
    "" or "doc-root" get swap path+ ;

: file-http-date ( filename -- string )
    file-modified unix-time>timestamp timestamp>http-string ;

: file-response ( filename mime-type -- )
    "200 OK" response
    [
        "Content-Type" set
        dup file-length number>string "Content-Length" set
        file-http-date "Last-Modified" set
        now timestamp>http-string "Date" set
    ] H{ } make-assoc print-header ;

: last-modified-matches? ( filename -- bool )
    file-http-date dup [
        "If-Modified-Since" header-param = 
    ] when ;

: not-modified-response ( -- )
    "304 Not Modified" response
    now timestamp>http-string "Date" associate print-header ;  

! You can override how files are served in a custom responder
SYMBOL: serve-file-hook

[
    file-response
    stdio get stream-copy
] serve-file-hook set-global

: serve-static ( filename mime-type -- )
    over last-modified-matches? [
        2drop not-modified-response
    ] [
        "method" get "head" = [
            file-response
        ] [
            >r dup <file-reader> swap r>
            serve-file-hook get call
        ] if 
    ] if ;

SYMBOL: page

: run-page ( filename -- )
    dup
    [ [ dup page set run-template-file ] with-scope ] try
    drop ;

: include-page ( filename -- )
    "doc-root" get swap path+ run-page ;

: serve-fhtml ( filename -- )
    serving-html
    "method" get "head" = [ drop ] [ run-page ] if ;

: serve-file ( filename -- )
    dup mime-type dup "application/x-factor-server-page" =
    [ drop serve-fhtml ] [ serve-static ] if ;

: file. ( name dirp -- )
    [ "/" append ] when
    dup <a =href a> write </a> ;

: directory. ( path request -- )
    dup [
        <h1> write </h1>
        <ul>
            directory sort-keys
            [ <li> file. </li> ] assoc-each
        </ul>
    ] simple-html-document ;

: list-directory ( directory -- )
    serving-html
     "method" get "head" = [
        drop
    ] [
        "request" get directory.
    ] if ;

: find-index ( filename -- path )
    { "index.html" "index.fhtml" }
    [ dupd path+ exists? ] find nip
    dup [ path+ ] [ nip ] if ;

: serve-directory ( filename -- )
    dup "/" tail? [
        dup find-index
        [ serve-file ] [ list-directory ] ?if
    ] [
        drop directory-no/
    ] if ;

: serve-object ( filename -- )
    dup directory? [ serve-directory ] [ serve-file ] if ;

: file-responder ( -- )
    "doc-root" get [
        "argument" get serving-path dup exists? [
            serve-object
        ] [
            drop "404 not found" httpd-error
        ] if
    ] [
        "404 doc-root not set" httpd-error
    ] if ;

global [
    ! Serve up our own source code
    "resources" [
        [
            "" resource-path "doc-root" set
            file-responder
        ] with-scope
    ] add-simple-responder
    
    ! Serves files from a directory stored in the "doc-root"
    ! variable. You can set the variable in the global
    ! namespace, or inside the responder.
    "file" [ file-responder ] add-simple-responder
    
    ! The root directory is served by...
    "file" set-default-responder
] bind