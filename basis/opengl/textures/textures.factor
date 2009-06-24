! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache colors.constants destructors kernel
opengl opengl.gl opengl.capabilities combinators images
images.tesselation grouping specialized-arrays.float sequences math
math.vectors math.matrices generalizations fry arrays namespaces
system locals ;
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

GENERIC: component-type>type ( component-type -- internal-format type )
GENERIC: component-order>format ( type component-order -- type format )
GENERIC: component-order>integer-format ( type component-order -- type format )

ERROR: unsupported-component-order component-order ;

M: ubyte-components component-type>type drop GL_RGBA8 GL_UNSIGNED_BYTE ;
M: ushort-components component-type>type drop GL_RGBA16 GL_UNSIGNED_SHORT ;
M: half-components component-type>type drop GL_RGBA16F_ARB GL_HALF_FLOAT_ARB ;
M: float-components component-type>type drop GL_RGBA32F_ARB GL_FLOAT ;
M: byte-integer-components component-type>type drop GL_RGBA8I_EXT GL_BYTE ;
M: short-integer-components component-type>type drop GL_RGBA16I_EXT GL_SHORT ;
M: int-integer-components component-type>type drop GL_RGBA32I_EXT GL_INT ;
M: ubyte-integer-components component-type>type drop GL_RGBA8I_EXT GL_UNSIGNED_BYTE ;
M: ushort-integer-components component-type>type drop GL_RGBA16I_EXT GL_UNSIGNED_SHORT ;
M: uint-integer-components component-type>type drop GL_RGBA32I_EXT GL_UNSIGNED_INT ;

M: RGB component-order>format drop GL_RGB ;
M: BGR component-order>format drop GL_BGR ;
M: RGBA component-order>format drop GL_RGBA ;
M: ARGB component-order>format
    swap GL_UNSIGNED_BYTE =
    [ drop GL_UNSIGNED_INT_8_8_8_8_REV GL_BGRA ]
    [ unsupported-component-order ] if ;
M: BGRA component-order>format drop GL_BGRA ;
M: BGRX component-order>format drop GL_BGRA ;
M: LA component-order>format drop GL_LUMINANCE_ALPHA ;
M: L component-order>format drop GL_LUMINANCE ;

M: object component-order>format unsupported-component-order ;

M: RGB component-order>integer-format drop GL_RGB_INTEGER_EXT ;
M: BGR component-order>integer-format drop GL_BGR_INTEGER_EXT ;
M: RGBA component-order>integer-format drop GL_RGBA_INTEGER_EXT ;
M: BGRA component-order>integer-format drop GL_BGRA_INTEGER_EXT ;
M: BGRX component-order>integer-format drop GL_BGRA_INTEGER_EXT ;
M: LA component-order>integer-format drop GL_LUMINANCE_ALPHA_INTEGER_EXT ;
M: L component-order>integer-format drop GL_LUMINANCE_INTEGER_EXT ;

M: object component-order>integer-format unsupported-component-order ;

SLOT: display-list

: draw-texture ( texture -- ) display-list>> [ glCallList ] when* ;

GENERIC: draw-scaled-texture ( dim texture -- )

DEFER: make-texture

<PRIVATE

TUPLE: single-texture image dim loc texture-coords texture display-list disposed ;

: adjust-texture-dim ( dim -- dim' )
    non-power-of-2-textures? get [
        [ dup 1 = [ next-power-of-2 ] unless ] map
    ] unless ;

: image-format ( image -- internal-format format type )
    dup component-type>>
    [ nip component-type>type ]
    [
        unnormalized-integer-components?
        [ component-order>> component-order>integer-format ]
        [ component-order>> component-order>format ] if
    ] 2bi swap ;

:: tex-image ( image bitmap -- )
    image image-format :> type :> format :> internal-format
    GL_TEXTURE_2D 0 internal-format
    image dim>> adjust-texture-dim first2 0
    format type bitmap glTexImage2D ;

: tex-sub-image ( image -- )
    [ GL_TEXTURE_2D 0 0 0 ] dip
    [ dim>> first2 ]
    [ image-format [ drop ] 2dip ]
    [ bitmap>> ] tri
    glTexSubImage2D ;

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

: make-texture ( image -- id )
    #! We use glTexSubImage2D to work around the power of 2 texture size
    #! limitation
    gen-texture [
        GL_TEXTURE_BIT [
            GL_TEXTURE_2D swap glBindTexture
            non-power-of-2-textures? get
            [ dup bitmap>> tex-image ]
            [ [ f tex-image ] [ tex-sub-image ] bi ] if
        ] do-attribs
    ] keep ;

: <texture> ( image loc -- texture )
    over dim>> max-texture-size [ <= ] 2all?
    [ <single-texture> ]
    [ [ max-texture-size tesselate ] dip <multi-texture> ] if ;
