! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-books
USING: gadgets gadgets-buttons gadgets-labels gadgets-layouts
generic kernel lists math matrices sequences ;

TUPLE: book page ;

C: book ( pages -- book )
    <gadget> over set-delegate
    0 over set-book-page
    [ add-gadgets ] keep ;

M: book pref-dim ( book -- dim )
    gadget-children [ pref-dim ] map @{ 0 0 0 }@ [ vmax ] reduce ;

M: book layout* ( book -- )
    dup rect-dim over gadget-children [
        f over set-gadget-visible?
        @{ 0 0 0 }@ over set-rect-loc
        set-gadget-dim
    ] each-with
    dup book-page swap gadget-children nth
    [ t swap set-gadget-visible? ] when* ;

: show-page ( n book -- )
    [ gadget-children length rem ] keep
    [ set-book-page ] keep relayout ;

: first-page ( book -- ) 0 swap show-page ;

: prev-page ( book -- ) [ book-page 1- ] keep show-page ;

: next-page ( book -- ) [ book-page 1+ ] keep show-page ;

: last-page ( book -- ) -1 swap show-page ;

TUPLE: book-browser book ;

: find-book ( gadget -- )
    [ book-browser? ] find-parent book-browser-book ;

: <book-buttons> ( book -- gadget )
    [
        { "|<" [ find-book first-page ] }
        { "<"  [ find-book prev-page  ] }
        { ">"  [ find-book next-page  ] }
        { ">|" [ find-book last-page  ] }
    ] [ first2 >r <label> r> <button> ] map
    <shelf> [ add-gadgets ] keep ;

C: book-browser ( book -- gadget )
    <frame> over set-delegate
    <book-buttons> over add-top
    [ 2dup set-book-browser-book add-center ] keep ;
