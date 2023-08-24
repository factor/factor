! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.enums alien.strings
assocs byte-arrays classes.struct destructors grouping images images.loader
io kernel libc locals math mime.types namespaces sequences specialized-arrays
system windows.com windows.gdiplus windows.streams windows.types ;
IN: images.loader.gdiplus

SPECIALIZED-ARRAY: ImageCodecInfo

SINGLETON: gdi+-image

os windows? [
    { "png" "tif" "tiff" "gif" "jpg" "jpeg" "bmp" "ico" }
    [ gdi+-image register-image-class ] each
] when

<PRIVATE

C: <GpRect> GpRect

: stream>gdi+-bitmap ( stream -- bitmap )
    stream>IStream &com-release
    { void* } [ GdipCreateBitmapFromStream check-gdi+-status ]
    with-out-parameters &GdipFree ;

: gdi+-bitmap-width ( bitmap -- w )
    { UINT } [ GdipGetImageWidth check-gdi+-status ]
    with-out-parameters ;

: gdi+-bitmap-height ( bitmap -- h )
    { UINT } [ GdipGetImageHeight check-gdi+-status ]
    with-out-parameters ;

:: gdi+-lock-bitmap ( bitmap rect mode format -- data )
    ! Copy the rect to stack space because the gc might move it
    ! because calling GdipBitmapLockBits triggers callbacks to Factor.
    { BitmapData GpRect } [
        :> ( stack-data stack-rect )
        stack-rect rect binary-object memcpy
        bitmap stack-rect mode format stack-data GdipBitmapLockBits
        check-gdi+-status
    ] with-out-parameters drop ;

:: gdi+-bitmap>data ( bitmap -- w h pixels )
    bitmap [ gdi+-bitmap-width ] [ gdi+-bitmap-height ] bi :> ( w h )
    bitmap 0 0 w h <GpRect> ImageLockModeRead enum>number
    PixelFormat32bppARGB gdi+-lock-bitmap :> bitmap-data
    bitmap-data [ Scan0>> ] [ Stride>> ] [ Height>> * ] tri
    memory>byte-array :> pixels
    bitmap bitmap-data GdipBitmapUnlockBits check-gdi+-status
    w h pixels ;

:: data>image ( w h pixels -- image )
    image new
        { w h } >>dim
        pixels >>bitmap
        BGRA >>component-order
        ubyte-components >>component-type
        f >>upside-down? ;

! Loaded images usually have the format BGRA, text rendered BGRX.
ERROR: unsupported-pixel-format component-order ;

: check-pixel-format ( component-order -- )
    dup { BGRX BGRA RGBA } member? [ drop ] [ unsupported-pixel-format ] if ;

: image>gdi+-bitmap ( image -- bitmap )
    dup component-order>> check-pixel-format
    [ dim>> first2 ] [ rowstride PixelFormat32bppARGB ] [ bitmap>> ] tri
    { void* } [
        GdipCreateBitmapFromScan0 check-gdi+-status
    ] with-out-parameters &GdipFree ;

: image-encoders-size ( -- num size )
    { UINT UINT } [
        GdipGetImageEncodersSize check-gdi+-status
    ] with-out-parameters ;

: image-encoders ( -- codec-infos )
    image-encoders-size dup <byte-array> 3dup
    GdipGetImageEncoders check-gdi+-status
    nip swap ImageCodecInfo <c-direct-array> ;

: extension>mime-type ( extension -- mime-type )
    mime-types ?at [ unknown-image-extension ] unless ;

: mime-type>clsid ( mime-type -- clsid )
    image-encoders [ MimeType>> alien>native-string = ] with find nip Clsid>> ;

: write-image-to-stream ( image stream extension -- )
    [ image>gdi+-bitmap ]
    [ stream>IStream &com-release ]
    [ extension>mime-type mime-type>clsid ] tri*
    f GdipSaveImageToStream check-gdi+-status ;

PRIVATE>

M: gdi+-image stream>image*
    drop
    stream>gdi+-bitmap
    gdi+-bitmap>data
    data>image ;

M: gdi+-image image>stream
    drop output-stream get swap write-image-to-stream ;
