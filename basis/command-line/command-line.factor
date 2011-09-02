! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: init continuations hashtables io io.encodings.utf8
io.files io.pathnames kernel kernel.private namespaces parser
sequences source-files strings system splitting vocabs.loader
alien.strings accessors ;
IN: command-line

SYMBOL: script
SYMBOL: command-line

: (command-line) ( -- args )
    10 special-object sift [ alien>native-string ] map ;

: rc-path ( name -- path )
    home prepend-path ;

: run-bootstrap-init ( -- )
    "user-init" get [
        ".factor-boot-rc" rc-path ?run-file
    ] when ;

: run-user-init ( -- )
    "user-init" get [
        ".factor-rc" rc-path ?run-file
    ] when ;

: load-vocab-roots ( -- )
    "user-init" get [
        ".factor-roots" rc-path dup exists? [
            utf8 file-lines harvest [ add-vocab-root ] each
        ] [ drop ] if
    ] when ;

: var-param ( name value -- ) swap set-global ;

: bool-param ( name -- ) "no-" ?head not var-param ;

: param ( param -- )
    "=" split1 [ var-param ] [ bool-param ] if* ;

: run-script ( file -- )
    t "quiet" [
        [ run-file ]
        [ source-file main>> [ execute( -- ) ] when* ] bi
    ] with-variable ;

: parse-command-line ( args -- )
    [ command-line off script off ] [
        unclip "-" ?head
        [ param parse-command-line ]
        [ script set command-line set ] if
    ] if-empty ;

SYMBOL: main-vocab-hook

: main-vocab ( -- vocab )
    embedded? [
        "alien.remote-control"
    ] [
        main-vocab-hook get [ call( -- vocab ) ] [ "listener" ] if*
    ] if ;

: default-cli-args ( -- )
    global [
        "quiet" off
        "e" off
        "user-init" on
        embedded? "quiet" set
        main-vocab "run" set
    ] bind ;

[ default-cli-args ] "command-line" add-startup-hook
