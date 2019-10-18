! Copyright (C) 2007 Elie CHAFTARI
! Portions copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.libraries
alien.parser alien.syntax classes.struct combinators kernel literals
namespaces openssl.libcrypto system ;

IN: openssl.libssl

<< "libssl" {
    { [ os windows? ] [ "libssl-38.dll" ] }
    { [ os macosx? ] [ "libssl.dylib" ] }
    { [ os unix? ] [ "libssl.so" ] }
} cond cdecl add-library >>

CONSTANT: X509_FILETYPE_PEM       1
CONSTANT: X509_FILETYPE_ASN1      2
CONSTANT: X509_FILETYPE_DEFAULT   3

ALIAS: SSL_FILETYPE_ASN1 X509_FILETYPE_ASN1
ALIAS: SSL_FILETYPE_PEM  X509_FILETYPE_PEM

CONSTANT: SSL_SENT_SHUTDOWN 1
CONSTANT: SSL_RECEIVED_SHUTDOWN 2

CONSTANT: SSL_NOTHING 1
CONSTANT: SSL_WRITING 2
CONSTANT: SSL_READING 3
CONSTANT: SSL_X509_LOOKUP 4

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
CONSTANT: SSL_CTRL_SET_MAX_SEND_FRAGMENT    52
CONSTANT: SSL_CTRL_SET_TLSEXT_SERVERNAME_CB       53
CONSTANT: SSL_CTRL_SET_TLSEXT_SERVERNAME_ARG      54
CONSTANT: SSL_CTRL_SET_TLSEXT_HOSTNAME            55
CONSTANT: SSL_CTRL_SET_TLSEXT_DEBUG_CB            56
CONSTANT: SSL_CTRL_SET_TLSEXT_DEBUG_ARG           57
CONSTANT: SSL_CTRL_GET_TLSEXT_TICKET_KEYS         58
CONSTANT: SSL_CTRL_SET_TLSEXT_TICKET_KEYS         59
CONSTANT: SSL_CTRL_SET_TLSEXT_OPAQUE_PRF_INPUT_CB 61
CONSTANT: SSL_CTRL_SET_TLSEXT_OPAQUE_PRF_INPUT_CB_ARG 62
CONSTANT: SSL_CTRL_SET_TLSEXT_STATUS_REQ_CB       63
CONSTANT: SSL_CTRL_SET_TLSEXT_STATUS_REQ_CB_ARG   64
CONSTANT: SSL_CTRL_SET_TLSEXT_STATUS_REQ_TYPE     65
CONSTANT: SSL_CTRL_GET_TLSEXT_STATUS_REQ_EXTS     66
CONSTANT: SSL_CTRL_SET_TLSEXT_STATUS_REQ_EXTS     67
CONSTANT: SSL_CTRL_GET_TLSEXT_STATUS_REQ_IDS      68
CONSTANT: SSL_CTRL_SET_TLSEXT_STATUS_REQ_IDS      69
CONSTANT: SSL_CTRL_GET_TLSEXT_STATUS_REQ_OCSP_RESP        70
CONSTANT: SSL_CTRL_SET_TLSEXT_STATUS_REQ_OCSP_RESP        71
CONSTANT: SSL_CTRL_SET_TLSEXT_TICKET_KEY_CB               72
CONSTANT: SSL_CTRL_SET_TLS_EXT_SRP_USERNAME_CB            75
CONSTANT: SSL_CTRL_SET_SRP_VERIFY_PARAM_CB                76
CONSTANT: SSL_CTRL_SET_SRP_GIVE_CLIENT_PWD_CB             77
CONSTANT: SSL_CTRL_SET_SRP_ARG                            78
CONSTANT: SSL_CTRL_SET_TLS_EXT_SRP_USERNAME               79
CONSTANT: SSL_CTRL_SET_TLS_EXT_SRP_STRENGTH               80
CONSTANT: SSL_CTRL_SET_TLS_EXT_SRP_PASSWORD               81
CONSTANT: SSL_CTRL_TLS_EXT_SEND_HEARTBEAT                 85
CONSTANT: SSL_CTRL_GET_TLS_EXT_HEARTBEAT_PENDING          86
CONSTANT: SSL_CTRL_SET_TLS_EXT_HEARTBEAT_NO_REQUESTS      87
CONSTANT: SSL_CTRL_CHAIN                                  88
CONSTANT: SSL_CTRL_CHAIN_CERT                             89
CONSTANT: SSL_CTRL_GET_CURVES                             90
CONSTANT: SSL_CTRL_SET_CURVES                             91
CONSTANT: SSL_CTRL_SET_CURVES_LIST                        92
CONSTANT: SSL_CTRL_GET_SHARED_CURVE                       93
CONSTANT: SSL_CTRL_SET_ECDH_AUTO                          94
CONSTANT: SSL_CTRL_SET_SIGALGS                            97
CONSTANT: SSL_CTRL_SET_SIGALGS_LIST                       98
CONSTANT: SSL_CTRL_CERT_FLAGS                             99
CONSTANT: SSL_CTRL_CLEAR_CERT_FLAGS                       100
CONSTANT: SSL_CTRL_SET_CLIENT_SIGALGS                     101
CONSTANT: SSL_CTRL_SET_CLIENT_SIGALGS_LIST                102
CONSTANT: SSL_CTRL_GET_CLIENT_CERT_TYPES                  103
CONSTANT: SSL_CTRL_SET_CLIENT_CERT_TYPES                  104
CONSTANT: SSL_CTRL_BUILD_CERT_CHAIN                       105
CONSTANT: SSL_CTRL_SET_VERIFY_CERT_STORE                  106
CONSTANT: SSL_CTRL_SET_CHAIN_CERT_STORE                   107
CONSTANT: SSL_CTRL_GET_PEER_SIGNATURE_NID                 108
CONSTANT: SSL_CTRL_GET_SERVER_TMP_KEY                     109
CONSTANT: SSL_CTRL_GET_RAW_CIPHERLIST                     110
CONSTANT: SSL_CTRL_GET_EC_POINT_FORMATS                   111
CONSTANT: SSL_CTRL_GET_CHAIN_CERTS                        115
CONSTANT: SSL_CTRL_SELECT_CURRENT_CERT                    116
CONSTANT: SSL_CTRL_SET_CURRENT_CERT                       117
CONSTANT: SSL_CTRL_CHECK_PROTO_VERSION                    119
CONSTANT: DTLS_CTRL_SET_LINK_MTU                          120
CONSTANT: DTLS_CTRL_GET_LINK_MIN_MTU                      121

