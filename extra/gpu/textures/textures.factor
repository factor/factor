! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays byte-arrays combinators
destructors gpu gpu.buffers images kernel math
opengl.gl opengl.textures sequences
specialized-arrays typed ui.gadgets.worlds variants ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
IN: gpu.textures

TUPLE: texture < gpu-object
    { component-order component-order read-only initial: RGBA }
    { component-type component-type read-only initial: ubyte-components } ;

TUPLE: texture-1d < texture ;
TUPLE: texture-2d < texture ;
TUPLE: texture-rectangle < texture ;
TUPLE: texture-3d < texture ;
TUPLE: texture-cube-map < texture ;

TUPLE: texture-1d-array < texture ;
TUPLE: texture-2d-array < texture ;

VARIANT: cube-map-axis
    -X -Y -Z +X +Y +Z ;

TUPLE: cube-map-face
    { texture texture-cube-map read-only }
    { axis cube-map-axis read-only } ;
C: <cube-map-face> cube-map-face

UNION: texture-1d-data-target
    texture-1d ;
UNION: texture-2d-data-target
    texture-2d texture-rectangle texture-1d-array cube-map-face ;
UNION: texture-3d-data-target
    texture-3d texture-2d-array ;
UNION: texture-data-target
    texture-1d-data-target texture-2d-data-target texture-3d-data-target ;

M: texture dispose
    [ [ delete-texture ] when* f ] change-handle drop ;

TUPLE: texture-data
    { ptr read-only }
    { component-order component-order read-only initial: RGBA }
    { component-type component-type read-only initial: ubyte-components } ;

C: <texture-data> texture-data

VARIANT: compressed-texture-format
    DXT1-RGB DXT1-RGBA DXT3 DXT5
    LATC1 LATC1-SIGNED LATC2 LATC2-SIGNED
    RGTC1 RGTC1-SIGNED RGTC2 RGTC2-SIGNED ;

TUPLE: compressed-texture-data
    { ptr read-only }
    { format compressed-texture-format read-only }
    { length integer read-only } ;

C: <compressed-texture-data> compressed-texture-data

VARIANT: texture-wrap
    clamp-texcoord-to-edge clamp-texcoord-to-border repeat-texcoord repeat-texcoord-mirrored ;
VARIANT: texture-filter
    filter-nearest filter-linear ;

UNION: wrap-set texture-wrap sequence ;

TUPLE: texture-parameters
    { wrap wrap-set initial: { repeat-texcoord repeat-texcoord repeat-texcoord } }
    { min-filter texture-filter initial: filter-nearest }
    { min-mipmap-filter maybe{ texture-filter } initial: filter-linear }
    { mag-filter texture-filter initial: filter-linear }
    { min-lod integer initial: -1000 }
    { max-lod integer initial:  1000 }
    { lod-bias integer initial: 0 }
    { base-level integer initial: 0 }
    { max-level integer initial: 1000 } ;

<PRIVATE

GENERIC: texture-object ( texture-data-target -- texture )
M: cube-map-face texture-object
    texture>> ; inline
M: texture texture-object
    ; inline

: gl-compressed-texture-format ( format -- gl-format )
    {
        { DXT1-RGB     [ GL_COMPRESSED_RGB_S3TC_DXT1_EXT  ] }
        { DXT1-RGBA    [ GL_COMPRESSED_RGBA_S3TC_DXT1_EXT ] }
        { DXT3         [ GL_COMPRESSED_RGBA_S3TC_DXT3_EXT ] }
        { DXT5         [ GL_COMPRESSED_RGBA_S3TC_DXT5_EXT ] }
        { RGTC1        [ GL_COMPRESSED_RED_RGTC1          ] }
        { RGTC1-SIGNED [ GL_COMPRESSED_SIGNED_RED_RGTC1   ] }
        { RGTC2        [ GL_COMPRESSED_RG_RGTC2           ] }
        { RGTC2-SIGNED [ GL_COMPRESSED_SIGNED_RG_RGTC2    ] }
    } case ; inline

: gl-wrap ( wrap -- gl-wrap )
    {
        { clamp-texcoord-to-edge [ GL_CLAMP_TO_EDGE ] }
        { clamp-texcoord-to-border [ GL_CLAMP_TO_BORDER ] }
        { repeat-texcoord [ GL_REPEAT ] }
        { repeat-texcoord-mirrored [ GL_MIRRORED_REPEAT ] }
    } case ; inline

