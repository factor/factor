USING: destructors kernel math namespaces openssl openssl.libssl
sequences tools.test ;
IN: openssl.libssl.tests

maybe-init-ssl

! It looks like Arch and Ubuntu Linux in newer versions are disabling
! SSLv2 and SSLv3 so we don't test those options.
: tls-opts ( -- opts )
    {
        SSL_OP_NO_TLSv1
        SSL_OP_NO_TLSv1_1
        SSL_OP_NO_TLSv1_2
    } [ execute( -- x ) ] map ;

: set-opt ( ctx op -- )
    SSL_CTRL_OPTIONS swap f SSL_CTX_ctrl drop ;

: has-opt ( ctx op -- ? )
    swap SSL_CTRL_OPTIONS 0 f SSL_CTX_ctrl bitand 0 > ;

: new-ctx ( method -- ctx )
    SSL_CTX_new &SSL_CTX_free ;

: new-tls1-ctx ( -- ctx )
    TLSv1_client_method new-ctx ;

: new-ssl ( ctx -- ssl )
    SSL_new &SSL_free ;

{
    { f f f }
} [
    [
        new-tls1-ctx tls-opts [ has-opt ] with map
    ] with-destructors
] unit-test

! Test setting options
{ t } [
    [
        new-tls1-ctx tls-opts [ [ set-opt ] [ has-opt ] 2bi ] with map
        [ t = ] count
    ] with-destructors
    ssl-new-api? get-global 0 3 ? =
] unit-test

! Initial state
{ t } [
    [ new-tls1-ctx new-ssl SSL_state_string_long ] with-destructors
    ssl-new-api? get-global
    "before SSL initialization" "before/connect initialization" ? =
] unit-test

{
    { "read header" 1 f }
} [
    [
        new-tls1-ctx new-ssl {
            SSL_rstate_string_long
            SSL_want
            SSL_get_peer_certificate
        } [ execute( x -- x ) ] with map
    ] with-destructors
] unit-test
