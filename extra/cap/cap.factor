! Copyright (C) 2008 Doug Coleman, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.syntax arrays byte-arrays fry images
images.normalization images.viewer kernel math math.vectors
models namespaces opengl opengl.gl sequences ui ui.gadgets
ui.gadgets.worlds ;
IN: cap

: screenshot-array ( world -- byte-array )
    dim>> [ first 4 * ] [ second ] bi
    [ gl-scale ] bi@ * >fixnum <byte-array> ;

: gl-screenshot ( gadget -- byte-array )
    [
        [
            GL_BACK glReadBuffer
            GL_PACK_ALIGNMENT 4 glPixelStorei
            0 0
        ] dip
        dim>> first2 [ gl-scale >fixnum ] bi@
        GL_RGBA GL_UNSIGNED_BYTE
    ]
    [ screenshot-array ] bi
    [ glReadPixels ] keep ;

: screenshot ( window -- bitmap )
    [ <image> t >>2x? ] dip
    [ gl-screenshot >>bitmap ]
    [ dim>> [ gl-scale >fixnum ] map >>dim ] bi
    ubyte-components >>component-type
    RGBA >>component-order
    t >>upside-down?
    normalize-image ;

: screenshot. ( window -- )
    [ screenshot <image-gadget> ] [ title>> ] bi open-window ; 
