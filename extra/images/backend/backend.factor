! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel ;
IN: images.backend

SINGLETONS: BGR RGB BGRA RGBA ABGR ARGB RGBX XRGB BGRX XBGR ;

TUPLE: image width height depth pitch component-order buffer ;

GENERIC: load-image* ( path tuple -- image )

: load-image ( path class -- image )
    new load-image* ;

: new-image ( width height depth component-order buffer class -- image )
    new 
        swap >>buffer
        swap >>component-order
        swap >>depth
        swap >>height
        swap >>width ; inline
