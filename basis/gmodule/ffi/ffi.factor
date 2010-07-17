! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries combinators kernel system
gobject-introspection glib.ffi ;
IN: gmodule.ffi

<<
"gmodule" {
    { [ os winnt? ] [ "libgmodule-2.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libgmodule-2.0.so" cdecl add-library ] }
} cond
>>

GIR: vocab:gmodule/GModule-2.0.gir

