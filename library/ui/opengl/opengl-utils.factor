! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: opengl
USING: alien errors io kernel math namespaces opengl
sequences ;

: gl-color ( { r g b a } -- ) first4 glColor4d ; inline

: gl-error ( -- )
    glGetError dup zero? [
        "GL error: " write dup gluErrorString print flush
    ] unless drop ;

: do-state ( what quot -- )
    swap glBegin call glEnd ; inline

: do-enabled ( what quot -- )
    over glEnable swap slip glDisable ; inline

: do-matrix ( mode quot -- )
    swap [ glMatrixMode glPushMatrix call ] keep
    glMatrixMode glPopMatrix ; inline

: top-left drop 0 0 glTexCoord2i 0.0 0.0 glVertex2d ; inline

: top-right 1 0 glTexCoord2i first 0.0 glVertex2d ; inline

: bottom-left 0 1 glTexCoord2i second 0.0 swap glVertex2d ; inline

: gl-vertex first2 glVertex2d ; inline

: bottom-right 1 1 glTexCoord2i gl-vertex ; inline

: four-sides ( dim -- )
    dup top-left dup top-right dup bottom-right bottom-left ;

: gl-line ( a b -- )
    GL_LINES [ gl-vertex gl-vertex ] do-state ;

: gl-fill-rect ( dim -- )
    #! Draws a two-dimensional box.
    GL_QUADS [ four-sides ] do-state ;

: gl-rect ( dim -- )
    #! Draws a two-dimensional box.
    GL_MODELVIEW [
        0.5 0.5 0.0 glTranslated { 1 1 } v-
        GL_LINE_STRIP [ dup four-sides top-left ] do-state
    ] do-matrix ;

: (gl-poly) [ [ gl-vertex ] each ] do-state ;

: gl-fill-poly ( points -- )
    #! Draw a filled polygon.
    dup length 2 > GL_POLYGON GL_LINES ? (gl-poly) ;

: gl-poly ( points -- )
    #! Draw a polygon.
    GL_LINE_LOOP (gl-poly) ;

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

: gl-translate ( { x y } -- ) first2 0.0 glTranslated ;

: make-sprite-dlist ( sprite -- id )
    GL_MODELVIEW [
        GL_COMPILE [
            dup sprite-loc gl-translate
            GL_TEXTURE_2D over sprite-texture glBindTexture
            init-texture
            dup sprite-dim2 gl-fill-rect
            dup sprite-dim { 1 0 0 } v*
            swap sprite-loc v- gl-translate
        ] make-dlist
    ] do-matrix ;

: init-sprite ( texture sprite -- )
    [ set-sprite-texture ] keep
    [ make-sprite-dlist ] keep set-sprite-dlist ;

: free-sprite ( sprite -- )
    dup sprite-dlist 1 glDeleteLists
    sprite-texture <uint> 1 swap glDeleteTextures ;

: free-sprites ( sprites -- ) [ [ free-sprite ] when* ] each ;
