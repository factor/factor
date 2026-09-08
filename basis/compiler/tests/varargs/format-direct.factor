USING: alien.c-types alien.strings alien.syntax byte-arrays io.encodings.utf8
kernel libc locals tools.test ;
IN: compiler.tests.alien-varargs.format-direct
LIBRARY: libc
FUNCTION-ALIAS: direct-snprintf int snprintf (
    void* output, size_t size, c-string format,
    ... c-string text, int number, int precision, double value, longlong wide )
:: direct-formatted ( -- count text )
    128 <byte-array> :> output
    output 128 "%s:%d:%.*f:%lld" "value" -42 3 1.25 -1234567890123 direct-snprintf
    output utf8 alien>string ;
{ 30 "value:-42:1.250:-1234567890123" } [ direct-formatted ] unit-test
