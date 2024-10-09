! Copyright (C) 2024 Dmitry Matveyev.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel raylib.live-coding.glfw threads calendar
namespaces vocabs.refresh continuations timers combinators
accessors concurrency.messaging concurrency.conditions ;
FROM: raylib => window-should-close is-key-pressed
    get-window-handle ;
IN: raylib.live-coding

SYMBOL: lc-listener-thread
SYMBOL: lc-game-thread
SYMBOL: lc-sleep-duration

!
! Common words
!

<PRIVATE
SYMBOL: lc-window-should-close?
ERROR: lc-continue-or-not original ;

: lc-enabled? ( -- ? ) lc-game-thread get ;

: send-to-listener ( message -- ) lc-listener-thread get send ;
: send-to-game ( message -- ) lc-game-thread get send ;

: set-window-should-close ( -- ) t lc-window-should-close? set ;
PRIVATE>

!
! On the game thread
!

<PRIVATE
: window-should-close? ( -- ? )
    window-should-close
    lc-window-should-close? get or ;

: with-listener-context ( quot -- )
    f make-context-current
    call
    get-window-handle make-context-current ; inline

: yield-to-listener ( -- )
    [ lc-sleep-duration get sleep ] with-listener-context ;

: with-rescue-to-listener ( quot -- )
    lc-enabled? [
        [ [ \ lc-continue-or-not boa send-to-listener
            "Game: listening to receive" .
            receive . ] with-listener-context ] recover
    ] [ call ] if ; inline
PRIVATE>

: until-window-should-close-with-live-coding ( game-loop-quot -- )
    '[
        [ @ ] with-rescue-to-listener
        lc-enabled? [ yield-to-listener ] when
        window-should-close? not
    ] loop ; inline

: on-key-reload-code ( key -- )
    is-key-pressed [
        [ refresh-all ] with-listener-context
    ] when ;

!
! On the listener thread
!

<PRIVATE
SYMBOL: lc-listen-timer

: reset-timer ( -- ) lc-listen-timer get [ stop-timer ] when* ;
: reset-library-state ( -- )
    reset-timer
    f lc-listener-thread set
    f lc-game-thread set
    f lc-window-should-close? set
    1 milliseconds lc-sleep-duration set-global ;

: restarts ( -- seq )
    { { "Close" t } { "Continue" f } } ;

DEFER: listen-for-messages
: handle-error ( error -- )
    original>> restarts rethrow-restarts [
        set-window-should-close
        t send-to-game
    ] [
        t send-to-game
        listen-for-messages
    ] if ;

: handle-message ( message -- )
    {
        { [ dup timed-out-error? ] [ drop ] }
        { [ dup lc-continue-or-not? ] [ handle-error ] }
    } cond ;

: listen-for-messages ( -- )
    ! XXX: race condition: if we call reset-timer exactly at the
    ! moment of execution of the first quotation, it won't
    ! get reset. It will be reset next time the live coding
    ! starts, unless in that moment this race condition happens
    ! once again.
    [ 1 milliseconds [ lc-continue-or-not? ] receive-if-timeout ]
    [
        ! Received timed-out-error
        [ listen-for-messages ] 1 seconds later
        lc-listen-timer set
    ]
    recover handle-message ;
PRIVATE>

: with-live-coding ( main-quot -- )
    reset-library-state
    self lc-listener-thread set
    [ [ reset-library-state ] finally ] curry
    "game" spawn lc-game-thread set
    listen-for-messages ;