: set-texture-gl-wrap ( target wraps -- )
    dup sequence? [ 1array ] unless 3 over last pad-tail {
        [ [ GL_TEXTURE_WRAP_S ] dip first  gl-wrap glTexParameteri ]
        [ [ GL_TEXTURE_WRAP_T ] dip second gl-wrap glTexParameteri ]
        [ [ GL_TEXTURE_WRAP_R ] dip third  gl-wrap glTexParameteri ]
    } 2cleave ; inline

: gl-mag-filter ( filter -- gl-filter )
    {
        { filter-nearest [ GL_NEAREST ] }
        { filter-linear [ GL_LINEAR ] }
    } case ; inline

: gl-min-filter ( filter mipmap-filter -- gl-filter )
    2array {
        { { filter-nearest f              } [ GL_NEAREST                ] }
        { { filter-linear  f              } [ GL_LINEAR                 ] }
        { { filter-nearest filter-nearest } [ GL_NEAREST_MIPMAP_NEAREST ] }
        { { filter-linear  filter-nearest } [ GL_LINEAR_MIPMAP_NEAREST  ] }
        { { filter-linear  filter-linear  } [ GL_LINEAR_MIPMAP_LINEAR   ] }
        { { filter-nearest filter-linear  } [ GL_NEAREST_MIPMAP_LINEAR  ] }
    } case ; inline

GENERIC: texture-gl-target ( texture -- target )
GENERIC: texture-data-gl-target ( texture -- target )

M: texture-1d        texture-gl-target drop GL_TEXTURE_1D ; inline
M: texture-2d        texture-gl-target drop GL_TEXTURE_2D ; inline
M: texture-rectangle texture-gl-target drop GL_TEXTURE_RECTANGLE ; inline
M: texture-3d        texture-gl-target drop GL_TEXTURE_3D ; inline
M: texture-cube-map  texture-gl-target drop GL_TEXTURE_CUBE_MAP ; inline
M: texture-1d-array  texture-gl-target drop GL_TEXTURE_1D_ARRAY ; inline
M: texture-2d-array  texture-gl-target drop GL_TEXTURE_2D_ARRAY ; inline

M: texture-1d        texture-data-gl-target drop GL_TEXTURE_1D ; inline
M: texture-2d        texture-data-gl-target drop GL_TEXTURE_2D ; inline
M: texture-rectangle texture-data-gl-target drop GL_TEXTURE_RECTANGLE ; inline
M: texture-3d        texture-data-gl-target drop GL_TEXTURE_3D ; inline
M: texture-1d-array  texture-data-gl-target drop GL_TEXTURE_1D_ARRAY ; inline
M: texture-2d-array  texture-data-gl-target drop GL_TEXTURE_2D_ARRAY ; inline
M: cube-map-face     texture-data-gl-target
    axis>> {
        { -X [ GL_TEXTURE_CUBE_MAP_NEGATIVE_X ] }
        { -Y [ GL_TEXTURE_CUBE_MAP_NEGATIVE_Y ] }
        { -Z [ GL_TEXTURE_CUBE_MAP_NEGATIVE_Z ] }
        { +X [ GL_TEXTURE_CUBE_MAP_POSITIVE_X ] }
        { +Y [ GL_TEXTURE_CUBE_MAP_POSITIVE_Y ] }
        { +Z [ GL_TEXTURE_CUBE_MAP_POSITIVE_Z ] }
    } case ; inline

: texture-gl-internal-format ( texture -- internal-format )
    [ component-order>> ] [ component-type>> ] bi image-internal-format ; inline

: texture-data-gl-args ( texture data -- format type ptr )
    [
        nip
        [ [ component-order>> ] [ component-type>> ] bi image-data-format ]
        [ ptr>> ] bi
    ] [
        [ component-order>> ] [ component-type>> ] bi image-data-format f
    ] if* ; inline

:: bind-tdt ( tdt -- texture )
    tdt texture-object :> texture
    texture [ texture-gl-target ] [ handle>> ] bi glBindTexture
    texture ; inline

: ?product ( x -- y )
    dup number? [ product ] unless ; inline

