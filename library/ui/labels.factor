! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl stdio ;

! A label gadget draws a string.
TUPLE: label text ;

C: label ( text -- label )
    <empty-gadget> over set-delegate [ set-label-text ] keep ;

M: label pref-size label-text shape-size ;

M: label draw-shape ( label -- )
    dup delegate draw-shape
    dup shape-pos [ label-text draw-shape ] with-trans ;
