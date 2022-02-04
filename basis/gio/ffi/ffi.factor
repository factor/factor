! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection system vocabs ;
IN: gio.ffi

<< "gobject.ffi" require >>

LIBRARY: gio

LIBRARY-UNIX: gio cdecl "libgio-2.0.so"
LIBRARY-MACOSX: gio cdecl "libgio-2.0.dylib"
LIBRARY-WINDOWS: gio cdecl "libgio-2.0-0.dll"

GIR: vocab:gio/Gio-2.0.gir
