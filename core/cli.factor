! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: command-line
USING: errors hashtables io kernel kernel-internals namespaces
parser sequences strings ;

: ?run-file ( file -- )
    dup exists? [ run-file ] [ drop ] if ;

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

: default-shell ( -- shell ) "tty" ;

: default-cli-args
    "e" off
    "user-init" on
    "compile" on
    "native-io" on
    "quiet" off
    macosx? "cocoa" set
    unix? macosx? not and "x11" set
    default-shell "shell" set ;

: ignore-cli-args? ( -- ? )
    macosx? "shell" get "ui" = and ;

: parse-command-line ( -- )
    cli-args [ cli-arg ] subset
    ignore-cli-args? [ drop ] [ [ run-file ] each ] if
    "e" get [ eval ] when* ;

IN: shells

: none ;
