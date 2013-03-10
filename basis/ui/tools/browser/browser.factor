! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes combinators
combinators.short-circuit compiler.units debugger fry help
help.apropos help.crossref help.home help.topics help.stylesheet
kernel models sequences sets ui ui.commands ui.gadgets
ui.gadgets.borders ui.gadgets.buttons ui.gadgets.editors
ui.gadgets.glass ui.gadgets.labels ui.gadgets.panes
ui.gadgets.scrollers ui.gadgets.status-bar ui.gadgets.tracks
ui.gadgets.viewports ui.gestures ui.tools.browser.history
ui.tools.browser.popups ui.tools.common vocabs ;
IN: ui.tools.browser

TUPLE: browser-gadget < tool history scroller search-field popup ;

{ 650 700 } browser-gadget set-tool-dim

M: browser-gadget history-value
    [ control-value ] [ scroller>> scroll-position ]
    bi 2array ;

M: browser-gadget set-history-value
    [ first2 ] dip
    [ set-control-value ] [ scroller>> set-scroll-position ]
    bi-curry bi* ;

: show-help ( link browser-gadget -- )
    [ >link ] dip
    [
        2dup model>> value>> =
        [ 2drop ] [ [ add-recent ] [ history>> add-history ] bi* ] if
    ]
    [ model>> set-model ]
    2bi ;

: <help-pane> ( browser-gadget -- gadget )
    model>> [ '[ _ print-topic ] try ] <pane-control> ;

: search-browser ( string browser -- )
    '[ <apropos-search> _ show-help ] unless-empty ;

: <search-field> ( browser -- field )
    '[ _ search-browser ] <action-field>
        10 >>min-cols
        10 >>max-cols ;

: <browser-toolbar> ( browser -- toolbar )
    horizontal <track>
        0 >>fill
        1/2 >>align
        { 5 5 } >>gap
        over <toolbar> f track-add
        swap search-field>> "Search:" label-on-left 1 track-add ;

: <browser-gadget> ( link -- gadget )
    vertical browser-gadget new-track
        1 >>fill
        swap >link <model> >>model
        dup <history> >>history
        dup <search-field> >>search-field
        dup <browser-toolbar> { 3 3 } <border> { 1 0 } >>fill f track-add
        dup dup <help-pane> { 10 0 } <border> { 1 1 } >>fill
        <scroller> >>scroller scroller>> 1 track-add ;

M: browser-gadget graft*
    [ add-definition-observer ] [ call-next-method ] bi ;

M: browser-gadget ungraft*
    [ call-next-method ] [ remove-definition-observer ] bi ;

M: browser-gadget handle-gesture
    {
        { [ over key-gesture? not ] [ call-next-method ] }
        { [ dup popup>> ] [ { [ pass-to-popup ] [ call-next-method ] } 2&& ] }
        [ call-next-method ]
    } cond ;

: showing-definition? ( defspec set -- ? )
    {
        [ in? ]
        [ [ dup word-link? [ name>> ] when ] dip in? ]
        [ [ dup vocab-link? [ lookup-vocab ] when ] dip in? ]
    } 2|| ;

M: browser-gadget definitions-changed ( set browser -- )
    [ model>> value>> swap showing-definition? ] keep
    '[ _ [ history-value ] keep set-history-value ] when ;

M: browser-gadget focusable-child* search-field>> ;

: (browser-window) ( topic -- )
    <browser-gadget> "Browser" open-status-window ;

: browser-window ( -- )
    "help.home" (browser-window) ;

: error-help-window ( error -- )
    {
        [ error-help ]
        [ dup tuple? [ class-of ] [ drop "errors" ] if ]
    } 1|| (browser-window) ;

\ browser-window H{ { +nullary+ t } } define-command

: com-browse ( link -- )
    [ browser-gadget? ] find-window
    [ [ raise-window ] [ gadget-child show-help ] bi ]
    [ (browser-window) ] if* ;

: show-browser ( -- )
    [ browser-gadget? ] find-window
    [ [ raise-window ] [ request-focus ] bi ] [ browser-window ] if* ;

\ show-browser H{ { +nullary+ t } } define-command

: com-back ( browser -- ) history>> go-back ;

: com-forward ( browser -- ) history>> go-forward ;

: com-home ( browser -- ) "help.home" swap show-help ;

: browser-help ( -- ) "ui-browser" com-browse ;

: glossary ( -- ) "conventions" com-browse ;

\ browser-help H{ { +nullary+ t } } define-command
\ glossary H{ { +nullary+ t } } define-command

browser-gadget "toolbar" f {
    { T{ key-down f { A+ } "LEFT" } com-back }
    { T{ key-down f { A+ } "RIGHT" } com-forward }
    { T{ key-down f { A+ } "H" } com-home }
    { T{ key-down f f "F1" } browser-help }
    { T{ key-down f { A+ } "F1" } glossary }
} define-command-map

: ?show-help ( link browser -- )
    over [ show-help ] [ 2drop ] if ;

: navigate ( browser quot -- )
    '[ control-value @ ] keep ?show-help ; inline

: com-up ( browser -- ) [ article-parent ] navigate ;

: com-prev ( browser -- ) [ prev-article ] navigate ;

: com-next ( browser -- ) [ next-article ] navigate ;

browser-gadget "navigation" "Commands for navigating in the article hierarchy" {
    { T{ key-down f { A+ } "u" } com-up }
    { T{ key-down f { A+ } "p" } com-prev }
    { T{ key-down f { A+ } "n" } com-next }
    { T{ key-down f { A+ } "k" } com-show-outgoing-links }
    { T{ key-down f { A+ } "K" } com-show-incoming-links }
} define-command-map

browser-gadget "multi-touch" f {
    { left-action com-back }
    { right-action com-forward }
} define-command-map

browser-gadget "scrolling"
"The browser's scroller can be scrolled from the keyboard."
{
    { T{ key-down f f "UP" } com-scroll-up }
    { T{ key-down f f "DOWN" } com-scroll-down }
    { T{ key-down f f "PAGE_UP" } com-page-up }
    { T{ key-down f f "PAGE_DOWN" } com-page-down }
} define-command-map

: com-font-size-plus ( browser -- )
    2 adjust-help-font-size model>> notify-connections ;

: com-font-size-minus ( browser -- )
    -2 adjust-help-font-size model>> notify-connections ;

browser-gadget "fonts" f {
    { T{ key-down f { A+ } "+" } com-font-size-plus }
    { T{ key-down f { A+ } "=" } com-font-size-plus }
    { T{ key-down f { A+ } "_" } com-font-size-minus }
    { T{ key-down f { A+ } "-" } com-font-size-minus }
} define-command-map

MAIN: browser-window
