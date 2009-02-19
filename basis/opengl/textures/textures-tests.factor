! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test opengl.textures opengl.textures.private
images kernel namespaces ;
IN: opengl.textures.tests

[ ] [
    { 3 5 }
    RGB
    B{
        1 2 3 4 5 6 7 8 9
        10 11 12 13 14 15 16 17 18
        19 20 21 22 23 24 25 26 27
        28 29 30 31 32 33 34 35 36
        37 38 39 40 41 42 43 44 45
    } image boa "image" set
] unit-test

[
    T{ image
        { dim { 4 8 } }
        { component-order RGB }
        { bitmap
          B{
              1 2 3 4 5 6 7 8 9 0 0 0
              10 11 12 13 14 15 16 17 18 0 0 0
              19 20 21 22 23 24 25 26 27 0 0 0
              28 29 30 31 32 33 34 35 36 0 0 0
              37 38 39 40 41 42 43 44 45 0 0 0
              0 0 0 0 0 0 0 0 0 0 0 0
              0 0 0 0 0 0 0 0 0 0 0 0
              0 0 0 0 0 0 0 0 0 0 0 0
          }
        }
    }
] [
    "image" get power-of-2-image
] unit-test

[
    T{ image
       { dim { 0 0 } }
       { component-order R32G32B32 }
       { bitmap B{ } } }
] [
    T{ image
       { dim { 0 0 } }
       { component-order R32G32B32 }
       { bitmap B{ } }
    } power-of-2-image
] unit-test