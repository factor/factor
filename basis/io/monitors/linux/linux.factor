! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel io.backend io.monitors io.monitors.recursive
io.files io.pathnames io.buffers io.ports io.timeouts
io.backend.unix io.encodings.utf8 unix.linux.inotify assocs
namespaces make threads continuations init libc math math.bitwise
sets alien alien.strings alien.c-types vocabs.loader accessors
system hashtables destructors unix classes.struct literals ;
IN: io.monitors.linux

SYMBOL: watches

SYMBOL: inotify

TUPLE: linux-monitor < monitor wd inotify watches ;

: <linux-monitor> ( wd path mailbox -- monitor )
    linux-monitor new-monitor
        inotify get >>inotify
        watches get >>watches
        swap >>wd ;

: wd>monitor ( wd -- monitor ) watches get at ;

: <inotify> ( -- port/f )
    inotify_init dup 0 < [ drop f ] [ <fd> init-fd <input-port> ] if ;

: inotify-fd ( -- fd ) inotify get handle>> handle-fd ;

: check-existing ( wd -- )
    watches get key? [
        "Cannot open multiple monitors for the same file" throw
    ] when ;

: (add-watch) ( path mask -- wd )
    inotify-fd -rot inotify_add_watch dup io-error dup check-existing ;

: add-watch ( path mask mailbox -- monitor )
    [ [ absolute-path ] dip [ (add-watch) ] keepd ] dip
    <linux-monitor> [ ] [ ] [ wd>> ] tri watches get set-at ;

: check-inotify ( -- )
    inotify get [
        "Calling <monitor> outside with-monitors" throw
    ] unless ;

M: linux (monitor)
    swap [
        <recursive-monitor>
    ] [
        check-inotify
        IN_CHANGE_EVENTS swap add-watch
    ] if ;

M: linux-monitor dispose*
    [ [ wd>> ] [ watches>> ] bi delete-at ]
    [
        dup inotify>> disposed>> [ drop ] [
            [ inotify>> handle>> handle-fd ] [ wd>> ] bi
            inotify_rm_watch io-error
        ] if
    ]
    [ call-next-method ]
    tri ;

: ignore-flags? ( mask -- ? )
    flags{
        IN_DELETE_SELF
        IN_MOVE_SELF
        IN_UNMOUNT
        IN_Q_OVERFLOW
        IN_IGNORED
    } bitand 0 > ;

: parse-action ( mask -- changed )
    [
        IN_CREATE +add-file+ ?flag
        IN_DELETE +remove-file+ ?flag
        IN_MODIFY +modify-file+ ?flag
        IN_ATTRIB +modify-file+ ?flag
        IN_MOVED_FROM +rename-file-old+ ?flag
        IN_MOVED_TO +rename-file-new+ ?flag
        drop
    ] { } make members ;

: parse-event-name ( event -- name )
    dup len>> zero?
    [ drop "" ] [ name>> utf8 alien>string ] if ;

: parse-file-notify ( buffer -- path changed )
    dup mask>> ignore-flags? [
        drop f f
    ] [
        [ parse-event-name ] [ mask>> parse-action ] bi
    ] if ;

: events-exhausted? ( i buffer -- ? )
    fill>> >= ;

: inotify-event@ ( i buffer -- inotify-event )
    ptr>> <displaced-alien> inotify-event memory>struct ;

: next-event ( i buffer -- i buffer )
    2dup inotify-event@
    len>> inotify-event heap-size +
    swap [ + ] dip ;

: parse-file-notifications ( i buffer -- )
    2dup events-exhausted? [ 2drop ] [
        2dup inotify-event@ dup wd>> wd>monitor
        [ parse-file-notify ] dip queue-change
        next-event parse-file-notifications
    ] if ;

: inotify-read-loop ( port -- )
    check-disposed
    dup wait-to-read drop
    0 over buffer>> parse-file-notifications
    0 over buffer>> buffer-reset
    inotify-read-loop ;

: inotify-read-thread ( port -- )
    [ inotify-read-loop ] curry ignore-errors ;

M: linux init-monitors
    H{ } clone watches namespaces:set
    <inotify> [
        [ inotify namespaces:set ]
        [
            [ inotify-read-thread ] curry
            "Linux monitor thread" spawn drop
        ] bi
    ] [
        "Linux kernel version is too old" throw
    ] if* ;

M: linux dispose-monitors
    inotify get dispose ;
