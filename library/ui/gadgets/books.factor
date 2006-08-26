! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-books
USING: gadgets gadgets-controls gadgets-panes gadgets-scrolling
kernel sequences models ;

TUPLE: book page pages ;

: get-page ( n book -- page )
    #! page gadgets are instantiated lazily.
    book-pages [ dup quotation? [ call ] when dup ] change-nth ;

M: book model-changed ( book -- )
    [ control-model model-value ] keep
    [ book-page unparent ] keep
    [ get-page ] keep
    [ set-book-page ] 2keep
    [ add-gadget ] keep
    dup request-focus ;

C: book ( pages -- book )
    dup 0 <model> delegate>control
    dup dup set-control-self
    [ set-book-pages ] keep
    dup model-changed ;

M: book pref-dim* book-page pref-dim ;

M: book layout*
    dup rect-dim swap book-page set-layout-dim ;

M: book gadget-title book-page gadget-title ;

M: book focusable-child* gadget-child ;
