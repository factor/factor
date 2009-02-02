! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays hashtables io kernel math models
namespaces sequences sequences words continuations debugger
prettyprint help editors ui ui.commands ui.gestures ui.gadgets
ui.gadgets.worlds ui.gadgets.packs ui.gadgets.buttons
ui.gadgets.labels ui.gadgets.panes ui.gadgets.presentations
ui.gadgets.viewports ui.gadgets.lists ui.gadgets.tracks
ui.gadgets.scrollers ui.gadgets.panes ui.tools.traceback ;
IN: ui.tools.debugger

TUPLE: debugger < track error restarts restart-hook restart-list continuation ;

<PRIVATE

: <restart-list> ( debugger -- gadget )
    [ restart-hook>> ] [ restarts>> ] bi
    [ name>> ] swap <model> <list> ; inline

: <error-pane> ( error -- pane )
    <pane> [ [ print-error ] with-pane ] keep ; inline

: <debugger-display> ( debugger -- gadget )
    <filled-pile>
        over error>> <error-pane> add-gadget
        swap restart-list>> add-gadget ; inline

PRIVATE>

: <debugger> ( error restarts restart-hook -- gadget )
    vertical debugger new-track
        add-toolbar
        swap >>restart-hook
        swap >>restarts
        swap >>error
        error-continuation get >>continuation
        dup <restart-list> >>restart-list
        dup <debugger-display> <scroller> 1 track-add ;

M: debugger focusable-child* restart-list>> ;

: debugger-window ( error -- )
    #! No restarts for the debugger window
    f [ drop ] <debugger> "Error" open-window ;

GENERIC: error-in-debugger? ( error -- ? )

M: world-error error-in-debugger? world>> gadget-child debugger? ;

M: object error-in-debugger? drop f ;

[
    dup error-in-debugger? [ rethrow ] [ debugger-window ] if 
] ui-error-hook set-global

M: world-error error.
    "An error occurred while drawing the world " write
    dup world>> pprint-short "." print
    "This world has been deactivated to prevent cascading errors." print
    error>> error. ;

debugger "gestures" f {
    { T{ button-down } request-focus }
} define-command-map

: com-traceback ( debugger -- ) continuation>> traceback-window ;

\ com-traceback H{ } define-command

: com-help ( debugger -- ) error>> (:help) ;

\ com-help H{ { +listener+ t } } define-command

: com-edit ( debugger -- ) error>> (:edit) ;

\ com-edit H{ { +listener+ t } } define-command

debugger "toolbar" f {
    { T{ key-down f f "s" } com-traceback }
    { T{ key-down f f "h" } com-help }
    { T{ key-down f f "e" } com-edit }
} define-command-map
