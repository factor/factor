! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend kernel continuations namespaces sequences
assocs hashtables sorting arrays threads boxes io.timeouts ;
IN: io.monitors

<PRIVATE

TUPLE: monitor queue closed? ;

: check-monitor ( monitor -- )
    monitor-closed? [ "Monitor closed" throw ] when ;

: (monitor) ( delegate -- monitor )
    H{ } clone {
        set-delegate
        set-monitor-queue
    } monitor construct ;

GENERIC: fill-queue ( monitor -- )

: changed-file ( changed path -- )
    namespace [ append ] change-at ;

: dequeue-change ( assoc -- path changes )
    delete-any prune natural-sort >array ;

M: monitor dispose
    dup check-monitor
    t over set-monitor-closed?
    delegate dispose ;

! Simple monitor; used on Linux and Mac OS X. On Windows,
! monitors are full-fledged ports.
TUPLE: simple-monitor handle callback timeout ;

M: simple-monitor timeout simple-monitor-timeout ;

M: simple-monitor set-timeout set-simple-monitor-timeout ;

: <simple-monitor> ( handle -- simple-monitor )
    f (monitor) <box> {
        set-simple-monitor-handle
        set-delegate
        set-simple-monitor-callback
    } simple-monitor construct ;

: construct-simple-monitor ( handle class -- simple-monitor )
    >r <simple-monitor> r> construct-delegate ; inline

: notify-callback ( simple-monitor -- )
    simple-monitor-callback [ resume ] if-box? ;

M: simple-monitor timed-out
    notify-callback ;

M: simple-monitor fill-queue ( monitor -- )
    [
        [ swap simple-monitor-callback >box ]
        "monitor" suspend drop
    ] with-timeout
    check-monitor ;

M: simple-monitor dispose ( monitor -- )
    dup delegate dispose notify-callback ;

PRIVATE>

HOOK: <monitor> io-backend ( path recursive? -- monitor )

: next-change ( monitor -- path changed )
    dup check-monitor
    dup monitor-queue dup assoc-empty? [
        drop dup fill-queue next-change
    ] [ nip dequeue-change ] if ;

SYMBOL: +add-file+
SYMBOL: +remove-file+
SYMBOL: +modify-file+
SYMBOL: +rename-file+

: with-monitor ( path recursive? quot -- )
    >r <monitor> r> with-disposal ; inline