:: (allocate-texture) ( tdt level dim data dim-quot teximage-quot -- )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level texture texture-gl-internal-format
    dim dim-quot call 0 texture data texture-data-gl-args
    pixel-unpack-buffer teximage-quot with-gpu-data-ptr ; inline

:: (allocate-compressed-texture) ( tdt level dim compressed-data dim-quot teximage-quot -- )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level compressed-data format>> gl-compressed-texture-format
    dim dim-quot call 0 compressed-data [ length>> ] [ ptr>> ] bi
    pixel-unpack-buffer teximage-quot with-gpu-data-ptr ; inline

:: (update-texture) ( tdt level loc dim data dim-quot texsubimage-quot -- )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level
    loc dim dim-quot bi@
    texture data texture-data-gl-args
    pixel-unpack-buffer texsubimage-quot with-gpu-data-ptr ; inline

:: (update-compressed-texture) ( tdt level loc dim compressed-data dim-quot texsubimage-quot -- )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level
    loc dim dim-quot bi@
    compressed-data [ format>> gl-compressed-texture-format ] [ length>> ] [ ptr>> ] tri
    pixel-unpack-buffer texsubimage-quot with-gpu-data-ptr ; inline

PRIVATE>

GENERIC#: allocate-texture 3 ( tdt level dim data -- )

M: texture-1d-data-target allocate-texture ( tdt level dim data -- )
    [ ] [ glTexImage1D ] (allocate-texture) ;

M: texture-2d-data-target allocate-texture ( tdt level dim data -- )
    [ first2 ] [ glTexImage2D ] (allocate-texture) ;

M: texture-3d-data-target allocate-texture ( tdt level dim data -- )
    [ first3 ] [ glTexImage3D ] (allocate-texture) ;

GENERIC#: allocate-compressed-texture 3 ( tdt level dim compressed-data -- )

M: texture-1d-data-target allocate-compressed-texture ( tdt level dim compressed-data -- )
    [ ] [ glCompressedTexImage1D ] (allocate-compressed-texture) ;

M: texture-2d-data-target allocate-compressed-texture ( tdt level dim compressed-data -- )
    [ first2 ] [ glCompressedTexImage2D ] (allocate-compressed-texture) ;

M: texture-3d-data-target allocate-compressed-texture ( tdt level dim compressed-data -- )
    [ first3 ] [ glCompressedTexImage3D ] (allocate-compressed-texture) ;

GENERIC#: update-texture 4 ( tdt level loc dim data -- )

M: texture-1d-data-target update-texture ( tdt level loc dim data -- )
    [ ] [ glTexSubImage1D ] (update-texture) ;

M: texture-2d-data-target update-texture ( tdt level loc dim data -- )
    [ first2 ] [ glTexSubImage2D ] (update-texture) ;

M: texture-3d-data-target update-texture ( tdt level loc dim data -- )
    [ first3 ] [ glTexSubImage3D ] (update-texture) ;

GENERIC#: update-compressed-texture 4 ( tdt level loc dim compressed-data -- )

M: texture-1d-data-target update-compressed-texture ( tdt level loc dim compressed-data -- )
    [ ] [ glCompressedTexSubImage1D ] (update-compressed-texture) ;

M: texture-2d-data-target update-compressed-texture ( tdt level loc dim compressed-data -- )
    [ first2 ] [ glCompressedTexSubImage2D ] (update-compressed-texture) ;

M: texture-3d-data-target update-compressed-texture ( tdt level loc dim compressed-data -- )
    [ first3 ] [ glCompressedTexSubImage3D ] (update-compressed-texture) ;

: image>texture-data ( image -- dim texture-data )
    { [ dim>> ] [ bitmap>> ] [ component-order>> ] [ component-type>> ] } cleave
    <texture-data> ; inline

GENERIC#: texture-dim 1 ( tdt level -- dim )

M:: texture-1d-data-target texture-dim ( tdt level -- dim )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level GL_TEXTURE_WIDTH get-texture-int ; inline

M:: texture-2d-data-target texture-dim ( tdt level -- dim )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level
    [ GL_TEXTURE_WIDTH get-texture-int ] [ GL_TEXTURE_HEIGHT get-texture-int ] 2bi
    2array ; inline

