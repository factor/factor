! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-books
USING: gadgets gadgets-buttons gadgets-labels gadgets-layouts
gadgets-theme generic kernel lists math namespaces sequences
styles ;

TUPLE: book page ;

C: book ( pages -- book )
    [ >r make-stack r> set-gadget-delegate ] keep
    0 over set-book-page ;

M: book layout* ( book -- )
    dup delegate layout*
    dup gadget-children [ hide-gadget ] each
    dup book-page swap gadget-children nth
    [ show-gadget ] when* ;

: show-page ( n book -- )
    [ gadget-children length rem ] keep
    [ set-book-page ] keep relayout-1 ;

: first-page ( book -- ) 0 swap show-page ;

: prev-page ( book -- ) [ book-page 1- ] keep show-page ;

: next-page ( book -- ) [ book-page 1+ ] keep show-page ;

: last-page ( book -- ) -1 swap show-page ;

TUPLE: book-browser book ;

: find-book ( gadget -- )
    [ book-browser? ] find-parent book-browser-book ;

: <book-button> ( polygon quot -- button )
    \ find-book swons >r gray swap <polygon-gadget> r>
    <bevel-button> ;

: <book-buttons> ( book -- gadget )
    [
        arrow-|left  [ first-page ] <book-button> ,
        arrow-left   [ prev-page  ] <book-button> ,
        arrow-right  [ next-page  ] <book-button> ,
        arrow-right| [ last-page  ] <book-button> ,
    ] { } make make-shelf ;

C: book-browser ( book -- gadget )
    dup delegate>frame
    <book-buttons> over @top frame-add
    [ 2dup set-book-browser-book @center frame-add ] keep ;
