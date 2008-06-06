USING: alien alien.c-types
math kernel byte-arrays freetype
opengl.gadgets accessors pango
ui.gadgets memoize
arrays sequences libc opengl.gl
system combinators alien.syntax
pango.layouts ;
IN: pango.ft2

<< "pangoft2" {
!    { [ os winnt? ] [ "libpangocairo-1.dll" ] }
!    { [ os macosx? ] [ "libpangocairo.dylib" ] }
    { [ os unix? ] [ "libpangoft2-1.0.so" ] }
} cond "cdecl" add-library >>

LIBRARY: pangoft2

FUNCTION: PangoFontMap*
pango_ft2_font_map_new ( ) ;

FUNCTION: PangoContext*
pango_ft2_font_map_create_context ( PangoFT2FontMap* fontmap ) ;

FUNCTION: void
pango_ft2_render_layout ( FT_Bitmap* bitmap, PangoLayout* layout, int x, int y ) ;

: 4*-ceil ( n -- k*4 )
    3 + 4 /i 4 * ;

: <ft-bitmap> ( width height -- ft-bitmap )
    swap dup
    2dup * 4*-ceil
    "uchar" malloc-array
    256
    FT_PIXEL_MODE_GRAY
    "FT_Bitmap" <c-object> dup >r
    {
        set-FT_Bitmap-rows
        set-FT_Bitmap-width
        set-FT_Bitmap-pitch
        set-FT_Bitmap-buffer
        set-FT_Bitmap-num_grays
        set-FT_Bitmap-pixel_mode
    } set-slots r> ;

: render-layout ( layout -- dims alien )
    [ 
        pango-layout-get-pixel-size
        2array dup 2^-bounds first2 <ft-bitmap> dup
    ] [ 0 0 pango_ft2_render_layout ] bi FT_Bitmap-buffer ;

MEMO: ft2-context ( -- PangoContext* )
    pango_ft2_font_map_new pango_ft2_font_map_create_context ;

: with-ft2-layout ( quot -- )
    ft2-context pango_layout_new swap with-layout ; inline
