! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel io.backend io.monitors io.monitors.private
io.files io.buffers io.nonblocking io.timeouts io.unix.backend
io.unix.select io.unix.launcher unix.linux.inotify assocs
namespaces threads continuations init math alien.c-types alien
vocabs.loader accessors ;
IN: io.unix.linux

TUPLE: linux-io ;

INSTANCE: linux-io unix-io

TUPLE: linux-monitor ;

: <linux-monitor> ( wd -- monitor )
    linux-monitor construct-simple-monitor ;

TUPLE: inotify watches ;

: watches ( -- assoc ) inotify get-global watches>> ;

: wd>monitor ( wd -- monitor ) watches at ;

: <inotify> ( -- port/f )
    H{ } clone
    inotify_init dup 0 < [ 2drop f ] [
        inotify <buffered-port>
        { set-inotify-watches set-delegate } inotify construct
    ] if ;

: inotify-fd inotify get-global handle>> ;

: (add-watch) ( path mask -- wd )
    inotify-fd -rot inotify_add_watch dup io-error ;

: check-existing ( wd -- )
    watches key? [
        "Cannot open multiple monitors for the same file" throw
    ] when ;

: add-watch ( path mask -- monitor )
    (add-watch) dup check-existing
    [ <linux-monitor> dup ] keep watches set-at ;

: remove-watch ( monitor -- )
    dup simple-monitor-handle watches delete-at
    simple-monitor-handle inotify-fd swap inotify_rm_watch io-error ;

: check-inotify
    inotify get [
        "inotify is not supported by this Linux release" throw
    ] unless ;

M: linux-io <monitor> ( path recursive? -- monitor )
    check-inotify
    drop IN_CHANGE_EVENTS add-watch ;

M: linux-monitor dispose ( monitor -- )
    dup delegate dispose remove-watch ;

: ?flag ( n mask symbol -- n )
    pick rot bitand 0 > [ , ] [ drop ] if ;

: parse-action ( mask -- changed )
    [
        IN_CREATE +add-file+ ?flag
        IN_DELETE +remove-file+ ?flag
        IN_DELETE_SELF +remove-file+ ?flag
        IN_MODIFY +modify-file+ ?flag
        IN_ATTRIB +modify-file+ ?flag
        IN_MOVED_FROM +rename-file+ ?flag
        IN_MOVED_TO +rename-file+ ?flag
        IN_MOVE_SELF +rename-file+ ?flag
        drop
    ] { } make ;

: parse-file-notify ( buffer -- changed path )
    { inotify-event-name inotify-event-mask } get-slots
    parse-action swap alien>char-string ;

: events-exhausted? ( i buffer -- ? )
    fill>> >= ;

: inotify-event@ ( i buffer -- alien )
    ptr>> <displaced-alien> ;

: next-event ( i buffer -- i buffer )
    2dup inotify-event@
    inotify-event-len "inotify-event" heap-size +
    swap >r + r> ;

: parse-file-notifications ( i buffer -- )
    2dup events-exhausted? [ 2drop ] [
        2dup inotify-event@ dup inotify-event-wd wd>monitor [
            monitor-queue [
                parse-file-notify changed-file
            ] bind
        ] keep notify-callback
        next-event parse-file-notifications
    ] if ;

: read-notifications ( port -- )
    dup refill drop
    0 over parse-file-notifications
    0 swap buffer-reset ;

TUPLE: inotify-task ;

: <inotify-task> ( port -- task )
    f inotify-task <input-task> ;

: init-inotify ( mx -- )
    <inotify> dup [
        dup inotify set-global
        <inotify-task> swap register-io-task
    ] [
        2drop
    ] if ;

M: inotify-task do-io-task ( task -- )
    io-task-port read-notifications f ;

M: linux-io init-io ( -- )
    <select-mx>
    [ mx set-global ]
    [ init-inotify ] bi ;

T{ linux-io } set-io-backend

[ start-wait-thread ] "io.unix.linux" add-init-hook
