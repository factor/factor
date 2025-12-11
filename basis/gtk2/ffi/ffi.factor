! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax combinators gobject-introspection
gobject-introspection.standard-types kernel
pango.ffi system vocabs ;
IN: gtk2.ffi

<<
"atk.ffi" require
"gdk2.ffi" require
>>

LIBRARY: gtk2

<<
"gtk" {
    { [ os windows? ] [ "libgtk-win32-2.0-0.dll" cdecl add-library ] }
    { [ os linux? ] [ "libgtk-x11-2.0.so" cdecl add-library ] }
    [ drop ]
} cond
>>

IMPLEMENT-STRUCTS: GtkTreeIter ;

GIR: vocab:gir/Gtk-2.0.gir

DESTRUCTOR: gtk_widget_destroy

! <workaround
FORGET: gtk_im_context_get_preedit_string
FUNCTION: void
gtk_im_context_get_preedit_string ( GtkIMContext* imcontext, gchar** str, PangoAttrList** attrs, gint* cursor_pos )
! workaround>
