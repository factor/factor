! Copyright (C) 2010 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test images.viewer images.viewer.private kernel accessors sequences images
namespaces ui ui.gadgets.debug math opengl.textures opengl.textures.private
models ;
IN: images.viewer.tests

: (gen-image) ( dim -- bitmap )
    product 3 * [ 200 ] BV{ } replicate-as ;
: gen-image ( dim -- image )
    dup (gen-image) <image> swap >>bitmap swap >>dim
    RGB >>component-order ubyte-components >>component-type ;

{ } [ { 50 50 } gen-image "s" set ] unit-test
{ } [ "s" get <image-gadget> "ig" set ] unit-test
"ig" get [
    [ t ] [ "ig" get image-gadget-texture single-texture? ] unit-test
] with-grafted-gadget

{ } [ "s" get <model> "m" set ] unit-test
{ } [ { 150 150 } gen-image "s1" set ] unit-test
{ } [ "m" get <image-control> "ic" set ] unit-test
"ic" get [
    [ t ] [ "ic" get image-gadget-texture single-texture? ] unit-test
    [ { 50 50 } ] [ "ic" get texture>> texture-size ] unit-test
] with-grafted-gadget

! TODO
! test that when changing the model, the gadget updates the texture.
! - same size images (both smaller than 512x512) (updates)
! test that when changing the model, the gadget creates a new texture.
! test different cases :
! - same size images (both bigger than 512x512) (creates)
! - different size images (both smaller than 512x512) (creates)
! - different size images (both bigger than 512x512) (creates)
! - different size images (1 smaller than, 1 bigger than 512x512)
