! (c)2009 Joe Groff bsd license
USING: accessors alien.c-types arrays byte-arrays combinators
destructors fry gpu gpu.buffers images kernel locals math
opengl opengl.gl opengl.textures sequences
specialized-arrays ui.gadgets.worlds variants ;
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
UNION: ?texture-data texture-data POSTPONE: f ;
UNION: ?float-array float-array POSTPONE: f ;

VARIANT: texture-wrap
    clamp-texcoord-to-edge clamp-texcoord-to-border repeat-texcoord repeat-texcoord-mirrored ;
VARIANT: texture-filter
    filter-nearest filter-linear ;

UNION: wrap-set texture-wrap sequence ;
UNION: ?texture-filter texture-filter POSTPONE: f ;

TUPLE: texture-parameters
    { wrap wrap-set initial: { repeat-texcoord repeat-texcoord repeat-texcoord } }
    { min-filter texture-filter initial: filter-nearest }
    { min-mipmap-filter ?texture-filter initial: filter-linear }
    { mag-filter texture-filter initial: filter-linear }
    { min-lod integer initial: -1000 }
    { max-lod integer initial:  1000 }
    { lod-bias integer initial: 0 }
    { base-level integer initial: 0 }
    { max-level integer initial: 1000 } ;

<PRIVATE

GENERIC: texture-object ( texture-data-target -- texture )
M: cube-map-face texture-object
    texture>> ;
M: texture texture-object
    ;

: gl-wrap ( wrap -- gl-wrap )
    {
        { clamp-texcoord-to-edge [ GL_CLAMP_TO_EDGE ] }
        { clamp-texcoord-to-border [ GL_CLAMP_TO_BORDER ] }
        { repeat-texcoord [ GL_REPEAT ] }
        { repeat-texcoord-mirrored [ GL_MIRRORED_REPEAT ] }
    } case ;

: set-texture-gl-wrap ( target wraps -- )
    dup sequence? [ 1array ] unless 3 over last pad-tail {
        [ [ GL_TEXTURE_WRAP_S ] dip first  gl-wrap glTexParameteri ]
        [ [ GL_TEXTURE_WRAP_T ] dip second gl-wrap glTexParameteri ]
        [ [ GL_TEXTURE_WRAP_R ] dip third  gl-wrap glTexParameteri ]
    } 2cleave ;

: gl-mag-filter ( filter -- gl-filter )
    {
        { filter-nearest [ GL_NEAREST ] }
        { filter-linear [ GL_LINEAR ] }
    } case ;

: gl-min-filter ( filter mipmap-filter -- gl-filter )
    2array {
        { { filter-nearest f              } [ GL_NEAREST                ] }
        { { filter-linear  f              } [ GL_LINEAR                 ] }
        { { filter-nearest filter-nearest } [ GL_NEAREST_MIPMAP_NEAREST ] }
        { { filter-linear  filter-nearest } [ GL_LINEAR_MIPMAP_NEAREST  ] }
        { { filter-linear  filter-linear  } [ GL_LINEAR_MIPMAP_LINEAR   ] }
        { { filter-nearest filter-linear  } [ GL_NEAREST_MIPMAP_LINEAR  ] }
    } case ;

GENERIC: texture-gl-target ( texture -- target )
GENERIC: texture-data-gl-target ( texture -- target )

M: texture-1d        texture-gl-target drop GL_TEXTURE_1D ;
M: texture-2d        texture-gl-target drop GL_TEXTURE_2D ;
M: texture-rectangle texture-gl-target drop GL_TEXTURE_RECTANGLE ;
M: texture-3d        texture-gl-target drop GL_TEXTURE_3D ;
M: texture-cube-map  texture-gl-target drop GL_TEXTURE_CUBE_MAP ;
M: texture-1d-array  texture-gl-target drop GL_TEXTURE_1D_ARRAY ;
M: texture-2d-array  texture-gl-target drop GL_TEXTURE_2D_ARRAY ;

M: texture-1d        texture-data-gl-target drop GL_TEXTURE_1D ;
M: texture-2d        texture-data-gl-target drop GL_TEXTURE_2D ;
M: texture-rectangle texture-data-gl-target drop GL_TEXTURE_RECTANGLE ;
M: texture-3d        texture-data-gl-target drop GL_TEXTURE_3D ;
M: texture-1d-array  texture-data-gl-target drop GL_TEXTURE_1D_ARRAY ;
M: texture-2d-array  texture-data-gl-target drop GL_TEXTURE_2D_ARRAY ;
M: cube-map-face     texture-data-gl-target
    axis>> {
        { -X [ GL_TEXTURE_CUBE_MAP_NEGATIVE_X ] }
        { -Y [ GL_TEXTURE_CUBE_MAP_NEGATIVE_Y ] }
        { -Z [ GL_TEXTURE_CUBE_MAP_NEGATIVE_Z ] }
        { +X [ GL_TEXTURE_CUBE_MAP_POSITIVE_X ] }
        { +Y [ GL_TEXTURE_CUBE_MAP_POSITIVE_Y ] }
        { +Z [ GL_TEXTURE_CUBE_MAP_POSITIVE_Z ] }
    } case ;

: texture-gl-internal-format ( texture -- internal-format )
    [ component-order>> ] [ component-type>> ] bi image-internal-format ; inline

