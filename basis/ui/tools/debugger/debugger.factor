! Copyright (C) 2006, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays hashtables io kernel math models
colors.constants namespaces sequences words continuations
debugger prettyprint help editors fonts ui ui.commands
ui.debugger ui.gestures ui.gadgets ui.pens.solid
ui.gadgets.worlds ui.gadgets.packs ui.gadgets.buttons
ui.gadgets.labels ui.gadgets.presentations ui.gadgets.panes
ui.gadgets.viewports ui.gadgets.tables ui.theme
ui.gadgets.tracks ui.gadgets.toolbar ui.gadgets.scrollers
ui.gadgets.borders ui.gadgets.status-bar ui.theme.images
ui.tools.traceback ui.tools.inspector ui.tools.browser
ui.tools.common ;
IN: ui.tools.debugger

TUPLE: debugger < track error restarts restart-hook restart-list continuation ;

<PRIVATE

SINGLETON: restart-renderer

M: restart-renderer row-columns
    drop [ name>> ] [ "Abort" ] if* "• " prepend 1array ;

: <restart-list> ( debugger -- gadget )
    dup restarts>> f prefix <model> restart-renderer <table>
        [ [ \ continue-restart invoke-command ] when* ] >>action
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
    ] bi ;

PRIVATE>

: <debugger> ( error continuation restarts restart-hook -- debugger )
    vertical debugger new-track with-lines
        swap >>restart-hook
        swap >>restarts
        swap >>continuation
        swap >>error
        dup <restart-list> >>restart-list
        dup <error-display> margins white-interior f track-add
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
    { T{ key-down f { C+ } "i" } com-inspect }
    { T{ key-down f { C+ } "t" } com-traceback }
    { T{ key-down f { C+ } "h" } com-help }
    { T{ key-down f { C+ } "e" } com-edit }
} define-command-map
