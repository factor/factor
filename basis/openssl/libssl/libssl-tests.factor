USING:
    arrays
    kernel
    math
    openssl.libssl
    sequences
    tools.test ;
IN: openssl.libssl.tests

: all-opts ( -- opts )
    {
        SSL_OP_NO_SSLv2
        SSL_OP_NO_SSLv3
        SSL_OP_NO_TLSv1
        SSL_OP_NO_TLSv1_1
        SSL_OP_NO_TLSv1_2
    } [ execute( -- x ) ] map ;

: set-opt ( ctx op -- )
    SSL_CTRL_OPTIONS swap f SSL_CTX_ctrl drop ;

: has-opt ( ctx op -- ? )
    swap SSL_CTRL_OPTIONS 0 f SSL_CTX_ctrl bitand 0 > ;

: new-ctx ( -- ctx )
    SSLv23_client_method SSL_CTX_new ;

: new-ssl ( -- ssl )
    new-ctx SSL_new ;

! Test default options
{ { f f f f f } } [ new-ctx all-opts [ has-opt ] with map ] unit-test

! Test setting options
{ 5 } [
    new-ctx all-opts [ [ set-opt ] [ has-opt ] 2bi ] with map [ t = ] count
] unit-test

! Initial state
{ { "before/connect initialization" "read header" 1 f } } [
    new-ssl {
        SSL_state_string_long
        SSL_rstate_string_long
        SSL_want
        SSL_get_peer_certificate
    } [ execute( x -- x ) ] with map
] unit-test
