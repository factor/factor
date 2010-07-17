! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax combinators kernel system
gobject-introspection glib.ffi ;
IN: pango.ffi

<< 
"pango" {
    { [ os winnt? ] [ "libpango-1.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ "/opt/local/lib/libpango-1.0.0.dylib" cdecl add-library ] }
    { [ os unix? ] [ "libpango-1.0.so" cdecl add-library ] }
} cond 
>>

TYPEDEF: void PangoLayoutRun
TYPEDEF: guint32 PangoGlyph

IMPLEMENT-STRUCTS: PangoRectangle ;

GIR: vocab:pango/Pango-1.0.gir

DESTRUCTOR: pango_font_description_free
DESTRUCTOR: pango_layout_iter_free

