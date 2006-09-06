! Copyright (C) 2006 Eduardo Cavazos.

USING: kernel namespaces sequences vectors opengl gadgets ;

IN: slate

TUPLE: slate action ;

C: slate ( -- <slate> ) dup delegate>gadget [ ] over set-slate-action ;

M: slate pref-dim* ( <slate> -- ) drop { 100 100 0 } ;

SYMBOL: self

M: slate draw-gadget* ( <slate> -- ) dup self set slate-action call ;

: get-action ( -- quot ) self get slate-action ;

: set-action ( quot -- ) self get set-slate-action ;

: flush-slate ( -- ) self get relayout-1 ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: rect-width ( <rect> -- width ) 0 swap rect-dim nth ;

: rect-height ( <rect> -- height ) 1 swap rect-dim nth ;

: window-width ( -- width ) self get rect-width ;

: window-height ( -- height ) self get rect-height ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: dlist

SYMBOL: capacity

: reset-dlist ( -- ) capacity get <vector> dlist set ;

: add-dlist ( quot -- ) dlist get swap nappend ;

: flush-dlist ( -- ) get-action dlist get append set-action reset-dlist ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-coordinates ( left right bottom top -- )
[ glLoadIdentity gluOrtho2D ] curry curry curry curry add-dlist ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: black ( -- color ) { 0 0 0 1 } ;

: white ( -- color ) { 1 1 1 1 } ;

: red ( -- color ) { 1 0 0 1 } ;

: green ( -- color ) { 0 1 0 1 } ;

: blue ( -- color ) { 0 0 1 1 } ;

: set-clear-color ( color -- ) [ first4 glClearColor ] curry add-dlist ;

: clear-window ( -- ) [ GL_COLOR_BUFFER_BIT glClear ] add-dlist ;

: set-color ( color -- ) [ first4 glColor4f ] curry add-dlist ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (draw-point) ( { x y } -- ) GL_POINTS glBegin first2 glVertex2f glEnd ;

: draw-point ( { x y } -- ) [ (draw-point) ] curry add-dlist ;

: (draw-line) ( a b -- )
GL_LINES glBegin first2 glVertex2f first2 glVertex2f glEnd ;

: draw-line ( a b -- ) [ (draw-line) ] curry curry add-dlist ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: reset-slate ( -- ) [ ] set-action reset-dlist ;

PROVIDE: contrib/slate ;