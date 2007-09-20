! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar html io io.files kernel math math.parser http.server.responders
http.server.templating namespaces parser sequences strings assocs hashtables
debugger http.mime sorting ;

IN: http.server.responders.file

: serving-path ( filename -- filename )
    "" or "doc-root" get swap path+ ;

: file-http-date ( filename -- string )
    file-modified unix-time>timestamp timestamp>http-string ;

: file-response ( filename mime-type -- )
    [
        "Content-Type" set
        dup file-length number>string "Content-Length" set
        file-http-date "Last-Modified" set
        now timestamp>http-string "Date" set
    ] H{ } make-assoc "200 OK" response nl ;

: last-modified-matches? ( filename -- bool )
    file-http-date dup [
        "If-Modified-Since" "header" get at = 
    ] when ;

: not-modified-response ( -- )
    now timestamp>http-string "Date" associate
    "304 Not Modified" response nl ;  

: serve-static ( filename mime-type -- )
    over last-modified-matches? [
        2drop not-modified-response
    ] [
        dupd file-response
        "method" get "head" = [
            drop
        ] [
            <file-reader> stdio get stream-copy
        ] if 
    ] if ;

SYMBOL: page

: run-page ( filename -- )
    dup
    [ [ dup page set run-template-file ] with-scope ] try
    drop ;

: include-page ( filename -- )
    "doc-root" get swap path+ run-page ;

: serve-file ( filename -- )
    dup mime-type dup "application/x-factor-server-page" =
    [ drop serving-html run-page ] [ serve-static ] if ;

: file. ( path name dirp -- )
    "[DIR] " "      " ? write
    dup <pathname> write-object nl ;

: directory. ( path -- )
    directory sort-keys [ first2 file. ] each ;

: list-directory ( directory -- )
    serving-html
     "method" get "head" = [
        drop
    ] [
        "request" get [ directory. ] simple-html-document
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
    ! Javascript source used by ajax libraries
    "resources" [ 
        [
            "extra/http/server/resources/" resource-path "doc-root" set
            file-responder
        ] with-scope
    ] add-simple-responder
    
    ! Serves files from a directory stored in the "doc-root"
    ! variable. You can set the variable in the global namespace,
    ! or inside the responder.
    "file" [ file-responder ] add-simple-responder
    
    ! The root directory is served by...
    "file" set-default-responder
] bind