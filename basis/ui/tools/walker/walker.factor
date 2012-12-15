! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel concurrency.messaging inspector
ui.tools.listener ui.tools.traceback ui.gadgets.buttons
ui.gadgets.status-bar ui.gadgets.tracks ui.commands ui.gadgets
models models.arrow ui.tools.browser ui.tools.common ui.gestures
ui.gadgets.labels ui threads namespaces make tools.walker assocs
combinators fry ;
IN: ui.tools.walker

TUPLE: walker-gadget < tool
status continuation thread
traceback
closing? ;

: walker-command ( walker msg -- )
    swap
    dup thread>> thread-registered?
    [ thread>> send-synchronous drop ]
    [ 2drop ]
    if ;

: com-step ( walker -- ) step walker-command ;

: com-into ( walker -- ) step-into walker-command ;

: com-out ( walker -- ) step-out walker-command ;

: com-back ( walker -- ) step-back walker-command ;

: com-continue ( walker -- ) step-all walker-command ;

: com-abandon ( walker -- ) abandon walker-command ;

M: walker-gadget ungraft*
    [ t >>closing? drop ] [ com-continue ] [ call-next-method ] tri ;

M: walker-gadget focusable-child*
    traceback>> ;

: walker-state-string ( status thread -- string )
    [
        "Thread: " %
        dup name>> %
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
    '[ _ walker-state-string ] <arrow> <label-control> ;

: <walker-gadget> ( status continuation thread -- gadget )
    vertical walker-gadget new-track
        swap >>thread
        swap >>continuation
        swap >>status
        dup continuation>> <traceback-gadget> >>traceback

        add-toolbar
        dup status>> self <thread-status> f track-add
        dup traceback>> 1 track-add ;
    
: walker-help ( -- ) "ui-walker" com-browse ;

\ walker-help H{ { +nullary+ t } } define-command

walker-gadget "toolbar" f {
    { T{ key-down f f "s" } com-step }
    { T{ key-down f f "i" } com-into }
    { T{ key-down f f "o" } com-out }
    { T{ key-down f f "b" } com-back }
    { T{ key-down f f "c" } com-continue }
    { T{ key-down f f "a" } com-abandon }
    { T{ key-down f f "q" } com-abandon }
    { T{ key-down f f "d" } close-window }
    { T{ key-down f f "w" } close-window }
    { T{ key-down f f "F1" } walker-help }
} define-command-map

walker-gadget "multitouch" f {
    { left-action com-back }
    { right-action com-step }
    { up-action com-out }
    { down-action com-into }
    { zoom-out-action close-window }
    { zoom-in-action com-abandon }
} define-command-map

: walker-for-thread? ( thread gadget -- ? )
    {
        { [ dup walker-gadget? not ] [ 2drop f ] }
        { [ dup closing?>> ] [ 2drop f ] }
        [ thread>> eq? ]
    } cond ;

: find-walker-window ( thread -- world/f )
    '[ _ swap walker-for-thread? ] find-window ;

: walker-window ( status continuation thread -- )
    [ <walker-gadget> ] [ name>> ] bi open-status-window ;

[
    dup find-walker-window dup
    [ raise-window 3drop ] [ drop '[ _ _ _ walker-window ] with-ui ] if
] show-walker-hook set-global
