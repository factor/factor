! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend kernel continuations namespaces sequences
assocs hashtables sorting arrays concurrency.threads ;
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
TUPLE: simple-monitor handle callback ;

: <simple-monitor> ( handle -- simple-monitor )
    f (monitor) {
        set-simple-monitor-handle
        set-delegate
    } simple-monitor construct ;

: construct-simple-monitor ( handle class -- simple-monitor )
    >r <simple-monitor> r> construct-delegate ; inline

: notify-callback ( simple-monitor -- )
    dup simple-monitor-callback
    f rot set-simple-monitor-callback
    [ resume ] when* ;

M: simple-monitor fill-queue ( monitor -- )
    dup simple-monitor-callback [
        "Cannot wait for changes on the same file from multiple threads" throw
    ] when
    [ swap set-simple-monitor-callback ] suspend drop
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
