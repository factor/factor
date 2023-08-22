! Copyright (C) 2006, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators concurrency.messaging kernel
models namespaces sequences threads tools.walker ui ui.commands
ui.gadgets ui.gadgets.labels ui.gadgets.status-bar
ui.gadgets.toolbar ui.gadgets.tracks ui.gestures ui.pens.solid
ui.theme ui.tools.browser ui.tools.common ui.tools.traceback ;
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

: thread-status-text ( status -- string )
    {
        { +stopped+ "Stopped" }
        { +suspended+ "Suspended" }
        { +running+ "Running" }
    } at "(" ")" surround ;

: thread-status-foreground ( status -- color )
    {
      { +stopped+   [ thread-status-stopped-foreground ] }
      { +suspended+ [ thread-status-suspended-foreground ] }
      { +running+   [ thread-status-running-foreground ] }
      { f           [ text-color ] }
    } case ;

: thread-status-background ( status -- color )
    {
      { +stopped+   [ thread-status-stopped-background ] }
      { +suspended+ [ thread-status-suspended-background ] }
      { +running+   [ thread-status-running-background ] }
      { f           [ content-background ] }
    } case ;

TUPLE: thread-status < label ;

M: thread-status model-changed
    [ value>> ] dip {
        [ [ thread-status-text ] [ string<< ] bi* ]
        [ [ thread-status-foreground ] [ font>> foreground<< ] bi* ]
        [ [ thread-status-background <solid> ] [ parent>> parent>> interior<< ] bi* ]
    } 2cleave ;

: <thread-status> ( model -- gadget )
    "" thread-status new-label
        swap >>model ;

: add-thread-status ( track -- track )
    horizontal <track> { 5 5 } >>gap
        "Thread:" <label>
            [ t >>bold? ] change-font
            f track-add
        self name>> <label> f track-add
        over status>> <thread-status>
            dup font>> t >>bold? drop
            f track-add
    margins f track-add ;

: add-traceback ( track -- track )
    dup traceback>> 1 track-add ;

: <walker-gadget> ( status continuation thread -- gadget )
    vertical walker-gadget new-track with-lines
        swap >>thread
        swap >>continuation
        swap >>status
        dup continuation>> <traceback-gadget> >>traceback
        add-toolbar
        add-thread-status
        add-traceback ;

: walker-help ( -- ) "ui-walker" com-browse ;

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
