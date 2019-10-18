! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: gadgets-workspace gadgets-panes
gadgets-tiles gadgets-tracks gadgets-scrolling gadgets-slots
gadgets kernel definitions gadgets-listener inspector ;
IN: gadgets-inspector

TUPLE: inspector-gadget object pane ;

: refresh ( inspector -- )
    dup inspector-gadget-object swap inspector-gadget-pane [
        H{ { +editable+ t } { +number-rows+ t } } describe*
    ] with-pane ;

C: inspector-gadget ( -- gadget )
    [
        toolbar,
        <pane> g-> set-inspector-gadget-pane <scroller> 1 track,
    ] { 0 1 } build-track ;

: inspect ( obj inspector -- )
    [ set-inspector-gadget-object ] keep refresh ;

\ &push H{ { +nullary+ t } { +listener+ t } } define-command

\ &back H{ { +nullary+ t } { +listener+ t } } define-command

: inspector-help "ui-inspector" help-window ;

\ inspector-help H{ { +nullary+ t } } define-command

inspector-gadget "toolbar" f {
    { T{ update-object } refresh }
    { f &push }
    { f &back }
    { T{ key-down f f "F1" } inspector-help }
} define-command-map
