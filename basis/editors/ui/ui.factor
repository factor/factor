! Copyright (C) 2018 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors editors kernel namespaces sequences splitting
ui ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.packs ui.gadgets.scrollers ui.tools.listener
vocabs.loader vocabs.parser ;
IN: editors.ui

: <reload-editor-button> ( editor -- button )
    dup '[
        drop 
        [ _ [ reload ] [ use-vocab ] [ "editors." ?head drop search editor-class set-global ] tri ]
        \ run call-listener
    ] <border-button> ;

: <editor-reloader> ( -- gadget )
    <filled-pile> { 2 2 } >>gap available-editors
    [ <reload-editor-button> add-gadget ] each ;

MAIN-WINDOW: editor-window { { title "Editors" } }
    <editor-reloader> { 2 2 } <border> <scroller> >>gadgets ;
