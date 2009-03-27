! Copyright (C) 2007 Elie CHAFTARI
! Portions copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax combinators kernel system namespaces
assocs parser lexer sequences words quotations math.bitwise
alien.libraries ;

IN: openssl.libssl

<< {
    { [ os openbsd? ] [ ] } ! VM is linked with it
    { [ os winnt? ] [ "libssl" "ssleay32.dll" "cdecl" add-library ] }
    { [ os macosx? ] [ "libssl" "libssl.dylib" "cdecl" add-library ] }
    { [ os unix? ] [ "libssl" "libssl.so" "cdecl" add-library ] }
} cond >>

CONSTANT: X509_FILETYPE_PEM       1
CONSTANT: X509_FILETYPE_ASN1      2
CONSTANT: X509_FILETYPE_DEFAULT   3

ALIAS: SSL_FILETYPE_ASN1 X509_FILETYPE_ASN1
ALIAS: SSL_FILETYPE_PEM  X509_FILETYPE_PEM

CONSTANT: SSL_CTRL_NEED_TMP_RSA   1
CONSTANT: SSL_CTRL_SET_TMP_RSA    2
CONSTANT: SSL_CTRL_SET_TMP_DH     3
CONSTANT: SSL_CTRL_SET_TMP_RSA_CB 4
CONSTANT: SSL_CTRL_SET_TMP_DH_CB  5

CONSTANT: SSL_CTRL_GET_SESSION_REUSED       6 
CONSTANT: SSL_CTRL_GET_CLIENT_CERT_REQUEST  7 
CONSTANT: SSL_CTRL_GET_NUM_RENEGOTIATIONS   8 
CONSTANT: SSL_CTRL_CLEAR_NUM_RENEGOTIATIONS 9 
CONSTANT: SSL_CTRL_GET_TOTAL_RENEGOTIATIONS 10
CONSTANT: SSL_CTRL_GET_FLAGS                11
CONSTANT: SSL_CTRL_EXTRA_CHAIN_CERT         12

CONSTANT: SSL_CTRL_SET_MSG_CALLBACK         13
CONSTANT: SSL_CTRL_SET_MSG_CALLBACK_ARG     14

CONSTANT: SSL_CTRL_SESS_NUMBER              20
CONSTANT: SSL_CTRL_SESS_CONNECT             21
CONSTANT: SSL_CTRL_SESS_CONNECT_GOOD        22
CONSTANT: SSL_CTRL_SESS_CONNECT_RENEGOTIATE 23
CONSTANT: SSL_CTRL_SESS_ACCEPT              24
CONSTANT: SSL_CTRL_SESS_ACCEPT_GOOD         25
CONSTANT: SSL_CTRL_SESS_ACCEPT_RENEGOTIATE  26
CONSTANT: SSL_CTRL_SESS_HIT                 27
CONSTANT: SSL_CTRL_SESS_CB_HIT              28
CONSTANT: SSL_CTRL_SESS_MISSES              29
CONSTANT: SSL_CTRL_SESS_TIMEOUTS            30
CONSTANT: SSL_CTRL_SESS_CACHE_FULL          31
CONSTANT: SSL_CTRL_OPTIONS                  32
CONSTANT: SSL_CTRL_MODE                     33

CONSTANT: SSL_CTRL_GET_READ_AHEAD           40
CONSTANT: SSL_CTRL_SET_READ_AHEAD           41
CONSTANT: SSL_CTRL_SET_SESS_CACHE_SIZE      42
CONSTANT: SSL_CTRL_GET_SESS_CACHE_SIZE      43
CONSTANT: SSL_CTRL_SET_SESS_CACHE_MODE      44
CONSTANT: SSL_CTRL_GET_SESS_CACHE_MODE      45

CONSTANT: SSL_CTRL_GET_MAX_CERT_LIST        50
CONSTANT: SSL_CTRL_SET_MAX_CERT_LIST        51

CONSTANT: SSL_ERROR_NONE             0
CONSTANT: SSL_ERROR_SSL              1
CONSTANT: SSL_ERROR_WANT_READ        2
CONSTANT: SSL_ERROR_WANT_WRITE       3
CONSTANT: SSL_ERROR_WANT_X509_LOOKUP 4
CONSTANT: SSL_ERROR_SYSCALL          5 ! consult errno for details
CONSTANT: SSL_ERROR_ZERO_RETURN      6
CONSTANT: SSL_ERROR_WANT_CONNECT     7
CONSTANT: SSL_ERROR_WANT_ACCEPT      8

