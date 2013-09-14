! Copyright (C) 2007 Elie CHAFTARI
! Portions copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax classes.struct combinators kernel
system namespaces assocs parser lexer sequences words
quotations math.bitwise alien.libraries literals ;

IN: openssl.libssl

<< {
    { [ os windows? ] [ "libssl" "ssleay32.dll" cdecl add-library ] }
    { [ os macosx? ] [ "libssl" "libssl.dylib" cdecl add-library ] }
    { [ os unix? ] [ "libssl" "libssl.so" cdecl add-library ] }
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

C-TYPE: SSL_CTX
C-TYPE: SSL_SESSION
C-TYPE: SSL

LIBRARY: libssl

! ===============================================
! stack.h
! ===============================================

STRUCT: stack_st
    { num int }
    { data char** }
    { sorted int }
    { num_alloc int }
    { comp void* } ;
TYPEDEF: stack_st _STACK

FUNCTION: int sk_num ( _STACK *s ) ;
FUNCTION: void* sk_value ( _STACK *s, int ) ;

! ===============================================
! asn1t.h
! ===============================================

C-TYPE: ASN1_ITEM

! ===============================================
! asn1.h
! ===============================================
C-TYPE: ASN1_VALUE
TYPEDEF: ASN1_ITEM ASN1_ITEM_EXP

STRUCT: ASN1_STRING
    { length int }
    { type int }
    { data uchar* }
    { flags long } ;

FUNCTION: int ASN1_STRING_cmp ( ASN1_STRING *a, ASN1_STRING *b ) ;

FUNCTION: ASN1_VALUE* ASN1_item_d2i ( ASN1_VALUE** val, uchar **in, long len, ASN1_ITEM *it ) ;

! ===============================================
! ossl_typ.h
! ===============================================
TYPEDEF: ASN1_STRING ASN1_OCTET_STRING

! ===============================================
! x509.h
! ===============================================

STRUCT: X509_EXTENSION
    { object void* }
    { critical void* }
    { value ASN1_OCTET_STRING* } ;

C-TYPE: X509_NAME
C-TYPE: X509

FUNCTION: int X509_NAME_get_text_by_NID ( X509_NAME* name, int nid, void* buf, int len ) ;
FUNCTION: int X509_get_ext_by_NID ( X509* a, int nid, int lastpos ) ;
FUNCTION: void* X509_get_ext_d2i ( X509 *a, int nid, int* crit, int* idx ) ;
FUNCTION: X509_NAME* X509_get_issuer_name ( X509* a ) ;
FUNCTION: X509_NAME* X509_get_subject_name ( X509* a ) ;
FUNCTION: int X509_check_trust ( X509* a, int id, int flags ) ;
FUNCTION: X509_EXTENSION* X509_get_ext ( X509* a, int loc ) ;

! ===============================================
! x509v3.h
! ===============================================

STRUCT: X509V3_EXT_METHOD
    { ext_nid int }
    { ext_flags int }
    { it void* } ;

FUNCTION: X509V3_EXT_METHOD* X509V3_EXT_get ( X509_EXTENSION* ext ) ;

UNION-STRUCT: GENERAL_NAME_st_d
    { ptr char* }
    { otherName void* }
    { rfc822Name void* }
    { dNSName ASN1_STRING* } ;

STRUCT: GENERAL_NAME_st
    { type int }
    { d GENERAL_NAME_st_d } ;

CONSTANT: GEN_OTHERNAME 0
CONSTANT: GEN_EMAIL     1
CONSTANT: GEN_DNS       2
CONSTANT: GEN_X400      3
CONSTANT: GEN_DIRNAME   4
CONSTANT: GEN_EDIPARTY  5
CONSTANT: GEN_URI       6
CONSTANT: GEN_IPADD     7
CONSTANT: GEN_RID       8

! ===============================================
! ssl.h
! ===============================================

STRUCT: ssl_method_st
    { version int }
    { ssl_new void* }
    { ssl_clear void* }
    { ssl_free void* }
    { ssl_accept void* }
    { ssl_connect void* }
    { ssl_read void* }
    { ssl_peek void* }
    { ssl_write void* }
    { ssl_shutdown void* }
    { ssl_renegotiate void* }
    { ssl_renegotiate_check void* }
    { ssl_get_message void* }
    { ssl_read_bytes void* }
    { ssl_write_bytes void* }
    { ssl_dispatch_alert void* }
    { ssl_ctrl void* }
    { ssl_ctx_ctrl void* }
    { get_cipher_by_char void* }
    { put_cipher_by_char void* }
    { ssl_pending void* }
    { num_ciphers void* }
    { get_cipher void* }
    { get_ssl_method void* }
    { get_timeout void* }
    { ssl3_enc void* }
    { ssl_version void* }
    { ssl_callback_ctrl void* }
    { ssl_ctx_callback_ctrl void* } ;
TYPEDEF: ssl_method_st* ssl-method

FUNCTION: c-string SSL_get_version ( SSL* ssl ) ;

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
                                                   c-string file ) ; ! PEM type

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

