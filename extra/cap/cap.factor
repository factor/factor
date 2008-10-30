USING: accessors arrays byte-arrays kernel math namespaces
opengl.gl sequences math.vectors ui graphics.bitmap graphics.viewer
models opengl.framebuffers ui.gadgets.worlds ui.gadgets fry ;
IN: cap

: screenshot-array ( world -- byte-array )
    dim>> product 3 * <byte-array> ;

: gl-screenshot ( gadget -- byte-array )
    [
        GL_COLOR_ATTACHMENT0_EXT glReadBuffer
        GL_PACK_ALIGNMENT 1 glPixelStorei
        0 0
    ] dip
    [ dim>> first2 GL_BGR GL_UNSIGNED_BYTE ]
    [ screenshot-array ] bi
    [ glReadPixels ] keep ;

: screenshot ( window -- bitmap )
    [ gl-screenshot ]
    [ dim>> first2 ] bi
    bgr>bitmap ;

: gadget-world ( gadget -- world )
    "fake" f <model> <world> ;

: draw-world-to-fbo ( world fbo -- )
    [ relayout-1 ] with-framebuffer ;

: <fbo> ( w h -- fbo )
    GL_DEPTH_TEST glDisable
    gen-framebuffer [ '[
        gen-renderbuffer
        GL_RENDERBUFFER_EXT over glBindRenderbufferEXT
        GL_RENDERBUFFER_EXT GL_RGB _ _ glRenderbufferStorageEXT
        GL_FRAMEBUFFER_EXT
        GL_COLOR_ATTACHMENT0_EXT
        GL_RENDERBUFFER_EXT roll glFramebufferRenderbufferEXT
        check-framebuffer
    ] with-framebuffer ] keep ;

: draw-gadget-to-bgr ( gadget -- byte-array )
    [ [ prefer ] [ gadget-world ] bi ] [ dim>> first2 <fbo> ] bi
    [ gl-screenshot ] with-framebuffer ;

: save-screenshot ( window path -- )
    [ screenshot ] dip save-bitmap ;

: screenshot. ( window -- )
    screenshot <graphics-gadget> "Screenshot" open-window ;