M:: texture-3d-data-target texture-dim ( tdt level -- dim )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level
    [ GL_TEXTURE_WIDTH get-texture-int ]
    [ GL_TEXTURE_HEIGHT get-texture-int ]
    [ GL_TEXTURE_DEPTH get-texture-int ] 2tri
    3array ; inline

: compressed-texture-data-size ( tdt level -- size )
    [ [ bind-tdt drop ] [ texture-data-gl-target ] bi ] dip
    GL_TEXTURE_COMPRESSED_IMAGE_SIZE get-texture-int ; inline

: texture-data-size ( tdt level -- size )
    [ texture-dim ?product ] [ drop texture-object bytes-per-pixel ] 2bi * ; inline

TYPED:: read-texture-to ( tdt: texture-data-target level: integer gpu-data-ptr -- )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level
    texture [ component-order>> ] [ component-type>> ] bi image-data-format
    gpu-data-ptr pixel-pack-buffer [ glGetTexImage ] with-gpu-data-ptr ;

TYPED: read-texture ( tdt: texture-data-target level: integer -- byte-array: byte-array )
    2dup texture-data-size (byte-array)
    [ read-texture-to ] keep ;

TYPED:: read-compressed-texture-to ( tdt: texture-data-target level: integer gpu-data-ptr -- )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level
    gpu-data-ptr pixel-pack-buffer [ glGetCompressedTexImage ] with-gpu-data-ptr ;

TYPED: read-compressed-texture ( tdt: texture-data-target level: integer -- byte-array: byte-array )
    2dup compressed-texture-data-size (byte-array)
    [ read-compressed-texture-to ] keep ;

: allocate-texture-image ( tdt level image -- )
    image>texture-data allocate-texture ; inline

: update-texture-image ( tdt level loc image -- )
    image>texture-data update-texture ; inline

: read-texture-image ( tdt level -- image )
    [ texture-dim ]
    [ drop texture-object [ component-order>> ] [ component-type>> ] bi f f ]
    [ read-texture ] 2tri
    f image boa ; inline

<PRIVATE
: bind-texture ( texture -- gl-target )
    [ texture-gl-target dup ] [ handle>> ] bi glBindTexture ; inline
PRIVATE>

: generate-mipmaps ( texture -- )
    bind-texture glGenerateMipmap ; inline

TYPED: set-texture-parameters ( texture: texture parameters: texture-parameters -- )
    [ bind-texture ] dip {
        [ wrap>> set-texture-gl-wrap ]
        [
            [ GL_TEXTURE_MIN_FILTER ] dip
            [ min-filter>> ] [ min-mipmap-filter>> ] bi gl-min-filter glTexParameteri
        ] [
            [ GL_TEXTURE_MAG_FILTER ] dip
            mag-filter>> gl-mag-filter glTexParameteri
        ]
        [ [ GL_TEXTURE_MIN_LOD ] dip min-lod>> glTexParameteri ]
        [ [ GL_TEXTURE_MAX_LOD ] dip max-lod>> glTexParameteri ]
        [ [ GL_TEXTURE_LOD_BIAS ] dip lod-bias>> glTexParameteri ]
        [ [ GL_TEXTURE_BASE_LEVEL ] dip base-level>> glTexParameteri ]
        [ [ GL_TEXTURE_MAX_LEVEL ] dip max-level>> glTexParameteri ]
    } 2cleave ;

<PRIVATE

: <texture> ( component-order component-type parameters class -- texture )
    '[ [ gen-texture ] 2dip _ boa dup window-resource ] dip
    [ T{ texture-parameters } clone ] unless* set-texture-parameters ; inline

PRIVATE>

: <texture-1d> ( component-order component-type parameters -- texture )
    texture-1d <texture> ; inline
: <texture-2d> ( component-order component-type parameters -- texture )
    texture-2d <texture> ; inline
: <texture-3d> ( component-order component-type parameters -- texture )
    texture-3d <texture> ; inline
: <texture-cube-map> ( component-order component-type parameters -- texture )
    texture-cube-map <texture> ; inline
: <texture-rectangle> ( component-order component-type parameters -- texture )
    texture-rectangle <texture> ; inline
: <texture-1d-array> ( component-order component-type parameters -- texture )
    texture-1d-array <texture> ; inline
: <texture-2d-array> ( component-order component-type parameters -- texture )
    texture-2d-array <texture> ; inline
