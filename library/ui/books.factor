! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math matrices sequences ;

TUPLE: book page ;

C: book ( pages -- book )
    <gadget> over set-delegate
    0 over set-book-page
    swap [ over add-gadget ] each ;

M: book pref-dim ( book -- dim )
    gadget-children { 0 0 0 } [ pref-dim vmax ] reduce ;

M: book layout* ( book -- )
    dup rectangle-dim over gadget-children [
        f over set-gadget-visible?
        { 0 0 0 } over set-rectangle-loc
        set-gadget-dim
    ] each-with
    dup book-page swap gadget-children nth
    t swap set-gadget-visible? ;

: show-page ( n book -- )
    [ gadget-children length rem ] keep
    [ set-book-page ] keep relayout ;

: first-page ( book -- )
    0 swap show-page ;

: prev-page ( book -- )
    [ book-page 1 - ] keep show-page ;

: next-page ( book -- )
    [ book-page 1 + ] keep show-page ;

: last-page ( book -- )
    -1 swap show-page ;

: book-buttons ( book -- gadget )
    <line-shelf> swap [
        [ "|<" first-page drop ]
        [ "<" prev-page drop ]
        [ ">" next-page drop ]
        [ ">|" last-page drop ]
    ] [
        uncons swapd cons <button> over add-gadget
    ] each-with ;

: <book-browser> ( book -- gadget )
    dup book-buttons <frame>
    [ add-top ] keep [ add-center ] keep ;
