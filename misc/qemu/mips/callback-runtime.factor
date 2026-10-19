! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Compile callback-runtime.c as a target shared library and set its absolute
! path using -mips-callback-library=PATH. Run with a compiler-loaded image.
USING: alien alien.c-types alien.libraries alien.syntax compiler.units
io kernel math memory namespaces ;
IN: mips.callback-runtime

<<
"mips-callback-runtime" "mips-callback-library" get
[ "Supply -mips-callback-library=PATH for the target shared library" throw ] unless*
cdecl add-library
>>

LIBRARY: mips-callback-runtime
CALLBACK: long mips-int-callback ( long n )
CALLBACK: double mips-fp-callback ( double x, int n )
FUNCTION: long mips_invoke_int ( mips-int-callback callback, long n )
FUNCTION: double mips_invoke_fp ( mips-fp-callback callback, double x, int n )
FUNCTION: double mips_mix ( long i, double x, long j, double y )

: check-result ( actual expected -- )
    = [ "MIPS callback runtime mismatch" throw ] unless ;

: invoke-int-runtime ( -- n )
    [ gc 2 * ] mips-int-callback 21 mips_invoke_int ;

: invoke-fp-runtime ( -- n )
    [ >float * gc ] mips-fp-callback 2.5 4 mips_invoke_fp ;

{
    mips_invoke_int mips_invoke_fp mips_mix
    invoke-int-runtime invoke-fp-runtime
} compile
1 2.5 3 4.5 mips_mix 11.0 check-result
invoke-int-runtime 42 check-result
invoke-fp-runtime 10.0 check-result
"MIPS integer/FP callbacks with live GC passed" print flush
