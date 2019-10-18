! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-books
USING: gadgets gadgets-controls gadgets-panes gadgets-scrolling
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

: <book-control> ( model pages -- book )
    <book> [ show-page ] <control> ;

M: book pref-dim* ( book -- dim ) book-page pref-dim ;

M: book layout* ( book -- )
    dup rect-dim swap book-page set-layout-dim ;

: make-book ( model obj quots -- assoc )
    [ make-pane <scroller> ] map-with <book-control> ;
