! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.tools.workspace inspector kernel ui.commands
ui.gadgets ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.slots ui.gadgets.tracks ui.gestures
ui.gadgets.buttons namespaces ;
IN: ui.tools.inspector

TUPLE: inspector-gadget object pane ;

: refresh ( inspector -- )
    dup inspector-gadget-object swap inspector-gadget-pane [
        H{ { +editable+ t } { +number-rows+ t } } describe*
    ] with-pane ;

: <inspector-gadget> ( -- gadget )
    inspector-gadget construct-empty
    [
        toolbar,
        <pane> g-> set-inspector-gadget-pane <scroller> 1 track,
    ] { 0 1 } build-track ;

: inspect-object ( obj inspector -- )
    [ set-inspector-gadget-object ] keep refresh ;

\ &push H{ { +nullary+ t } { +listener+ t } } define-command

\ &back H{ { +nullary+ t } { +listener+ t } } define-command

: globals ( -- ) global inspect ;

\ globals H{ { +nullary+ t } { +listener+ t } } define-command

: inspector-help "ui-inspector" help-window ;

\ inspector-help H{ { +nullary+ t } } define-command

inspector-gadget "toolbar" f {
    { T{ update-object } refresh }
    { f &push }
    { f &back }
    { f globals }
    { T{ key-down f f "F1" } inspector-help }
} define-command-map

M: inspector-gadget tool-scroller
    inspector-gadget-pane find-scroller ;
