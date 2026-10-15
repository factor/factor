! Fresh optimized ABI wrappers; construct opaque native NaNs before collecting
! comparison flags. Stored and raw API values retain canonical IEEE encoding.
USING: alien alien.c-types alien.libraries alien.syntax compiler compiler.test
compiler.units destructors io kernel locals math math.bitwise math.floats.env
math.private namespaces sequences tools.test words ;
FROM: alien.c-types => float ;
IN: cpu.hppa.nan-ffi
"hppa-nan-fixture" "./libhppa-nan-fixture.so" cdecl add-library
LIBRARY: hppa-nan-fixture
FUNCTION: double hppa_qdouble ( )
FUNCTION: double hppa_sdouble ( )
FUNCTION: float hppa_qfloat ( )
FUNCTION: float hppa_sfloat ( )
FUNCTION: ulonglong hppa_double_bits ( double value )
FUNCTION: uint hppa_float_bits ( float value )
FUNCTION: ulonglong hppa_vararg_bits ( int ignored, ... double value )
FUNCTION: double hppa_callback ( double value, void* callback )
: raw-double-roundtrip ( bits -- bits ) bits>double double>bits ;
: raw-float-roundtrip ( bits -- bits ) bits>float float>bits ;
: raw-after-compare ( value -- bits ) dup 1.0 float-u< drop double>bits ;
: identity-callback ( -- callback ) double { double } cdecl [ ] alien-callback ;
:: invalid? ( value word -- ? )
    value 1.0 [ word execute( x y -- ? ) ] collect-fp-exceptions nip
    +fp-invalid-operation+ swap member? ;
{ hppa_qdouble hppa_sdouble hppa_qfloat hppa_sfloat hppa_double_bits
  hppa_float_bits hppa_vararg_bits hppa_callback identity-callback
  raw-double-roundtrip raw-float-roundtrip raw-after-compare } compile
{ t } [ { hppa_qdouble hppa_sdouble hppa_qfloat hppa_sfloat hppa_double_bits
          hppa_float_bits hppa_vararg_bits hppa_callback identity-callback
          raw-double-roundtrip raw-float-roundtrip raw-after-compare }
        [ word-optimized? ] all? ] unit-test
{ 0x7ffc000000000000 } [ hppa_qdouble double>bits ] unit-test
{ 0x7ff0000000001234 } [ hppa_sdouble double>bits ] unit-test
{ 0x7fe00000 } [ hppa_qfloat float>bits ] unit-test
{ 0x7f801234 } [ hppa_sfloat float>bits ] unit-test
{ 0x7ffc000000000000 } [
    0.0 0.0 \ float/f execute( x y -- z ) double>bits
] unit-test
{ { f f f f } } [ hppa_qdouble { float-u< float-u<= float-u> float-u>= } [ invalid? ] with map ] unit-test
{ { t t t t } } [ hppa_sdouble { float-u< float-u<= float-u> float-u>= } [ invalid? ] with map ] unit-test
{ { f f f f } } [ hppa_qfloat { float-u< float-u<= float-u> float-u>= } [ invalid? ] with map ] unit-test
{ { t t t t } } [ hppa_sfloat { float-u< float-u<= float-u> float-u>= } [ invalid? ] with map ] unit-test
{ 0x7ff4000000000000 } [ 0x7ff8000000000000 bits>double hppa_double_bits ] unit-test
{ 0x7ff8000000001234 } [ 0x7ff0000000001234 bits>double hppa_double_bits ] unit-test
{ 0x7fa00000 } [ 0x7fc00000 bits>float hppa_float_bits ] unit-test
{ 0x7fc01234 } [ 0x7f801234 bits>float hppa_float_bits ] unit-test
{ 0x7ff4000000000000 } [ 0 0x7ff8000000000000 bits>double hppa_vararg_bits ] unit-test
{ 0x7ff8000000001234 } [ 0 0x7ff0000000001234 bits>double hppa_vararg_bits ] unit-test
{ 0x7ffc000000000000 } [ 0x7ff8000000000000 bits>double identity-callback [ hppa_callback ] with-callback double>bits ] unit-test
{ 0x7ff0000000001234 } [ 0x7ff0000000001234 bits>double identity-callback [ hppa_callback ] with-callback double>bits ] unit-test
{ t } [ { 0x7ff0000000000001 0x7ff8000000000000 0x7ff8123456789abc 0xfff0000000001234 }
        [ dup raw-double-roundtrip = ] all? ] unit-test
{ t } [ { 0x7f800001 0x7fc00000 0x7fc12345 0xff800123 0xffc00000 }
        [ dup raw-float-roundtrip = ] all? ] unit-test
{ t } [ { 0x7ff8000000000000 0xfff8000000000000 0x7ff0000000001234 0xfff0000000001234 }
        [ dup bits>double raw-after-compare = ] all? ] unit-test
test-failures get empty? t assert=
"Optimized HPPA canonical/native NaN FFI boundaries passed" print
