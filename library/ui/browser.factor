! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-browser
USING: arrays gadgets gadgets-buttons gadgets-labels
gadgets-layouts gadgets-panes gadgets-scrolling gadgets-theme
generic hashtables help inspector kernel lists math namespaces
prettyprint sequences words ;

SYMBOL: components

H{ } clone components set-global

: get-components ( class -- assoc )
    components get-global hash [ { } ] unless*
    { "Slots" [ describe ] } add ;

{
    { "Definition" [ help ] }
    { "Calls in" [ usage. ] }
    { "Calls out" [ uses. ] }
} \ word components get-global set-hash

{
    { "Documentation" [ help ] }
} \ link components get-global set-hash

TUPLE: book page pages ;

: show-page ( key book -- )
    dup book-page unparent
    [ book-pages assoc ] keep
    [ set-book-page ] 2keep
    add-gadget ;

C: book ( pages -- book )
    dup delegate>gadget
    [ set-book-pages ] 2keep
    [ >r first first r> show-page ] keep ;

M: book pref-dim* ( book -- dim )
    book-pages { 0 0 0 } [ second pref-dim vmax ] reduce ;

M: book layout* ( book -- )
    dup rect-dim swap book-page set-gadget-dim ;

: component-pages ( obj -- assoc )
    dup class get-components
    [ first2 swapd make-pane <scroller> 2array ] map-with ;

: <tab> ( name book -- button )
    dupd [ show-page ] curry curry
    >r <label> r> <bevel-button> ;

: tabs ( assoc book gadget -- )
    >r swap [ first swap <tab> ] map-with r> add-gadgets ;

TUPLE: browser object history tabs ;

: save-current ( browser -- )
    dup browser-object swap browser-history push ;

: browse ( obj browser -- )
    [ set-browser-object ] 2keep
    dup browser-tabs clear-gadget
    >r component-pages dup <book> r>
    [ @center frame-add ] 2keep browser-tabs tabs ;

: find-browser [ browser? ] find-parent ;

: browse-back ( browser -- )
    dup browser-history dup empty?
    [ 2drop ] [ pop swap browse ] if ;

C: browser ( obj -- browser )
    V{ } clone over set-browser-history
    dup delegate>frame [
        "<" <label> [ find-browser browse-back ] <bevel-button> ,
        <shelf> dup pick set-browser-tabs ,
    ] { } make make-shelf dup highlight-theme
    over @top frame-add
    [ browse ] keep ;

TUPLE: browser-button object ;

: browser-window ( obj -- ) <browser> "Browser" open-window ;

: browser-button-action ( button -- )
    [ browser-button-object ] keep find-browser
    [ dup save-current browse ] [ browser-window ] if* ;

C: browser-button ( gadget object -- button )
    [ set-browser-button-object ] keep
    [
        >r [ browser-button-action ] <roll-button> r>
        set-gadget-delegate
    ] keep ;

M: browser-button gadget-help ( button -- string )
    browser-button-object dup word? [ synopsis ] [ summary ] if ;
