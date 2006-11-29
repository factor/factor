! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-books
USING: gadgets gadgets-panes gadgets-scrolling
kernel sequences models ;

TUPLE: book ;

: hide-all ( book -- ) gadget-children [ hide-gadget ] each ;

: current-page ( book -- gadget )
    [ control-value ] keep nth-gadget ;

M: book model-changed ( book -- )
    dup hide-all
    dup current-page show-gadget
    dup relayout
    request-focus ;

C: book ( pages -- book )
    dup 0 <model> <gadget> delegate>control
    [ add-gadgets ] keep
    dup model-changed ;

M: book pref-dim* gadget-children pref-dims max-dim ;

M: book layout*
    dup rect-dim swap gadget-children
    [ set-layout-dim ] each-with ;

M: book focusable-child* current-page ;
