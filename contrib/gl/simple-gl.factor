! Copyright (C) 2005 Alex Chapman.
! See http://factor.sf.net/license.txt for BSD license.
IN: simple-gl
USING: kernel sdl gl glu math words sequences namespaces ;

: colour-depth 16 ; inline
: fov          60.0 ; inline
: near         0.1 ; inline
: far          100.0 ; inline

SYMBOL: theta

: flags ( lst -- enum )
    [ execute ] map 0 swap [ bitor ] each ;

: resize ( width height -- )
    2dup colour-depth [ SDL_OPENGL SDL_RESIZABLE SDL_HWSURFACE SDL_DOUBLEBUF ] flags init-screen
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    /f fov swap near far gluPerspective
    GL_MODELVIEW glMatrixMode
    glLoadIdentity ;

: render ( -- )
    GL_COLOR_BUFFER_BIT glClear
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    0.0 0.0 -2.0 glTranslatef
    theta get 0.0 1.0 0.0 glRotatef
    GL_TRIANGLES glBegin
        0.0 0.5 0.0 glVertex3f
       -0.5 0.0 0.0 glVertex3f
        0.5 0.0 0.0 glVertex3f
    glEnd
    SDL_GL_SwapBuffers ;

: event-loop ( event -- )
    theta [ 1 + ] change
    render
    dup SDL_PollEvent [
        dup quit-event? [
	    drop
        ] [
	    dup resize-event? [
	        dup resize-event-w resize-event-h resize ! broken
	    ] when
	    event-loop
	] ifte
    ] [
        event-loop
    ] ifte ;

: simple-gl
    800 600 colour-depth [ SDL_OPENGL SDL_RESIZABLE SDL_HWSURFACE SDL_DOUBLEBUF ] flags [
	0 theta set
        800 600 resize
        GL_FLAT glShadeModel
        0.0 0.0 0.0 0.0 glClearColor 
        1.0 0.0 0.0 glColor3f
	<event> event-loop
    ] with-screen ;

