! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays byte-arrays
combinators destructors gpu gpu.buffers gpu.private gpu.textures
gpu.textures.private images kernel locals math math.rectangles
opengl opengl.framebuffers opengl.gl opengl.textures sequences
specialized-arrays typed ui.gadgets.worlds variants ;
SPECIALIZED-ARRAY: int
SPECIALIZED-ARRAY: uint
IN: gpu.framebuffers

SINGLETON: system-framebuffer

TUPLE: renderbuffer < gpu-object
    { component-order component-order initial: RGBA }
    { component-type component-type initial: ubyte-components }
    { samples integer initial: 0 } ;

<PRIVATE

: get-framebuffer-int ( enum -- value )
    GL_RENDERBUFFER swap 0 int <ref>
    [ glGetRenderbufferParameteriv ] keep int deref ;

PRIVATE>

TYPED:: allocate-renderbuffer ( renderbuffer: renderbuffer dim -- )
    GL_RENDERBUFFER renderbuffer handle>> glBindRenderbuffer
    GL_RENDERBUFFER
    renderbuffer samples>> dup zero?
    [ drop renderbuffer texture-gl-internal-format dim first2 glRenderbufferStorage ]
    [ renderbuffer texture-gl-internal-format dim first2 glRenderbufferStorageMultisample ]
    if ;

TYPED:: renderbuffer-dim ( renderbuffer: renderbuffer -- dim: array )
    GL_RENDERBUFFER renderbuffer handle>> glBindRenderbuffer
    GL_RENDERBUFFER_WIDTH get-framebuffer-int
    GL_RENDERBUFFER_HEIGHT get-framebuffer-int 2array ;

TYPED: <renderbuffer> ( component-order: component-order
                        component-type: component-type
                        samples
                        dim
                        --
                        renderbuffer )
    [ [ gen-renderbuffer ] 3dip renderbuffer boa dup ] dip
    [ allocate-renderbuffer ] [ drop ] if*
    window-resource ;

M: renderbuffer dispose
    [ [ delete-renderbuffer ] when* f ] change-handle drop ;

TUPLE: texture-1d-attachment
    { texture texture-1d-data-target read-only initial: T{ texture-1d } }
    { level integer read-only } ;

C: <texture-1d-attachment> texture-1d-attachment

TUPLE: texture-2d-attachment
    { texture texture-2d-data-target read-only initial: T{ texture-2d } }
    { level integer read-only } ;

C: <texture-2d-attachment> texture-2d-attachment

TUPLE: texture-3d-attachment
    { texture texture-3d read-only initial: T{ texture-3d } }
    { z-offset integer read-only }
    { level integer read-only } ;

C: <texture-3d-attachment> texture-3d-attachment

TUPLE: texture-layer-attachment
    { texture texture-3d-data-target read-only initial: T{ texture-3d } }
    { layer integer read-only }
    { level integer read-only } ;

C: <texture-layer-attachment> texture-layer-attachment

UNION: texture-attachment
    texture-1d-attachment texture-2d-attachment texture-3d-attachment texture-layer-attachment ;

M: texture-attachment dispose texture>> dispose ;

UNION: framebuffer-attachment renderbuffer texture-attachment ;

GENERIC: attachment-object ( attachment -- object )
M: renderbuffer attachment-object ;
M: texture-attachment attachment-object texture>> texture-object ;

TUPLE: framebuffer < gpu-object
    { color-attachments array read-only }
    { depth-attachment maybe{ framebuffer-attachment } read-only initial: f }
    { stencil-attachment maybe{ framebuffer-attachment } read-only initial: f } ;

UNION: any-framebuffer system-framebuffer framebuffer ;

VARIANT: framebuffer-attachment-side
    left-side right-side ;

VARIANT: framebuffer-attachment-face
    back-face front-face ;

VARIANT: color-attachment-ref
    default-attachment
    system-attachment: {
        { side maybe{ framebuffer-attachment-side } initial: f }
        { face maybe{ framebuffer-attachment-face } initial: back-face }
    }
    color-attachment: { { index integer } } ;

VARIANT: non-color-attachment-ref
    depth-attachment
    stencil-attachment ;

UNION: attachment-ref
    color-attachment-ref
    non-color-attachment-ref
    POSTPONE: f ;

