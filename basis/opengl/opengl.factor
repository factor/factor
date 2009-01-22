! Copyright (C) 2005, 2009 Slava Pestov.
! Portions copyright (C) 2007 Eduardo Cavazos.
! Portions copyright (C) 2008 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types continuations kernel libc math macros
namespaces math.vectors math.constants math.functions
math.parser opengl.gl opengl.glu combinators arrays sequences
splitting words byte-arrays assocs colors accessors
generalizations locals fry specialized-arrays.float
specialized-arrays.uint ;
IN: opengl

: gl-color ( color -- ) >rgba-components glColor4d ; inline

: gl-clear-color ( color -- ) >rgba-components glClearColor ;

: gl-clear ( color -- )
    gl-clear-color GL_COLOR_BUFFER_BIT glClear ;

: gl-error ( -- )
    glGetError dup zero? [
        "GL error: " over gluErrorString append throw
    ] unless drop ;

: do-enabled ( what quot -- )
    over glEnable dip glDisable ; inline

: do-enabled-client-state ( what quot -- )
    over glEnableClientState dip glDisableClientState ; inline

: words>values ( word/value-seq -- value-seq )
    [ dup word? [ execute ] when ] map ;

: (all-enabled) ( seq quot -- )
    over [ glEnable ] each dip [ glDisable ] each ; inline

: (all-enabled-client-state) ( seq quot -- )
    [ dup [ glEnableClientState ] each ] dip
    dip
    [ glDisableClientState ] each ; inline

MACRO: all-enabled ( seq quot -- )
    [ words>values ] dip [ (all-enabled) ] 2curry ;

MACRO: all-enabled-client-state ( seq quot -- )
    [ words>values ] dip [ (all-enabled-client-state) ] 2curry ;

: do-matrix ( mode quot -- )
    swap [ glMatrixMode glPushMatrix call ] keep
    glMatrixMode glPopMatrix ; inline

: gl-material ( face pname params -- )
    float-array{ } like underlying>> glMaterialfv ;

: gl-vertex-pointer ( seq -- )
    [ 2 GL_FLOAT 0 ] dip underlying>> glVertexPointer ; inline

: gl-color-pointer ( seq -- )
    [ 4 GL_FLOAT 0 ] dip underlying>> glColorPointer ; inline

: gl-texture-coord-pointer ( seq -- )
    [ 2 GL_FLOAT 0 ] dip underlying>> glTexCoordPointer ; inline

: line-vertices ( a b -- )
    [ first2 [ 0.5 + ] bi@ ] bi@ 4 float-array{ } nsequence
    gl-vertex-pointer ;

: gl-line ( a b -- )
    line-vertices GL_LINES 0 2 glDrawArrays ;

: (rect-vertices) ( dim -- vertices )
    #! We use GL_LINE_STRIP with a duplicated first vertex
    #! instead of GL_LINE_LOOP to work around a bug in Apple's
    #! X3100 driver.
    {
        [ drop 0.5 0.5 ]
        [ first 0.3 - 0.5 ]
        [ [ first 0.3 - ] [ second 0.3 - ] bi ]
        [ second 0.3 - 0.5 swap ]
        [ drop 0.5 0.5 ]
    } cleave 10 float-array{ } nsequence ;

: rect-vertices ( dim -- )
    (rect-vertices) gl-vertex-pointer ;

: (gl-rect) ( -- )
    GL_LINE_STRIP 0 5 glDrawArrays ;

: gl-rect ( dim -- )
    rect-vertices (gl-rect) ;

: (fill-rect-vertices) ( dim -- vertices )
    {
        [ drop 0 0 ]
        [ first 0 ]
        [ first2 ]
        [ second 0 swap ]
    } cleave 8 float-array{ } nsequence ;

: fill-rect-vertices ( dim -- )
    (fill-rect-vertices) gl-vertex-pointer ;

: (gl-fill-rect) ( -- )
    GL_QUADS 0 4 glDrawArrays ;

: gl-fill-rect ( dim -- )
    fill-rect-vertices (gl-fill-rect) ;

: circle-steps ( steps -- angles )
    dup length v/n 2 pi * v*n ;

