! Render the real listener and optionally save its framebuffer as a PNG.
USING: accessors alien.c-types alien.data arrays byte-arrays calendar
continuations debugger environment images images.loader images.normalization
io kernel locals math namespaces opengl opengl.capabilities opengl.gl
prettyprint sequences system threads ui ui.backend ui.gadgets ui.gadgets.worlds
ui.render ui.tools.listener ;
IN: qemu.store-linux.ui-listener

: listener-error ( error -- ) print-error nl flush 1 exit ;

:: save-framebuffer ( world path -- )
    world set-gl-context
    world dim>> [ gl-scale >fixnum ] map :> dimensions
    dimensions first2 * 4 * <byte-array> :> pixels
    GL_FRAMEBUFFER_BINDING { int } [ glGetIntegerv ] with-out-parameters
    0 = GL_BACK GL_COLOR_ATTACHMENT0 ? glReadBuffer
    GL_PACK_ALIGNMENT 4 glPixelStorei
    0 0 dimensions first2 GL_RGBA GL_UNSIGNED_BYTE pixels glReadPixels
    gl-error
    <image> dimensions >>dim pixels >>bitmap
        ubyte-components >>component-type RGBA >>component-order
        t >>upside-down? normalize-image path save-graphic-image ;

:: inspect-listener ( world -- )
    nano-count 30,000,000,000 + :> deadline
    [ world draw-world? not nano-count deadline < and ] [
        20 milliseconds sleep
    ] while
    world draw-world? t assert=
    1 seconds sleep
    world draw-world
    world set-gl-context
    GL_FRAMEBUFFER glCheckFramebufferStatus GL_FRAMEBUFFER_COMPLETE assert=
    "UI_BACKEND " write ui-backend get .
    "UI_GL_VENDOR " write gl-vendor print
    "UI_GL_RENDERER " write GL_RENDERER glGetString print
    "UI_GL_VERSION " write GL_VERSION glGetString print
    "FACTOR_UI_SCREENSHOT" os-env [ world swap save-framebuffer ] when*
    "UI_LISTENER_RENDERED" print flush
    close-all-windows ;

: listener-smoke ( -- )
    [ listener-error ] ui-error-hook set-global
    [
        listener-window* find-world
        '[ _ [ inspect-listener ] [ listener-error ] recover ]
        "Listener rendering check" spawn drop
    ] with-ui ;

MAIN: listener-smoke
