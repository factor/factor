! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Build adjacent C as a GNU shared library (-mfp32 on O32, -mabi=64 on N64).
! Supply -mips-double-homes-library=PATH.
USING: alien alien.c-types alien.libraries alien.syntax compiler.units io kernel math memory namespaces ;
IN: mips.double-homes
<< "double-homes" "mips-double-homes-library" get cdecl add-library >>
LIBRARY: double-homes
FUNCTION: double leading ( double a, double b, int c, int d, int e )
CALLBACK: double leading_cb ( double a, double b, int c, int d, int e )
FUNCTION: double call_leading ( leading_cb cb )
: combine ( a b c d e -- n ) gc + + + + ;
: check ( -- )
  2.5 4.5 3 4 5 leading 19.0 = [ ] [ "outgoing leading doubles with stack integers" throw ] if
  [ combine ] leading_cb call_leading 19.0 = [ ] [ "callback leading doubles with stack integers" throw ] if ;
{ leading call_leading check } compile
check "Leading double homes and native stack arguments PASS" print flush
