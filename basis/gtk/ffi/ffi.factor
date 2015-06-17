! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.libraries
alien.libraries.finder alien.syntax gobject-introspection
gobject-introspection.standard-types init pango.ffi vocabs ;
IN: gtk.ffi

<<
"atk.ffi" require
"gdk.ffi" require
>>

LIBRARY: gtk

[ "gtk" "gtk-x11-2.0" find-library cdecl update-library ] "gtk" add-startup-hook

IMPLEMENT-STRUCTS: GtkTreeIter ;

GIR: vocab:gtk/Gtk-3.0.gir

DESTRUCTOR: gtk_widget_destroy

! <workaround
FORGET: gtk_im_context_get_preedit_string
FUNCTION: void
gtk_im_context_get_preedit_string ( GtkIMContext* imcontext, gchar** str, PangoAttrList** attrs, gint* cursor_pos ) ;
! workaround>
