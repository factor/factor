! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.strings assocs continuations fry
hashtables init io io.encodings.utf8 io.files io.pathnames
kernel kernel.private namespaces parser parser.notes sequences
source-files source-files.errors splitting strings system
tools.errors vocabs.loader ;
IN: command-line

SYMBOL: user-init-errors
SYMBOL: +user-init-error+

T{ error-type
    { type +user-init-error+ }
    { word ":user-init-errors" }
    { plural "rc file errors" }
    { icon "vocab:ui/tools/error-list/icons/help-lint-error.tiff" }
    { quot [ user-init-errors get-global values ] }
    { forget-quot [ user-init-errors get-global delete-at ] }
} define-error-type

: :user-init-errors ( -- )
    user-init-errors get-global values errors. ;

TUPLE: user-init-error error file line# asset ;

: <user-init-error> ( error -- error' )
    [ ] [ error-file ] [ error-line ] tri
    f user-init-error boa ; inline
M: user-init-error error-file file>> ;
M: user-init-error error-line line#>> ;
M: user-init-error error-type drop +user-init-error+ ;

SYMBOL: script
SYMBOL: command-line

: (command-line) ( -- args )
    OBJ-ARGS special-object sift [ alien>native-string ] map ;

: rc-path ( name -- path )
    home prepend-path ;

: try-user-init ( file -- )
    "user-init" get swap '[
        _ [ ?run-file ] [
            <user-init-error>
            swap user-init-errors get set-at
            notify-error-observers
        ] recover
    ] when ;

: run-bootstrap-init ( -- )
    ".factor-boot-rc" rc-path try-user-init ;

: run-user-init ( -- )
    ".factor-rc" rc-path try-user-init ;

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
    t parser-quiet? [
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
    [
        "e" off
        "user-init" on
        main-vocab "run" set
    ] with-global ;

[
    H{ } user-init-errors set-global
    default-cli-args
] "command-line" add-startup-hook
