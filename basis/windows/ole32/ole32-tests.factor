USING: alien.c-types classes.struct kernel math sequences
sets specialized-arrays tools.test windows.com.syntax
windows.kernel32 windows.ole32 ;
SPECIALIZED-ARRAY: uchar
IN: windows.ole32.tests

[ t ] [
    "{01234567-89ab-cdef-0123-456789abcdef}" string>guid
    "{01234567-89ab-cdef-0123-456789abcdef}" string>guid
    guid=
] unit-test

[ f ] [
    "{76543210-89ab-cdef-0123-456789abcdef}" string>guid
    "{01234567-89ab-cdef-0123-456789abcdef}" string>guid
    guid=
] unit-test

[ f ] [
    "{01234567-89ab-cdef-0123-fedcba987654}" string>guid
    "{01234567-89ab-cdef-0123-456789abcdef}" string>guid
    guid=
] unit-test

[
    GUID: 01234567-89ab-cdef-0123-456789abcdef}
] [ "{01234567-89ab-cdef-0123-456789abcdef}" string>guid ] unit-test

[ "{01234567-89ab-cdef-0123-456789abcdef}" ]
[ "{01234567-89ab-cdef-0123-456789abcdef}" string>guid guid>string ]
unit-test

{ 0 } [ 10 [ create-guid ] replicate duplicates length ] unit-test