: unit-circle ( angles -- points1 points2 )
    [ [ sin ] map ] [ [ cos ] map ] bi ;

: adjust-points ( points1 points2 -- points1' points2' )
    [ [ 1 + 0.5 * ] map ] bi@ ;

: scale-points ( loc dim points1 points2 -- points )
    zip [ v* ] with map [ v+ ] with map ;

: circle-points ( loc dim steps -- points )
    circle-steps unit-circle adjust-points scale-points ;

: close-path ( points -- points' )
    dup first suffix ;

: circle-vertices ( loc dim steps -- vertices )
    #! We use GL_LINE_STRIP with a duplicated first vertex
    #! instead of GL_LINE_LOOP to work around a bug in Apple's
    #! X3100 driver.
    circle-points close-path concat >float-array ;

: fill-circle-vertices ( loc dim steps -- vertices )
    circle-points concat >float-array ;

: (gen-gl-object) ( quot -- id )
    [ 1 0 <uint> ] dip keep *uint ; inline

: gen-texture ( -- id )
    [ glGenTextures ] (gen-gl-object) ;

: gen-gl-buffer ( -- id )
    [ glGenBuffers ] (gen-gl-object) ;

: (delete-gl-object) ( id quot -- )
    [ 1 swap <uint> ] dip call ; inline

: delete-texture ( id -- )
    [ glDeleteTextures ] (delete-gl-object) ;

: delete-gl-buffer ( id -- )
    [ glDeleteBuffers ] (delete-gl-object) ;

:: with-gl-buffer ( binding id quot -- )
    binding id glBindBuffer
    quot [ binding 0 glBindBuffer ] [ ] cleanup ; inline

: with-array-element-buffers ( array-buffer element-buffer quot -- )
    [ GL_ELEMENT_ARRAY_BUFFER ] 2dip '[
        GL_ARRAY_BUFFER swap _ with-gl-buffer
    ] with-gl-buffer ; inline

: <gl-buffer> ( target data hint -- id )
    pick gen-gl-buffer [
        [
            [ [ byte-length ] keep ] dip glBufferData
        ] with-gl-buffer
    ] keep ;

: buffer-offset ( int -- alien )
    <alien> ; inline

: bind-texture-unit ( id target unit -- )
    glActiveTexture swap glBindTexture gl-error ;

: (set-draw-buffers) ( buffers -- )
    [ length ] [ >uint-array underlying>> ] bi glDrawBuffers ;

MACRO: set-draw-buffers ( buffers -- )
    words>values [ (set-draw-buffers) ] curry ;

: do-attribs ( bits quot -- )
    swap glPushAttrib call glPopAttrib ; inline

: gl-look-at ( eye focus up -- )
    [ first3 ] tri@ gluLookAt ;

: make-texture ( dim pixmap type -- id )
    [ gen-texture ] 3dip swap '[
        GL_TEXTURE_BIT [
            GL_TEXTURE_2D swap glBindTexture
            GL_TEXTURE_2D
            0
            GL_RGBA
            _ first2
            0
            _
            GL_UNSIGNED_BYTE
            _
            glTexImage2D
        ] do-attribs
    ] keep ;

: gen-dlist ( -- id ) 1 glGenLists ;

: make-dlist ( type quot -- id )
    [ gen-dlist ] 2dip '[ _ glNewList @ glEndList ] keep ; inline

: init-texture ( -- )
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP glTexParameterf
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP glTexParameterf ;

: gl-translate ( point -- ) first2 0.0 glTranslated ;

: rect-texture-coords ( -- )
    float-array{ 0 0 1 0 1 1 0 1 } gl-texture-coord-pointer ;

: delete-dlist ( id -- ) 1 glDeleteLists ;

: with-translation ( loc quot -- )
    GL_MODELVIEW [ [ gl-translate ] dip call ] do-matrix ; inline

: fix-coordinates ( point1 point2 -- x1 y2 x2 y2 )
    [ first2 [ >fixnum ] bi@ ] bi@ ;

: gl-set-clip ( loc dim -- )
    fix-coordinates glScissor ;

: gl-viewport ( loc dim -- )
    fix-coordinates glViewport ;

: init-matrices ( -- )
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    GL_MODELVIEW glMatrixMode
    glLoadIdentity ;