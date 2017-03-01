! Copyright (C) 2017 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax combinators system ;
IN: sodium.ffi

<< "sodium" {
    { [ os windows? ] [ "libsodium.dll" ] }
    { [ os macosx? ] [ "libsodium.dylib" ] }
    { [ os unix? ] [ "libsodium.so" ] }
} cond cdecl add-library >>

LIBRARY: sodium
