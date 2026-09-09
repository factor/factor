! Copyright (C) 2009 Joe Groff, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data kernel combinators continuations
sequences math windows.gdi32 windows.types windows.errors images
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

:: <dib-bitmap> ( dim dc -- bitmap bits )
    dc dim (bitmap-info) DIB_RGB_COLORS { void* }
    [ f 0 CreateDIBSection ] with-out-parameters
    [ dup win32-error=0/f ] dip ;

:: make-bitmap ( dim dc -- hBitmap bits )
    [
        dim dc <dib-bitmap> :> bits :> bitmap
        bitmap |DeleteObject drop
        dc bitmap SelectObject win32-error=0/f
        bitmap bits
    ] with-destructors ;

: make-offscreen-dc-and-bitmap ( dim -- dc hBitmap bits )
    [ [ f CreateCompatibleDC dup win32-error=0/f |DeleteDC ] dip
        over make-bitmap ] with-destructors ;

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
    [ [ f CreateCompatibleDC dup win32-error=0/f &DeleteDC ] dip call ] with-destructors ; inline

:: make-bitmap-image ( dim dc quot -- image )
    [
        dim dc <dib-bitmap> :> bits :> bitmap
        bitmap &DeleteObject drop
        dc bitmap SelectObject dup win32-error=0/f :> previous
        [ quot call GdiFlush win32-error=0/f bits dim bitmap>image ]
        [ dc previous SelectObject win32-error=0/f ] finally
    ] with-destructors ; inline
