! (c)2009 Joe Groff bsd license
USING: accessors alien alien.c-types arrays byte-arrays
combinators destructors gpu kernel locals math opengl opengl.gl
ui.gadgets.worlds variants ;
IN: gpu.buffers

VARIANT: buffer-upload-pattern
    stream-upload static-upload dynamic-upload ;

VARIANT: buffer-usage-pattern
    draw-usage read-usage copy-usage ;

VARIANT: buffer-access-mode
    read-access write-access read-write-access ;

VARIANT: buffer-kind
    vertex-buffer index-buffer
    pixel-unpack-buffer pixel-pack-buffer ;

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
    } case ; inline

PRIVATE>

M: buffer dispose
    [ [ delete-gl-buffer ] when* f ] change-handle drop ;

TUPLE: buffer-ptr 
    { buffer buffer read-only }
    { offset integer read-only } ;
C: <buffer-ptr> buffer-ptr

UNION: gpu-data-ptr buffer-ptr c-ptr ;

:: allocate-buffer ( buffer size initial-data -- )
    buffer kind>> gl-target :> target
    target buffer handle>> glBindBuffer
    target size initial-data buffer gl-buffer-usage glBufferData ;

: <buffer> ( upload usage kind size initial-data -- buffer )
    [ [ gen-gl-buffer ] 3dip buffer boa dup ] 2dip allocate-buffer
    window-resource ;

: byte-array>buffer ( byte-array upload usage kind -- buffer )
    [ ] 3curry dip
    [ byte-length ] [ ] bi <buffer> ;

:: update-buffer ( buffer-ptr size data -- )
    buffer-ptr buffer>> :> buffer
    buffer kind>> gl-target :> target
    target buffer handle>> glBindBuffer
    target buffer-ptr offset>> size data glBufferSubData ;

:: read-buffer ( buffer-ptr size -- data )
    buffer-ptr buffer>> :> buffer
    buffer kind>> gl-target :> target
    size <byte-array> :> data
    target buffer handle>> glBindBuffer
    target buffer-ptr offset>> size data glGetBufferSubData
    data ;

:: copy-buffer ( to-buffer-ptr from-buffer-ptr size -- )
    GL_COPY_WRITE_BUFFER to-buffer-ptr buffer>> glBindBuffer
    GL_COPY_READ_BUFFER from-buffer-ptr buffer>> glBindBuffer

    GL_COPY_READ_BUFFER GL_COPY_WRITE_BUFFER
    from-buffer-ptr offset>> to-buffer-ptr offset>>
    size glCopyBufferSubData ;

:: with-mapped-buffer ( buffer access quot: ( alien -- ) -- )
    buffer kind>> gl-target :> target

    target buffer handle>> glBindBuffer
    target access gl-access glMapBuffer

    quot call

    target glUnmapBuffer ; inline

:: with-bound-buffer ( buffer target quot: ( -- ) -- )
    target gl-target buffer glBindBuffer
    quot call ; inline

: with-buffer-ptr ( buffer-ptr target quot: ( c-ptr -- ) -- )
    [ [ offset>> <alien> ] [ buffer>> handle>> ] bi ] 2dip
    with-bound-buffer ; inline

: with-gpu-data-ptr ( gpu-data-ptr target quot: ( c-ptr -- ) -- )
    pick buffer-ptr?
    [ with-buffer-ptr ]
    [ [ gl-target 0 glBindBuffer ] dip call ] if ; inline

