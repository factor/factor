! Run after refreshing cpu.hppa and recompiling affected callers normally.
USING: alien.accessors byte-arrays compiler compiler.test compiler.units cpu.architecture
io kernel namespaces sequences tools.test words ;
IN: cpu.hppa.accessor-boundaries
: signed-roundtrip ( n -- n' )
    4 <byte-array> [ 0 set-alien-signed-4 ] keep 0 alien-signed-4 ;
: unsigned-roundtrip ( n -- n' )
    4 <byte-array> [ 0 set-alien-unsigned-4 ] keep 0 alien-unsigned-4 ;
{ signed-roundtrip unsigned-roundtrip } compile
{ t } [ { signed-roundtrip unsigned-roundtrip } [ word-optimized? ] all? ] unit-test
{ t } [
    { -2147483648 -134217729 -134217728 -1 0 134217727 134217728 1791054068 2147483647 }
    [ dup signed-roundtrip = ] all?
] unit-test
{ t } [
    { 0 134217727 134217728 1791054068 2147483647 2147483648 4294967295 }
    [ dup unsigned-roundtrip = ] all?
] unit-test
test-failures get empty? t assert=
"Optimized signed/unsigned 32-bit accessor boundaries passed" print
