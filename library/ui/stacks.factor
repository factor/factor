! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors generic hashtables kernel lists math matrices
namespaces sdl sequences ;

! A stack just lays out all its children on top of each other.
TUPLE: stack ;
C: stack ( list -- stack )
    <empty-gadget> over set-delegate
    swap [ over add-gadget ] each ;

: max-dim ( shapelist -- dim )
    { 0 0 0 } [ shape-dim vmax ] reduce ;

M: stack pref-size gadget-children max-dim 3unseq drop ;

M: stack layout* ( stack -- )
    dup shape-dim swap gadget-children
    [ set-gadget-dim ] each-with ;
