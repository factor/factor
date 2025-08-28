! Copyright (C) 2008 Doug Coleman, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays images images.normalization
images.viewer kernel math namespaces opengl opengl.gl
sequences ui ui.gadgets.worlds ;
IN: cap

<PRIVATE

: screenshot-array ( world -- byte-array )
    dim>> [ first 4 * ] [ second ] bi
    [ gl-scale ] bi@ * >fixnum <byte-array> ;

: gl-screenshot ( gadget -- byte-array )
    [ find-gl-context ]
    [
        [
            GL_BACK glReadBuffer
            GL_PACK_ALIGNMENT 4 glPixelStorei
            0 0
        ] dip
        dim>> first2 [ gl-scale >fixnum ] bi@
        GL_RGBA GL_UNSIGNED_BYTE
    ]
    [ screenshot-array ] tri
    [ glReadPixels ] keep ;

PRIVATE>

:: screenshot ( window -- bitmap )
    <image>
        window gl-screenshot >>bitmap
        window dim>> [ gl-scale >fixnum ] map >>dim
        ubyte-components >>component-type
        RGBA >>component-order
        t >>upside-down?
    normalize-image ;

: screenshot. ( window -- )
    [ screenshot <image-gadget> ] [ title>> ] bi open-window ;
