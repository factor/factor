! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test opengl.textures opengl.textures.private
opengl.textures.private images kernel namespaces accessors
sequences ;
IN: opengl.textures.tests

[ ] [
    T{ image
       { dim { 3 5 } }
       { component-order RGB }
       { bitmap
         B{
             1 2 3 4 5 6 7 8 9
             10 11 12 13 14 15 16 17 18
             19 20 21 22 23 24 25 26 27
             28 29 30 31 32 33 34 35 36
             37 38 39 40 41 42 43 44 45
         }
       }
    } "image" set
] unit-test

[
    T{ image
        { dim { 4 8 } }
        { component-order RGB }
        { bitmap
          B{
              1 2 3 4 5 6 7 8 9 7 8 9
              10 11 12 13 14 15 16 17 18 16 17 18
              19 20 21 22 23 24 25 26 27 25 26 27
              28 29 30 31 32 33 34 35 36 34 35 36
              37 38 39 40 41 42 43 44 45 43 44 45
              37 38 39 40 41 42 43 44 45 43 44 45
              37 38 39 40 41 42 43 44 45 43 44 45
              37 38 39 40 41 42 43 44 45 43 44 45
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