CONSTANT: TLSEXT_NAMETYPE_host_name 0
CONSTANT: TLSEXT_STATUSTYPE_ocsp 1

CONSTANT: TLSEXT_ECPOINTFORMAT_first                      0
CONSTANT: TLSEXT_ECPOINTFORMAT_uncompressed               0
CONSTANT: TLSEXT_ECPOINTFORMAT_ansiX962_compressed_prime  1
CONSTANT: TLSEXT_ECPOINTFORMAT_ansiX962_compressed_char2  2
CONSTANT: TLSEXT_ECPOINTFORMAT_last                       2

CONSTANT: TLSEXT_signature_anonymous                      0
CONSTANT: TLSEXT_signature_rsa                            1
CONSTANT: TLSEXT_signature_dsa                            2
CONSTANT: TLSEXT_signature_ecdsa                          3
CONSTANT: TLSEXT_signature_num                            4

CONSTANT: TLSEXT_hash_none                                0
CONSTANT: TLSEXT_hash_md5                                 1
CONSTANT: TLSEXT_hash_sha1                                2
CONSTANT: TLSEXT_hash_sha224                              3
CONSTANT: TLSEXT_hash_sha256                              4
CONSTANT: TLSEXT_hash_sha384                              5
CONSTANT: TLSEXT_hash_sha512                              6
CONSTANT: TLSEXT_hash_num                                 7

CONSTANT: TLSEXT_nid_unknown                              0x1000000

CONSTANT: SSL_OP_NO_SSLv2 0x01000000
CONSTANT: SSL_OP_NO_SSLv3 0x02000000
CONSTANT: SSL_OP_NO_TLSv1 0x04000000
CONSTANT: SSL_OP_NO_TLSv1_2 0x08000000
CONSTANT: SSL_OP_NO_TLSv1_1 0x10000000

