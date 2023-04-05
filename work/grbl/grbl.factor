! File: grbl
! Version: 0.1
! DRI: Dave Carlton
! Description: GRBL controller interface
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors debugger io kernel literals models parser
system ui ui.commands ui.gadgets ui.gadgets.labels
ui.gadgets.panes ui.gadgets.scrollers ui.gadgets.status-bar
ui.gadgets.toolbar ui.gadgets.tracks ui.gadgets.worlds
ui.gestures ui.tools.browser ui.tools.common vocabs.parser ;
IN: grbl

TUPLE: grbl-gadget < tool
    connection received send ;

: com-back ( browser -- ) drop ;

: com-forward ( browser -- ) drop ; 

: com-home ( browser -- ) drop ;

grbl-gadget "toolbar" f {
    { T{ key-down f ${ os macosx? M+ A+ ? } "LEFT" } com-back }
    { T{ key-down f ${ os macosx? M+ A+ ? } "RIGHT" } com-forward }
    { T{ key-down f ${ os macosx? M+ A+ ? } "HOME" } com-home }
} define-command-map

: <grbl-toolbar> ( grbl -- toolbar )
    <toolbar> ;

: add-grbl-toolbar ( track -- track )
    dup <grbl-toolbar>  format-toolbar f track-add ;

: <comm-listen-pane> ( grbl-gadget -- gadget )
    model>> [ [ print ] curry try ]  <pane-control> ;

: add-comm-listen-pane ( track -- track )
    <comm-listen-pane> margins  <scroller> >>scroller
    scroller>> white-interior  1 track-add ;

: <grbl-gadget> ( -- gadget )
    vertical grbl-gadget  new-track with-lines  1 >>fill
    add-grbl-toolbar add-comm-listen-pane ;

: (grbl-window) ( -- )
    <grbl-gadget> <world-attributes>  "GRBL" >>title
    open-status-window
    ;

: grbl-window ( -- )  (grbl-window) ;

MAIN-WINDOW: grbl
        {
            { title "GRBL" }
            { pref-dim { 640 480 } }
        }
        "GRBL" <label> >>gadgets
;
    
