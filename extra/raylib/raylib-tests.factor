! Signature coverage requires no raylib shared library or GUI initialization.
USING: accessors alien.libraries effects io kernel parser raylib
sequences system tools.test words ;
IN: raylib.tests

{ ( logLevel text args -- ) } [
    \ TraceLogCallback "callback-effect" word-prop
] unit-test

! The named-argument count controls the platform's variadic calling convention.
{ 2 } [ 4 \ trace-log def>> nth ] unit-test
{ 1 } [ 4 \ text-format def>> nth ] unit-test

"raylib" library-dll dll-valid? [
    "resource:extra/raylib/native/varargs.factor" run-test-file
] [
    "Raylib native formatting tests unavailable: shared library not installed." print
] if