CONSTANT: SSL_VERIFY_NONE 0
CONSTANT: SSL_VERIFY_PEER 1
CONSTANT: SSL_VERIFY_FAIL_IF_NO_PEER_CERT 2
CONSTANT: SSL_VERIFY_CLIENT_ONCE 4

CONSTANT: SSL_SESS_CACHE_OFF    0x0000
CONSTANT: SSL_SESS_CACHE_CLIENT 0x0001
CONSTANT: SSL_SESS_CACHE_SERVER 0x0002

CONSTANT: SSL_SESS_CACHE_BOTH flags{ SSL_SESS_CACHE_CLIENT SSL_SESS_CACHE_SERVER }

CONSTANT: SSL_SESS_CACHE_NO_AUTO_CLEAR      0x0080
CONSTANT: SSL_SESS_CACHE_NO_INTERNAL_LOOKUP 0x0100
CONSTANT: SSL_SESS_CACHE_NO_INTERNAL_STORE  0x0200

CONSTANT: SSL_SESS_CACHE_NO_INTERNAL
    flags{ SSL_SESS_CACHE_NO_INTERNAL_LOOKUP SSL_SESS_CACHE_NO_INTERNAL_STORE }

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

FUNCTION: int ASN1_STRING_cmp ( ASN1_STRING *a, ASN1_STRING *b )
FUNCTION: ASN1_VALUE* ASN1_item_d2i ( ASN1_VALUE** val, uchar **in, long len, ASN1_ITEM *it )

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

! ===============================================
! x509v3.h
! ===============================================
STRUCT: X509V3_EXT_METHOD
    { ext_nid int }
    { ext_flags int }
    { it void* } ;

FUNCTION: X509V3_EXT_METHOD* X509V3_EXT_get ( X509_EXTENSION* ext )

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

STRUCT: SSL
    { version int }
    { type int }
    { method ssl_method_st* }
    { rbio BIO* }
    { wbio BIO* }
    { bbio BIO* }
    { rwstate int }
    { in_handshake int }
    { handshake_func void* }
    { server int }
    { new_session int }
    { quiet_shutdown int }
    { shutdown int }
    { state int }
    { rstate int }
    { init_buf void* }
    { init_msg void* }
    { init_num int }
    { init_off int }
    { packet void* }
    { packet_length int }
    { s2 void* }
    { s3 void* }
    { d1 void* }
    { read_ahead int }
    { msg_callback void* }
    { msg_callback_arg void* }
    { hit int }
    { param void* }
    { cipher_list void* }
    { cipher_list_by_id void* }
    { mac_flags int }
    { enc_read_ctx void* }
    { read_hash void* }
    { expand void* }
    { enc_write_ctx void* }
    { write_hash void* }
    { compress void* }
    { cert void* }
    { sid_ctx_length uint }
    { sid_ctx void* }
    { session SSL_SESSION* }
    { generate_session_id void* }
    { verify_mode int }
    { verify_callback void* }
    { info_callback void* }
    { error int }
    { error_code int }
    { kssl_ctx void* }
    { psk_client_callback void* }
    { psk_server_callback void* }
    { ctx SSL_CTX* } ;

! ------------------------------------------------------------------------------
! API >= 1.1.0
! ------------------------------------------------------------------------------
CONSTANT: OPENSSL_INIT_NO_LOAD_CRYPTO_STRINGS 0x00000001
CONSTANT: OPENSSL_INIT_LOAD_CRYPTO_STRINGS    0x00000002
CONSTANT: OPENSSL_INIT_NO_LOAD_SSL_STRINGS    0x00100000
CONSTANT: OPENSSL_INIT_LOAD_SSL_STRINGS       0x00200000
CONSTANT: OPENSSL_INIT_ADD_ALL_CIPHERS        0x00000004
CONSTANT: OPENSSL_INIT_ADD_ALL_DIGESTS        0x00000008
CONSTANT: OPENSSL_INIT_NO_ADD_ALL_CIPHERS     0x00000010
CONSTANT: OPENSSL_INIT_NO_ADD_ALL_DIGESTS     0x00000020


FUNCTION: int OPENSSL_init_ssl ( uint64_t opts, void *settings )
! ------------------------------------------------------------------------------
! API < 1.1.0, removed in new versions
! ------------------------------------------------------------------------------
! Initialization functions
FUNCTION: int SSL_library_init (  )

