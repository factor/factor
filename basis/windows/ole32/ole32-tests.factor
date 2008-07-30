USING: kernel tools.test windows.ole32 alien.c-types ;
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
        
little-endian?
[ B{
    HEX: 67 HEX: 45 HEX: 23 HEX: 01 HEX: ab HEX: 89 HEX: ef HEX: cd
    HEX: 01 HEX: 23 HEX: 45 HEX: 67 HEX: 89 HEX: ab HEX: cd HEX: ef
} ]
[ B{
    HEX: 01 HEX: 23 HEX: 45 HEX: 67 HEX: 89 HEX: ab HEX: cd HEX: ef
    HEX: 01 HEX: 23 HEX: 45 HEX: 67 HEX: 89 HEX: ab HEX: cd HEX: ef
} ] ?
[ "{01234567-89ab-cdef-0123-456789abcdef}" string>guid ]
unit-test

[ "{01234567-89ab-cdef-0123-456789abcdef}" ]
[ "{01234567-89ab-cdef-0123-456789abcdef}" string>guid guid>string ]
unit-test