! Error messages table
: error-messages ( -- hash )
    H{
        { 0  "SSL_ERROR_NONE" }
        { 1  "SSL_ERROR_SSL" }
        { 2  "SSL_ERROR_WANT_READ" }
        { 3  "SSL_ERROR_WANT_WRITE" }
        { 4  "SSL_ERROR_WANT_X509_LOOKUP" }
        { 5  "SSL_ERROR_SYSCALL" }
        { 6  "SSL_ERROR_ZERO_RETURN" }
        { 7  "SSL_ERROR_WANT_CONNECT" }
        { 8  "SSL_ERROR_WANT_ACCEPT" }
    } ;

TYPEDEF: void* ssl-method
TYPEDEF: void* SSL_CTX*
TYPEDEF: void* SSL_SESSION*
TYPEDEF: void* SSL*

LIBRARY: libssl

! ===============================================
! ssl.h
! ===============================================

FUNCTION: char* SSL_get_version ( SSL* ssl ) ;

! Maps OpenSSL errors to strings
FUNCTION: void SSL_load_error_strings (  ) ;

! Must be called before any other action takes place
FUNCTION: int SSL_library_init (  ) ;

! Sets the default SSL version
FUNCTION: ssl-method SSLv2_client_method (  ) ;

FUNCTION: ssl-method SSLv23_client_method (  ) ;

FUNCTION: ssl-method SSLv23_server_method (  ) ;

FUNCTION: ssl-method SSLv23_method (  ) ; ! SSLv3 but can rollback to v2

FUNCTION: ssl-method SSLv3_client_method (  ) ;

FUNCTION: ssl-method SSLv3_server_method (  ) ;

FUNCTION: ssl-method SSLv3_method (  ) ;

FUNCTION: ssl-method TLSv1_client_method (  ) ;

FUNCTION: ssl-method TLSv1_server_method (  ) ;

FUNCTION: ssl-method TLSv1_method (  ) ;

! Creates the context
FUNCTION: SSL_CTX* SSL_CTX_new ( ssl-method method ) ;

! Load the certificates and private keys into the SSL_CTX
FUNCTION: int SSL_CTX_use_certificate_chain_file ( SSL_CTX* ctx,
                                                   char* file ) ; ! PEM type

FUNCTION: SSL* SSL_new ( SSL_CTX* ctx ) ;

FUNCTION: int SSL_set_fd ( SSL* ssl, int fd ) ;

FUNCTION: void SSL_set_bio ( SSL* ssl, void* rbio, void* wbio ) ;

FUNCTION: int SSL_set_session ( SSL* to, SSL_SESSION* session ) ;

FUNCTION: int SSL_get_error ( SSL* ssl, int ret ) ;

FUNCTION: void SSL_set_connect_state ( SSL* ssl ) ;

FUNCTION: void SSL_set_accept_state ( SSL* ssl ) ;

FUNCTION: int SSL_connect ( SSL* ssl ) ;

FUNCTION: int SSL_accept ( SSL* ssl ) ;

FUNCTION: int SSL_write ( SSL* ssl, void* buf, int num ) ;

FUNCTION: int SSL_read ( SSL* ssl, void* buf, int num ) ;

FUNCTION: int SSL_shutdown ( SSL* ssl ) ;

CONSTANT: SSL_SENT_SHUTDOWN 1
CONSTANT: SSL_RECEIVED_SHUTDOWN 2

FUNCTION: int SSL_get_shutdown ( SSL* ssl ) ;

FUNCTION: int SSL_CTX_set_session_id_context ( SSL_CTX* ctx, char* sid_ctx, uint len ) ;

FUNCTION: SSL_SESSION* SSL_get1_session ( SSL* ssl ) ;

FUNCTION: void SSL_free ( SSL* ssl ) ;

FUNCTION: void SSL_SESSION_free ( SSL_SESSION* ses ) ;

FUNCTION: int SSL_want ( SSL* ssl ) ;