! Maps OpenSSL errors to strings
FUNCTION: void SSL_load_error_strings (  )
! ------------------------------------------------------------------------------

! Sets the default SSL version
FUNCTION: ssl-method SSLv2_client_method (  )
FUNCTION: ssl-method SSLv23_client_method (  )
FUNCTION: ssl-method SSLv23_server_method (  )
FUNCTION: ssl-method SSLv23_method (  ) ! SSLv3 but can rollback to v2
FUNCTION: ssl-method SSLv3_client_method (  )
FUNCTION: ssl-method SSLv3_server_method (  )
FUNCTION: ssl-method SSLv3_method (  )
FUNCTION: ssl-method TLSv1_client_method (  )
FUNCTION: ssl-method TLSv1_server_method (  )
FUNCTION: ssl-method TLSv1_method (  )
FUNCTION: ssl-method TLSv1_1_method (  )
FUNCTION: ssl-method TLSv1_2_method (  )

FUNCTION: void SSL_SESSION_free ( SSL_SESSION* ses )
FUNCTION: void RAND_seed ( void* buf, int num )
FUNCTION: void* BIO_f_ssl (  )

! ------------------------------------------------------------------------------
! SSL
! ------------------------------------------------------------------------------
FUNCTION: c-string SSL_get_version ( SSL* ssl )

FUNCTION: c-string SSL_state_string ( SSL* ssl )
FUNCTION: c-string SSL_rstate_string ( SSL* ssl )
FUNCTION: c-string SSL_state_string_long ( SSL* ssl )
FUNCTION: c-string SSL_rstate_string_long ( SSL* ssl )

FUNCTION: int SSL_set_fd ( SSL* ssl, int fd )

FUNCTION: void SSL_set_bio ( SSL* ssl, void* rbio, void* wbio )

FUNCTION: int SSL_set_session ( SSL* to, SSL_SESSION* session )
FUNCTION: SSL_SESSION* SSL_get_session ( SSL* to )
FUNCTION: SSL_SESSION* SSL_get1_session ( SSL* ssl )

FUNCTION: int SSL_get_error ( SSL* ssl, int ret )

FUNCTION: void SSL_set_connect_state ( SSL* ssl )

FUNCTION: void SSL_set_accept_state ( SSL* ssl )
FUNCTION: void SSL_free ( SSL* ssl )
DESTRUCTOR: SSL_free

FUNCTION: int SSL_accept ( SSL* ssl )
FUNCTION: int SSL_connect ( SSL* ssl )
FUNCTION: int SSL_read ( SSL* ssl, void* buf, int num )
FUNCTION: int SSL_write ( SSL* ssl, void* buf, int num )
FUNCTION: long SSL_ctrl ( SSL* ssl, int cmd, long larg, void* parg )

FUNCTION: int SSL_shutdown ( SSL* ssl )
FUNCTION: int SSL_get_shutdown ( SSL* ssl )

FUNCTION: int SSL_want ( SSL* ssl )
FUNCTION: long SSL_get_verify_result ( SSL* ssl )
FUNCTION: X509* SSL_get_peer_certificate ( SSL* s )

FUNCTION: int SSL_set_cipher_list ( SSL* ssl, c-string str )
FUNCTION: int SSL_use_RSAPrivateKey_file ( SSL* ssl, c-string str )
FUNCTION: int SSL_use_certificate_file ( SSL* ssl, c-string str, int type )

FUNCTION: SSL* SSL_load_client_CA_file ( c-string file )

! ------------------------------------------------------------------------------
! SSL_CTX
! ------------------------------------------------------------------------------
FUNCTION: SSL_CTX* SSL_CTX_new ( ssl-method method )
FUNCTION: void SSL_CTX_free ( SSL_CTX* ctx )
DESTRUCTOR: SSL_CTX_free

! Load the certificates and private keys into the SSL_CTX
FUNCTION: int SSL_CTX_use_certificate_chain_file ( SSL_CTX* ctx,
                                                   c-string file ) ! PEM type
FUNCTION: int SSL_CTX_use_certificate ( SSL_CTX* ctx, X509* x )

FUNCTION: SSL* SSL_new ( SSL_CTX* ctx )


