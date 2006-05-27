! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-tabs
USING: arrays gadgets gadgets-buttons gadgets-labels
gadgets-layouts gadgets-panes gadgets-scrolling gadgets-theme
kernel sequences ;

TUPLE: book page pages ;

: show-page ( n book -- )
    dup book-page unparent
    [ book-pages nth ] keep
    [ set-book-page ] 2keep
    add-gadget ;

C: book ( pages -- book )
    dup delegate>gadget
    [ set-book-pages ] keep
    0 over show-page ;

M: book pref-dim* ( book -- dim ) book-page pref-dim ;

M: book layout* ( book -- )
    dup rect-dim swap book-page set-gadget-dim ;

: <tab> ( name n book -- button )
    [ show-page drop ] curry curry
    >r <label> r> <bevel-button> ;

: make-tabs ( book names -- gadget )
    dup length [ pick <tab> ] 2map make-shelf
    dup highlight-theme nip ;

TUPLE: tabs buttons book ;

C: tabs dup delegate>frame ;

: set-tabs ( names pages tabs -- )
    {
        { [ <book> tuck ] set-tabs-book @center }
        { [ make-tabs ] set-tabs-buttons @top }
    } build-frame ;

: set-pages ( obj assoc tabs -- )
    >r flip first2 swapd [ make-pane <scroller> ] map-with
    r> set-tabs ;

: <pages> ( obj assoc -- tabs ) <tabs> [ set-pages ] keep ;
