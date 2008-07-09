! Copyright (C) 2007 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel generalizations ;

IN: shuffle

: 2swap ( x y z t -- z t x y ) rot >r rot r> ; inline

: nipd ( a b c -- b c ) rot drop ; inline

: 3nip ( a b c d -- d ) 3 nnip ; inline

: 4nip ( a b c d e -- e ) 4 nnip ; inline

: 4dup ( a b c d -- a b c d a b c d ) 4 ndup ; inline

: 4drop ( a b c d -- ) 3drop drop ; inline

: tuckd ( x y z -- z x y z ) 2 ntuck ; inline