TUPLE: framebuffer-rect
    { framebuffer any-framebuffer read-only initial: system-framebuffer }
    { attachment color-attachment-ref read-only initial: default-attachment }
    { rect rect read-only } ;

C: <framebuffer-rect> framebuffer-rect

TYPED: framebuffer-attachment-at ( framebuffer: framebuffer
                                   attachment-ref: attachment-ref
                                   --
                                   attachment: framebuffer-attachment )
    {
        { default-attachment [ color-attachments>> first ] }
        { color-attachment [ swap color-attachments>> nth ] }
        { depth-attachment [ depth-attachment>> ] }
        { stencil-attachment [ stencil-attachment>> ] }
    } match ;

<PRIVATE

GENERIC: framebuffer-handle ( framebuffer -- handle )

M: system-framebuffer framebuffer-handle drop 0 ;
M: framebuffer framebuffer-handle handle>> ;

GENERIC#: allocate-framebuffer-attachment 1 ( framebuffer-attachment dim -- )

M: texture-attachment allocate-framebuffer-attachment
    [ [ texture>> ] [ level>> ] bi ] dip f allocate-texture ;
M: renderbuffer allocate-framebuffer-attachment
    allocate-renderbuffer ;

GENERIC: framebuffer-attachment-dim ( framebuffer-attachment -- dim )

M: texture-attachment framebuffer-attachment-dim
    [ texture>> ] [ level>> ] bi texture-dim
    dup number? [ 1 2array ] [ 2 head ] if ;

M: renderbuffer framebuffer-attachment-dim
    renderbuffer-dim ;

: each-attachment ( framebuffer quot: ( attachment -- ) -- )
    [ [ color-attachments>> ] dip each ]
    [ swap depth-attachment>>   [ swap call ] [ drop ] if* ]
    [ swap stencil-attachment>> [ swap call ] [ drop ] if* ] 2tri ; inline

:: each-attachment-target ( framebuffer quot: ( attachment-target attachment -- ) -- )
    framebuffer color-attachments>>
    [| attachment n | n GL_COLOR_ATTACHMENT0 + attachment quot call ] each-index
    framebuffer depth-attachment>>
    [| attachment | GL_DEPTH_ATTACHMENT attachment quot call ] when*
    framebuffer stencil-attachment>>
    [| attachment | GL_STENCIL_ATTACHMENT attachment quot call ] when* ; inline

GENERIC: bind-framebuffer-attachment ( attachment-target attachment -- )

M:: renderbuffer bind-framebuffer-attachment ( attachment-target renderbuffer -- )
    GL_DRAW_FRAMEBUFFER attachment-target
    GL_RENDERBUFFER renderbuffer handle>>
    glFramebufferRenderbuffer ;

M:: texture-1d-attachment bind-framebuffer-attachment ( attachment-target texture-attachment -- )
    GL_DRAW_FRAMEBUFFER attachment-target
    texture-attachment [ texture>> [ texture-data-gl-target ] [ texture-object handle>> ] bi ] [ level>> ] bi
    glFramebufferTexture1D ;

M:: texture-2d-attachment bind-framebuffer-attachment ( attachment-target texture-attachment -- )
    GL_DRAW_FRAMEBUFFER attachment-target
    texture-attachment [ texture>> [ texture-data-gl-target ] [ texture-object handle>> ] bi ] [ level>> ] bi
    glFramebufferTexture2D ;

M:: texture-3d-attachment bind-framebuffer-attachment ( attachment-target texture-attachment -- )
    GL_DRAW_FRAMEBUFFER attachment-target
    texture-attachment
    [ texture>> [ texture-data-gl-target ] [ texture-object handle>> ] bi ]
    [ level>> ] [ z-offset>> ] tri
    glFramebufferTexture3D ;

M:: texture-layer-attachment bind-framebuffer-attachment ( attachment-target texture-attachment -- )
    GL_DRAW_FRAMEBUFFER attachment-target
    texture-attachment
    [ texture>> texture-object handle>> ]
    [ level>> ] [ layer>> ] tri
    glFramebufferTextureLayer ;

GENERIC: (default-gl-attachment) ( framebuffer -- gl-attachment )
GENERIC: (default-attachment-type) ( framebuffer -- type )
GENERIC: (default-attachment-image-type) ( framebuffer -- order type )

