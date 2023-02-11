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
