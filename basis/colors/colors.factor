! Copyright (C) 2003, 2009 Slava Pestov.
! Copyright (C) 2008 Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors combinators ;
IN: colors

TUPLE: color ;

TUPLE: rgba < color red green blue alpha ;

C: <rgba> rgba

GENERIC: >rgba ( color -- rgba )

M: rgba >rgba ( rgba -- rgba ) ;

M: color red>> ( color -- red ) >rgba red>> ;
M: color green>> ( color -- green ) >rgba green>> ;
M: color blue>> ( color -- blue ) >rgba blue>> ;

: >rgba-components ( object -- r g b a )
    >rgba { [ red>> ] [ green>> ] [ blue>> ] [ alpha>> ] } cleave ; inline

CONSTANT: black T{ rgba f 0.0 0.0 0.0 1.0 }
CONSTANT: blue T{ rgba f 0.0 0.0 1.0 1.0 }
CONSTANT: cyan T{ rgba f 0 0.941 0.941 1 }
CONSTANT: gray T{ rgba f 0.6 0.6 0.6 1.0 }
CONSTANT: dark-gray T{ rgba f 0.8 0.8 0.8 1.0 }
CONSTANT: green T{ rgba f 0.0 1.0 0.0 1.0 }
CONSTANT: light-gray T{ rgba f 0.95 0.95 0.95 0.95 }
CONSTANT: light-purple T{ rgba f 0.8 0.8 1.0 1.0 }
CONSTANT: medium-purple T{ rgba f 0.7 0.7 0.9 1.0 }
CONSTANT: magenta T{ rgba f 0.941 0 0.941 1 }
CONSTANT: orange T{ rgba f 0.941 0.627 0 1 }
CONSTANT: purple T{ rgba f 0.627 0 0.941 1 }
CONSTANT: red T{ rgba f 1.0 0.0 0.0 1.0 }
CONSTANT: white T{ rgba f 1.0 1.0 1.0 1.0 }
CONSTANT: yellow T{ rgba f 1.0 1.0 0.0 1.0 }
