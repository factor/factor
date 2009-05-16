! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.smart command-line db
db.sqlite db.tuples db.types io kernel namespaces sequences ;
IN: mason.notify.server

CONSTANT: +starting+ "starting"
CONSTANT: +make-vm+ "make-vm"
CONSTANT: +boot+ "boot"
CONSTANT: +test+ "test"
CONSTANT: +clean+ "clean"
CONSTANT: +dirty+ "dirty"

TUPLE: builder host-name os cpu clean-git-id last-git-id last-report current-git-id status ;

builder "BUILDERS" {
    { "host-name" "HOST_NAME" TEXT +user-assigned-id+ }
    { "os" "OS" TEXT +user-assigned-id+ }
    { "cpu" "CPU" TEXT +user-assigned-id+ }
    { "clean-git-id" "CLEAN_GIT_ID" TEXT }
    { "last-git-id" "LAST_GIT_ID" TEXT }
    { "last-report" "LAST_REPORT" TEXT }
    { "current-git-id" "CURRENT_GIT_ID" TEXT }
    { "status" "STATUS" TEXT }
} define-persistent

SYMBOLS: host-name target-os target-cpu message message-arg ;

: parse-args ( command-line -- )
    dup peek message-arg set
    [
        {
            [ host-name set ]
            [ target-cpu set ]
            [ target-os set ]
            [ message set ]
        } spread
    ] input<sequence ;

: find-builder ( -- builder )
    builder new
        host-name get >>host-name
        target-os get >>os
        target-cpu get >>cpu
    dup select-tuple [ ] [ dup insert-tuple ] ?if ;

: git-id ( builder id -- )
    >>current-git-id +starting+ >>status drop ;

: make-vm ( builder -- ) +make-vm+ >>status drop ;

: boot ( report -- ) +boot+ >>status drop ;

: test ( report -- ) +test+ >>status drop ;

: report ( builder status content -- )
    [ >>status ] [ >>last-report ] bi*
    dup status>> +clean+ = [ dup current-git-id>> >>clean-git-id ] when
    dup current-git-id>> >>last-git-id
    drop ;

: update-builder ( builder -- )
    message get {
        { "git-id" [ message-arg get git-id ] }
        { "make-vm" [ make-vm ] }
        { "boot" [ boot ] }
        { "test" [ test ] }
        { "report" [ message-arg get contents report ] }
    } case ;

: mason-db ( -- db ) "resource:mason.db" <sqlite-db> ;

: handle-update ( command-line -- )
    mason-db [
        parse-args find-builder
        [ update-builder ] [ update-tuple ] bi
    ] with-db ;

: main ( -- )
    command-line get handle-update ;

MAIN: main
