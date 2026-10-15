USING: accessors alien.strings alien.syntax
byte-arrays byte-vectors compiler.codegen.relocation endian kernel namespaces sequences tools.test ;
IN: compiler.codegen.relocation.tests

{
    B{ 114 101 97 100 108 105 110 101 0 }
    "libreadline.so"
} [
    init-relocation
    "readline" DLL" libreadline.so" add-dlsym-parameters
    parameter-table get first2 path>> alien>native-string
] unit-test

! Independent wire bytes, including a value with the high bit set.
{ B{ 18 52 86 120 254 220 186 152 } } [
    [
        big-endian relocation-byte-order set
        BV{ } clone 0x12345678 over push-uint
        0xfedcba98 over push-uint >byte-array
    ] with-scope
] unit-test

{ B{ 120 86 52 18 152 186 220 254 } } [
    [
        little-endian relocation-byte-order set
        BV{ } clone 0x12345678 over push-uint
        0xfedcba98 over push-uint >byte-array
    ] with-scope
] unit-test
