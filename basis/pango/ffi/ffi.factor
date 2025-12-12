! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax combinators gobject-introspection
gobject-introspection.standard-types system vocabs ;
IN: pango.ffi

<< "gobject.ffi" require >>

LIBRARY: pango

C-LIBRARY: pango {
    { windows "libpango-1.0-0.dll" }
    { macos "libpango-1.0.dylib" }
    { unix "libpango-1.0.so" }
}

IMPLEMENT-STRUCTS: PangoRectangle ;

FOREIGN-RECORD-TYPE: FT_Bitmap void*
FOREIGN-RECORD-TYPE: FT_Face void*
FOREIGN-RECORD-TYPE: FT_Library void*

GIR: vocab:gir/Pango-1.0.gir

DESTRUCTOR: pango_font_description_free
DESTRUCTOR: pango_layout_iter_free

! <workaround

FORGET: pango_layout_line_index_to_x
FUNCTION: void
pango_layout_line_index_to_x ( PangoLayoutLine* line, gint index_, gboolean trailing, gint* x_pos )

FORGET: pango_layout_line_x_to_index
FUNCTION: gboolean
pango_layout_line_x_to_index ( PangoLayoutLine* line, gint x_pos, gint* index_, gint* trailing )

! workaround>
