! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators
gobject-introspection gobject.ffi kernel system vocabs ;
IN: gio.ffi

LIBRARY: gio

<<
"gio" {
    { [ os windows? ] [ "libgio-2.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ "libgio-2.0.dylib" cdecl add-library ] }
    { [ os unix? ] [ "libgio-2.0.so" cdecl add-library ] }
} cond
>>

INITIALIZER: init-ffi

GIR: vocab:gio/Gio-2.0.gir
