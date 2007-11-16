! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences models ui.gadgets ;
IN: ui.gadgets.books

TUPLE: book ;

: hide-all ( book -- ) gadget-children [ hide-gadget ] each ;

: current-page ( book -- gadget )
    [ control-value ] keep nth-gadget ;

M: book model-changed
    nip
    dup hide-all
    dup current-page show-gadget
    relayout ;

: <book> ( pages model -- book )
    <gadget> book construct-control [ add-gadgets ] keep ;

M: book pref-dim* gadget-children pref-dims max-dim ;

M: book layout*
    dup rect-dim swap gadget-children
    [ set-layout-dim ] curry* each ;

M: book focusable-child* current-page ;
