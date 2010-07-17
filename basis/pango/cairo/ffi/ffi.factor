! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax cairo.ffi
combinators kernel system
gobject-introspection pango.ffi ;
IN: pango.cairo.ffi

<< 
"pango.cairo" {
    { [ os winnt? ] [ "libpangocairo-1.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ "/opt/local/lib/libpangocairo-1.0.0.dylib" cdecl add-library ] }
    { [ os unix? ] [ "libpangocairo-1.0.so" cdecl add-library ] }
} cond 
>>

GIR: vocab:pango/cairo/PangoCairo-1.0.gir

FUNCTION: void
pango_cairo_update_layout ( cairo_t* cr, PangoLayout* layout ) ;

FUNCTION: void
pango_cairo_show_layout ( cairo_t* cr, PangoLayout* layout ) ;

FUNCTION: PangoLayout*
pango_cairo_create_layout ( cairo_t* cr ) ;

