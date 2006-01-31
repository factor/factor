! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

! This example only runs in the UI listener.

! Pass with-canvas a quotation calling these words:
! - turn-by
! - move-by
! - plot-point
! - line-to
! - new-pen

! plot-string doesn't yet work.

! other GL calls can be made, but be careful.

IN: gadgets-canvas
USING: arrays errors freetype gadgets gadgets-labels
gadgets-layouts gadgets-panes gadgets-theme generic kernel math
namespaces opengl sequences styles ;

SYMBOL: canvas-font

{ "monospaced" plain 12 } canvas-font set-global

: turn-by ( angle -- ) 0 0 1 glRotated ;

: move-by ( distance -- ) 0 0 glTranslated ;

: plot-point ( -- )
    GL_POINTS [ 0 0 0 glVertex3d ] do-state ;

: line-to ( distance -- )
    dup
    GL_LINES [ 0 0 0 glVertex3d 0 0 glVertex3d ] do-state
    move-by ;

: plot-string ( string -- )
    canvas-font get open-font swap draw-string ;

: new-pen ( quot -- ) GL_MODELVIEW swap do-matrix ; inline

TUPLE: canvas quot id ;

C: canvas ( quot -- )
    dup delegate>gadget [ set-canvas-quot ] keep ;

M: canvas add-notify* ( gadget -- )
    dup canvas-quot GL_COMPILE [ with-scope ] make-dlist
    swap set-canvas-id ;

M: canvas draw-gadget* ( gadget -- )
    GL_MODELVIEW [
        dup rect-dim 2 v/n gl-translate
        canvas-id glCallList
    ] do-matrix ;

: with-canvas ( size quot -- )
    <canvas> dup solid-boundary [ set-gadget-dim ] keep gadget. ;

: random-walk ( n -- )
    [ 2 random-int 1/2 - 180 * turn-by 10 line-to ] times ;

: regular-polygon ( sides n -- )
    [ 360 swap / ] keep [ over line-to dup turn-by ] times 2drop ;

: random-color
    4 [ drop 255 random-int 255 /f ] map gl-color ;

: turtle-test
    { 400 400 0 } [
        36 [
            ! random-color
            10 line-to
            10 turn-by [ 60 10 regular-polygon ] new-pen
        ] times
    ] with-canvas ;
