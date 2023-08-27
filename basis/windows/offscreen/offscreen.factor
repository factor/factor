! Copyright (C) 2009 Joe Groff, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data kernel combinators
sequences math windows.gdi32 windows.types images
destructors accessors fry locals classes.struct ;
IN: windows.offscreen

: (bitmap-info) ( dim -- BITMAPINFO )
    [
        BITMAPINFO new
        dup bmiHeader>>
        BITMAPINFOHEADER heap-size >>biSize
    ] dip
        [ first >>biWidth ]
        [ second >>biHeight ]
        [ first2 * 4 * >>biSizeImage ] tri
        1 >>biPlanes
        32 >>biBitCount
        BI_RGB >>biCompression
        72 >>biXPelsPerMeter
        72 >>biYPelsPerMeter
        0 >>biClrUsed
        0 >>biClrImportant
        drop ;

: make-bitmap ( dim dc -- hBitmap bits )
    [ nip ]
    [
        swap (bitmap-info) DIB_RGB_COLORS { void* }
        [ f 0 CreateDIBSection ] with-out-parameters
    ] 2bi
    [ [ SelectObject drop ] keep ] dip ;

: make-offscreen-dc-and-bitmap ( dim -- dc hBitmap bits )
    [ f CreateCompatibleDC ] dip over make-bitmap ;

: bitmap>byte-array ( bits dim -- byte-array )
    product 4 * memory>byte-array ;

: bitmap>image ( bits dim -- image )
    [ bitmap>byte-array ] keep
    <image>
        swap >>dim
        swap >>bitmap
        BGRX >>component-order
        ubyte-components >>component-type
        t >>upside-down? ;

: with-memory-dc ( ..a quot: ( ..a hDC -- ..b ) -- ..b )
    [ [ f CreateCompatibleDC &DeleteDC ] dip call ] with-destructors ; inline

:: make-bitmap-image ( dim dc quot -- image )
    dim dc make-bitmap [ &DeleteObject drop ] dip
    quot dip
    dim bitmap>image ; inline
