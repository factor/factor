USING: accessors alien.c-types alien.data alien.syntax byte-arrays
fonts kernel locals math sequences tools.test windows.fonts
windows.gdi32 windows.kernel32 windows.types ;
IN: windows.fonts.tests

LIBRARY: gdi32
FUNCTION: int GetObjectW ( HGDIOBJ object, int size, void* data )
LIBRARY: user32
FUNCTION: DWORD GetGuiResources ( HANDLE process, DWORD flags )

:: native-font-height ( handle -- height )
    92 <byte-array> :> data
    handle 92 data GetObjectW 92 =
    [ data int deref ] [ "GetObjectW failed" throw ] if ;

:: equivalent-fractional-fonts ( quality -- reused? no-growth? )
    "Arial" <font> 12 >>size quality 1 cache-font-at-scale :> base
    GetCurrentProcess 0 GetGuiResources :> before
    100 <iota> [
        1 + 1000 / 12 + "Arial" <font> swap >>size
        quality 1 cache-font-at-scale base =
    ] map [ ] all?
    before GetCurrentProcess 0 GetGuiResources = ;

! Distinct logical sizes mapping to the same native height share one HFONT.
{ t t } [ DEFAULT_QUALITY equivalent-fractional-fonts ] unit-test
{ t t } [ ANTIALIASED_QUALITY equivalent-fractional-fonts ] unit-test

! Positive subpixel sizes must not become GDI's zero-height default font.
{ { -1 -1 -1 } } [
    { 0.01 0.5 0.999 } [
        "Arial" <font> swap >>size DEFAULT_QUALITY 1 cache-font-at-scale
        native-font-height
    ] map
] unit-test

! Quantize the physical size after applying DPI, not the logical size.
{ -25 -1 } [
    "Arial" <font> 12.75 >>size DEFAULT_QUALITY 2 cache-font-at-scale native-font-height
    "Arial" <font> 0.75 >>size DEFAULT_QUALITY 2 cache-font-at-scale native-font-height
] unit-test

! Low-level callers use the same normalized memo boundary.
{ t t } [
    "Arial" 12.25 f f (cache-font)
    "Arial" 12.9 f f (cache-font) =
    "Arial" 12.25 f f ANTIALIASED_QUALITY (cache-font-with-quality)
    "Arial" 12.9 f f ANTIALIASED_QUALITY (cache-font-with-quality) =
] unit-test
