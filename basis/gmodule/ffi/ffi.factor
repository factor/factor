! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection system vocabs ;
IN: gmodule.ffi

<< "glib.ffi" require >>

LIBRARY: gmodule

LIBRARY-UNIX: gmodule cdecl "libgmodule-2.0.so"
LIBRARY-MACOSX: gmodule cdecl "libgmodule-2.0.dylib"
LIBRARY-WINDOWS: gmodule cdecl "libgmodule-2.0-0.dll"

GIR: vocab:gmodule/GModule-2.0.gir
