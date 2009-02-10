! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel ;
IN: images.backend

TUPLE: image width height depth pitch buffer ;

GENERIC: load-image* ( path tuple -- image )

: load-image ( path class -- image )
    new load-image* ;

: new-image ( width height depth buffer class -- image )
    new 
        swap >>buffer
        swap >>depth
        swap >>height
        swap >>width ; inline
