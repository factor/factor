! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax alien.libraries cairo.ffi combinators 
kernel system
gir glib glib.ffi gobject gio gmodule gdk.pixbuf gdk atk ;

<<
"gtk" {
    { [ os winnt? ] [ "libgtk-win32-2.0-0.dll" "cdecl" add-library ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgtk-x11-2.0.so" "cdecl" add-library ] }
} cond
>>

IN: gtk.ffi

TYPEDEF: void GtkAllocation
TYPEDEF: void GtkEnumValue
TYPEDEF: void GtkFlagValue
TYPEDEF: GType GtkType

IN-GIR: gtk vocab:gtk/Gtk-2.0.gir

