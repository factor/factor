! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection system vocabs ;
IN: gmodule.ffi

<< "glib.ffi" require >>

LIBRARY: gmodule

C-LIBRARY: gmodule {
    { windows "gmodule-2.0-0.dll" }
    { macos "libgmodule-2.0.dylib" }
    { unix "libgmodule-2.0.so" }
}

GIR: vocab:gir/GModule-2.0.gir
