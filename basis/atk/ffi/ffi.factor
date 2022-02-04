! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection system vocabs vocabs.platforms ;
IN: atk.ffi

<< "gobject.ffi" require >>

LIBRARY: atk

LIBRARY-UNIX: atk cdecl "libatk-1.0.so"
LIBRARY-MACOSX: atk cdecl "libatk-1.0.dylib"
LIBRARY-WINDOWS: atk cdecl "libatk-1.0-0.dll"

GIR: vocab:atk/Atk-1.0.gir
