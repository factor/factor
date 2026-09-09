USING: alien alien.c-types alien.libraries alien.strings alien.syntax
alien.varargs arrays byte-arrays combinators compiler.test continuations db.sqlite.ffi
io.encodings.utf8 io.pathnames kernel locals namespaces sequences system tools.test ;
IN: compiler.tests.sqlite-varargs

<<
"sqlite-varargs-caller" "resource:" absolute-path os {
    { windows [ "libfactor-ffi-test.dll" ] }
    { macos [ "libfactor-ffi-test.dylib" ] }
    [ drop "libfactor-ffi-test.so" ]
} case append-path cdecl add-library
>>
LIBRARY: sqlite-varargs-caller
CALLBACK: int sqlite-format-list ( c-string format, va_list args )
FUNCTION: int va_call_format_list ( sqlite-format-list callback )

SYMBOL: formatted

:: owned-text ( ptr -- text )
    [ ptr utf8 alien>string ] [ ptr sqlite3_free ] finally ;

! C supplies "%s:%d:%.*f:%lld", "value", -42, 3, 1.25, and -1234567890123LL.
! Repeated forwarding must use independent native copies of the borrowed list.
{ 1 { "value:-42:1.250:-1234567890123" "value:-42:1.250:-1234567890123" "value" } } [
    [
        [| format args |
            format args sqlite3_vmprintf owned-text
            format args sqlite3_vmprintf owned-text
            args c-string va-arg 3array formatted set-global 1
        ] sqlite-format-list [ va_call_format_list ] with-callback
        formatted get
    ] compile-call
] unit-test

{ 1 "value:-42:1.250:-1234567890123" } [
    [
        [| format args |
            64 <byte-array> :> output
            64 output format args sqlite3_vsnprintf alien? t assert=
            output utf8 alien>string formatted set-global 1
        ] sqlite-format-list [ va_call_format_list ] with-callback
        formatted get
    ] compile-call
] unit-test

{ 1 "value:-" } [
    [
        [| format args |
            8 <byte-array> :> output
            8 output format args sqlite3_vsnprintf drop
            output utf8 alien>string formatted set-global 1
        ] sqlite-format-list [ va_call_format_list ] with-callback
        formatted get
    ] compile-call
] unit-test

{ 1 "prefix:value:-42:1.250:-1234567890123" } [
    [
        [| format args |
            f sqlite3_str_new :> builder
            builder "prefix:" sqlite3_str_appendf
            builder format args sqlite3_str_vappendf
            builder sqlite3_str_finish owned-text formatted set-global 1
        ] sqlite-format-list [ va_call_format_list ] with-callback
        formatted get
    ] compile-call
] unit-test
