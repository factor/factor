! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors sequences assocs arrays continuations
destructors combinators kernel threads concurrency.messaging
concurrency.mailboxes concurrency.promises io.files io.files.info
io.directories io.pathnames io.monitors debugger fry ;
IN: io.monitors.recursive

! Simulate recursive monitors on platforms that don't have them

TUPLE: recursive-monitor < monitor children thread ready ;

: notify? ( -- ? ) monitor tget ready>> promise-fulfilled? ;

DEFER: add-child-monitor

: qualify-path ( path -- path' )
    monitor tget path>> prepend-path ;

: add-child-monitors ( path -- )
    #! We yield since this directory scan might take a while.
    dup [
        [ append-path ] with map
        [ add-child-monitor ] each yield
    ] with-directory-files ;

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

M: recursive-monitor dispose*
    [ "stop" swap thread>> send-synchronous drop ]
    [ queue>> dispose ]
    bi ;

: stop-pump ( -- )
    monitor tget children>> values dispose-each ;

: pump-step ( msg -- )
    [ [ monitor>> path>> ] [ path>> ] bi append-path ] [ changed>> ] bi
    monitor tget queue-change ;

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
    ] with with each ;

: pump-loop ( -- )
    receive dup synchronous? [
        [ stop-pump t ] dip reply-synchronous
    ] [
        [ '[ _ update-hierarchy ] ignore-errors ] [ pump-step ] bi
        pump-loop
    ] if ;

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
    [ absolute-path ] dip
    recursive-monitor new-monitor
        H{ } clone >>children
        <promise> >>ready
    dup start-pump-thread
    dup wait-for-ready ;
