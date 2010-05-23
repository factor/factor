! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators kernel
system
gir glib gobject glib.ffi ;

<<
"atk" {
    { [ os winnt? ] [ "libatk-1.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ drop ] }
    { [ os unix? ] [ "libatk-1.0.so" cdecl add-library ] }
} cond
>>

IN: atk.ffi

TYPEDEF: guint64 AtkState
TYPEDEF: GSList AtkAttributeSet

IN-GIR: atk vocab:atk/Atk-1.0.gir

