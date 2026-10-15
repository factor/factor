! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar combinators continuations destructors
io.directories io.files.info io.files.info.unix io.monitors
io.pathnames kernel locals namespaces sequences sequences.generalizations threads vectors ;
IN: io.monitors.bsd

! Portable BSD monitoring. Snapshots do not follow symbolic links, and
! omit access times (reading a directory must not generate notifications).
TUPLE: bsd-monitor < monitor recursive snapshot thread ;
SYMBOL: bsd-monitors

: init-bsd-monitors ( -- ) V{ } clone bsd-monitors set ;
: dispose-bsd-monitors ( -- ) bsd-monitors get dispose-each ;

: file-signature ( info -- signature )
    { [ dev>> ] [ ino>> ] [ size>> ] [ modified>> ]
      [ permissions>> ] [ created>> ] } cleave 6 narray ;

DEFER: snapshot-path

:: snapshot-path ( relative monitor snapshot -- )
    monitor path>> relative append-path :> path
    [ path link-info ] [ drop f ] recover :> info
    info [
        info file-signature relative snapshot set-at
        info directory? relative empty? monitor recursive>> or and [
            [ path directory-files ] [ drop { } ] recover [| child |
                monitor disposed>> [
                    relative child append-path monitor snapshot snapshot-path
                ] unless
            ] each yield
        ] when
    ] when ;

:: take-snapshot ( monitor -- snapshot )
    H{ } clone :> snapshot
    "" monitor snapshot snapshot-path
    snapshot ;

:: matching-name ( signature snapshot -- name/f )
    snapshot keys [| name |
        name snapshot at 2 head signature 2 head =
    ] find nip ;

:: report-change ( name changes monitor -- )
    monitor path>> name append-path changes monitor queue-change ;

:: report-snapshot ( current monitor -- )
    monitor snapshot>> :> previous
    H{ } clone :> removed
    H{ } clone :> added
    previous [| name signature |
        name current key? [
            name current at signature = [
                name { +modify-file+ } monitor report-change
            ] unless
        ] [ signature name removed set-at ] if
    ] assoc-each
    current [| name signature |
        name previous key? [ signature name added set-at ] unless
    ] assoc-each
    removed [| name signature |
        signature added matching-name :> renamed
        renamed [
            name { +rename-file-old+ } monitor report-change
            renamed { +rename-file-new+ } monitor report-change
            renamed added delete-at
        ] [ name { +remove-file+ } monitor report-change ] if
    ] assoc-each
    added [| name signature |
        name { +add-file+ } monitor report-change
    ] assoc-each
    monitor current >>snapshot drop ;

:: poll-monitor ( monitor -- )
    [ monitor disposed>> not ] [
        50 milliseconds sleep
        monitor disposed>> [
            monitor take-snapshot :> current
            monitor disposed>> [ current monitor report-snapshot ] unless
        ] unless
    ] while ;

:: <bsd-monitor> ( path recursive? mailbox -- monitor )
    path absolute-path :> path
    ! Fail synchronously for a missing or inaccessible initial path.
    path link-info drop
    path mailbox bsd-monitor new-monitor
        recursive? >>recursive :> monitor
    monitor monitor take-snapshot >>snapshot drop
    bsd-monitors get [ monitor swap push ] when*
    [ monitor poll-monitor ] "BSD file monitor" spawn
    monitor swap >>thread ;
