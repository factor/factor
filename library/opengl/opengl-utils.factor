! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: opengl
USING: alien errors kernel math namespaces opengl sdl sequences ;

: init-gl ( -- )
    0.0 0.0 0.0 0.0 glClearColor 
    1.0 0.0 0.0 glColor3d
    GL_COLOR_BUFFER_BIT glClear
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    0 0 width get height get glViewport
    0 width get height get 0 gluOrtho2D
    GL_SMOOTH glShadeModel
    GL_TEXTURE_2D glEnable ;

: gl-flags
    SDL_OPENGL SDL_RESIZABLE bitor SDL_HWSURFACE bitor SDL_DOUBLEBUF bitor ;

: gl-resize ( event -- )
    #! Acts on an SDL resize event.
    dup resize-event-w swap resize-event-h 0 gl-flags
    init-surface ;

: with-gl-screen ( quot -- )
    >r 0 gl-flags r> with-screen ;

: gl-error ( -- )
    glGetError dup 0 = [ drop ] [ gluErrorString throw ] if ;

: with-gl-surface ( quot -- )
    #! Execute a quotation, locking the current surface if it
    #! is required (eg, hardware surface).
    [ init-gl call gl-error ] [ SDL_GL_SwapBuffers ] cleanup ;

: do-state ( what quot -- )
    swap glBegin call glEnd ; inline

: gl-color ( { r g b } -- )
    dup first 255 /f over second 255 /f rot third 255 /f
    glColor3d ;

: gl-vertex first3 glVertex3d ;

: top-left drop @{ 0 0 0 }@ gl-vertex ;

: top-right @{ 1 0 0 }@ v* gl-vertex ;

: bottom-left @{ 0 1 0 }@ v* gl-vertex ;

: bottom-right gl-vertex ;

: four-sides ( dim -- )
    dup top-left dup top-right dup bottom-right bottom-left ;

: gl-line ( from to { r g b } -- )
    gl-color [ gl-vertex ] 2apply ;

: (gl-rect) swap gl-color [ four-sides ] do-state ;

: gl-fill-rect ( dim { r g b } -- )
    #! Draws a two-dimensional box.
    GL_QUADS (gl-rect) ;

: gl-rect ( dim { r g b } -- )
    #! Draws a two-dimensional box.
    GL_LINE_LOOP (gl-rect) ;

: (gl-poly) swap gl-color [ [ gl-vertex ] each ] do-state ;

: gl-fill-poly ( points { r g b } -- )
    #! Draw a filled polygon.
    GL_POLYGON (gl-poly) ;

: gl-poly ( points { r g b } -- )
    #! Draw a filled polygon.
    GL_LINE_LOOP (gl-poly) ;

: do-matrix ( mode quot -- )
    swap glMatrixMode glPushMatrix call glPopMatrix ; inline

: gl-set-clip ( loc dim -- )
    [ first2 ] 2apply glScissor ;

: prepare-gradient ( direction dim -- v1 v2 )
    tuck v* [ v- ] keep ;

: gl-gradient ( direction colors dim -- )
    #! Draws a quad strip.
    GL_QUAD_STRIP [
        swap >r prepare-gradient r>
        [ length dup 1- v/n ] keep [
            >r >r 2dup r> r> gl-color v*n
            dup gl-vertex v+ gl-vertex
        ] 2each 2drop
    ] do-state ;

: gen-texture ( -- id )
    #! Generate texture ID.
    1 0 <uint> [ glGenTextures ] keep *uint ;

: save-attribs ( bits quot -- )
    swap glPushAttrib call glPopAttrib ; inline

: gray-texture ( width height buffer -- id )
    #! Given a buffer holding a width x height (powers of two)
    #! grayscale texture, bind it and return the ID.
    gen-texture [
        GL_TEXTURE_BIT [
            GL_TEXTURE_2D swap glBindTexture
            GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
            GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
            GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP glTexParameterf
            GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP glTexParameterf
            >r >r >r GL_TEXTURE_2D 0 GL_RGBA r> r> 0 GL_RGBA
            GL_UNSIGNED_BYTE r> glTexImage2D
        ] save-attribs
    ] keep ;

: gen-dlist ( -- id )
    #! Generate display list ID.
    1 glGenLists ;

: make-dlist ( type quot -- id )
    #! Make a display list.
    gen-dlist [ rot glNewList call glEndList ] keep ; inline

: texture>dlist ( width height id -- id )
    #! Given a texture width/height and ID, make a display list
    #! for draws a quad with this texture.
    GL_MODELVIEW [
        GL_COMPILE [
            1 1 1 glColor3f
            GL_TEXTURE_2D swap glBindTexture
            GL_QUADS [
                0 0 glTexCoord2d 0 0 glVertex2i
                0 1 glTexCoord2d 0 over glVertex2i
                1 1 glTexCoord2d 2dup glVertex2i
                1 0 glTexCoord2d over 0 glVertex2i
            ] do-state
            drop 0 0 glTranslatef
        ] make-dlist
    ] do-matrix ;
