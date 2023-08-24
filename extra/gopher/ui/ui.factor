! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays debugger fonts gopher gopher.private
kernel math.vectors models present sequences ui ui.commands
ui.gadgets ui.gadgets.editors ui.gadgets.panes
ui.gadgets.scrollers ui.gadgets.status-bar ui.gadgets.toolbar
ui.gadgets.tracks ui.gadgets.viewports ui.gestures ui.operations
ui.tools.browser ui.tools.browser.history ui.tools.common urls
webbrowser ;

IN: gopher.ui

TUPLE: gopher-gadget < tool history scroller url-field ;

gopher-gadget default-font-size { 50 50 } n*v set-tool-dim

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

: ?gopher-url ( obj -- url )
    present dup "://" subseq-of? [ "gopher://" prepend ] unless >url ;

: show-gopher ( url gopher-gadget -- )
    [ [ ?gopher-url ] [ f ] if* ] dip
    over [ protocol>> "gopher" = ] [ t ] if* [
        [
            2dup control-value =
            [ 2drop ] [ nip history>> add-history ] if
        ]
        [ set-control-value ]
        2bi
    ] [ drop open-url ] if ;

: <url-field> ( gopher-gadget -- field )
    '[ _ show-gopher ] <action-field>
        "Gopher URL" >>default-text
        white-interior ;

: <gopher-pane> ( gopher-gadget -- gadget )
    model>> [ '[ _ [ gopher. ] when* ] try ] <pane-control> ;

: <gopher-toolbar> ( browser -- toolbar )
    horizontal <track>
        0 >>fill
        1/2 >>align
        { 5 5 } >>gap
        over <toolbar> f track-add
        swap url-field>> 1 track-add ;

: add-gopher-toolbar ( track -- track )
    dup <gopher-toolbar> format-toolbar f track-add ;

: add-gopher-pane ( track -- track )
    dup dup <gopher-pane> margins
    <scroller> >>scroller scroller>> white-interior 1 track-add ;

: <gopher-gadget> ( -- gadget )
    vertical gopher-gadget new-track with-lines
        f <model> >>model
        dup <history> >>history
        dup <url-field> >>url-field
        add-gopher-toolbar
        add-gopher-pane ;

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

: gopher-main ( -- )
    [ "gopher.quux.org" open-gopher-window ] with-ui ;

MAIN: gopher-main
