USING: accessors alien.c-types alien.data calendar continuations debugger io
kernel locals math namespaces opengl opengl.capabilities opengl.gl sequences
prettyprint system threads ui ui.backend ui.gadgets.labels ui.gadgets.worlds ui.render ;
IN: qemu.ui-graphics-provenance

: graphics-error ( error -- ) print-error nl flush 1 exit ;

:: wait-for-native-world ( world -- )
    nano-count 10,000,000,000 + :> deadline
    [ world draw-world? not nano-count deadline < and ] [
        20 milliseconds sleep
    ] while
    world draw-world? t assert= ;

:: inspect-native-world ( world -- )
    world wait-for-native-world
    ! Toolkit widget allocation is asynchronous even after grafting.
    500 milliseconds sleep
    world set-gl-context
    GL_FRAMEBUFFER glCheckFramebufferStatus GL_FRAMEBUFFER_COMPLETE assert=
    "UI_BACKEND " write ui-backend get .
    "UI_GL_VENDOR " write gl-vendor print
    "UI_GL_RENDERER " write GL_RENDERER glGetString print
    "UI_GL_VERSION " write GL_VERSION glGetString print
    gl-error flush
    world draw-world
    close-all-windows ;

: graphics-provenance ( -- )
    ui-backend-available? t assert=
    [ graphics-error ] ui-error-hook set-global
    [
        "Native stock GL context control" <label> "UI graphics provenance" open-window*
        '[ _ [ inspect-native-world ] [ graphics-error ] recover ]
        "UI graphics provenance" spawn drop
    ] with-ui
    "UI_GRAPHICS_CONTEXT_OK" print flush ;

MAIN: graphics-provenance
