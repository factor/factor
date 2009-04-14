! Copyright (C) 2008 Doug Coleman, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays kernel math namespaces
opengl.gl sequences math.vectors ui images images.normalization
images.viewer models ui.gadgets.worlds ui.gadgets fry alien.syntax ;
IN: cap

: screenshot-array ( world -- byte-array )
    dim>> [ first 4 * ] [ second ] bi * <byte-array> ;

: gl-screenshot ( gadget -- byte-array )
    [
        [
            GL_BACK glReadBuffer
            GL_PACK_ALIGNMENT 4 glPixelStorei
            0 0
        ] dip
        dim>> first2 GL_RGBA GL_UNSIGNED_BYTE
    ]
    [ screenshot-array ] bi
    [ glReadPixels ] keep ;

: screenshot ( window -- bitmap )
    [ <image> ] dip
    [ gl-screenshot >>bitmap ] [ dim>> >>dim ] bi
    RGBA >>component-order
    t >>upside-down?
    normalize-image ;

: screenshot. ( window -- )
    [ screenshot <image-gadget> ] [ title>> ] bi open-window ; 
