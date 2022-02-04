! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection kernel system vocabs ;
IN: clutter.json.ffi

<<
"gobject.ffi" require
"gio.ffi" require
>>

LIBRARY: clutter.json

LIBRARY-UNIX: clutter.json cdecl "libclutter-glx-1.0.so"

GIR: Json-1.0.gir
