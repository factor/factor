! Copyright (C) 2007 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel generalizations ;

IN: shuffle

: 2swap ( x y z t -- z t x y ) 2 2 mnswap ; inline

: 4dup ( a b c d -- a b c d a b c d ) 4 ndup ; inline

: 4drop ( a b c d -- ) 3drop drop ; inline
