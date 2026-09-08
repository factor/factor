USING: alien alien.accessors alien.c-types alien.libraries alien.strings alien.syntax
alien.varargs byte-arrays combinators io.encodings.utf8 io.pathnames
kernel locals system tools.test ;
IN: alien.varargs.tests

<< "va-cursor-fixture" "resource:" absolute-path os {
    { windows [ "libfactor-ffi-test.dll" ] }
    { macos [ "libfactor-ffi-test.dylib" ] }
    [ drop "libfactor-ffi-test.so" ]
} case append-path cdecl add-library >>
LIBRARY: va-cursor-fixture
FUNCTION-ALIAS: va-test-vsnprintf-pointer void* va_vsnprintf_pointer ( )

! UCRT may provide vsnprintf only through an inline header wrapper, rather
! than an exported symbol. The C fixture supplies the real callable address.
: va-test-vsnprintf ( output size format args -- count )
    va-test-vsnprintf-pointer
    int { void* size_t c-string va_list } cdecl alien-indirect ;

! Real libc consumes native va_list state. Every forwarding call receives
! an independent copy and leaves our cursor ready to read the first value.
{ 6 "7/2.50" 6 "7/2.50" 7 } [
    [| mem |
        7 mem 0 set-alien-signed-4 2.5 mem 64 set-alien-double
        7 mem 256 set-alien-signed-4 2.5 mem 264 set-alien-double
        mem os cursor-at :> cursor
        32 <byte-array> :> output
        output 32 "%d/%.2f" cursor va-test-vsnprintf
        output utf8 alien>string
        output 32 "%d/%.2f" cursor va-test-vsnprintf
        output utf8 alien>string
        cursor int va-arg
    ] with-va-memory
] unit-test

{ 7 7 } [
    [| mem |
        7 mem 0 set-alien-signed-4 7 mem 256 set-alien-signed-4
        mem os cursor-at :> cursor
        cursor cursor>native-va-list native-va-list>cursor int va-arg
        cursor int va-arg
    ] with-va-memory
] unit-test