FUNCTION: int SSL_CTX_set_session_id_context ( SSL_CTX* ctx, c-string sid_ctx, uint len ) ;

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

FUNCTION: int SSL_set_cipher_list ( SSL* ssl, c-string str ) ;

FUNCTION: int SSL_use_RSAPrivateKey_file ( SSL* ssl, c-string str ) ;

FUNCTION: int SSL_CTX_use_RSAPrivateKey_file ( SSL_CTX* ctx, int type ) ;

FUNCTION: int SSL_use_certificate_file ( SSL* ssl,
                                         c-string str, int type ) ;

FUNCTION: int SSL_CTX_load_verify_locations ( SSL_CTX* ctx, c-string CAfile,
                                              c-string CApath ) ;

FUNCTION: int SSL_CTX_set_default_verify_paths ( SSL_CTX* ctx ) ;

CONSTANT: SSL_VERIFY_NONE 0
CONSTANT: SSL_VERIFY_PEER 1
CONSTANT: SSL_VERIFY_FAIL_IF_NO_PEER_CERT 2
CONSTANT: SSL_VERIFY_CLIENT_ONCE 4

FUNCTION: void SSL_CTX_set_verify ( SSL_CTX* ctx, int mode, void* callback ) ;

FUNCTION: void SSL_CTX_set_client_CA_list ( SSL_CTX* ctx, SSL* list ) ;

FUNCTION: SSL* SSL_load_client_CA_file ( c-string file ) ;

! Used to manipulate settings of the SSL_CTX and SSL objects.
! This function should never be called directly
FUNCTION: long SSL_CTX_ctrl ( SSL_CTX* ctx, int cmd, long larg, void* parg ) ;

FUNCTION: void SSL_CTX_set_default_passwd_cb ( SSL_CTX* ctx, void* cb ) ;

FUNCTION: void SSL_CTX_set_default_passwd_cb_userdata ( SSL_CTX* ctx,
                                                        void* u ) ;

FUNCTION: int SSL_CTX_use_PrivateKey_file ( SSL_CTX* ctx, c-string file,
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

CONSTANT: SSL_SESS_CACHE_OFF    0x0000
CONSTANT: SSL_SESS_CACHE_CLIENT 0x0001
CONSTANT: SSL_SESS_CACHE_SERVER 0x0002

CONSTANT: SSL_SESS_CACHE_BOTH flags{ SSL_SESS_CACHE_CLIENT SSL_SESS_CACHE_SERVER }

CONSTANT: SSL_SESS_CACHE_NO_AUTO_CLEAR      0x0080
CONSTANT: SSL_SESS_CACHE_NO_INTERNAL_LOOKUP 0x0100
CONSTANT: SSL_SESS_CACHE_NO_INTERNAL_STORE  0x0200

CONSTANT: SSL_SESS_CACHE_NO_INTERNAL
    flags{ SSL_SESS_CACHE_NO_INTERNAL_LOOKUP SSL_SESS_CACHE_NO_INTERNAL_STORE }

! ===============================================
! x509_vfy.h
! ===============================================

<<

SYMBOL: verify-messages

H{ } clone verify-messages set-global

: verify-message ( n -- word ) verify-messages get-global at ;

SYNTAX: X509_V_:
    scan-token "X509_V_" prepend create-in
    scan-number
    [ 1quotation ( -- value ) define-inline ]
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

CONSTANT: NID_commonName        13
CONSTANT: NID_subject_alt_name  85
CONSTANT: NID_issuer_alt_name   86
