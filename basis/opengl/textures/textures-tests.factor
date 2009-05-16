! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test opengl.textures opengl.textures.private
images kernel namespaces accessors sequences ;
IN: opengl.textures.tests

[
    {
        { { 0 0 } { 10 0 } }
        { { 0 20 } { 10 20 } }
    }
] [
    {
        { { 10 20 } { 30 20 } }
        { { 10 30 } { 30 300 } }
    }
    [ [ image new swap >>dim ] map ] map image-locs
] unit-test