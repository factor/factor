! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-browser
USING: components gadgets gadgets-buttons gadgets-labels
gadgets-layouts gadgets-panes gadgets-scrolling gadgets-theme
hashtables help inspector kernel lists math namespaces
prettyprint sequences words ;

TUPLE: book page pages ;

: show-page ( key book -- )
    dup book-page unparent
    [ book-pages hash ] keep
    [ set-book-page ] 2keep
    add-gadget ;

C: book ( page pages -- book )
    dup delegate>gadget
    [ set-book-pages ] keep
    [ show-page ] keep ;

M: book pref-dim* ( book -- dim )
    { 0 0 0 } swap book-pages [ nip pref-dim vmax ] hash-each ;

M: book layout* ( book -- )
    dup rect-dim swap book-page set-gadget-dim ;

: component-page ( obj component -- gadget )
    component-builder make-pane <scroller> ;

: component-pages ( obj -- hash )
    dup get-components [
        [ component-name over ] keep component-page
    ] map>hash nip ;

: component-book ( hash -- book )
    dup hash-keys natural-sort first swap <book> ;

: <tab> ( name book -- button )
    dupd [ show-page ] curry curry
    >r <label> r> <bevel-button> ;

: tabs ( hash book gadget -- )
    >r swap hash-keys natural-sort
    [ swap <tab> ] map-with r> add-gadgets ;

TUPLE: browser object history tabs ;

: save-current ( browser -- )
    dup browser-object swap browser-history push ;

: browse ( obj browser -- )
    [ set-browser-object ] 2keep
    dup browser-tabs clear-gadget
    >r component-pages dup component-book r>
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

: in-browser ( obj -- )
    <browser> "Browser" simple-window ;

: browser-button-action ( button -- )
    [ browser-button-object ] keep find-browser
    [ dup save-current browse ] [ in-browser ] if* ;

C: browser-button ( gadget object -- button )
    [ set-browser-button-object ] keep
    [
        >r [ browser-button-action ] <roll-button> r>
        set-gadget-delegate
    ] keep ;

M: browser-button gadget-help ( button -- string )
    browser-button-object dup word? [ synopsis ] [ summary ] if ;
