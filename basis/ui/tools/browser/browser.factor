! Copyright (C) 2006, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes combinators
combinators.short-circuit compiler.units debugger fonts help
help.apropos help.crossref help.home help.markup help.stylesheet
help.topics io.styles kernel literals make math math.vectors
models namespaces sequences sets system ui ui.commands
ui.gadgets ui.gadgets.borders ui.gadgets.editors
ui.gadgets.glass ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.status-bar ui.gadgets.toolbar ui.gadgets.tracks
ui.gadgets.viewports ui.gadgets.worlds ui.gestures ui.pens.solid
ui.theme ui.tools.browser.history ui.tools.browser.popups
ui.tools.common unicode vocabs ;
IN: ui.tools.browser

TUPLE: browser-gadget < tool history scroller search-field popup ;

browser-gadget default-font-size { 54 58 } n*v set-tool-dim

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
        2dup control-value =
        [ 2drop ] [ [ add-recent ] [ history>> add-history ] bi* ] if
    ]
    [ set-control-value ]
    2bi ;

CONSTANT: prev -1
CONSTANT: next 1

: add-navigation-arrow ( str direction -- str )
    prev = [ "←" prefix ] [ "→" suffix ] if ;

: $navigation-arrow ( content element direction -- )
    [ prefix 1array ] dip add-navigation-arrow , ;

:: $navigation ( topic direction -- )
    help-path-style get [
        topic [
            direction prev/next-article
            [ 1array \ $long-link direction $navigation-arrow ] when*
        ] { } make [ ($navigation-table) ] unless-empty
    ] with-style ;

: $title ( topic -- )
    title-style get clone page-color over delete-at
    [
        [ ($title) ]
        [ ($navigation-path) ] bi
    ] with-nesting ;

