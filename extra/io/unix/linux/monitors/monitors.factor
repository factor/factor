! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel io.backend io.monitors io.monitors.recursive
io.files io.buffers io.monitors io.nonblocking io.timeouts
io.unix.backend io.unix.select unix.linux.inotify assocs
namespaces threads continuations init math math.bitfields sets
alien.c-types alien vocabs.loader accessors system hashtables ;
IN: io.unix.linux.monitors

TUPLE: linux-monitor < monitor wd ;

: <linux-monitor> ( wd path mailbox -- monitor )
    linux-monitor new-monitor
        swap >>wd ;

SYMBOL: watches

SYMBOL: inotify

: wd>monitor ( wd -- monitor ) watches get at ;

: <inotify> ( -- port/f )
    inotify_init dup 0 < [ drop f ] [ <reader> ] if ;

: inotify-fd inotify get handle>> ;

: check-existing ( wd -- )
    watches get key? [
        "Cannot open multiple monitors for the same file" throw
    ] when ;

: (add-watch) ( path mask -- wd )
    inotify-fd -rot inotify_add_watch dup io-error dup check-existing ;

: add-watch ( path mask mailbox -- monitor )
    >r
    >r (normalize-path) r>
    [ (add-watch) ] [ drop ] 2bi r>
    <linux-monitor> [ ] [ ] [ wd>> ] tri watches get set-at ;

: check-inotify
    inotify get [
        "Calling <monitor> outside with-monitors" throw
    ] unless ;

M: linux (monitor) ( path recursive? mailbox -- monitor )
    swap [
        <recursive-monitor>
    ] [
        check-inotify
        IN_CHANGE_EVENTS swap add-watch
    ] if ;

M: linux-monitor dispose ( monitor -- )
    [ wd>> watches get delete-at ]
    [ wd>> inotify-fd swap inotify_rm_watch io-error ] bi ;

: ignore-flags? ( mask -- ? )
    {
        IN_DELETE_SELF
        IN_MOVE_SELF
        IN_UNMOUNT
        IN_Q_OVERFLOW
        IN_IGNORED
    } flags bitand 0 > ;

: parse-action ( mask -- changed )
    [
        IN_CREATE +add-file+ ?flag
        IN_DELETE +remove-file+ ?flag
        IN_MODIFY +modify-file+ ?flag
        IN_ATTRIB +modify-file+ ?flag
        IN_MOVED_FROM +rename-file-old+ ?flag
        IN_MOVED_TO +rename-file-new+ ?flag
        drop
    ] { } make prune ;

: parse-file-notify ( buffer -- path changed )
    dup inotify-event-mask ignore-flags? [
        drop f f
    ] [
        [ inotify-event-name alien>char-string ]
        [ inotify-event-mask parse-action ] bi
    ] if ;

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
        2dup inotify-event@ dup inotify-event-wd wd>monitor
        >r parse-file-notify r> queue-change
        next-event parse-file-notifications
    ] if ;

: inotify-read-loop ( port -- )
    dup wait-to-read1
    0 over buffer>> parse-file-notifications
    0 over buffer>> buffer-reset
    inotify-read-loop ;

: inotify-read-thread ( port -- )
    [ inotify-read-loop ] curry ignore-errors ;

M: linux init-monitors
    H{ } clone watches set
    <inotify> [
        [ inotify set ]
        [
            [ inotify-read-thread ] curry
            "Linux monitor thread" spawn drop
        ] bi
    ] [
        "Linux kernel version is too old" throw
    ] if* ;

M: linux dispose-monitors
    inotify get dispose ;
