! Copyright (C) 2008 Slava Pestov, Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math system dlists namespaces assocs init threads
io.streams.duplex ;
IN: io.timeouts

TUPLE: lapse entry timeout cutoff ;

: <lapse> f 0 0 \ lapse construct-boa ;

GENERIC: lapse ( obj -- lapse )
GENERIC: set-timeout ( ms obj -- )

M: object set-timeout lapse set-lapse-timeout ;

M: duplex-stream set-timeout
    2dup
    duplex-stream-in set-timeout
    duplex-stream-out set-timeout ;

: timeout ( obj -- ms ) lapse lapse-timeout ;
: entry ( obj -- dlist-node ) lapse lapse-entry ;
: set-entry ( dlist-node -- obj ) lapse set-lapse-entry ;
: cutoff ( obj -- ms ) lapse lapse-cutoff ;
: set-cutoff ( ms obj -- ) lapse set-lapse-cutoff ;

SYMBOL: timeout-queue

: timeout? ( lapse -- ? )
    cutoff dup zero? not swap millis < and ;

timeout-queue global [ [ <dlist> ] unless* ] change-at

: unqueue-timeout ( obj -- )
    entry [
        timeout-queue get-global swap delete-node
    ] when* ;

: queue-timeout ( obj -- )
    dup timeout-queue get-global push-front*
    swap set-entry ;

GENERIC: timed-out ( obj -- )

M: object timed-out drop ;

: expire-timeouts ( -- )
    timeout-queue get-global dup dlist-empty? [ drop ] [
        dup peek-back timeout?
        [ pop-back timed-out expire-timeouts ] [ drop ] if
    ] if ;

: begin-timeout ( obj -- )
    dup timeout dup zero? [
        2drop
    ] [
        millis + over set-cutoff
        dup unqueue-timeout queue-timeout
    ] if ;

: with-timeout ( obj quot -- )
    over begin-timeout keep unqueue-timeout ; inline

: expiry-thread ( -- )
    expire-timeouts 5000 sleep expire-timeouts ;

[ expiry-thread ] "io.timeouts" add-init-hook
