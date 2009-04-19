! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache colors.constants destructors fry kernel
opengl opengl.gl opengl.capabilities combinators images
images.tesselation grouping specialized-arrays.float sequences math
math.vectors math.matrices generalizations fry arrays namespaces
system ;
IN: opengl.textures

SYMBOL: non-power-of-2-textures?

: check-extensions ( -- )
    #! ATI frglx driver doesn't implement GL_ARB_texture_non_power_of_two properly.
    #! See thread 'Linux font display problem' April 2009 on Factor-talk
    gl-vendor "ATI Technologies Inc." = not os macosx? or [
        "2.0" { "GL_ARB_texture_non_power_of_two" }
        has-gl-version-or-extensions?
        non-power-of-2-textures? set
    ] when ;

: gen-texture ( -- id ) [ glGenTextures ] (gen-gl-object) ;

: delete-texture ( id -- ) [ glDeleteTextures ] (delete-gl-object) ;

GENERIC: component-order>format ( component-order -- format type )

M: RGB component-order>format drop GL_RGB GL_UNSIGNED_BYTE ;
M: BGR component-order>format drop GL_BGR GL_UNSIGNED_BYTE ;
M: RGBA component-order>format drop GL_RGBA GL_UNSIGNED_BYTE ;
M: ARGB component-order>format drop GL_BGRA_EXT GL_UNSIGNED_INT_8_8_8_8_REV ;
M: BGRA component-order>format drop GL_BGRA_EXT GL_UNSIGNED_BYTE ;
M: BGRX component-order>format drop GL_BGRA_EXT GL_UNSIGNED_BYTE ;
M: LA component-order>format drop GL_LUMINANCE_ALPHA GL_UNSIGNED_BYTE ;
M: L component-order>format drop GL_LUMINANCE GL_UNSIGNED_BYTE ;

SLOT: display-list

: draw-texture ( texture -- ) display-list>> [ glCallList ] when* ;

GENERIC: draw-scaled-texture ( dim texture -- )

<PRIVATE

TUPLE: single-texture image dim loc texture-coords texture display-list disposed ;

: adjust-texture-dim ( dim -- dim' )
    non-power-of-2-textures? get [
        [ dup 1 = [ next-power-of-2 ] unless ] map
    ] unless ;

: (tex-image) ( image bitmap -- )
    [
        [ GL_TEXTURE_2D 0 GL_RGBA ] dip
        [ dim>> adjust-texture-dim first2 0 ]
        [ component-order>> component-order>format ] bi
    ] dip
    glTexImage2D ;

: (tex-sub-image) ( image -- )
    [ GL_TEXTURE_2D 0 0 0 ] dip
    [ dim>> first2 ] [ component-order>> component-order>format ] [ bitmap>> ] tri
    glTexSubImage2D ;

: make-texture ( image -- id )
    #! We use glTexSubImage2D to work around the power of 2 texture size
    #! limitation
    gen-texture [
        GL_TEXTURE_BIT [
            GL_TEXTURE_2D swap glBindTexture
            non-power-of-2-textures? get
            [ dup bitmap>> (tex-image) ]
            [ [ f (tex-image) ] [ (tex-sub-image) ] bi ] if
        ] do-attribs
    ] keep ;

: init-texture ( -- )
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_REPEAT glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_REPEAT glTexParameteri ;

: with-texturing ( quot -- )
    GL_TEXTURE_2D [
        GL_TEXTURE_BIT [
            GL_TEXTURE_COORD_ARRAY [
                COLOR: white gl-color
                call
            ] do-enabled-client-state
        ] do-attribs
    ] do-enabled ; inline

: (draw-textured-rect) ( dim texture -- )
    [ loc>> ]
    [ [ GL_TEXTURE_2D ] dip texture>> glBindTexture ]
    [ init-texture texture-coords>> gl-texture-coord-pointer ] tri
    swap gl-fill-rect ;

: draw-textured-rect ( dim texture -- )
    [
        [ image>> has-alpha? [ GL_BLEND glDisable ] unless ]
        [ (draw-textured-rect) GL_TEXTURE_2D 0 glBindTexture ]
        [ image>> has-alpha? [ GL_BLEND glEnable ] unless ]
        tri
    ] with-texturing ;

: texture-coords ( texture -- coords )
    [ [ dim>> ] [ image>> dim>> adjust-texture-dim ] bi v/ ]
    [
        image>> upside-down?>>
        { { 0 1 } { 1 1 } { 1 0 } { 0 0 } }
        { { 0 0 } { 1 0 } { 1 1 } { 0 1 } } ?
    ] bi
    [ v* ] with map float-array{ } join ;

: make-texture-display-list ( texture -- dlist )
    GL_COMPILE [ [ dim>> ] keep draw-textured-rect ] make-dlist ;

: <single-texture> ( image loc -- texture )
    single-texture new swap >>loc swap [ >>image ] [ dim>> >>dim ] bi
    dup image>> dim>> product 0 = [
        dup texture-coords >>texture-coords
        dup image>> make-texture >>texture
        dup make-texture-display-list >>display-list
    ] unless ;

M: single-texture dispose*
    [ texture>> [ delete-texture ] when* ]
    [ display-list>> [ delete-dlist ] when* ] bi ;

M: single-texture draw-scaled-texture
    2dup dim>> = [ nip draw-texture ] [
        dup texture>> [ draw-textured-rect ] [ 2drop ] if
    ] if ;

TUPLE: multi-texture grid display-list loc disposed ;

: image-locs ( image-grid -- loc-grid )
    [ first [ dim>> first ] map ] [ [ first dim>> second ] map ] bi
    [ 0 [ + ] accumulate nip ] bi@
    cross-zip flip ;

: <texture-grid> ( image-grid loc -- grid )
    [ dup image-locs ] dip
    '[ [ _ v+ <single-texture> |dispose ] 2map ] 2map ;

: draw-textured-grid ( grid -- )
    [ [ [ dim>> ] keep (draw-textured-rect) ] each ] each ;

: grid-has-alpha? ( grid -- ? )
    first first image>> has-alpha? ;

: make-textured-grid-display-list ( grid -- dlist )
    GL_COMPILE [
        [
            [ grid-has-alpha? [ GL_BLEND glDisable ] unless ]
            [ [ [ [ dim>> ] keep (draw-textured-rect) ] each ] each ]
            [ grid-has-alpha? [ GL_BLEND glEnable ] unless ] tri
            GL_TEXTURE_2D 0 glBindTexture
        ] with-texturing
    ] make-dlist ;

: <multi-texture> ( image-grid loc -- multi-texture )
    [
        [
            <texture-grid> dup
            make-textured-grid-display-list
        ] keep
        f multi-texture boa
    ] with-destructors ;

M: multi-texture draw-scaled-texture nip draw-texture ;

M: multi-texture dispose* grid>> [ [ dispose ] each ] each ;

CONSTANT: max-texture-size { 512 512 }

PRIVATE>

: <texture> ( image loc -- texture )
    over dim>> max-texture-size [ <= ] 2all?
    [ <single-texture> ]
    [ [ max-texture-size tesselate ] dip <multi-texture> ] if ;
