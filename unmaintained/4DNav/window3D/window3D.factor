! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: kernel 
ui.gadgets
ui.render
opengl
opengl.gl
opengl.glu
4DNav.camera
4DNav.turtle
math
values
alien.c-types
accessors
namespaces
adsoda 
models
prettyprint
;

IN: 4DNav.window3D

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! drawing functions 
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: window3D  < gadget observer ; 

: <window3D>  ( model observer -- gadget )
    window3D  new
    swap 2dup 
    projection-mode>> add-connection
    2dup 
    collision-mode>> add-connection
    >>observer 
    swap <model> >>model 
    t >>root?
;

M: window3D pref-dim* ( gadget -- dim )  drop { 300 300 } ;

M: window3D draw-gadget* ( gadget -- )

    GL_PROJECTION glMatrixMode
        glLoadIdentity
        0.6 0.6 0.6 .9 glClearColor
        dup observer>> projection-mode>> value>> 1 =    
        [ 60.0 1.0 0.1 3000.0 gluPerspective ]
        [ -400.0 400.0 -400.0 400.0 0.0 4000.0 glOrtho ] if
        dup observer>> collision-mode>> value>> 
        \ remove-hidden-solids?   
        set-value
        dup  observer>> do-look-at
        GL_MODELVIEW glMatrixMode
            glLoadIdentity  
            0.9 0.9 0.9 1.0 glClearColor
            1.0 glClearDepth
            GL_LINE_SMOOTH glEnable
            GL_BLEND glEnable
            GL_DEPTH_TEST glEnable       
            GL_LEQUAL glDepthFunc
            GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
            GL_LINE_SMOOTH_HINT GL_NICEST glHint
            1.25 glLineWidth
            GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor 
                glClear
            glLoadIdentity
            GL_LIGHTING glEnable
            GL_LIGHT0 glEnable
            GL_COLOR_MATERIAL glEnable
            GL_FRONT GL_AMBIENT_AND_DIFFUSE glColorMaterial
            ! *************************
            
            control-value
            [ space->GL ] when*

            ! *************************
;

M: window3D graft* drop ;

M: window3D model-changed nip relayout ; 
