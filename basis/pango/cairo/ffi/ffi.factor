! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection system vocabs ;
USE: cairo.ffi
IN: pango.cairo.ffi

<< "pango.ffi" require >>

LIBRARY: pango.cairo

<< "pango.cairo" {
    { [ os windows? ] [ "libpangocairo-1.0-0.dll" ] }
    { [ os macos? ] [ "libpangocairo-1.0.dylib" ] }
    { [ os unix? ] [ "libpangocairo-1.0.so" ] }
} cond cdecl add-library >>

FOREIGN-RECORD-TYPE: cairo.Context cairo_t
FOREIGN-RECORD-TYPE: cairo.ScaledFont cairo_scaled_font_t
FOREIGN-ENUM-TYPE: cairo.FontType cairo_font_type_t
FOREIGN-RECORD-TYPE: cairo.FontOptions cairo_font_options_t

GIR: vocab:gir/PangoCairo-1.0.gir
