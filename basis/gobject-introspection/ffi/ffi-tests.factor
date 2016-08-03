USING: accessors alien.c-types compiler.units
gobject-introspection.ffi gobject-introspection.repository kernel
tools.test ;
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
