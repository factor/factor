! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files namespaces webapps.file http.server.responders
xmode.code2html kernel html sequences ;
IN: webapps.source

! This responder is a potential security problem. Make sure you
! don't have sensitive files stored under vm/, core/, extra/
! or misc/.

: check-source-path ( path -- ? )
    { "vm/" "core/" "extra/" "misc/" }
    [ head? ] curry* contains? ;

: source-responder ( path mime-type -- )
    drop
    serving-html
    [ dup <file-reader> htmlize-stream ] with-html-stream ;

global [
    ! Serve up our own source code
    "source" [
        "argument" get check-source-path [
            [
                "" resource-path "doc-root" set
                [ source-responder ] serve-file-hook set
                file-responder
            ] with-scope
        ] [
            "403 forbidden" httpd-error
        ] if
    ] add-simple-responder
] bind
