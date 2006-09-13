! Copyright (C) 2006 Eduardo Cavazos.

REQUIRES: contrib/math contrib/alien ;

USING: alien-contrib kernel namespaces math sequences vectors
       arrays opengl math-contrib gadgets ;

IN: slate

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Slate gadget implementation
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: slate action ;

C: slate ( -- <slate> ) dup delegate>gadget [ ] over set-slate-action ;

M: slate pref-dim* ( <slate> -- ) drop { 100 100 0 } ;

SYMBOL: self

M: slate draw-gadget* ( <slate> -- ) dup self set slate-action call ;

: get-action ( -- quot ) self get slate-action ;

: set-action ( quot -- ) self get set-slate-action ;

: flush-slate ( -- ) self get relayout-1 ;

SYMBOL: dlist

SYMBOL: capacity

: reset-dlist ( -- ) capacity get <vector> dlist set ;

: add-dlist ( quot -- ) dlist get swap nappend ;

: flush-dlist ( -- ) get-action dlist get append set-action reset-dlist ;

: reset-slate ( -- ) [ ] set-action reset-dlist ;

: new-slate ( -- )
<slate> self set   100 capacity set   reset-dlist   self get ;

: slate-window ( -- ) new-slate "Slate" open-titled-window ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Slate OpenGL commands
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: curry2 ( a b quot -- quot ) 2 [ curry ] times ;

: curry3 ( a b c quot -- quot ) 3 [ curry ] times ;

: curry4 ( a b c d quot -- quot ) 4 [ curry ] times ;

: curry6 ( a b c d e f quot -- quot ) 6 [ curry ] times ;

: curry9 ( a b c d e f g h i quot -- quot ) 9 [ curry ] times ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gl-clear-color ( vec -- ) first4 [ glClearColor ] curry4 add-dlist ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gl-clear ( mask -- ) [ glClear ] curry add-dlist ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gl-color ( vec -- ) first4 [ glColor4f ] curry4 add-dlist ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gl-ortho ( left right bottom top near far -- ) [ glOrtho ] curry6 add-dlist ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gl-vertex2 ( vec -- ) first2 [ glVertex2f ] curry2 add-dlist ;

: gl-vertex3 ( vec -- ) first3 [ glVertex3f ] curry3 add-dlist ;

: gl-vertex4 ( vec -- ) first4 [ glVertex4f ] curry4 add-dlist ;

: gl-vertex ( vec -- ) gl-vertex3 ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gl-begin ( mode -- ) [ glBegin ] curry add-dlist ;

: gl-end ( -- ) [ glEnd ] add-dlist ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gl-load-identity ( -- ) [ glLoadIdentity ] add-dlist ;

: gl-matrix-mode ( mode -- ) [ glMatrixMode ] curry add-dlist ;

: gl-push-matrix ( -- ) [ glPushMatrix ] add-dlist ;

: gl-pop-matrix ( -- ) [ glPopMatrix ] add-dlist ;

: gl-rotate ( angle vec -- ) first3 [ glRotatef ] curry4 add-dlist ;

: gl-scale ( vec -- ) first3 [ glScalef ] curry3 add-dlist ;

: gl-translate ( vec -- ) first3 [ glTranslatef ] curry3 add-dlist ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gl-light-fv ( light pname params -- )
>float-array [ glLightfv ] curry3 add-dlist ;

: gl-light-model-fv ( pname params -- )
>float-array [ glLightModelfv ] curry2 add-dlist ;

: gl-material-fv ( face pname params -- )
>float-array [ glMaterialfv ] curry3 add-dlist ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: glu-look-at ( position focus up -- )
[ glLoadIdentity ] add-dlist
>r >r first3 r> first3 r> first3 [ gluLookAt ] curry9 add-dlist ;

: glu-ortho-2d ( left right bottom top -- ) [ gluOrtho2D ] curry4 add-dlist ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: black ( -- color ) { 0 0 0 1 } ;

: white ( -- color ) { 1 1 1 1 } ;

: red ( -- color ) { 1 0 0 1 } ;

: green ( -- color ) { 0 1 0 1 } ;

: blue ( -- color ) { 0 0 1 1 } ;

: yellow ( -- color ) { 1 1 0 1 } ;

: set-color-alpha ( color alpha -- color ) swap 3 head swap add ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: draw-line ( a b --- ) GL_LINES gl-begin gl-vertex gl-vertex gl-end ;

: draw-line-strip ( seq -- ) GL_LINE_STRIP gl-begin [ gl-vertex ] each gl-end ;

: draw-line-loop ( seq -- ) GL_LINE_LOOP gl-begin [ gl-vertex ] each gl-end ;

: draw-polygon ( seq -- ) GL_POLYGON gl-begin [ gl-vertex ] each gl-end ;

: draw-circle ( -- )
100 [ 100 / 360 * deg>rad dup cos swap sin 0 3array ] map draw-polygon ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Slate 2d utilities
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

IN: slate-2d

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-2d ( left right bottom top -- )
GL_PROJECTION gl-matrix-mode gl-load-identity -1 1 gl-ortho
GL_MODELVIEW gl-matrix-mode gl-load-identity ;

: draw-point ( point -- ) GL_POINTS gl-begin gl-vertex2 gl-end ;

: draw-line ( a b -- ) GL_LINES gl-begin gl-vertex2 gl-vertex2 gl-end ;

: draw-line-strip ( seq -- )
GL_LINE_STRIP gl-begin [ gl-vertex2 ] each gl-end ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-coordinates ( left right bottom top -- )
[ glLoadIdentity gluOrtho2D ] curry curry curry curry add-dlist ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Slate miscellaneous utilities
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

IN: slate-misc

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: rect-width ( <rect> -- width ) 0 swap rect-dim nth ;

: rect-height ( <rect> -- height ) 1 swap rect-dim nth ;

: window-width ( -- width ) self get rect-width ;

: window-height ( -- height ) self get rect-height ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-clear-color ( color -- ) [ first4 glClearColor ] curry add-dlist ;

: clear-window ( -- ) [ GL_COLOR_BUFFER_BIT glClear ] add-dlist ;

: set-color ( color -- ) [ first4 glColor4f ] curry add-dlist ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

PROVIDE: contrib/slate ;