! Copyright (C) 2008 Doug Coleman, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays kernel math namespaces
opengl.gl sequences math.vectors ui images.bitmap images.viewer
models ui.gadgets.worlds ui.gadgets fry alien.syntax ;
IN: cap

: screenshot-array ( world -- byte-array )
    dim>> [ first 3 * 4 align ] [ second ] bi * <byte-array> ;

: gl-screenshot ( gadget -- byte-array )
    [
        GL_BACK glReadBuffer
        GL_PACK_ALIGNMENT 4 glPixelStorei
        0 0
    ] dip
    [ dim>> first2 GL_BGR GL_UNSIGNED_BYTE ]
    [ screenshot-array ] bi
    [ glReadPixels ] keep ;

: screenshot ( window -- bitmap )
    [ gl-screenshot ]
    [ dim>> first2 ] bi
    bgr>bitmap ;

: save-screenshot ( window path -- )
    [ screenshot ] dip save-bitmap ;

: screenshot. ( window -- )
    [ screenshot <image-gadget> ] [ title>> ] bi open-window ; 