M: system-framebuffer (default-gl-attachment)
    drop GL_BACK ;
M: framebuffer (default-gl-attachment)
    drop GL_COLOR_ATTACHMENT0 ;

SYMBOLS: float-type int-type uint-type ;

: (color-attachment-type) ( framebuffer index -- type )
    swap color-attachments>> nth attachment-object component-type>> {
        { [ dup signed-unnormalized-integer-components?   ] [ drop int-type  ] }
        { [ dup unsigned-unnormalized-integer-components? ] [ drop uint-type ] }
        [ drop float-type ]
    } cond ;

M: system-framebuffer (default-attachment-type)
    drop float-type ;
M: framebuffer (default-attachment-type)
    0 (color-attachment-type) ;

M: system-framebuffer (default-attachment-image-type) ( framebuffer -- order type )
    drop RGBA ubyte-components ;
M: framebuffer (default-attachment-image-type) ( framebuffer -- order type )
    color-attachments>> first attachment-object
    [ component-order>> ] [ component-type>> ] bi ;

: gl-system-attachment ( side face -- attachment )
    2array {
        { { f          f          } [ GL_FRONT_AND_BACK ] }
        { { f          front-face } [ GL_FRONT          ] }
        { { f          back-face  } [ GL_BACK           ] }
        { { left-side  f          } [ GL_LEFT           ] }
        { { left-side  front-face } [ GL_FRONT_LEFT     ] }
        { { left-side  back-face  } [ GL_BACK_LEFT      ] }
        { { right-side f          } [ GL_RIGHT          ] }
        { { right-side front-face } [ GL_FRONT_RIGHT    ] }
        { { right-side back-face  } [ GL_BACK_RIGHT     ] }
    } case ;

: gl-attachment ( framebuffer attachment-ref -- gl-attachment )
    [ {
        { depth-attachment [ GL_DEPTH_ATTACHMENT ] }
        { stencil-attachment [ GL_STENCIL_ATTACHMENT ] }
        { color-attachment [ GL_COLOR_ATTACHMENT0 + ] }
        { system-attachment [ gl-system-attachment ] }
        { default-attachment [ dup (default-gl-attachment) ] }
    } match ] [ GL_NONE ] if* nip ;

: color-attachment-image-type ( framebuffer attachment-ref -- order type )
    {
        { color-attachment [
            swap color-attachments>> nth
            attachment-object [ component-order>> ] [ component-type>> ] bi
        ] }
        { system-attachment [ 3drop RGBA ubyte-components ] }
        { default-attachment [ (default-attachment-image-type) ] }
    } match ;

: framebuffer-rect-image-type ( framebuffer-rect -- order type )
    [ framebuffer>> ] [ attachment>> ] bi color-attachment-image-type ;

HOOK: (clear-integer-color-attachment) gpu-api ( type value -- )

M: opengl-2 (clear-integer-color-attachment)
    4 0 pad-tail first4
    swap {
        { int-type [ glClearColorIiEXT ] }
        { uint-type [ glClearColorIuiEXT ] }
    } case GL_COLOR_BUFFER_BIT glClear ;

M: opengl-3 (clear-integer-color-attachment)
    [ GL_COLOR 0 ] dip 4 0 pad-tail
    swap {
        { int-type  [ int >c-array  glClearBufferiv  ] }
        { uint-type [ uint >c-array glClearBufferuiv ] }
    } case ;

:: (clear-color-attachment) ( type attachment value -- )
    attachment glDrawBuffer
    type float-type =
    [ value 4 value last pad-tail first4 glClearColor GL_COLOR_BUFFER_BIT glClear ]
    [ type value (clear-integer-color-attachment) ] if ;

: framebuffer-rect-size ( framebuffer-rect -- size )
    [ rect>> dim>> product ]
    [ framebuffer-rect-image-type (bytes-per-pixel) ] bi * ;

PRIVATE>

TYPED: <full-framebuffer-rect> ( framebuffer: any-framebuffer
                                 attachment: attachment-ref
                                 --
                                 framebuffer-rect: framebuffer-rect )
    2dup framebuffer-attachment-at
    { 0 0 } swap framebuffer-attachment-dim <rect>
    <framebuffer-rect> ;

TYPED: resize-framebuffer ( framebuffer: framebuffer dim -- )
    [ allocate-framebuffer-attachment ] curry each-attachment ;

