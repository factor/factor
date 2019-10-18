! Copyright (C) 2005 Alex Chapman.
! See http://factor.sf.net/license.txt for BSD license.
IN: simple-gl
USING: kernel sdl gl glu math words sequences namespaces generic prettyprint ;

: colour-depth 16 ; inline
: fov          60.0 ; inline
: near         0.1 ; inline
: far          100.0 ; inline

SYMBOL: theta
SYMBOL: phi
SYMBOL: width
SYMBOL: height

: flags
    SDL_OPENGL SDL_RESIZABLE bitor SDL_HWSURFACE bitor SDL_DOUBLEBUF bitor ;

: init-gl
    0 0 width get height get glViewport
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    fov width get height get /f near far gluPerspective
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    GL_FLAT glShadeModel
    0.0 0.0 0.0 0.0 glClearColor 
    1.0 0.0 0.0 glColor3f ;

: resize ( width height -- )
    2dup height set width set
    colour-depth flags SDL_SetVideoMode drop
    init-gl ;

: render ( -- )
    GL_COLOR_BUFFER_BIT glClear
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    1 1 1 0 0 0 2 2 2 gluLookAt
    theta get 0 1 0 glRotatef
    phi get 1 0 0 glRotatef
    GL_TRIANGLES glBegin
        0.0 0.5 0.0 glVertex3f
       -0.5 0.0 0.0 glVertex3f
        0.5 0.0 0.0 glVertex3f
    glEnd
    SDL_GL_SwapBuffers ;

GENERIC: process-event ( event -- ? )
M: quit-event process-event 
    drop f ;
M: resize-event process-event 
    dup resize-event-w swap resize-event-h resize t ;
M: object process-event 
    drop t ;

: event-loop ( event -- )
    theta [ 1 + 360 mod ] change
    phi [ 2 + 360 mod ] change
    render
    dup SDL_PollEvent [
        dup process-event [
	    event-loop
	] [
	    drop
	] ifte
    ] [
	event-loop
    ] ifte ;

: simple-gl
    800 600 colour-depth flags [
        init-gl
	0 theta set
	0 phi set
	<event> event-loop
    ] with-screen ;

simple-gl

