! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license
USING: system alien.destructors alien.c-types alien.syntax alien
combinators ;
IN: pango

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Helpful functions from other parts of pango
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<< "pango" {
    { [ os winnt? ] [ "libpango-1.0-0.dll" ] }
    { [ os macosx? ] [ "libpango-1.0.0.dylib" ] }
    { [ os unix? ] [ "libpango-1.0.so" ] }
} cond "cdecl" add-library >>

LIBRARY: pango

CONSTANT: PANGO_SCALE 1024

FUNCTION: PangoLayout*
pango_layout_new ( PangoContext* context ) ;

FUNCTION: void
pango_layout_set_text ( PangoLayout* layout, char* text, int length ) ;

FUNCTION: char*
pango_layout_get_text ( PangoLayout* layout ) ;

FUNCTION: void
pango_layout_get_size ( PangoLayout* layout, int* width, int* height ) ;

FUNCTION: PangoFontDescription*
pango_font_description_from_string ( char* str ) ;

FUNCTION: char*
pango_font_description_to_string ( PangoFontDescription* desc ) ;

FUNCTION: char*
pango_font_description_to_filename ( PangoFontDescription* desc ) ;

FUNCTION: void
pango_layout_set_font_description ( PangoLayout* layout, PangoFontDescription* desc ) ;

FUNCTION: PangoFontDescription*
pango_layout_get_font_description ( PangoLayout* layout ) ;

FUNCTION: void
pango_layout_get_pixel_size ( PangoLayout* layout, int* width, int* height ) ;

FUNCTION: void
pango_font_description_free ( PangoFontDescription* desc ) ;

DESTRUCTOR: pango_font_description_free
