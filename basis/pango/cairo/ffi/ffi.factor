! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection system vocabs ;
USE: cairo.ffi
IN: pango.cairo.ffi

<< "pango.ffi" require >>

LIBRARY: pango.cairo

LIBRARY-UNIX: pango.cairo cdecl "libpangocairo-1.0.so"
LIBRARY-MACOSX: pango.cairo cdecl "libpangocairo-1.0.dylib"
LIBRARY-WINDOWS: pango.cairo cdecl "libpangocairo-1.0-0.dll"

FOREIGN-RECORD-TYPE: cairo.Context cairo_t
FOREIGN-RECORD-TYPE: cairo.ScaledFont cairo_scaled_font_t
FOREIGN-ENUM-TYPE: cairo.FontType cairo_font_type_t
FOREIGN-RECORD-TYPE: cairo.FontOptions cairo_font_options_t

GIR: vocab:pango/cairo/PangoCairo-1.0.gir
