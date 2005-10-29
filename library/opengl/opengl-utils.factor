! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: opengl
USING: alien errors kernel math namespaces opengl sdl sequences ;

: gl-color ( @{ r g b a }@ -- ) first4 glColor4d ; inline

: init-gl ( -- )
    0.0 0.0 0.0 0.0 glClearColor 
    @{ 1.0 0.0 0.0 0.0 }@ gl-color
    GL_COLOR_BUFFER_BIT glClear
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    0 0 width get height get glViewport
    0 width get height get 0 gluOrtho2D
    GL_SMOOTH glShadeModel
    GL_BLEND glEnable
    GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    GL_SCISSOR_TEST glEnable
    GL_MODELVIEW glMatrixMode ;

: gl-flags
    SDL_OPENGL
    SDL_RESIZABLE bitor
    SDL_HWSURFACE bitor
    SDL_DOUBLEBUF bitor ;

: gl-resize ( event -- )
    #! Acts on an SDL resize event.
    dup resize-event-w swap resize-event-h 0 gl-flags
    init-surface ;

: with-gl-screen ( quot -- )
    >r 0 gl-flags r> with-screen ; inline

: gl-error ( -- )
    glGetError dup 0 = [ drop ] [ gluErrorString throw ] if ;

: with-gl-surface ( quot -- )
    #! Execute a quotation, locking the current surface if it
    #! is required (eg, hardware surface).
    [ init-gl call gl-error ] [ SDL_GL_SwapBuffers ] cleanup ;

: do-state ( what quot -- )
    swap glBegin call glEnd ; inline

: do-matrix ( mode quot -- )
    swap glMatrixMode glPushMatrix call glPopMatrix ; inline

: gl-vertex first3 glVertex3d ; inline

: top-left drop 0 0 glTexCoord2d @{ 0 0 0 }@ gl-vertex ; inline

: top-right 1 0 glTexCoord2d @{ 1 0 0 }@ v* gl-vertex ; inline

: bottom-left 0 1 glTexCoord2d @{ 0 1 0 }@ v* gl-vertex ; inline

: bottom-right 1 1 glTexCoord2d gl-vertex ; inline

: four-sides ( dim -- )
    dup top-left dup top-right dup bottom-right bottom-left ;

: gl-line ( from to color -- )
    gl-color [ gl-vertex ] 2apply ;

: gl-fill-rect ( dim -- )
    #! Draws a two-dimensional box.
    GL_QUADS [ four-sides ] do-state ;

: gl-rect ( dim -- )
    #! Draws a two-dimensional box.
    GL_MODELVIEW [
        0.5 0.5 0 glTranslatef @{ 1 1 0 }@ v-
        GL_LINE_STRIP [ dup four-sides top-left ] do-state
    ] do-matrix ;

: (gl-poly) [ [ gl-vertex ] each ] do-state ;

: gl-fill-poly ( points -- )
    #! Draw a filled polygon.
    dup length 2 > GL_POLYGON GL_LINES ? (gl-poly) ;

: gl-poly ( points color -- )
    #! Draw a polygon.
    GL_LINE_LOOP (gl-poly) ;

: gl-set-clip ( loc dim -- )
    dup first2 1+ >r >r
    over second swap second + height get swap - >r
    first r> r> r> glScissor ;

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

! A sprite is a texture and a display list.
TUPLE: sprite dlist texture loc dim dim2 ;

C: sprite ( loc dim dim2 -- )
    [ set-sprite-dim2 ] keep
    [ set-sprite-dim ] keep
    [ set-sprite-loc ] keep ;

: sprite-size2 sprite-dim2 first2 ;

: sprite-width sprite-dim first ;

: gray-texture ( sprite buffer -- id )
    #! Given a buffer holding a width x height (powers of two)
    #! grayscale texture, bind it and return the ID.
    gen-texture [
        GL_TEXTURE_BIT [
            GL_TEXTURE_2D swap glBindTexture
            >r >r GL_TEXTURE_2D 0 GL_RGBA r>
            sprite-size2 0 GL_LUMINANCE_ALPHA
            GL_UNSIGNED_BYTE r> glTexImage2D
        ] save-attribs
    ] keep ;

: gen-dlist ( -- id )
    #! Generate display list ID.
    1 glGenLists ;

: make-dlist ( type quot -- id )
    #! Make a display list.
    gen-dlist [ rot glNewList call glEndList ] keep ; inline

: init-texture ( -- )
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP glTexParameterf
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP glTexParameterf ;

: gl-translate ( @{ x y z }@ -- ) first3 glTranslatef ;

: make-sprite-dlist ( sprite -- id )
    GL_MODELVIEW [
        GL_COMPILE [
            dup sprite-loc gl-translate
            GL_TEXTURE_2D over sprite-texture glBindTexture
            init-texture
            dup sprite-dim2 gl-fill-rect
            dup sprite-dim @{ 1 0 0 }@ v*
            swap sprite-loc v- gl-translate
        ] make-dlist
    ] do-matrix ;

: init-sprite ( texture sprite -- )
    [ set-sprite-texture ] keep
    [ make-sprite-dlist ] keep set-sprite-dlist ;
