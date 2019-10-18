! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors generic hashtables kernel lists math namespaces
sdl sequences ;

! A stack just lays out all its children on top of each other.
TUPLE: stack ;
C: stack ( list -- stack )
    <empty-gadget> over set-delegate
    swap [ over add-gadget ] each ;

: max-size ( stack -- w h )
    [
        [
            dup
            shape-w width [ max ] change
            shape-h height [ max ] change
        ] each
    ] with-pref-size ;

M: stack pref-size gadget-children max-size ;

M: stack layout* ( stack -- )
    dup gadget-children [
        >r dup shape-w over shape-h r> resize-gadget
    ] each drop ;
