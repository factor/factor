! (c)2010 Joe Groff bsd license
USING: accessors alien alien.c-types alien.data alien.enums alien.strings
assocs byte-arrays classes.struct destructors grouping images images.loader
io kernel locals math mime.types namespaces sequences specialized-arrays
windows.com windows.gdiplus windows.streams windows.types ;
FROM: system => os windows? ;
IN: images.loader.gdiplus

SPECIALIZED-ARRAY: ImageCodecInfo

SINGLETON: gdi+-image

os windows? [
    { "png" "tif" "tiff" "gif" "jpg" "jpeg" "bmp" "ico" }
    [ gdi+-image register-image-class ] each
] when

<PRIVATE

: <GpRect> ( x y w h -- rect )
    GpRect <struct-boa> ; inline

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

: gdi+-lock-bitmap ( bitmap rect mode format -- data )
    { BitmapData } [ GdipBitmapLockBits check-gdi+-status ]
    with-out-parameters ;

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

! Only one pixel format supported, but I can't find images in the
! wild, loaded using gdi+, in which the format is different.
ERROR: unsupported-pixel-format component-order ;

: check-pixel-format ( image -- )
    component-order>> dup BGRA = [ drop ] [ unsupported-pixel-format ] if ;

: image>gdi+-bitmap ( image -- bitmap )
    dup check-pixel-format
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
    ! Crashes if you let this mime through on my machine.
    dup mime-types at dup "image/bmp" = [ unknown-image-extension ] when nip ;

: mime-type>clsid ( mime-type -- clsid )
    image-encoders [ MimeType>> alien>native-string = ] with find nip Clsid>> ;

: startup-gdi+ ( -- )
    start-gdi+ &stop-gdi+ drop ;

: write-image-to-stream ( image stream extension -- )
    [ image>gdi+-bitmap ]
    [ stream>IStream &com-release ]
    [ extension>mime-type mime-type>clsid ] tri*
    f GdipSaveImageToStream check-gdi+-status ;

PRIVATE>

M: gdi+-image stream>image*
    drop startup-gdi+
    stream>gdi+-bitmap
    gdi+-bitmap>data
    data>image ;

M: gdi+-image image>stream ( image extension class -- )
    drop startup-gdi+ output-stream get swap write-image-to-stream ;