: <help-header> ( browser-gadget -- gadget )
    model>> [ '[ _ $title ] try ] <pane-control> ;

: add-help-header ( track -- track )
    dup <help-header> { 3 3 } <border>
    help-header-background <solid> >>interior 
    { 1 0 } >>fill f track-add ;

: <help-footer> ( browser-gadget direction -- gadget )
    [ model>> ] dip '[ [ _ $navigation ] try ] <pane-control>
    { 0 0 } <border> { 1/2 1/2 } >>align
    toolbar-background <solid> >>interior ;

: add-help-footer ( track -- track )
    horizontal <track> with-lines
    dupd swap prev <help-footer> 1 track-add
    dupd swap next <help-footer> 1 track-add
    f track-add ;

: print-topic ( topic -- )
    >link
    last-element off
    article-content print-content ;

: <help-pane> ( browser-gadget -- gadget )
    model>> [ '[ _ print-topic ] try ] <pane-control> ;

: add-help-pane ( track -- track )
    dup dup <help-pane> margins
    <scroller> >>scroller scroller>> white-interior 1 track-add ;

: search-browser ( string browser -- )
    '[ [ blank? ] trim <apropos-search> _ show-help ] unless-empty ;

: <search-field> ( browser -- field )
    '[ _ search-browser ] <action-field>
        "Search" >>default-text
        10 >>min-cols
        10 >>max-cols
        white-interior ;

: <browser-toolbar> ( browser -- toolbar )
    [ <toolbar> ] [
        search-field>> horizontal <track>
            0 >>fill swap 1 track-add
        1 track-add
    ] bi ;

: add-browser-toolbar ( track -- track )
    dup <browser-toolbar> format-toolbar f track-add ;

: <browser-gadget> ( link -- gadget )
    vertical browser-gadget new-track with-lines
        1 >>fill
        swap >link <model> >>model
        dup <history> >>history
        dup <search-field> >>search-field
        add-browser-toolbar
        add-help-header
        add-help-pane
        add-help-footer ;

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

M: browser-gadget definitions-changed
    [ control-value swap showing-definition? ] keep
    '[ _ [ history-value ] keep set-history-value ] when ;

M: browser-gadget focusable-child* search-field>> ;

: com-browse-new ( topic -- )
    <browser-gadget>
    <world-attributes>
        "Browser" >>title
    open-status-window ;

: browser-window ( -- )
    "help.home" com-browse-new ;

: error-help-window ( error -- )
    {
        [ error-help ]
        [ dup tuple? [ class-of ] [ drop "errors" ] if ]
    } 1|| com-browse-new ;

\ browser-window H{ { +nullary+ t } } define-command

: com-browse ( link -- )
    [ browser-gadget? ] find-window
    [ [ raise-window ] [ gadget-child show-help ] bi ]
    [ com-browse-new ] if* ;

: show-browser ( -- )
    [ browser-gadget? ] find-window
    [ [ raise-window ] [ request-focus ] bi ] [ browser-window ] if* ;

\ show-browser H{ { +nullary+ t } } define-command

: com-back ( browser -- ) history>> go-back ;

: com-forward ( browser -- ) history>> go-forward ;

: browser-focus-search ( browser -- ) search-field>> request-focus ;

: com-home ( browser -- ) "help.home" swap show-help ;

: browser-help ( -- ) "ui-browser" com-browse ;

: glossary ( -- ) "conventions" com-browse ;

\ browser-help H{ { +nullary+ t } } define-command
\ glossary H{ { +nullary+ t } } define-command

browser-gadget "toolbar" f {
    { T{ key-down f ${ os macosx? M+ A+ ? } "LEFT" } com-back }
    { T{ key-down f ${ os macosx? M+ A+ ? } "RIGHT" } com-forward }
    { T{ key-down f ${ os macosx? M+ A+ ? } "HOME" } com-home }
    { T{ key-down f f "F1" } browser-help }
    { T{ key-down f ${ os macosx? M+ A+ ? } "F1" } glossary }
} define-command-map

: ?show-help ( link browser -- )
    over [ show-help ] [ 2drop ] if ;

: navigate ( browser quot -- )
    '[ control-value @ ] keep ?show-help ; inline

: com-up ( browser -- ) [ article-parent ] navigate ;

: com-prev ( browser -- ) [ prev-article ] navigate ;

: com-next ( browser -- ) [ next-article ] navigate ;

browser-gadget "navigation" "Commands for navigating in the article hierarchy" {
    { T{ key-down f ${ os macosx? M+ A+ ? } "UP" } com-up }
    { T{ key-down f ${ os macosx? M+ A+ ? } "p" } com-prev }
    { T{ key-down f ${ os macosx? M+ A+ ? } "n" } com-next }
    { T{ key-down f ${ os macosx? M+ A+ ? } "k" } com-show-outgoing-links }
    { T{ key-down f ${ os macosx? M+ A+ ? } "K" } com-show-incoming-links }
    { T{ key-down f ${ os macosx? M+ A+ ? } "f" } browser-focus-search }
} os macosx? [ {
    { T{ key-down f { M+ } "[" } com-back }
    { T{ key-down f { M+ } "]" } com-forward }
} append ] when define-command-map

browser-gadget "multi-touch" f {
    { left-action com-back }
    { right-action com-forward }
} define-command-map

browser-gadget "touchbar" f {
    { f com-back }
    { f com-forward }
    { f com-home }
    { f browser-help }
    { f glossary }
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

: com-font-size-normal ( browser -- )
    font-size-span default-style get font-size of -
    adjust-help-font-size model>> notify-connections ;

browser-gadget "fonts" f {
    { T{ key-down f ${ os macosx? M+ C+ ? } "+" } com-font-size-plus }
    { T{ key-down f ${ os macosx? M+ C+ ? } "=" } com-font-size-plus }
    { T{ key-down f ${ os macosx? M+ C+ ? } "_" } com-font-size-minus }
    { T{ key-down f ${ os macosx? M+ C+ ? } "-" } com-font-size-minus }
    { T{ key-down f ${ os macosx? M+ C+ ? } "0" } com-font-size-normal }
} define-command-map

MAIN: browser-window
