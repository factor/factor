! Run with a saved s390x compiler/I/O image on each native VM.
USING: alien.c-types alien.data alien.syntax arrays compiler.test io io.directories
io.encodings.utf8 io.files io.files.temp kernel math sequences specialized-arrays tools.test ;
IN: s390x.stage2.smoke

SPECIALIZED-ARRAY: int

LIBRARY: libc
FUNCTION: long labs ( long value )
CALLBACK: int smoke-comparator ( void* a, void* b )
FUNCTION: void qsort ( void* base, size_t count, size_t size, smoke-comparator comparator )

: arithmetic-smoke ( x -- y ) dup * 7 + ;

{ 151 } [ 12 [ arithmetic-smoke ] compile-call ] unit-test
{ 576460752303423488 } [ 576460752303423487 1 [ + ] compile-call ] unit-test
{ 1152921504606846976 } [ 1073741824 1073741824 [ * ] compile-call ] unit-test
{ -21 } [ -63 3 [ /i ] compile-call ] unit-test
{ 3.75 } [ 1.25 2.5 [ + ] compile-call ] unit-test
{ 123 } [ -123 [ labs ] compile-call ] unit-test
{ { 1 2 3 } } [
    { 3 1 2 } int >c-array
    [ dup 3 4 [ [ int deref ] bi@ - ] smoke-comparator qsort ] compile-call >array
] unit-test

{ "s390x UTF-8: λ\n" } [
    "s390x-stage2-smoke.txt" temp-file
    [ "s390x UTF-8: λ\n" swap utf8 set-file-contents ]
    [ utf8 file-contents ]
    [ delete-file ] tri
] unit-test

"s390x compiled arithmetic, native FFI/callback and UTF-8 file I/O passed" print
