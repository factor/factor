! Copyright (C) 2024 Dmitry Matveyev.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar concurrency.messaging continuations kernel
namespaces raylib.live-coding.glfw threads ui.tools.listener
vocabs.loader vocabs.refresh ;
FROM: raylib => window-should-close is-key-pressed
    get-window-handle ;
IN: raylib.live-coding

SYMBOL: lc-sleep-duration

!
! Common words
!

<PRIVATE
SYMBOL: lc-enabled
SYMBOL: lc-window-should-close?

: lc-enabled? ( -- ? ) lc-enabled get ;
PRIVATE>

!
! On the listener thread
!

<PRIVATE
: reset-library-state ( -- )
    lc-window-should-close? off
    lc-enabled off
    1 milliseconds lc-sleep-duration set-global ;

: restarts ( -- seq )
    { { "Close window" t } { "Continue" f } } ;

: handle-error ( thread error -- )
    restarts rethrow-restarts [
        lc-window-should-close? on
    ] when t swap send ;
PRIVATE>

: with-live-coding ( main-quot -- )
    reset-library-state
    lc-enabled on
    '[ _ [ reset-library-state ] finally ]
    "game" spawn drop ;

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
        [
            [
                self swap '[ _ _ handle-error ] \ run call-listener
                ! Wait for listener to choose a restart.
                receive drop
            ] with-listener-context
        ] recover
    ] [ call ] if ; inline
PRIVATE>

: until-window-should-close-with-live-coding ( game-loop-quot -- )
    '[
        _ with-rescue-to-listener
        lc-enabled? [ yield-to-listener ] when
        window-should-close? not
    ] loop ; inline

: on-key-reload-code ( key -- )
    is-key-pressed [
        [ refresh-all ] with-listener-context
    ] when ;