:: attach-framebuffer-attachments ( framebuffer -- )
    GL_DRAW_FRAMEBUFFER framebuffer handle>> glBindFramebuffer
    framebuffer [ bind-framebuffer-attachment ] each-attachment-target ; inline

M: framebuffer dispose
    [ [ delete-framebuffer ] when* f ] change-handle drop ;

TYPED: dispose-framebuffer-attachments ( framebuffer: framebuffer -- )
    [ [ dispose ] when* ] each-attachment ;

: <framebuffer> ( color-attachments
                  depth-attachment: framebuffer-attachment
                  stencil-attachment: framebuffer-attachment
                  dim
                  --
                  framebuffer: framebuffer )
    [ [ 0 ] 3dip framebuffer boa dup ] dip
    [ resize-framebuffer ] [ drop ] if*
    gen-framebuffer >>handle
    dup attach-framebuffer-attachments
    window-resource ;

TYPED:: clear-framebuffer-attachment ( framebuffer: any-framebuffer
                                       attachment-ref: attachment-ref
                                       value -- )
    GL_DRAW_FRAMEBUFFER framebuffer framebuffer-handle glBindFramebuffer
    attachment-ref {
        { system-attachment [| side face |
            float-type
            side face gl-system-attachment
            value (clear-color-attachment)
        ] }
        { color-attachment [| i |
            framebuffer i (color-attachment-type)
            GL_COLOR_ATTACHMENT0 i +
            value (clear-color-attachment)
        ] }
        { default-attachment [
            framebuffer [ (default-attachment-type) ] [ (default-gl-attachment) ] bi
            value (clear-color-attachment)
        ] }
        { depth-attachment   [ value glClearDepth GL_DEPTH_BUFFER_BIT glClear ] }
        { stencil-attachment [ value glClearStencil GL_STENCIL_BUFFER_BIT glClear ] }
    } match ;

: clear-framebuffer ( framebuffer alist -- )
    [ first2 clear-framebuffer-attachment ] with each ; inline

TYPED:: read-framebuffer-to ( framebuffer-rect: framebuffer-rect
                              gpu-data-ptr -- )
    GL_READ_FRAMEBUFFER framebuffer-rect framebuffer>> framebuffer-handle glBindFramebuffer
    framebuffer-rect [ framebuffer>> ] [ attachment>> ] bi gl-attachment glReadBuffer
    framebuffer-rect rect>> [ loc>> first2 ] [ dim>> first2 ] bi
    framebuffer-rect framebuffer-rect-image-type image-data-format
    gpu-data-ptr pixel-pack-buffer [ glReadPixels ] with-gpu-data-ptr ;

: read-framebuffer ( framebuffer-rect -- byte-array )
    dup framebuffer-rect-size <byte-array> [ read-framebuffer-to ] keep ; inline

TYPED: read-framebuffer-image ( framebuffer-rect: framebuffer-rect -- image )
    [ <image> ] dip {
        [ rect>> dim>> >>dim ]
        [
            framebuffer-rect-image-type
            [ >>component-order ] [ >>component-type ] bi*
        ]
        [ read-framebuffer >>bitmap ]
    } cleave ;

TYPED:: copy-framebuffer ( to-fb-rect: framebuffer-rect
                           from-fb-rect: framebuffer-rect
                           depth? stencil? filter: texture-filter -- )
    GL_DRAW_FRAMEBUFFER to-fb-rect framebuffer>> framebuffer-handle glBindFramebuffer
    to-fb-rect [ framebuffer>> ] [ attachment>> ] bi gl-attachment glDrawBuffer
    GL_READ_FRAMEBUFFER from-fb-rect framebuffer>> framebuffer-handle glBindFramebuffer
    from-fb-rect [ framebuffer>> ] [ attachment>> ] bi gl-attachment glReadBuffer
    to-fb-rect attachment>> [ GL_COLOR_BUFFER_BIT ] [ 0 ] if
    depth?   [ GL_DEPTH_BUFFER_BIT bitor ] when
    stencil? [ GL_STENCIL_BUFFER_BIT bitor ] when :> mask

    from-fb-rect rect>> rect-extent [ first2 ] bi@
    to-fb-rect   rect>> rect-extent [ first2 ] bi@
    mask filter gl-mag-filter glBlitFramebuffer ;
