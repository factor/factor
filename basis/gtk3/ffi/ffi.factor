! Copyright (C) 2025 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.destructors alien.syntax gobject-introspection system vocabs ;
IN: gtk3.ffi

<<
"atk.ffi" require
"gdk3.ffi" require
>>

LIBRARY: gtk3

C-LIBRARY: gtk3 {
    { unix "libgtk-3.so" }
}

FOREIGN-RECORD-TYPE: xlib.Window void*

GIR: vocab:gir/Gtk-3.0.gir

DESTRUCTOR: gtk_widget_destroy
