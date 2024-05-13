! Copyright (C) 2003, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.strings assocs continuations
io.encodings.utf8 io.files kernel kernel.private namespaces
parser sequences source-files.errors splitting system
vocabs.loader ;
IN: command-line

SYMBOL: user-init-errors
SYMBOL: +user-init-error+

TUPLE: user-init-error error path line# asset ;

: <user-init-error> ( error -- error' )
    [ ] [ error-file ] [ error-line ] tri
    f user-init-error boa ; inline
M: user-init-error error-file path>> ;
M: user-init-error error-line line#>> ;
M: user-init-error error-type drop +user-init-error+ ;

SYMBOL: script
SYMBOL: command-line

: (command-line) ( -- args )
    OBJ-ARGS special-object sift [ alien>native-string ] map ;

: delete-user-init-errors ( file -- )
    user-init-errors get delete-at* nip
    [ notify-error-observers ] when ;

: try-user-init ( file -- )
    [ delete-user-init-errors ] keep
    "user-init" get swap '[
        _ [ ?run-file ] [
            <user-init-error>
            swap user-init-errors get set-at
            notify-error-observers
        ] recover
    ] when ;

: run-bootstrap-init ( -- )
    "~/.factor-boot-rc" try-user-init ;

: run-user-init ( -- )
    "~/.factor-rc" try-user-init ;

: load-vocab-roots ( -- )
    "user-init" get [
        "~/.factor-roots" [
            utf8 file-lines harvest [ add-vocab-root ] each
        ] when-file-exists
        "roots" get [
            os windows? ";" ":" ?
            split [ add-vocab-root ] each
        ] when*
    ] when ;

: var-param ( name value -- ) swap set-global ;

: bool-param ( name -- ) "no-" ?head not var-param ;

: param ( param -- )
    "=" split1 [ var-param ] [ bool-param ] if* ;

: command-line-options ( args -- args' )
    [ dup ?first "-" ?head ] [
        [ CHAR: - = ] trim-head param rest
    ] while drop ;

: (parse-command-line) ( args -- )
    [
        unclip "-" ?head [
            [ CHAR: - = ] trim-head
            [ param ] [ "run=" head? ] bi
            [ command-line set ]
            [ (parse-command-line) ] if
        ] [
            script set command-line set
        ] if
    ] unless-empty ;

: parse-command-line ( args -- )
    command-line off
    script off
    rest (parse-command-line) ;

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

STARTUP-HOOK: [
    H{ } user-init-errors set-global
    default-cli-args
]

{ "debugger" "command-line" } "command-line.debugger" require-when
