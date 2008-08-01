! Copyright (C) 2003, 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.

USING: kernel combinators sequences arrays classes.tuple accessors colors.hsv ;

IN: colors

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: color ;

TUPLE: rgba < color red green blue alpha ;

TUPLE: hsva < color hue saturation value alpha ;

TUPLE: gray < color gray alpha ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: >rgba ( object -- rgba )

M: rgba >rgba ( rgba -- rgba ) ;

M: hsva >rgba ( hsva -- rgba )
  { [ hue>> ] [ saturation>> ] [ value>> ] [ alpha>> ] } cleave 4array
  [ hsv>rgb ] [ peek ] bi suffix first4 rgba boa ;

M: gray >rgba ( gray -- rgba ) [ gray>> dup dup ] [ alpha>> ] bi rgba boa ;

! M: array >rgba ( array -- rgba ) first4 rgba boa ;

M: color red>>   ( color -- red   ) >rgba red>>   ;
M: color green>> ( color -- green ) >rgba green>> ;
M: color blue>>  ( color -- blue  ) >rgba blue>>  ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: black        T{ rgba f 0.0   0.0   0.0   1.0  } ;
: blue         T{ rgba f 0.0   0.0   1.0   1.0  } ;
: cyan         T{ rgba f 0     0.941 0.941 1    } ;
: gray         T{ rgba f 0.6   0.6   0.6   1.0  } ;
: green        T{ rgba f 0.0   1.0   0.0   1.0  } ;
: light-gray   T{ rgba f 0.95  0.95  0.95  0.95 } ;
: light-purple T{ rgba f 0.8   0.8   1.0   1.0  } ;
: magenta      T{ rgba f 0.941 0     0.941 1    } ;
: orange       T{ rgba f 0.941 0.627 0     1    } ;
: purple       T{ rgba f 0.627 0     0.941 1    } ;
: red          T{ rgba f 1.0   0.0   0.0   1.0  } ;
: white        T{ rgba f 1.0   1.0   1.0   1.0  } ;
: yellow       T{ rgba f 1.0   1.0   0.0   1.0  } ;
