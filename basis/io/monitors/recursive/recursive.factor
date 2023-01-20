! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators concurrency.mailboxes
concurrency.messaging concurrency.promises continuations
destructors io.directories io.files.info io.monitors
io.monitors.private io.pathnames kernel sequences threads ;
IN: io.monitors.recursive

! Simulate recursive monitors on platforms that don't have them

TUPLE: recursive-monitor < monitor children thread ready ;

: notify? ( -- ? ) monitor tget ready>> promise-fulfilled? ;

DEFER: add-child-monitor

: qualify-path ( path -- path' )
    monitor tget path>> prepend-path ;

: add-child-monitors ( path -- )
    ! We yield since this directory scan might take a while.
    qualified-directory-files [ add-child-monitor ] each yield ;

: add-child-monitor ( path -- )
    notify? [ dup { +add-file+ } monitor tget queue-change ] when
    qualify-path dup link-info directory? [
        [ add-child-monitors ]
        [
            '[
                _ [ f my-mailbox (monitor) ] keep
                monitor tget children>> set-at
            ] ignore-errors
        ] bi
    ] [ drop ] if ;

: remove-child-monitor ( monitor -- )
    monitor tget children>> delete-at* [ dispose ] [ drop ] if ;

SYMBOL: +stop+

M: recursive-monitor dispose*
    [ [ +stop+ ] dip thread>> send ] [ call-next-method ] bi ;

: stop-pump ( -- )
    monitor tget children>> values dispose-each ;

: pump-step ( msg -- )
    monitor tget disposed>> [ drop ] [
        [ [ monitor>> path>> ] [ path>> ] bi append-path ] [ changed>> ] bi
        monitor tget queue-change
    ] if ;

: child-added ( path monitor -- )
    path>> prepend-path add-child-monitor ;

: child-removed ( path monitor -- )
    path>> prepend-path remove-child-monitor ;

: update-hierarchy ( msg -- )
    [ path>> ] [ monitor>> ] [ changed>> ] tri [
        {
            { +add-file+ [ child-added ] }
            { +remove-file+ [ child-removed ] }
            { +rename-file-old+ [ child-removed ] }
            { +rename-file-new+ [ child-added ] }
            [ 3drop ]
        } case
    ] 2with each ;

: pump-loop ( -- )
    receive {
        { [ dup +stop+ eq? ] [ drop stop-pump ] }
        { [ dup monitor-disposed eq? ] [ drop ] }
        [
            [ '[ _ update-hierarchy ] ignore-errors ] [ pump-step ] bi
            pump-loop
        ]
    } cond ;

: monitor-ready ( error/t -- )
    monitor tget ready>> fulfill ;

: pump-thread ( monitor -- )
    monitor tset
    [ "" add-child-monitor t monitor-ready ]
    [ [ self <linked-error> monitor-ready ] keep rethrow ]
    recover
    pump-loop ;

: start-pump-thread ( monitor -- )
    dup '[ _ pump-thread ]
    "Recursive monitor pump" spawn
    >>thread drop ;

: wait-for-ready ( monitor -- )
    ready>> ?promise ?linked drop ;

: <recursive-monitor> ( path mailbox -- monitor )
    [
        [ absolute-path ] dip
        recursive-monitor new-monitor |dispose
            H{ } clone >>children
            <promise> >>ready
        dup start-pump-thread
        dup wait-for-ready
    ] with-destructors ;
