! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors images kernel literals opengl.gl
opengl.textures opengl.textures.private sequences tools.test ;

{
    {
        { { 0 0 } { 10 0 } }
        { { 0 20 } { 10 20 } }
    }
} [
    {
        { { 10 20 } { 30 20 } }
        { { 10 30 } { 30 300 } }
    }
    [ [ image new swap >>dim ] map ] map image-locs
] unit-test

${ GL_RGBA8 GL_RGBA GL_UNSIGNED_BYTE }
[ RGBA ubyte-components (image-format) ] unit-test

${ GL_RGBA8 GL_BGRA GL_UNSIGNED_BYTE }
[ BGRA ubyte-components (image-format) ] unit-test

${ GL_RGBA8 GL_BGRA GL_UNSIGNED_INT_8_8_8_8_REV }
[ ARGB ubyte-components (image-format) ] unit-test

${ GL_RGBA32F GL_RGBA GL_FLOAT }
[ RGBA float-components (image-format) ] unit-test

${ GL_RGBA32UI GL_BGRA_INTEGER GL_UNSIGNED_INT }
[ BGRA uint-integer-components (image-format) ] unit-test

${ GL_RGB9_E5 GL_RGB GL_UNSIGNED_INT_5_9_9_9_REV }
[ BGR u-9-9-9-e5-components (image-format) ] unit-test

${ GL_R11F_G11F_B10F GL_RGB GL_UNSIGNED_INT_10F_11F_11F_REV }
[ BGR float-11-11-10-components (image-format) ] unit-test

! multi-textures are made of a grid of single-textures that, for this example
! could have dims like the following:
!  { { 512 512 } { 256 512 } }
!  { { 512 256 } { 256 256 } }
! with a total of 768x768 pixels, 
! to scale each axis of the above image by half (384x384), each single-texture
! will have a common factor to achieve this
{
 { 256 256 }
}
[ { 384 384 } { { { 1 1   } { 1/2 1   } }
                { { 1 1/2 } { 1/2 1/2 } } } normalize-scaling-dims ] unit-test
! the adapted scaling factor can be multiplied with the normalisation matrix
{
  { { { 256 256 } { 128 256 } }
    { { 256 128 } { 128 128 } } }
}
[ { { { 1 1   } { 1/2 1   } }
    { { 1 1/2 } { 1/2 1/2 } } } { 256 256 } per-texture-scalings-in-grid ] unit-test
! now each axis has accumulated dimensions adding to a half of the original 768 pixels
! while maintaining their ratios per single-texture
{
  { { { 0 0 } { 256 0 } }
    { { 0 256 } { 256 256 } } }
}
[   { { { 256 256 } { 128 256 } }
      { { 256 128 } { 128 128 } } } accumulate-divisions-to-grid ] unit-test
! and new locations of each single texture can be calculated by accumulating along each axis

