! Copyright (C) 2003, 2008 Slava Pestov.
! Copyright (C) 2008 Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors ;
IN: colors

TUPLE: color ;

TUPLE: rgba < color red green blue alpha ;

C: <rgba> rgba

GENERIC: >rgba ( object -- rgba )

M: rgba >rgba ( rgba -- rgba ) ;

M: color red>>   ( color -- red   ) >rgba red>>   ;
M: color green>> ( color -- green ) >rgba green>> ;
M: color blue>>  ( color -- blue  ) >rgba blue>>  ;

: black        T{ rgba f 0.0   0.0   0.0   1.0  } ; inline
: blue         T{ rgba f 0.0   0.0   1.0   1.0  } ; inline
: cyan         T{ rgba f 0     0.941 0.941 1    } ; inline
: gray         T{ rgba f 0.6   0.6   0.6   1.0  } ; inline
: dark-gray    T{ rgba f 0.8   0.8   0.8   1.0  } ; inline
: green        T{ rgba f 0.0   1.0   0.0   1.0  } ; inline
: light-gray   T{ rgba f 0.95  0.95  0.95  0.95 } ; inline
: light-purple T{ rgba f 0.8   0.8   1.0   1.0  } ; inline
: magenta      T{ rgba f 0.941 0     0.941 1    } ; inline
: orange       T{ rgba f 0.941 0.627 0     1    } ; inline
: purple       T{ rgba f 0.627 0     0.941 1    } ; inline
: red          T{ rgba f 1.0   0.0   0.0   1.0  } ; inline
: white        T{ rgba f 1.0   1.0   1.0   1.0  } ; inline
: yellow       T{ rgba f 1.0   1.0   0.0   1.0  } ; inline
