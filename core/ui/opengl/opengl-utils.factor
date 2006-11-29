! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: opengl
USING: alien errors io kernel math namespaces opengl
sequences ;

: gl-color ( colorspec -- ) first4 glColor4d ; inline

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

: gl-vertex first2 glVertex2d ; inline

: gl-line ( a b -- )
    GL_LINES [ gl-vertex gl-vertex ] do-state ;

: gl-fill-rect ( loc dim -- )
    #! Draws a two-dimensional box.
    [ first2 ] 2apply glRectd ;

: gl-rect ( loc dim -- )
    #! Draws a two-dimensional box.
    GL_FRONT_AND_BACK GL_LINE glPolygonMode
    >r { 0.5 0.5 } v+ r> { 0.5 0.5 } v- gl-fill-rect
    GL_FRONT_AND_BACK GL_FILL glPolygonMode ;

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

C: sprite ( loc dim dim2 -- sprite )
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

: gl-translate ( point -- ) first2 0.0 glTranslated ;

: top-left drop 0 0 glTexCoord2i 0.0 0.0 glVertex2d ; inline

: top-right 1 0 glTexCoord2i first 0.0 glVertex2d ; inline

: bottom-left 0 1 glTexCoord2i second 0.0 swap glVertex2d ; inline

: bottom-right 1 1 glTexCoord2i gl-vertex ; inline

: four-sides ( dim -- )
    dup top-left dup top-right dup bottom-right bottom-left ;

: draw-sprite ( sprite -- )
    dup sprite-loc gl-translate
    GL_TEXTURE_2D over sprite-texture glBindTexture
    init-texture
    GL_QUADS [ dup sprite-dim2 four-sides ] do-state
    dup sprite-dim { 1 0 } v*
    swap sprite-loc v- gl-translate
    GL_TEXTURE_2D 0 glBindTexture ;

: make-sprite-dlist ( sprite -- id )
    GL_MODELVIEW [
        GL_COMPILE [ draw-sprite ] make-dlist
    ] do-matrix ;

: init-sprite ( texture sprite -- )
    [ set-sprite-texture ] keep
    [ make-sprite-dlist ] keep set-sprite-dlist ;

: free-sprite ( sprite -- )
    dup sprite-dlist 1 glDeleteLists
    sprite-texture <uint> 1 swap glDeleteTextures ;

: free-sprites ( sprites -- ) [ [ free-sprite ] when* ] each ;

: with-translation ( loc quot -- )
    GL_MODELVIEW [ >r gl-translate r> call ] do-matrix ; inline
