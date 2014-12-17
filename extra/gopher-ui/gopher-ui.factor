! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays debugger fry gopher gopher.private
kernel models present sequences ui ui.commands ui.gadgets
ui.gadgets.borders ui.gadgets.buttons ui.gadgets.editors
ui.gadgets.panes ui.gadgets.scrollers ui.gadgets.status-bar
ui.gadgets.tracks ui.gadgets.viewports ui.gestures ui.operations
ui.tools.browser ui.tools.browser.history ui.tools.common urls ;

IN: gopher-ui

TUPLE: gopher-gadget < tool history scroller url-field ;

{ 600 600 } gopher-gadget set-tool-dim

M: gopher-gadget history-value
    [ control-value ] [ scroller>> scroll-position ]
    bi 2array ;

M: gopher-gadget set-history-value
    [ first2 ] dip
    [ set-control-value ] [ scroller>> set-scroll-position ]
    bi-curry bi* ;

M: gopher-gadget model-changed
    [ value>> present ]
    [ url-field>> editor>> set-editor-string ] bi* ;

: show-gopher ( url gopher-gadget -- )
    [ [ >url ] [ f ] if* ] dip
    [
        2dup control-value =
        [ 2drop ] [ nip history>> add-history ] if
    ]
    [ set-control-value ]
    2bi ;

: <url-field> ( gopher-gadget -- field )
    '[ >url _ show-gopher ] <action-field> ;

: <gopher-pane> ( gopher-gadget -- gadget )
    model>> [ '[ _ [ gopher. ] when* ] try ] <pane-control> ;

: <gopher-toolbar> ( browser -- toolbar )
    horizontal <track>
        0 >>fill
        1/2 >>align
        { 5 5 } >>gap
        over <toolbar> f track-add
        swap url-field>> 1 track-add ;

: <gopher-gadget> ( -- gadget )
    vertical gopher-gadget new-track
        f <model> >>model
        dup <history> >>history
        dup <url-field> >>url-field
        dup <gopher-toolbar> { 3 3 } <border> { 1 0 } >>fill f track-add
        dup <gopher-pane> { 3 3 } <border> { 1 1 } >>fill
        <scroller> [ >>scroller ] [ 1 track-add ] bi ;

: open-gopher-window ( url -- )
    <gopher-gadget>
    [ "Gopher" open-status-window ]
    [ show-gopher ] bi ;

: com-clear ( gopher -- )
    f swap set-control-value ;

: com-gopher ( url -- )
    [ gopher-gadget? ] find-window
    [ [ raise-window ] [ gadget-child show-gopher ] bi ]
    [ open-gopher-window ] if* ;

gopher-gadget "toolbar" f {
    { f com-back }
    { f com-forward }
    { f com-clear }
} define-command-map

gopher-gadget "scrolling" f {
    { T{ key-down f f "UP" } com-scroll-up }
    { T{ key-down f f "DOWN" } com-scroll-down }
    { T{ key-down f f "PAGE_UP" } com-page-up }
    { T{ key-down f f "PAGE_DOWN" } com-page-down }
} define-command-map

[ gopher-link? ] \ com-gopher H{ { +primary+ t } } define-operation
