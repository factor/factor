! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes continuations help help.topics kernel models
sequences assocs arrays namespaces accessors math.vectors fry ui
ui.backend ui.tools.debugger ui.gadgets ui.gadgets.books
ui.gadgets.buttons ui.gadgets.labelled ui.gadgets.panes
ui.gadgets.scrollers ui.gadgets.tracks ui.gadgets.worlds
ui.gadgets.presentations ui.gadgets.status-bar ui.commands
ui.gestures ;
IN: ui.tools.workspace

TUPLE: workspace < track listener popup ;

: find-workspace ( gadget -- workspace ) [ workspace? ] find-parent ;

SYMBOL: workspace-window-hook

: workspace-window* ( -- workspace ) workspace-window-hook get call ;

: workspace-window ( -- ) workspace-window* drop ;

: get-workspace* ( quot -- workspace )
    '[ dup workspace? _ [ drop f ] if ] find-window
    [ dup raise-window gadget-child ]
    [ workspace-window* ] if* ; inline

: get-workspace ( -- workspace ) [ drop t ] get-workspace* ;

: hide-popup ( workspace -- )
    dup popup>> track-remove
    f >>popup
    request-focus ;

: show-popup ( gadget workspace -- )
    dup hide-popup
    over >>popup
    over f track-add drop
    request-focus ;

: show-titled-popup ( workspace gadget title -- )
    [ find-workspace hide-popup ] <closable-gadget>
    swap show-popup ;

: debugger-popup ( error workspace -- )
    swap dup compute-restarts
    [ find-workspace hide-popup ] <debugger>
    "Error" show-titled-popup ;

SYMBOL: workspace-dim

{ 600 700 } workspace-dim set-global

M: workspace pref-dim* call-next-method workspace-dim get vmax ;

M: workspace focusable-child*
    [ popup>> ] [ listener>> ] bi or ;


