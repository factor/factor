! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-tabs
USING: arrays gadgets gadgets-buttons gadgets-frames
gadgets-grids gadgets-labels gadgets-panes gadgets-scrolling
gadgets-theme kernel sequences ;

TUPLE: book page pages ;

: show-page ( gadget book -- )
    dup book-page unparent [ set-book-page ] 2keep add-gadget ;

C: book ( pages -- book )
    dup delegate>gadget
    [ set-book-pages ] keep
    dup book-pages first over show-page ;

M: book pref-dim* ( book -- dim ) book-page pref-dim ;

M: book layout* ( book -- )
    dup rect-dim swap book-page set-gadget-dim ;

TUPLE: radio-box value buttons quot ;

: update-selection ( radio-box -- )
    dup radio-box-buttons [
        second f swap set-button-selected?
    ] each
    dup radio-box-value over radio-box-buttons assoc
    t swap set-button-selected?
    dup dup radio-box-quot call
    relayout-1 ;

: find-radio-box [ radio-box? ] find-parent ;

: set-radio-box-value* ( value gadget -- )
    [ set-radio-box-value ] keep update-selection ;

: select-value ( button value -- )
    swap find-radio-box set-radio-box-value* ;

: <radio-button> ( string value -- gadget )
    [ select-value ] curry >r <label> r> <bevel-button> ;

C: radio-box ( assoc quot -- gadget )
    { 1 0 0 } over delegate>pack
    [ set-radio-box-quot ] keep
    >r [ first2 tuck <radio-button> 2array ] map r>
    [ >r [ second ] map r> add-gadgets ] 2keep
    [ set-radio-box-buttons ] 2keep
    [ >r first first r> set-radio-box-value* ] keep
    dup highlight-theme ;

TUPLE: tabs buttons book ;

C: tabs dup delegate>frame ;

: find-tabs [ tabs? ] find-parent ;

: update-tabs ( tabs -- )
    dup tabs-buttons radio-box-value swap tabs-book show-page ;

: make-tabs ( assoc -- gadget )
    [ find-tabs [ update-tabs ] when* ] <radio-box> ;

: set-tabs ( assoc tabs -- )
    {
        { [ dup [ second ] map <book> ] set-tabs-book @center }
        { [ make-tabs ] set-tabs-buttons @top }
    } build-grid ;

: make-pages ( obj assoc -- assoc )
    [ first2 swapd make-pane <scroller> 2array ] map-with ;

: set-pages ( obj assoc tabs -- ) >r make-pages r> set-tabs ;

: <pages> ( obj assoc -- tabs ) <tabs> [ set-pages ] keep ;