FUNCTION: int SSL_CTX_set_default_verify_paths ( SSL_CTX* ctx )
FUNCTION: int SSL_CTX_set_session_id_context ( SSL_CTX* ctx,
                                               c-string sid_ctx,
                                               uint len )
FUNCTION: int SSL_CTX_use_RSAPrivateKey_file ( SSL_CTX* ctx, int type )
FUNCTION: int SSL_CTX_load_verify_locations ( SSL_CTX* ctx,
                                              c-string CAfile,
                                              c-string CApath )
FUNCTION: void SSL_CTX_set_verify ( SSL_CTX* ctx, int mode, void* callback )
FUNCTION: void SSL_CTX_set_client_CA_list ( SSL_CTX* ctx, SSL* list )

! Used to manipulate settings of the SSL_CTX and SSL objects.
! This function should never be called directly
FUNCTION: long SSL_CTX_ctrl ( SSL_CTX* ctx, int cmd, long larg, void* parg )

FUNCTION: void SSL_CTX_set_default_passwd_cb ( SSL_CTX* ctx, void* cb )

FUNCTION: void SSL_CTX_set_default_passwd_cb_userdata ( SSL_CTX* ctx,
                                                        void* u )

FUNCTION: int SSL_CTX_use_PrivateKey_file ( SSL_CTX* ctx, c-string file,
                                            int type )

! Sets the maximum depth for the allowed ctx certificate chain verification
FUNCTION: void SSL_CTX_set_verify_depth ( SSL_CTX* ctx, int depth )

! Sets DH parameters to be used to be dh.
! The key is inherited by all ssl objects created from ctx
FUNCTION: void SSL_CTX_set_tmp_dh_callback ( SSL_CTX* ctx, void* dh )

FUNCTION: void SSL_CTX_set_tmp_rsa_callback ( SSL_CTX* ctx, void* rsa )

! ------------------------------------------------------------------------------
! Misc
! ------------------------------------------------------------------------------
: SSL_set_tlsext_host_name ( ctx hostname -- n )
    [ SSL_CTRL_SET_TLSEXT_HOSTNAME TLSEXT_NAMETYPE_host_name ] dip
    SSL_ctrl ;

: SSL_CTX_need_tmp_rsa ( ctx -- n )
    SSL_CTRL_NEED_TMP_RSA 0 f SSL_CTX_ctrl ;

: SSL_CTX_set_tmp_rsa ( ctx rsa -- n )
    [ SSL_CTRL_SET_TMP_RSA 0 ] dip SSL_CTX_ctrl ;

: SSL_CTX_set_tmp_dh ( ctx dh -- n )
    [ SSL_CTRL_SET_TMP_DH 0 ] dip SSL_CTX_ctrl ;

: SSL_CTX_set_session_cache_mode ( ctx mode -- n )
    [ SSL_CTRL_SET_SESS_CACHE_MODE ] dip f SSL_CTX_ctrl ;

