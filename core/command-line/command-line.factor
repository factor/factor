! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: command-line
USING: init continuations debugger hashtables io kernel
kernel.private namespaces parser sequences strings system
splitting io.files ;

: run-bootstrap-init ( -- )
    "user-init" get [
        home ".factor-boot-rc" path+ ?run-file
    ] when ;

: run-user-init ( -- )
    "user-init" get [
        home ".factor-rc" path+ ?run-file
    ] when ;

: cli-var-param ( name value -- ) swap set-global ;

: cli-bool-param ( name -- ) "no-" ?head not cli-var-param ;

: cli-param ( param -- )
    "=" split1 [ cli-var-param ] [ cli-bool-param ] if* ;

: cli-arg ( argument -- argument )
    "-" ?head [ cli-param f ] when ;

: cli-args ( -- args ) 10 getenv ;

SYMBOL: main-vocab-hook

: main-vocab ( -- vocab )
    embedded? [
        "alien.remote-control"
    ] [
        main-vocab-hook get [ call ] [ "listener" ] if*
    ] if ;

: default-cli-args
    global [
        "quiet" off
        "script" off
        "e" off
        "user-init" on
        embedded? "quiet" set
        main-vocab "run" set
    ] bind ;

: ignore-cli-args? ( -- ? )
    macosx? "run" get "ui" = and ;

: script-mode ( -- )
    t "quiet" set-global
    "none" "run" set-global ;

: parse-command-line ( -- )
    cli-args [ cli-arg ] subset
    "script" get [ script-mode ] when
    ignore-cli-args? [ drop ] [ [ run-file ] each ] if
    "e" get [ eval ] when* ;

[ default-cli-args ] "command-line" add-init-hook
