! Copyright (C) 2019 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors escape-strings fonts kernel models.arrow
sequences ui ui.gadgets ui.gadgets.editors ui.gadgets.labeled
ui.gadgets.labels ui.gadgets.scrollers ui.gadgets.tracks ;
IN: escape-strings.ui

: <escape-string-ui> ( -- gadget )
    vertical <track>
        1 >>fill
        { 10 10 } >>gap

    <source-editor> [ model>> swap ] keep
    <scroller>

    "Plain Text" <labeled-gadget>
        1/3 track-add

    over [ "\n" join number-escape-string ] <arrow> 
    <label-control> monospace-font >>font
    <scroller>

    "Number Escape" <labeled-gadget>
        1/3 track-add

    swap [ "\n" join escape-string ] <arrow>
    <label-control> monospace-font >>font
    <scroller>

    "Lua Escape" <labeled-gadget>
        1/3 track-add ;


MAIN-WINDOW: escape-string-ui
    {
        { title "Escape String Editor" }
        { pref-dim { 600 700 } }
    }
    <escape-string-ui> >>gadgets ;
