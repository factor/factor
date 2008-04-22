! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors sequences assocs arrays continuations combinators kernel
threads concurrency.messaging concurrency.mailboxes concurrency.promises
io.files io.monitors debugger ;
IN: io.monitors.recursive

! Simulate recursive monitors on platforms that don't have them

TUPLE: recursive-monitor < monitor children thread ready ;

: notify? ( -- ? ) monitor tget ready>> promise-fulfilled? ;

DEFER: add-child-monitor

: qualify-path ( path -- path' )
    monitor tget path>> prepend-path ;

: add-child-monitors ( path -- )
    #! We yield since this directory scan might take a while.
    directory* [ first add-child-monitor ] each yield ;

: add-child-monitor ( path -- )
    notify? [ dup { +add-file+ } monitor tget queue-change ] when
    qualify-path dup link-info type>> +directory+ eq? [
        [ add-child-monitors ]
        [
            [
                [ f my-mailbox (monitor) ] keep
                monitor tget children>> set-at
            ] curry ignore-errors
        ] bi
    ] [ drop ] if ;

: remove-child-monitor ( monitor -- )
    monitor tget children>> delete-at* [ dispose ] [ drop ] if ;

M: recursive-monitor dispose
    dup queue>> closed>> [
        drop
    ] [
        [ "stop" swap thread>> send-synchronous drop ]
        [ queue>> dispose ] bi
    ] if ;

: stop-pump ( -- )
    monitor tget children>> [ nip dispose ] assoc-each ;

: pump-step ( msg -- )
    first3 path>> swap >r prepend-path r> monitor tget 3array
    monitor tget queue>>
    mailbox-put ;

: child-added ( path monitor -- )
    path>> prepend-path add-child-monitor ;

: child-removed ( path monitor -- )
    path>> prepend-path remove-child-monitor ;

: update-hierarchy ( msg -- )
    first3 swap [
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
        >r stop-pump t r> reply-synchronous
    ] [
        [ [ update-hierarchy ] curry ignore-errors ] [ pump-step ] bi
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
    dup [ pump-thread ] curry
    "Recursive monitor pump" spawn
    >>thread drop ;

: wait-for-ready ( monitor -- )
    ready>> ?promise ?linked drop ;

: <recursive-monitor> ( path mailbox -- monitor )
    >r (normalize-path) r>
    recursive-monitor new-monitor
        H{ } clone >>children
        <promise> >>ready
    dup start-pump-thread
    dup wait-for-ready ;
