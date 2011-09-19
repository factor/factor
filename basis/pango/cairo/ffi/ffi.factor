! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax cairo.ffi combinators
kernel gobject-introspection system vocabs.loader ;
IN: pango.cairo.ffi

<<
"pango.ffi" require
>>

LIBRARY: pango.cairo

<< 
"pango.cairo" {
    { [ os windows? ] [ "libpangocairo-1.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ drop ] }
} cond 
>>

FOREIGN-RECORD-TYPE: cairo.Context cairo_t
FOREIGN-RECORD-TYPE: cairo.ScaledFont cairo_scaled_font_t
FOREIGN-ENUM-TYPE: cairo.FontType cairo_font_type_t
FOREIGN-RECORD-TYPE: cairo.FontOptions cairo_font_options_t

GIR: vocab:pango/cairo/PangoCairo-1.0.gir
