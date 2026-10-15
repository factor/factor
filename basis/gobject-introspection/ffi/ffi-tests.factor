USING: accessors alien.c-types compiler.units glib.ffi
gobject-introspection.ffi gobject-introspection.repository kernel
sequences tools.test ;
IN: gobject-introspection.ffi.tests

! callback
<<

{
    T{ return
       { type T{ simple-type { name "none" } } }
       { transfer-ownership "none" }
    }
} [
    "blah" "blah" f
    "none" f simple-type boa "none" return boa
    { } f callback boa return>>
] unit-test

! def-callback-type
{ } [
    [
        "blah" "blah"
        f "none" f simple-type boa "none" return boa
        { } f callback boa def-callback-type
    ] with-compilation-unit
] unit-test

! return-c-type
{ void } [
    "none" f simple-type boa "none" return boa return-c-type
] unit-test

>>

! An output struct supplied by the caller needs one pointer, not two.
{ t } [
    parameter new
        simple-type new "GLib.Error" >>name >>type
        "out" >>direction t >>caller-allocates?
    parameter-c-type GError <pointer> =
] unit-test

! GIR's throws flag adds a return location for an error, not an error object.
{ t } [
    error-parameter parameter-c-type GError <pointer> <pointer> =
] unit-test

{ 1 "error" "out" } [
    function new { } >>parameters t >>throws?
    ?suffix-parameters-with-error
    [ length ] [ first [ name>> ] [ direction>> ] bi ] bi
] unit-test

{ { } } [
    function new { } >>parameters f >>throws?
    ?suffix-parameters-with-error
] unit-test