CONSTANT: SSL_NOTHING 1
CONSTANT: SSL_WRITING 2
CONSTANT: SSL_READING 3
CONSTANT: SSL_X509_LOOKUP 4

FUNCTION: long SSL_get_verify_result ( SSL* ssl ) ;

FUNCTION: X509* SSL_get_peer_certificate ( SSL* s ) ;

FUNCTION: void SSL_CTX_free ( SSL_CTX* ctx ) ;

FUNCTION: void RAND_seed ( void* buf, int num ) ;

FUNCTION: int SSL_set_cipher_list ( SSL* ssl, char* str ) ;

FUNCTION: int SSL_use_RSAPrivateKey_file ( SSL* ssl, char* str ) ;

FUNCTION: int SSL_CTX_use_RSAPrivateKey_file ( SSL_CTX* ctx, int type ) ;

FUNCTION: int SSL_use_certificate_file ( SSL* ssl,
                                         char* str, int type ) ;

FUNCTION: int SSL_CTX_load_verify_locations ( SSL_CTX* ctx, char* CAfile,
                                              char* CApath ) ;

FUNCTION: int SSL_CTX_set_default_verify_paths ( SSL_CTX* ctx ) ;

CONSTANT: SSL_VERIFY_NONE 0
CONSTANT: SSL_VERIFY_PEER 1
CONSTANT: SSL_VERIFY_FAIL_IF_NO_PEER_CERT 2
CONSTANT: SSL_VERIFY_CLIENT_ONCE 4

FUNCTION: void SSL_CTX_set_verify ( SSL_CTX* ctx, int mode, void* callback ) ;

FUNCTION: void SSL_CTX_set_client_CA_list ( SSL_CTX* ctx, SSL* list ) ;

FUNCTION: SSL* SSL_load_client_CA_file ( char* file ) ;

! Used to manipulate settings of the SSL_CTX and SSL objects.
! This function should never be called directly
FUNCTION: long SSL_CTX_ctrl ( SSL_CTX* ctx, int cmd, long larg, void* parg ) ;

FUNCTION: void SSL_CTX_set_default_passwd_cb ( SSL_CTX* ctx, void* cb ) ;

FUNCTION: void SSL_CTX_set_default_passwd_cb_userdata ( SSL_CTX* ctx,
                                                        void* u ) ;

FUNCTION: int SSL_CTX_use_PrivateKey_file ( SSL_CTX* ctx, char* file,
                                            int type ) ;

! Sets the maximum depth for the allowed ctx certificate chain verification
FUNCTION: void SSL_CTX_set_verify_depth ( SSL_CTX* ctx, int depth ) ;

! Sets DH parameters to be used to be dh.
! The key is inherited by all ssl objects created from ctx
FUNCTION: void SSL_CTX_set_tmp_dh_callback ( SSL_CTX* ctx, void* dh ) ;

FUNCTION: void SSL_CTX_set_tmp_rsa_callback ( SSL_CTX* ctx, void* rsa ) ;

FUNCTION: void* BIO_f_ssl (  ) ;

: SSL_CTX_set_tmp_rsa ( ctx rsa -- n )
    [ SSL_CTRL_SET_TMP_RSA 0 ] dip SSL_CTX_ctrl ;

: SSL_CTX_set_tmp_dh ( ctx dh -- n )
    [ SSL_CTRL_SET_TMP_DH 0 ] dip SSL_CTX_ctrl ;

: SSL_CTX_set_session_cache_mode ( ctx mode -- n )
    [ SSL_CTRL_SET_SESS_CACHE_MODE ] dip f SSL_CTX_ctrl ;

CONSTANT: SSL_SESS_CACHE_OFF    HEX: 0000
CONSTANT: SSL_SESS_CACHE_CLIENT HEX: 0001
CONSTANT: SSL_SESS_CACHE_SERVER HEX: 0002

: SSL_SESS_CACHE_BOTH ( -- n )
    { SSL_SESS_CACHE_CLIENT SSL_SESS_CACHE_SERVER } flags ; inline

CONSTANT: SSL_SESS_CACHE_NO_AUTO_CLEAR      HEX: 0080
CONSTANT: SSL_SESS_CACHE_NO_INTERNAL_LOOKUP HEX: 0100
CONSTANT: SSL_SESS_CACHE_NO_INTERNAL_STORE  HEX: 0200

