! Copyright (C) 2006, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays continuations debugger editors kernel
models namespaces sequences ui.commands ui.debugger ui.gadgets
ui.gadgets.labels ui.gadgets.packs ui.gadgets.panes
ui.gadgets.scrollers ui.gadgets.status-bar ui.gadgets.tables
ui.gadgets.toolbar ui.gadgets.tracks ui.gadgets.worlds
ui.gestures ui.tools.browser ui.tools.common ui.tools.inspector
ui.tools.traceback ;
IN: ui.tools.debugger

TUPLE: debugger < track error restarts restart-hook restart-list continuation ;

<PRIVATE

SINGLETON: restart-renderer

M: restart-renderer row-columns
    drop [ name>> ] [ "Abort" ] if* "• " prepend 1array ;

: <restart-list> ( debugger -- gadget )
    dup restarts>> f prefix <model> restart-renderer <table>
        [
            [
                ! The "Abort" restart is actually an `f` object, so to show a restart
                ! with information but do nothing, we define a no-op-restart
                dup obj>> no-op-restart =
                [ drop ] [ \ continue-restart invoke-command ] if
            ] when*
        ] >>action
        swap restart-hook>> >>hook
        t >>selection-required?
        t >>single-click? ; inline

: <error-pane> ( error -- pane )
    <pane> [ [ print-error ] with-pane ] keep ; inline

: <error-display> ( debugger -- gadget )
    [ <filled-pile> ] dip
    [ error>> <error-pane> add-gadget ]
    [
        dup restart-hook>> [
            [ "To continue, pick one of the options below:" <label> add-gadget ] dip
            restart-list>> add-gadget
        ] [ drop ] if
    ] bi <scroller> ;

PRIVATE>

: <debugger> ( error continuation restarts restart-hook -- debugger )
    vertical debugger new-track with-lines
        swap >>restart-hook
        swap >>restarts
        swap >>continuation
        swap >>error
        dup <restart-list> >>restart-list
        dup <error-display> margins white-interior 1 track-add
        add-toolbar ;

M: debugger focusable-child*
    dup restart-hook>> [ restart-list>> ] [ drop t ] if ;

: debugger-window ( error continuation -- )
    ! No restarts for the debugger window
    f f <debugger> "Error" open-status-window ;

GENERIC: error-in-debugger? ( error -- ? )

M: world-error error-in-debugger?
    world>> children>> ?first debugger? ;

M: object error-in-debugger? drop f ;

[
    dup error-in-debugger?
    [ error-alert ] [ error-continuation get debugger-window ] if
] ui-error-hook set-global

debugger "gestures" f {
    { T{ button-down } request-focus }
} define-command-map

: com-inspect ( debugger -- ) error>> inspector ;

: com-traceback ( debugger -- ) continuation>> traceback-window ;

: com-help ( debugger -- ) error>> error-help-window ;

: com-edit ( debugger -- ) error>> edit-error ;

\ com-edit H{ { +listener+ t } } define-command

debugger "toolbar" f {
    { T{ key-down f f "i" } com-inspect }
    { T{ key-down f f "t" } com-traceback }
    { T{ key-down f f "h" } com-help }
    { T{ key-down f f "e" } com-edit }
} define-command-map
