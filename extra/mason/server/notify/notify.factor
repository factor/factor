! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar combinators combinators.smart
command-line db.tuples io io.encodings.utf8 io.files kernel
mason.server namespaces present sequences ;
IN: mason.server.notify

SYMBOLS: host-name target-os target-cpu message message-arg ;

: parse-args ( command-line -- )
    dup last message-arg set
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

: boot ( builder -- ) +boot+ >>status drop ;

: test ( builder -- ) +test+ >>status drop ;

: report ( builder status content -- )
    [ >>status ] [ >>last-report ] bi*
    dup status>> +clean+ = [
        dup current-git-id>> >>clean-git-id
        dup current-timestamp>> >>clean-timestamp
    ] when
    dup current-git-id>> >>last-git-id
    dup current-timestamp>> >>last-timestamp
    drop ;

: release ( builder name -- )
    >>last-release
    dup clean-git-id>> >>release-git-id
    drop ;

: update-builder ( builder -- )
    message get {
        { "git-id" [ message-arg get git-id ] }
        { "make-vm" [ make-vm ] }
        { "boot" [ boot ] }
        { "test" [ test ] }
        { "report" [ message-arg get contents report ] }
        { "release" [ message-arg get release ] }
    } case ;

: handle-update ( command-line timestamp -- )
    [
        [ parse-args find-builder ] dip >>current-timestamp
        [ update-builder ] [ update-tuple ] bi
    ] with-mason-db ;

CONSTANT: log-file "resource:mason.log"

: log-update ( command-line timestamp -- )
    log-file utf8 [
        present write ": " write " " join print
    ] with-file-appender ;

: main ( -- )
    command-line get now [ log-update ] [ handle-update ] 2bi ;

MAIN: main
