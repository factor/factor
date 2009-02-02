! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: debugger help help.topics help.crossref kernel models compiler.units
assocs words vocabs accessors fry combinators.short-circuit
sequences models models.history tools.apropos
ui.commands ui.gadgets ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.tracks ui.gestures ui.gadgets.buttons ui.gadgets.packs
ui.gadgets.editors ui.gadgets.labels ui.gadgets.status-bar
ui.tools.common ui ;
IN: ui.tools.browser

TUPLE: browser-gadget < tool pane scroller search-field ;

{ 550 400 } browser-gadget set-tool-dim

: show-help ( link browser-gadget -- )
    model>> dup add-history
    [ >link ] dip set-model ;

: <help-pane> ( browser-gadget -- gadget )
    model>> [ '[ _ print-topic ] try ] <pane-control> ;

: search-browser ( string browser -- )
    '[ <apropos> _ show-help ] unless-empty ;

: <search-field> ( browser -- field )
    '[ _ search-browser ] <action-field>
        10 >>min-width
        10 >>max-width ;

: <browser-toolbar> ( browser -- toolbar )
    <shelf>
        +baseline+ >>align
        { 5 5 } >>gap
        over <toolbar> add-gadget
        swap search-field>> "Search:" label-on-left add-gadget ;

: <browser-gadget> ( link -- gadget )
    vertical browser-gadget new-track
        swap >link <history> >>model
        dup <search-field> >>search-field
        dup <browser-toolbar> f track-add
        dup <help-pane> >>pane
        dup pane>> <scroller> >>scroller
        dup scroller>> 1 track-add ;

M: browser-gadget graft*
    [ add-definition-observer ] [ call-next-method ] bi ;

M: browser-gadget ungraft*
    [ call-next-method ] [ remove-definition-observer ] bi ;

: showing-definition? ( defspec assoc -- ? )
    {
        [ key? ]
        [ [ dup word-link? [ name>> ] when ] dip key? ]
        [ [ dup vocab-link? [ vocab ] when ] dip key? ]
    } 2|| ;

M: browser-gadget definitions-changed ( assoc browser -- )
    model>> [ value>> swap showing-definition? ] keep
    '[ _ notify-connections ] when ;

M: browser-gadget focusable-child* search-field>> ;

: (browser-window) ( topic -- )
    <browser-gadget> "Browser" open-status-window ;

: browser-window ( -- )
    "handbook" (browser-window) ;

\ browser-window H{ { +nullary+ t } } define-command

: com-follow ( link -- )
    [ browser-gadget? ] find-window
    [ [ raise-window ] [ gadget-child show-help ] bi ]
    [ (browser-window) ] if* ;

: show-browser ( -- ) "handbook" com-follow ;

\ show-browser H{ { +nullary+ t } } define-command

: com-back ( browser -- ) model>> go-back ;

: com-forward ( browser -- ) model>> go-forward ;

: com-documentation ( browser -- ) "handbook" swap show-help ;

: browser-help ( -- ) "ui-browser" com-follow ;

\ browser-help H{ { +nullary+ t } } define-command

browser-gadget "toolbar" f {
    { T{ key-down f { A+ } "LEFT" } com-back }
    { T{ key-down f { A+ } "RIGHT" } com-forward }
    { f com-documentation }
    { T{ key-down f f "F1" } browser-help }
} define-command-map

: ?show-help ( link browser -- )
    over [ show-help ] [ 2drop ] if ;

: navigate ( browser quot -- )
    '[ control-value @ ] keep ?show-help ;

: com-up ( browser -- ) [ article-parent ] navigate ;

: com-prev ( browser -- ) [ prev-article ] navigate ;

: com-next ( browser -- ) [ next-article ] navigate ;

browser-gadget "navigation" "Commands for navigating in the article hierarchy" {
    { T{ key-down f { A+ } "u" } com-up }
    { T{ key-down f { A+ } "p" } com-prev }
    { T{ key-down f { A+ } "n" } com-next }
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

MAIN: browser-window