: texture-data-gl-args ( texture data -- format type ptr )
    [
        nip
        [ [ component-order>> ] [ component-type>> ] bi image-data-format ]
        [ ptr>> ] bi
    ] [
        [ component-order>> ] [ component-type>> ] bi image-data-format f
    ] if* ;

:: bind-tdt ( tdt -- texture )
    tdt texture-object :> texture
    texture [ texture-gl-target ] [ handle>> ] bi glBindTexture
    texture ;

: get-texture-float ( target level enum -- value )
    0 <float> [ glGetTexLevelParameterfv ] keep *float ;
: get-texture-int ( target level enum -- value )
    0 <int> [ glGetTexLevelParameteriv ] keep *int ;

: ?product ( x -- y )
    dup number? [ product ] unless ;

PRIVATE>

GENERIC# allocate-texture 3 ( tdt level dim data -- )

M:: texture-1d-data-target allocate-texture ( tdt level dim data -- )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level texture texture-gl-internal-format
    dim 0 texture data texture-data-gl-args
    pixel-unpack-buffer [ glTexImage1D ] with-gpu-data-ptr ;

M:: texture-2d-data-target allocate-texture ( tdt level dim data -- )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level texture texture-gl-internal-format
    dim first2 0 texture data texture-data-gl-args
    pixel-unpack-buffer [ glTexImage2D ] with-gpu-data-ptr ;

M:: texture-3d-data-target allocate-texture ( tdt level dim data -- )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level texture texture-gl-internal-format
    dim first3 0 texture data texture-data-gl-args
    pixel-unpack-buffer [ glTexImage3D ] with-gpu-data-ptr ;

GENERIC# update-texture 4 ( tdt level loc dim data -- )

M:: texture-1d-data-target update-texture ( tdt level loc dim data -- )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level
    loc dim texture data texture-data-gl-args
    pixel-unpack-buffer [ glTexSubImage1D ] with-gpu-data-ptr ;

M:: texture-2d-data-target update-texture ( tdt level loc dim data -- )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level
    loc dim [ first2 ] bi@
    texture data texture-data-gl-args
    pixel-unpack-buffer [ glTexSubImage2D ] with-gpu-data-ptr ;

M:: texture-3d-data-target update-texture ( tdt level loc dim data -- )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level
    loc dim [ first3 ] bi@
    texture data texture-data-gl-args
    pixel-unpack-buffer [ glTexSubImage3D ] with-gpu-data-ptr ;

: image>texture-data ( image -- dim texture-data )
    { [ dim>> ] [ bitmap>> ] [ component-order>> ] [ component-type>> ] } cleave
    <texture-data> ; inline

GENERIC# texture-dim 1 ( tdt level -- dim )

M:: texture-1d-data-target texture-dim ( tdt level -- dim )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level GL_TEXTURE_WIDTH get-texture-int ;

M:: texture-2d-data-target texture-dim ( tdt level -- dim )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level 
    [ GL_TEXTURE_WIDTH get-texture-int ] [ GL_TEXTURE_HEIGHT get-texture-int ] 2bi
    2array ;

M:: texture-3d-data-target texture-dim ( tdt level -- dim )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level 
    [ GL_TEXTURE_WIDTH get-texture-int ]
    [ GL_TEXTURE_HEIGHT get-texture-int ]
    [ GL_TEXTURE_DEPTH get-texture-int ] 2tri
    3array ;

: texture-data-size ( tdt level -- size )
    [ texture-dim ?product ] [ drop texture-object bytes-per-pixel ] 2bi * ;

:: read-texture-to ( tdt level gpu-data-ptr -- )
    tdt bind-tdt :> texture
    tdt texture-data-gl-target level
    texture [ component-order>> ] [ component-type>> ] bi image-data-format
    gpu-data-ptr pixel-pack-buffer [ glGetTexImage ] with-gpu-data-ptr ;

: read-texture ( tdt level -- byte-array )
    2dup texture-data-size <byte-array>
    [ read-texture-to ] keep ;

: allocate-texture-image ( tdt level image -- )
    image>texture-data allocate-texture ;

: update-texture-image ( tdt level loc image -- )
    image>texture-data update-texture ;

: read-texture-image ( tdt level -- image )
    [ texture-dim ]
    [ drop texture-object [ component-order>> ] [ component-type>> ] bi f ]
    [ read-texture ] 2tri
    image boa ;

<PRIVATE
: bind-texture ( texture -- gl-target )
    [ texture-gl-target dup ] [ handle>> ] bi glBindTexture ;
PRIVATE>

: generate-mipmaps ( texture -- )
    bind-texture glGenerateMipmap ;

: set-texture-parameters ( texture parameters -- )
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
    texture-1d <texture> ;
: <texture-2d> ( component-order component-type parameters -- texture )
    texture-2d <texture> ;
: <texture-3d> ( component-order component-type parameters -- texture )
    texture-3d <texture> ;
: <texture-cube-map> ( component-order component-type parameters -- texture )
    texture-cube-map <texture> ;
: <texture-rectangle> ( component-order component-type parameters -- texture )
    texture-rectangle <texture> ;
: <texture-1d-array> ( component-order component-type parameters -- texture )
    texture-1d-array <texture> ;
: <texture-2d-array> ( component-order component-type parameters -- texture )
    texture-2d-array <texture> ;

