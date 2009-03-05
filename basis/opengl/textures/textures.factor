! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache colors.constants destructors fry kernel
opengl opengl.gl combinators images grouping specialized-arrays.float
locals sequences math math.vectors generalizations ;
IN: opengl.textures

: gen-texture ( -- id ) [ glGenTextures ] (gen-gl-object) ;

: delete-texture ( id -- ) [ glDeleteTextures ] (delete-gl-object) ;

TUPLE: texture loc dim texture-coords texture display-list disposed ;

<PRIVATE

GENERIC: component-order>format ( component-order -- format type )

M: RGBA component-order>format drop GL_RGBA GL_UNSIGNED_BYTE ;
M: ARGB component-order>format drop GL_BGRA_EXT GL_UNSIGNED_INT_8_8_8_8_REV ;
M: BGRA component-order>format drop GL_BGRA_EXT GL_UNSIGNED_BYTE ;

: repeat-last ( seq n -- seq' )
    over peek pad-tail concat ;

: power-of-2-bitmap ( rows dim size -- bitmap dim )
    '[
        first2
        [ [ _ ] dip '[ _ group _ repeat-last ] map ]
        [ repeat-last ]
        bi*
    ] keep ;

: image-rows ( image -- rows )
    [ bitmap>> ]
    [ dim>> first ]
    [ component-order>> bytes-per-pixel ]
    tri * group ; inline

: power-of-2-image ( image -- image )
    dup dim>> [ 0 = ] all? [
        clone dup
        [ image-rows ]
        [ dim>> [ next-power-of-2 ] map ]
        [ component-order>> bytes-per-pixel ] tri
        power-of-2-bitmap
        [ >>bitmap ] [ >>dim ] bi*
    ] unless ;

:: make-texture ( image -- id )
    gen-texture [
        GL_TEXTURE_BIT [
            GL_TEXTURE_2D swap glBindTexture
            GL_TEXTURE_2D
            0
            GL_RGBA
            image dim>> first2
            0
            image component-order>> component-order>format
            image bitmap>>
            glTexImage2D
        ] do-attribs
    ] keep ;

: init-texture ( -- )
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_REPEAT glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_REPEAT glTexParameteri ;

: draw-textured-rect ( dim texture -- )
    GL_TEXTURE_2D [
        GL_TEXTURE_BIT [
            GL_TEXTURE_COORD_ARRAY [
                COLOR: white gl-color
                dup loc>> [
                    [ [ GL_TEXTURE_2D ] dip texture>> glBindTexture ]
                    [ init-texture texture-coords>> gl-texture-coord-pointer ] bi
                    fill-rect-vertices (gl-fill-rect)
                    GL_TEXTURE_2D 0 glBindTexture
                ] with-translation
            ] do-enabled-client-state
        ] do-attribs
    ] do-enabled ;

: texture-coords ( dim -- coords )
    [ dup next-power-of-2 /f ] map
    { { 0 0 } { 1 0 } { 1 1 } { 0 1 } } [ v* ] with map
    float-array{ } join ;

: make-texture-display-list ( texture -- dlist )
    GL_COMPILE [ [ dim>> ] keep draw-textured-rect ] make-dlist ;

PRIVATE>

: <texture> ( image loc -- texture )
    texture new swap >>loc
    swap
    [ dim>> >>dim ] keep
    [ dim>> product 0 = ] keep '[
        _
        [ dim>> texture-coords >>texture-coords ]
        [ power-of-2-image make-texture >>texture ] bi
        dup make-texture-display-list >>display-list
    ] unless ;

M: texture dispose*
    [ texture>> [ delete-texture ] when* ]
    [ display-list>> [ delete-dlist ] when* ] bi ;

: draw-texture ( texture -- )
    display-list>> [ glCallList ] when* ;

: draw-scaled-texture ( dim texture -- )
    dup texture>> [ draw-textured-rect ] [ 2drop ] if ;