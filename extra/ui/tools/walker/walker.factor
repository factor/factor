! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel concurrency.messaging inspector ui.tools.listener
ui.tools.traceback ui.gadgets.buttons ui.gadgets.status-bar
ui.gadgets.tracks ui.commands ui.gadgets models
ui.tools.workspace ui.gestures ui.gadgets.labels ui threads
namespaces tools.walker assocs combinators ;
IN: ui.tools.walker

TUPLE: walker-gadget
status continuation thread
traceback
closing? ;

: walker-command ( walker msg -- )
    swap
    dup walker-gadget-thread thread-registered?
    [ walker-gadget-thread send-synchronous drop ]
    [ 2drop ] if ;

: com-step ( walker -- ) step walker-command ;

: com-into ( walker -- ) step-into walker-command ;

: com-out ( walker -- ) step-out walker-command ;

: com-back ( walker -- ) step-back walker-command ;

: com-continue ( walker -- ) step-all walker-command ;

: com-abandon ( walker -- ) abandon walker-command ;

M: walker-gadget ungraft*
    [ t swap set-walker-gadget-closing? ]
    [ com-continue ]
    [ delegate ungraft* ] tri ;

M: walker-gadget focusable-child*
    walker-gadget-traceback ;

: walker-state-string ( status thread -- string )
    [
        "Thread: " %
        dup thread-name %
        " (" %
        swap {
            { +stopped+ "Stopped" }
            { +suspended+ "Suspended" }
            { +running+ "Running" }
        } at %
        ")" %
        drop
    ] "" make ;

: <thread-status> ( model thread -- gadget )
    [ walker-state-string ] curry <filter> <label-control> ;

: <walker-gadget> ( status continuation thread -- gadget )
    over <traceback-gadget> f walker-gadget construct-boa [
        toolbar,
        g walker-gadget-status self <thread-status> f track,
        g walker-gadget-traceback 1 track,
    ] { 0 1 } build-track ;

: walker-help "ui-walker" help-window ;

\ walker-help H{ { +nullary+ t } } define-command

walker-gadget "toolbar" f {
    { T{ key-down f f "s" } com-step }
    { T{ key-down f f "i" } com-into }
    { T{ key-down f f "o" } com-out }
    { T{ key-down f f "b" } com-back }
    { T{ key-down f f "c" } com-continue }
    { T{ key-down f f "a" } com-abandon }
    { T{ key-down f f "d" } close-window }
    { T{ key-down f f "F1" } walker-help }
} define-command-map

: walker-for-thread? ( thread gadget -- ? )
    {
        { [ dup walker-gadget? not ] [ 2drop f ] }
        { [ dup walker-gadget-closing? ] [ 2drop f ] }
        [ walker-gadget-thread eq? ]
    } cond ;

: find-walker-window ( thread -- world/f )
    [ swap walker-for-thread? ] curry find-window ;

: walker-window ( status continuation thread -- )
    [ <walker-gadget> ] [ thread-name ] bi open-status-window ;

[
    dup find-walker-window dup
    [ raise-window 3drop ] [ drop [ walker-window ] with-ui ] if
] show-walker-hook set-global
