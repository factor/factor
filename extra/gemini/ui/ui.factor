! Copyright (C) 2021 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays debugger fonts gemini kernel
math.vectors models present sequences splitting ui ui.commands
ui.gadgets ui.gadgets.editors ui.gadgets.panes
ui.gadgets.scrollers ui.gadgets.status-bar ui.gadgets.toolbar
ui.gadgets.tracks ui.gadgets.viewports ui.gestures ui.operations
ui.tools.browser ui.tools.browser.history ui.tools.common urls
webbrowser ;

IN: gemini.ui

TUPLE: gemini-gadget < tool history scroller url-field ;

gemini-gadget default-font-size { 50 50 } n*v set-tool-dim

M: gemini-gadget history-value
    [ control-value ] [ scroller>> scroll-position ]
    bi 2array ;

M: gemini-gadget set-history-value
    [ first2 ] dip
    [ set-control-value ] [ scroller>> set-scroll-position ]
    bi-curry bi* ;

M: gemini-gadget model-changed
    [ value>> present ]
    [ url-field>> editor>> set-editor-string ] bi* ;

: ?gemini-url ( obj -- url )
    present dup "://" subseq-of? [ "gemini://" prepend ] unless >url ;

: show-gemini ( url gemini-gadget -- )
    [ [ ?gemini-url ] [ f ] if* ] dip
    over [ protocol>> "gemini" = ] [ t ] if* [
        [
            2dup control-value =
            [ 2drop ] [ nip history>> add-history ] if
        ]
        [ set-control-value ]
        2bi
    ] [ drop open-url ] if ;

: <url-field> ( gemini-gadget -- field )
    '[ _ show-gemini ] <action-field>
        "Gemini URL" >>default-text
        white-interior ;

: <gemini-pane> ( gemini-gadget -- gadget )
    model>> [ '[ _ [ gemini. ] when* ] try ] <pane-control> ;

: <gemini-toolbar> ( browser -- toolbar )
    horizontal <track>
        0 >>fill
        1/2 >>align
        { 5 5 } >>gap
        over <toolbar> f track-add
        swap url-field>> 1 track-add ;

: add-gemini-toolbar ( track -- track )
    dup <gemini-toolbar> format-toolbar f track-add ;

: add-gemini-pane ( track -- track )
    dup dup <gemini-pane> margins
    <scroller> >>scroller scroller>> white-interior 1 track-add ;

: <gemini-gadget> ( -- gadget )
    vertical gemini-gadget new-track with-lines
        f <model> >>model
        dup <history> >>history
        dup <url-field> >>url-field
        add-gemini-toolbar
        add-gemini-pane ;

: open-gemini-window ( url -- )
    <gemini-gadget>
    [ "gemini" open-status-window ]
    [ show-gemini ] bi ;

: com-clear ( gemini -- )
    f swap set-control-value ;

: com-up ( gemini -- )
    [
        control-value dup [
            f >>query f >>anchor
            [ dup "/" tail? "./../" "./" ? url-append-path ] change-path
        ] when
    ]
    [ show-gemini ] bi ;

: com-gemini ( url -- )
    [ gemini-gadget? ] find-window
    [ [ raise-window ] [ gadget-child show-gemini ] bi ]
    [ open-gemini-window ] if* ;

gemini-gadget "toolbar" f {
    { f com-back }
    { f com-forward }
    { f com-up }
    { f com-clear }
} define-command-map

gemini-gadget "scrolling" f {
    { T{ key-down f f "UP" } com-scroll-up }
    { T{ key-down f f "DOWN" } com-scroll-down }
    { T{ key-down f f "PAGE_UP" } com-page-up }
    { T{ key-down f f "PAGE_DOWN" } com-page-down }
} define-command-map

[ dup url? [ protocol>> "gemini" = ] [ drop f ] if ] \ com-gemini H{ { +primary+ t } } define-operation

: gemini-main ( -- )
    [ "gemini.circumlunar.space" open-gemini-window ] with-ui ;

MAIN: gemini-main
