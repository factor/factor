! Copyright (C) 2006, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences models ui.gadgets
math.rectangles fry ;
IN: ui.gadgets.books

TUPLE: book < gadget ;

: hide-all ( book -- ) children>> [ hide-gadget ] each ;

: current-page ( book -- gadget ) [ control-value ] keep nth-gadget ;

M: book model-changed
    nip
    dup hide-all
    dup current-page show-gadget
    relayout ;

: new-book ( model class -- book )
    new
        swap >>model ; inline

: <book> ( pages model -- book )
    book new-book swap add-gadgets ;

: <empty-book> ( model -- book )
    book new-book ;

M: book pref-dim* children>> pref-dims max-dims ;

M: book layout*
    [ children>> ] [ dim>> ] bi '[ _ >>dim drop ] each ;

M: book focusable-child* current-page ;
