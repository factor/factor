! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-books
USING: gadgets gadgets-controls gadgets-panes gadgets-scrolling
kernel sequences ;

TUPLE: book page pages ;

: get-page ( n book -- page )
    #! page gadgets are instantiated lazily.
    book-pages [ dup quotation? [ call ] when dup ] change-nth ;

: show-page ( n book -- )
    dup book-page unparent
    [ get-page ] keep
    [ set-book-page ] 2keep
    add-gadget ;

C: book ( pages -- book )
    dup delegate>gadget
    [ set-book-pages ] keep
    0 over show-page ;

: <book-control> ( model pages -- book )
    <book> [ show-page ] <control> ;

M: book pref-dim* book-page pref-dim ;

M: book layout*
    dup rect-dim swap book-page set-layout-dim ;
