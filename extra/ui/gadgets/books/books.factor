! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences models ui.gadgets math.geometry.rect ;
IN: ui.gadgets.books

TUPLE: book < gadget ;

: hide-all ( book -- ) gadget-children [ hide-gadget ] each ;

: current-page ( book -- gadget )
    [ control-value ] keep nth-gadget ;

M: book model-changed
    nip
    dup hide-all
    dup current-page show-gadget
    relayout ;

: new-book ( pages model class -- book )
    new-gadget
        swap >>model
        [ swap add-gadgets drop ] keep ; inline

: <book> ( pages model -- book )
    book new-book ;

M: book pref-dim* gadget-children pref-dims max-dim ;

M: book layout*
    dup rect-dim swap gadget-children
    [ set-layout-dim ] with each ;

M: book focusable-child* current-page ;