: SSL_SESS_CACHE_NO_INTERNAL ( -- n )
    { SSL_SESS_CACHE_NO_INTERNAL_LOOKUP SSL_SESS_CACHE_NO_INTERNAL_STORE } flags ; inline

! ===============================================
! x509.h
! ===============================================

TYPEDEF: void* X509_NAME*

TYPEDEF: void* X509*

FUNCTION: int X509_NAME_get_text_by_NID ( X509_NAME* name, int nid, void* buf, int len ) ;
FUNCTION: X509_NAME* X509_get_subject_name ( X509* a ) ;

! ===============================================
! x509_vfy.h
! ===============================================

<<

SYMBOL: verify-messages

H{ } clone verify-messages set-global

: verify-message ( n -- word ) verify-messages get-global at ;

SYNTAX: X509_V_:
    scan "X509_V_" prepend create-in
    scan-word
    [ 1quotation (( -- value )) define-inline ]
    [ verify-messages get set-at ]
    2bi ;

>>

X509_V_: OK 0
X509_V_: ERR_UNABLE_TO_GET_ISSUER_CERT 2
X509_V_: ERR_UNABLE_TO_GET_CRL 3
X509_V_: ERR_UNABLE_TO_DECRYPT_CERT_SIGNATURE 4
X509_V_: ERR_UNABLE_TO_DECRYPT_CRL_SIGNATURE 5
X509_V_: ERR_UNABLE_TO_DECODE_ISSUER_PUBLIC_KEY 6
X509_V_: ERR_CERT_SIGNATURE_FAILURE 7
X509_V_: ERR_CRL_SIGNATURE_FAILURE 8
X509_V_: ERR_CERT_NOT_YET_VALID 9
X509_V_: ERR_CERT_HAS_EXPIRED 10
X509_V_: ERR_CRL_NOT_YET_VALID 11
X509_V_: ERR_CRL_HAS_EXPIRED 12
X509_V_: ERR_ERROR_IN_CERT_NOT_BEFORE_FIELD 13
X509_V_: ERR_ERROR_IN_CERT_NOT_AFTER_FIELD 14
X509_V_: ERR_ERROR_IN_CRL_LAST_UPDATE_FIELD 15
X509_V_: ERR_ERROR_IN_CRL_NEXT_UPDATE_FIELD 16
X509_V_: ERR_OUT_OF_MEM 17
X509_V_: ERR_DEPTH_ZERO_SELF_SIGNED_CERT 18
X509_V_: ERR_SELF_SIGNED_CERT_IN_CHAIN 19
X509_V_: ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY 20
X509_V_: ERR_UNABLE_TO_VERIFY_LEAF_SIGNATURE 21
X509_V_: ERR_CERT_CHAIN_TOO_LONG 22
X509_V_: ERR_CERT_REVOKED 23
X509_V_: ERR_INVALID_CA 24
X509_V_: ERR_PATH_LENGTH_EXCEEDED 25
X509_V_: ERR_INVALID_PURPOSE 26
X509_V_: ERR_CERT_UNTRUSTED 27
X509_V_: ERR_CERT_REJECTED 28
X509_V_: ERR_SUBJECT_ISSUER_MISMATCH 29
X509_V_: ERR_AKID_SKID_MISMATCH 30
X509_V_: ERR_AKID_ISSUER_SERIAL_MISMATCH 31
X509_V_: ERR_KEYUSAGE_NO_CERTSIGN 32
X509_V_: ERR_UNABLE_TO_GET_CRL_ISSUER 33
X509_V_: ERR_UNHANDLED_CRITICAL_EXTENSION 34
X509_V_: ERR_KEYUSAGE_NO_CRL_SIGN 35
X509_V_: ERR_UNHANDLED_CRITICAL_CRL_EXTENSION 36
X509_V_: ERR_INVALID_NON_CA 37
X509_V_: ERR_PROXY_PATH_LENGTH_EXCEEDED 38
X509_V_: ERR_KEYUSAGE_NO_DIGITAL_SIGNATURE 39
X509_V_: ERR_PROXY_CERTIFICATES_NOT_ALLOWED 40
X509_V_: ERR_APPLICATION_VERIFICATION 50

! ===============================================
! obj_mac.h
! ===============================================

CONSTANT: NID_commonName 13
