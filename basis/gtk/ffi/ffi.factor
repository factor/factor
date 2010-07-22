! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax alien.destructors alien.libraries
cairo.ffi combinators kernel system
gobject-introspection atk.ffi gdk.ffi gdk.pixbuf.ffi gio.ffi
glib.ffi gmodule.ffi gobject.ffi pango.ffi ;
EXCLUDE: alien.c-types => pointer ;
IN: gtk.ffi

<<
"gtk" {
    { [ os winnt? ] [ "libgtk-win32-2.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgtk-x11-2.0.so" cdecl add-library ] }
} cond
>>

TYPEDEF: void GtkAllocation
TYPEDEF: void GtkEnumValue
TYPEDEF: void GtkFlagValue
TYPEDEF: GType GtkType

IMPLEMENT-STRUCTS: GtkTreeIter ;

GIR: vocab:gtk/Gtk-2.0.gir

DESTRUCTOR: gtk_widget_destroy