! ===============================================
! x509_vfy.h
! ===============================================
ENUM: X509_V_ERROR
    X509_V_ERR_OK
    { X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT 2 }
    X509_V_ERR_UNABLE_TO_GET_CRL
    X509_V_ERR_UNABLE_TO_DECRYPT_CERT_SIGNATURE
    X509_V_ERR_UNABLE_TO_DECRYPT_CRL_SIGNATURE
    X509_V_ERR_UNABLE_TO_DECODE_ISSUER_PUBLIC_KEY
    X509_V_ERR_CERT_SIGNATURE_FAILURE
    X509_V_ERR_CRL_SIGNATURE_FAILURE
    X509_V_ERR_CERT_NOT_YET_VALID
    X509_V_ERR_CERT_HAS_EXPIRED
    X509_V_ERR_CRL_NOT_YET_VALID
    X509_V_ERR_CRL_HAS_EXPIRED
    X509_V_ERR_ERROR_IN_CERT_NOT_BEFORE_FIELD
    X509_V_ERR_ERROR_IN_CERT_NOT_AFTER_FIELD
    X509_V_ERR_ERROR_IN_CRL_LAST_UPDATE_FIELD
    X509_V_ERR_ERROR_IN_CRL_NEXT_UPDATE_FIELD
    X509_V_ERR_OUT_OF_MEM
    X509_V_ERR_DEPTH_ZERO_SELF_SIGNED_CERT
    X509_V_ERR_SELF_SIGNED_CERT_IN_CHAIN
    X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY
    X509_V_ERR_UNABLE_TO_VERIFY_LEAF_SIGNATURE
    X509_V_ERR_CERT_CHAIN_TOO_LONG
    X509_V_ERR_CERT_REVOKED
    X509_V_ERR_INVALID_CA
    X509_V_ERR_PATH_LENGTH_EXCEEDED
    X509_V_ERR_INVALID_PURPOSE
    X509_V_ERR_CERT_UNTRUSTED
    X509_V_ERR_CERT_REJECTED
    X509_V_ERR_SUBJECT_ISSUER_MISMATCH
    X509_V_ERR_AKID_SKID_MISMATCH
    X509_V_ERR_AKID_ISSUER_SERIAL_MISMATCH
    X509_V_ERR_KEYUSAGE_NO_CERTSIGN
    X509_V_ERR_UNABLE_TO_GET_CRL_ISSUER
    X509_V_ERR_UNHANDLED_CRITICAL_EXTENSION
    X509_V_ERR_KEYUSAGE_NO_CRL_SIGN
    X509_V_ERR_UNHANDLED_CRITICAL_CRL_EXTENSION
    X509_V_ERR_INVALID_NON_CA
    X509_V_ERR_PROXY_PATH_LENGTH_EXCEEDED
    X509_V_ERR_KEYUSAGE_NO_DIGITAL_SIGNATURE
    X509_V_ERR_PROXY_CERTIFICATES_NOT_ALLOWED
    { X509_V_ERR_APPLICATION_VERIFICATION 50 } ;

! ===============================================
! obj_mac.h
! ===============================================
CONSTANT: NID_commonName        13
CONSTANT: NID_subject_alt_name  85
CONSTANT: NID_issuer_alt_name   86

! ===============================================
! On Windows, some of the functions making up libressl
! are placed in libcrypto-37.dll
! ===============================================
<< os windows? [
    "libssl-windows"
    [ "libcrypto-37.dll" cdecl add-library ] [ current-library set ] bi
] when >>

! ===============================================
! x509.h
! ===============================================
CONSTANT: X509_R_CERT_ALREADY_IN_HASH_TABLE 101

FUNCTION: int X509_NAME_get_text_by_NID ( X509_NAME* name, int nid, void* buf, int len )
! X509_NAME_oneline could return c-string but needs to be freed with OPENSSL_free
FUNCTION: char* X509_NAME_oneline ( X509_NAME* a, char* buf, int size )

FUNCTION: int X509_get_ext_by_NID ( X509* a, int nid, int lastpos )
FUNCTION: void* X509_get_ext_d2i ( X509 *a, int nid, int* crit, int* idx )
FUNCTION: X509_NAME* X509_get_issuer_name ( X509* a )
FUNCTION: X509_NAME* X509_get_subject_name ( X509* a )
FUNCTION: int X509_check_trust ( X509* a, int id, int flags )
FUNCTION: X509_EXTENSION* X509_get_ext ( X509* a, int loc )
FUNCTION: void X509_free ( X509 *a )
DESTRUCTOR: X509_free
FUNCTION: X509* d2i_X509 ( X509** px, uchar** in, int len )
FUNCTION: int i2d_X509 ( X509* x, uchar** out )
FUNCTION: int i2d_re_X509_tbs ( X509* x, uchar** out )

C-TYPE: X509_STORE
FUNCTION: X509_STORE* X509_STORE_new ( )
FUNCTION: int X509_STORE_add_cert ( X509_STORE* ctx, X509* x )

! ------------------------------------------------------------------------------
! API >= 1.1.0
! ------------------------------------------------------------------------------
FUNCTION: int OPENSSL_sk_num ( _STACK *s )
FUNCTION: void* OPENSSL_sk_value ( _STACK *s, int v )

! ------------------------------------------------------------------------------
! API < 1.1.0, removed in new versions
! ------------------------------------------------------------------------------
FUNCTION: int sk_num ( _STACK *s )
FUNCTION: void* sk_value ( _STACK *s, int v )

! ------------------------------------------------------------------------------
