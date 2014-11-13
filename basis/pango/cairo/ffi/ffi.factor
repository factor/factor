! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax cairo.ffi combinators
kernel gobject-introspection system vocabs ;
IN: pango.cairo.ffi

<< "pango.ffi" require >>

LIBRARY: pango.cairo

<< "pango.cairo" {
    { [ os windows? ] [ "libpangocairo-1.0-0.dll" ] }
    { [ os macosx? ] [ "libpangocairo-1.0.dylib" ] }
    { [ os unix? ] [ "libpangocairo-1.0.so" ] }
} cond cdecl add-library >>

FOREIGN-RECORD-TYPE: cairo.Context cairo_t
FOREIGN-RECORD-TYPE: cairo.ScaledFont cairo_scaled_font_t
FOREIGN-ENUM-TYPE: cairo.FontType cairo_font_type_t
FOREIGN-RECORD-TYPE: cairo.FontOptions cairo_font_options_t

GIR: vocab:pango/cairo/PangoCairo-1.0.gir
