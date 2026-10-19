! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Supply -mips-complex-library=PATH to the GNU-built target shared library.
USING: alien alien.c-types alien.complex alien.libraries alien.syntax compiler.units io kernel locals math memory namespaces ;
FROM: alien.c-types => float ;
IN: mips.complex-boundary
<< "complex-boundary" "mips-complex-library" get cdecl add-library >>
LIBRARY: complex-boundary
CALLBACK: complex-float complex_cb ( complex-float x, complex-double y )
CALLBACK: complex-float complex_boundary_cb ( float a, float b, float c, float d, float e, float f, float g, complex-float x, complex-double y )
FUNCTION: complex-float complex_callback ( complex_cb cb )
FUNCTION: complex-float complex_boundary_callback ( complex_boundary_cb cb )
FUNCTION: complex-float complex_boundary ( float a, float b, float c, float d, float e, float f, float g, complex-float x, complex-double y )
FUNCTION: complex-float complex_stack ( float a, float b, float c, float d, float e, float f, float g, float h, complex-float x, complex-double y )
FUNCTION: complex-float complex_variadic ( int tag, ... complex-float x, complex-double y )
:: combine ( x y -- z ) gc x y 2 * + ;
:: combine-boundary ( a b c d e f g x y -- z ) gc x y 2 * + a + b + c + d + e + f + g + ;
: check-boundary ( -- )
  7 C{ 1.0 2.0 } C{ 1.5 1.0 } complex_variadic C{ 11.0 4.0 } = [ ] [ "variadic complex" throw ] if
  1.0 2.0 3.0 4.0 5.0 6.0 7.0 C{ 1.0 2.0 } C{ 1.5 1.0 } complex_boundary C{ 32.0 4.0 } = [ ] [ "boundary outgoing" throw ] if
  1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 C{ 1.0 2.0 } C{ 1.5 1.0 } complex_stack C{ 40.0 4.0 } = [ ] [ "stack outgoing" throw ] if
  [ combine ] complex_cb complex_callback C{ 4.0 4.0 } = [ ] [ "complex GC callback" throw ] if
  [ combine-boundary ] complex_boundary_cb complex_boundary_callback C{ 32.0 4.0 } = [ ] [ "boundary GC callback" throw ] if ;
{ complex_variadic complex_boundary complex_stack complex_callback complex_boundary_callback check-boundary } compile
check-boundary "GNU complex varargs, register boundary, stack and live-GC callback PASS" print flush
