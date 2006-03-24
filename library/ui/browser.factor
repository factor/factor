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

: tabs ( hash book -- gadget )
    swap hash-keys natural-sort
    [ swap <tab> ] map-with make-pile
    1 over set-pack-fill dup highlight-theme ;

TUPLE: browser history ;

: browse ( obj browser -- )
    swap component-pages
    [ component-book dup pick @center frame-add ] keep
    swap tabs over @left frame-add ;

C: browser ( obj -- browser )
    dup delegate>frame [ browse ] keep ;

TUPLE: browser-button object ;

: in-browser ( obj -- )
    [ <browser> "Browser: " ] keep unparse-short append
    simple-window ;

C: browser-button ( gadget object -- button )
    [ set-browser-button-object ] keep
    [
        >r [ browser-button-object in-browser ] <roll-button> r>
        set-gadget-delegate
    ] keep ;

M: browser-button gadget-help ( button -- string )
    browser-button-object dup word? [ synopsis ] [ summary ] if ;
