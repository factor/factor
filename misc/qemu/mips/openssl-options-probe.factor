! Exercise the actual option-mask argument and return ABI on ILP32 and LP64.
USING: kernel locals math math.bitwise openssl.libssl tools.test ;
IN: mips.openssl-options-probe

:: context-options-roundtrip? ( mask -- ? )
    TLS_method SSL_CTX_new :> ctx
    ctx mask SSL_CTX_set_options mask bitand mask =
    ctx SSL_CTX_get_options mask bitand mask = and
    ctx mask SSL_CTX_clear_options mask bitand zero? and
    ctx SSL_CTX_get_options mask bitand zero? and
    ctx SSL_CTX_free ;

:: connection-options-roundtrip? ( mask -- ? )
    TLS_method SSL_CTX_new :> ctx
    ctx SSL_new :> ssl
    ssl mask SSL_set_options mask bitand mask =
    ssl SSL_get_options mask bitand mask = and
    ssl mask SSL_clear_options mask bitand zero? and
    ssl SSL_get_options mask bitand zero? and
    ssl SSL_free ctx SSL_CTX_free ;

! A high bit makes an accidental ILP32 unsigned-long declaration observable.
! The legacy API is tested with a mask that fits its unsigned-long domain.
: option-mask ( -- mask )
    openssl-64-bit-options? [ 0x10000000000 ] [ 0x40000 ] if ;

{ t } [ option-mask context-options-roundtrip? ] unit-test
{ t } [ option-mask connection-options-roundtrip? ] unit-test
