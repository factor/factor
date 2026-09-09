! Run with factor.com -no-user-init reference/texture-edge-regression.factor.
! Requires a desktop OpenGL context. The temporary test window closes itself.
USING: accessors alien.c-types alien.data arrays byte-arrays calendar
continuations images io kernel literals locals math namespaces opengl opengl.gl
opengl.textures opengl.textures.private prettyprint sequences
system threads tools.test ui ui.gadgets
ui.gadgets.worlds vocabs.loader ;
IN: texture-edge-regression

<< "opengl.textures" reload >>

: gray-pixels ( values -- bytes )
    [ dup dup 255 4array ] map concat >byte-array ;

: numbered-image ( dim -- image )
    <image> swap >>dim
    dup dim>> product <iota> [ 1 + ] map gray-pixels >>bitmap
    RGBA >>component-order ubyte-components >>component-type ;

:: uploaded-pixels ( dim npot? -- pixels )
    npot? non-power-of-2-textures? [
        dim numbered-image make-texture :> texture
        [
            GL_TEXTURE_2D texture glBindTexture
            dim adjust-texture-dim product 4 * <byte-array> :> pixels
            GL_TEXTURE_2D 0 GL_RGBA GL_UNSIGNED_BYTE pixels glGetTexImage
            gl-error pixels
        ] [ texture delete-texture ] finally
    ] with-variable ;

: unpack-state ( -- state )
    ${ GL_UNPACK_ALIGNMENT GL_UNPACK_ROW_LENGTH
      GL_UNPACK_SKIP_PIXELS GL_UNPACK_SKIP_ROWS }
    [ { int } [ glGetIntegerv ] with-out-parameters ] map ;

: preserves-unpack-state? ( -- ? )
    f non-power-of-2-textures? [
        { 3 3 } numbered-image dup make-texture
        GL_TEXTURE_2D over glBindTexture
        [
            GL_CLIENT_PIXEL_STORE_BIT glPushClientAttrib
            [
                GL_UNPACK_ALIGNMENT 8 glPixelStorei
                GL_UNPACK_ROW_LENGTH 23 glPixelStorei
                GL_UNPACK_SKIP_PIXELS 2 glPixelStorei
                GL_UNPACK_SKIP_ROWS 1 glPixelStorei
                [ unpack-state ] dip pad-texture-edges
                unpack-state = gl-error
            ] [ glPopClientAttrib ] finally
        ] dip delete-texture
    ] with-variable ;

: run-edge-tests ( -- )
    { t } [ { 3 3 } f uploaded-pixels
        { 1 2 3 3 4 5 6 6 7 8 9 9 7 8 9 9 } gray-pixels = ] unit-test
    { t } [ { 3 4 } f uploaded-pixels
        { 1 2 3 3 4 5 6 6 7 8 9 9 10 11 12 12 } gray-pixels = ] unit-test
    { t } [ { 4 3 } f uploaded-pixels
        { 1 2 3 4 5 6 7 8 9 10 11 12 9 10 11 12 } gray-pixels = ] unit-test
    { t } [ { 1 3 } f uploaded-pixels { 1 2 3 3 } gray-pixels = ] unit-test
    { t } [ { 3 1 } f uploaded-pixels { 1 2 3 3 } gray-pixels = ] unit-test
    { t } [ { 4 4 } f uploaded-pixels 16 <iota> [ 1 + ] map gray-pixels = ] unit-test
    { t } [ { 3 3 } t uploaded-pixels 9 <iota> [ 1 + ] map gray-pixels = ] unit-test
    { t } [ preserves-unpack-state? ] unit-test ;

[
    <gadget> { 64 64 } >>dim dup "Texture edge regression" open-window
    [
        1 seconds sleep
        dup find-world set-gl-context
        GL_PACK_ALIGNMENT 1 glPixelStorei
        GL_UNPACK_ALIGNMENT 1 glPixelStorei
        [ run-edge-tests ] [ . flush 1 exit ] recover
        :test-failures
        test-failures get length . flush
        close-window
        test-failures get empty? 0 1 ? exit
    ] curry "Texture edge regression" spawn drop
] with-ui
