! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data arrays byte-arrays
combinators destructors gpu kernel math opengl opengl.gl
typed ui.gadgets.worlds variants ;
IN: gpu.buffers

VARIANT: buffer-upload-pattern
    stream-upload static-upload dynamic-upload ;

VARIANT: buffer-usage-pattern
    draw-usage read-usage copy-usage ;

VARIANT: buffer-access-mode
    read-access write-access read-write-access ;

VARIANT: buffer-kind
    vertex-buffer index-buffer
    pixel-unpack-buffer pixel-pack-buffer
    transform-feedback-buffer ;

TUPLE: buffer < gpu-object
    { upload-pattern buffer-upload-pattern }
    { usage-pattern buffer-usage-pattern }
    { kind buffer-kind } ;

<PRIVATE

: gl-buffer-usage ( buffer -- usage )
    [ upload-pattern>> ] [ usage-pattern>> ] bi 2array {
        { { stream-upload draw-usage } [ GL_STREAM_DRAW ] }
        { { stream-upload read-usage } [ GL_STREAM_READ ] }
        { { stream-upload copy-usage } [ GL_STREAM_COPY ] }

        { { static-upload draw-usage } [ GL_STATIC_DRAW ] }
        { { static-upload read-usage } [ GL_STATIC_READ ] }
        { { static-upload copy-usage } [ GL_STATIC_COPY ] }

        { { dynamic-upload draw-usage } [ GL_DYNAMIC_DRAW ] }
        { { dynamic-upload read-usage } [ GL_DYNAMIC_READ ] }
        { { dynamic-upload copy-usage } [ GL_DYNAMIC_COPY ] }
    } case ; inline

: gl-access ( access -- gl-access )
    {
        { read-access [ GL_READ_ONLY ] }
        { write-access [ GL_WRITE_ONLY ] }
        { read-write-access [ GL_READ_WRITE ] }
    } case ; inline

: gl-target ( kind -- target )
    {
        { vertex-buffer [ GL_ARRAY_BUFFER ] }
        { index-buffer [ GL_ELEMENT_ARRAY_BUFFER ] }
        { pixel-unpack-buffer [ GL_PIXEL_UNPACK_BUFFER ] }
        { pixel-pack-buffer [ GL_PIXEL_PACK_BUFFER ] }
        { transform-feedback-buffer [ GL_TRANSFORM_FEEDBACK_BUFFER ] }
    } case ; inline

: get-buffer-int ( target enum -- value )
    0 int <ref> [ glGetBufferParameteriv ] keep int deref ; inline

: bind-buffer ( buffer -- target )
    [ kind>> gl-target dup ] [ handle>> glBindBuffer ] bi ; inline

PRIVATE>

M: buffer dispose
    [ [ delete-gl-buffer ] when* f ] change-handle drop ;

TUPLE: buffer-ptr
    { buffer buffer read-only }
    { offset integer read-only } ;
C: <buffer-ptr> buffer-ptr

TUPLE: buffer-range < buffer-ptr
    { size integer read-only } ;
C: <buffer-range> buffer-range

UNION: gpu-data-ptr buffer-ptr c-ptr ;

TYPED: buffer-size ( buffer: buffer -- size: integer )
    bind-buffer GL_BUFFER_SIZE get-buffer-int ;

: buffer-ptr>range ( buffer-ptr -- buffer-range )
    [ buffer>> ] [ offset>> ] bi
    2dup [ buffer-size ] dip -
    buffer-range boa ; inline

:: allocate-buffer ( buffer size initial-data -- )
    buffer bind-buffer :> target
    target size initial-data buffer gl-buffer-usage glBufferData ; inline

: allocate-byte-array ( buffer byte-array -- )
    [ byte-length ] [ ] bi allocate-buffer ; inline

TYPED: <buffer> ( upload: buffer-upload-pattern
                  usage: buffer-usage-pattern
                  kind: buffer-kind
                  size: integer
                  initial-data
                  --
                  buffer: buffer )
    [ [ gen-gl-buffer ] 3dip buffer boa dup ] 2dip allocate-buffer
    window-resource ;

TYPED: byte-array>buffer ( byte-array
                           upload: buffer-upload-pattern
                           usage: buffer-usage-pattern
                           kind: buffer-kind
                           --
                           buffer: buffer )
    [ ] 3curry dip
    [ byte-length ] [ ] bi <buffer> ;

TYPED:: update-buffer ( buffer-ptr: buffer-ptr size: integer data -- )
    buffer-ptr buffer>> :> buffer
    buffer bind-buffer :> target
    target buffer-ptr offset>> size data glBufferSubData ;

TYPED:: read-buffer ( buffer-ptr: buffer-ptr size: integer -- data: byte-array )
    buffer-ptr buffer>> :> buffer
    buffer bind-buffer :> target
    size <byte-array> :> data
    target buffer-ptr offset>> size data glGetBufferSubData
    data ;

TYPED:: copy-buffer ( to-buffer-ptr: buffer-ptr from-buffer-ptr: buffer-ptr size: integer -- )
    GL_COPY_WRITE_BUFFER to-buffer-ptr buffer>> glBindBuffer
    GL_COPY_READ_BUFFER from-buffer-ptr buffer>> glBindBuffer

    GL_COPY_READ_BUFFER GL_COPY_WRITE_BUFFER
    from-buffer-ptr offset>> to-buffer-ptr offset>>
    size glCopyBufferSubData ;

: (grow-buffer-size) ( target-size old-size -- new-size )
    [ 2dup > ] [ 2 * ] while nip ; inline

TYPED: grow-buffer ( buffer: buffer target-size: integer -- )
    over buffer-size 2dup >
    [ (grow-buffer-size) f allocate-buffer ] [ 3drop ] if ; inline

:: with-mapped-buffer ( ..a buffer access quot: ( ..a alien -- ..b ) -- ..b )
    buffer bind-buffer :> target
    target access gl-access glMapBuffer

    quot call

    target glUnmapBuffer drop ; inline

:: with-mapped-buffer-array ( ..a buffer access c-type quot: ( ..a array -- ..b ) -- ..b )
    buffer buffer-size c-type heap-size /i :> len
    buffer access [ len c-type <c-direct-array> quot call ] with-mapped-buffer ; inline

:: with-bound-buffer ( ..a buffer target quot: ( ..a -- ..b ) -- ..b )
    target gl-target buffer glBindBuffer
    quot call ; inline

: with-buffer-ptr ( ..a buffer-ptr target quot: ( ..a c-ptr -- ..b ) -- ..b )
    [ [ offset>> <alien> ] [ buffer>> handle>> ] bi ] 2dip
    with-bound-buffer ; inline

: with-gpu-data-ptr ( ..a gpu-data-ptr target quot: ( ..a c-ptr -- ..b ) -- ..b )
    pick buffer-ptr?
    [ with-buffer-ptr ]
    [ [ gl-target 0 glBindBuffer ] dip call ] if ; inline
