! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors editors fry kernel sequences ui ui.gadgets
ui.gadgets.borders ui.gadgets.buttons ui.gadgets.packs
ui.gadgets.scrollers ui.tools.listener vocabs.loader ;
IN: editors.ui

: <reload-editor-button> ( editor -- button )
    dup '[ drop [ _ reload ] \ run call-listener ] <border-button> ;

: <editor-reloader> ( -- gadget )
    <filled-pile> { 2 2 } >>gap available-editors
    [ <reload-editor-button> add-gadget ] each ;

MAIN-WINDOW: editor-window { { title "Editors" } }
    <editor-reloader> { 2 2 } <border> <scroller> >>gadgets ;
