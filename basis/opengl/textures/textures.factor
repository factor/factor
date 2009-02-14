! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache colors.constants destructors fry
kernel opengl opengl.gl combinators images endian
specialized-arrays.float locals sequences ;
IN: opengl.textures

: init-texture ( -- )
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_REPEAT glTexParameterf
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_REPEAT glTexParameterf ;

: rect-texture-coords ( -- )
    float-array{ 0 0 1 0 1 1 0 1 } gl-texture-coord-pointer ;

: gen-texture ( -- id )
    [ glGenTextures ] (gen-gl-object) ;

:: make-texture ( dim pixmap format type -- id )
    gen-texture [
        GL_TEXTURE_BIT [
            GL_TEXTURE_2D swap glBindTexture
            GL_TEXTURE_2D
            0
            GL_RGBA
            dim first2
            0
            format
            type
            pixmap
            glTexImage2D
        ] do-attribs
    ] keep ;

: draw-textured-rect ( dim texture -- )
    GL_TEXTURE_2D [
        GL_TEXTURE_BIT [
            GL_TEXTURE_COORD_ARRAY [
                COLOR: white gl-color
                GL_TEXTURE_2D swap glBindTexture
                init-texture rect-texture-coords
                fill-rect-vertices (gl-fill-rect)
                GL_TEXTURE_2D 0 glBindTexture
            ] do-enabled-client-state
        ] do-attribs
    ] do-enabled ;

: delete-texture ( id -- )
    [ glDeleteTextures ] (delete-gl-object) ;

TUPLE: texture texture display-list disposed ;

: make-texture-display-list ( dim texture -- dlist )
    GL_COMPILE [ draw-textured-rect ] make-dlist ;

GENERIC: component-order>format ( component-order -- format type )

M: RGBA component-order>format drop GL_RGBA GL_UNSIGNED_BYTE ;
M: ARGB component-order>format drop GL_BGRA_EXT GL_UNSIGNED_INT_8_8_8_8_REV ;
M: BGRA component-order>format drop GL_BGRA_EXT GL_UNSIGNED_INT_8_8_8_8 ;

: <texture> ( image -- texture )
    [
        [ dim>> ]
        [ bitmap>> ]
        [ component-order>> component-order>format ]
        tri make-texture
    ] [ dim>> ] bi
    over make-texture-display-list f texture boa ;

M: texture dispose*
    [ texture>> delete-texture ]
    [ display-list>> delete-dlist ] bi ;