USING: accessors destructors destructors.private images images.loader
images.loader.gdiplus.private io.files.temp kernel math memory
namespaces sequences tools.test ;
IN: images.loader.gdiplus.tests

{ } [
    BGRA check-pixel-format
    BGRX check-pixel-format
    RGBA check-pixel-format
] unit-test

[ RGB check-pixel-format ] [ unsupported-pixel-format? ] must-fail-with

: test-image ( bitmap order upside-down? -- image )
    [ <image> { 1 2 } >>dim ubyte-components >>component-type ] 3dip
    [ >>bitmap ] 2dip [ >>component-order ] dip >>upside-down? ;

: png-roundtrip ( image -- image' )
    [ "roundtrip.png" [ save-graphic-image ] [ load-image ] bi ]
    with-test-directory ;

! GDI text bitmaps use BGRX: the unused byte is not an alpha channel (#2357).
{ B{ 0 0 0 255 255 255 255 255 } } [
    B{ 0 0 0 0 255 255 255 0 } BGRX f test-image
    png-roundtrip bitmap>>
] unit-test

! Each save releases its native pixels, bitmap and COM stream immediately.
{ 0 } [
    always-destructors get length
    B{ 0 0 0 255 255 255 255 255 } BGRA f test-image
    png-roundtrip drop
    always-destructors get length swap -
] unit-test

! The bottom-up orientation used by Windows text must be respected (#2356).
{ B{ 0 0 255 255 255 0 0 255 } } [
    B{ 255 0 0 255 0 0 255 255 } BGRA t test-image
    png-roundtrip bitmap>>
] unit-test

! PixelFormat32bppARGB expects BGRA bytes, not RGBA.
{ B{ 0 0 255 255 255 0 0 255 } } [
    B{ 255 0 0 255 0 0 255 255 } RGBA f test-image
    png-roundtrip bitmap>>
] unit-test

! Saving must not change the original bitmap, component order or orientation.
{ t } [
    B{ 255 0 0 255 0 0 255 255 } RGBA t test-image
    dup clone [ dup png-roundtrip drop ] dip =
] unit-test

! The bitmap's scan buffer remains valid across a moving collection.
{ B{ 0 0 255 255 255 0 0 255 } } [
    [
        B{ 0 0 255 255 255 0 0 255 } BGRA f test-image
        image>gdi+-bitmap gc gdi+-bitmap>data 2nip
    ] with-destructors
] unit-test

! JPEG is lossy; check the vertical order using black and white rows.
{ t } [
    B{ 0 0 0 0 255 255 255 0 } BGRX t test-image
    [ "roundtrip.jpg" [ save-graphic-image ] [ load-image ] bi ]
    with-test-directory bitmap>> [ first ] [ 4 swap nth ] bi >
] unit-test
