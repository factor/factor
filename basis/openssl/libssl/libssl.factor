! Copyright (C) 2007 Elie CHAFTARI
! Portions copyright (C) 2008 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.libraries
alien.libraries.finder alien.parser alien.syntax classes.struct
combinators kernel literals namespaces openssl.libcrypto
sequences system words ;
IN: openssl.libssl

C-LIBRARY: libssl {
    { windows $[ cpu x86.64 = "-x64" "" ? "libssl-3" ".dll" surround ] }
    { macos "libssl.35.dylib" }
    { unix "libssl.so" }
}

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
CONSTANT: SSL_CTRL_GET_EXTMS_SUPPORT                      122
CONSTANT: SSL_CTRL_SET_MIN_PROTO_VERSION                  123
CONSTANT: SSL_CTRL_SET_MAX_PROTO_VERSION                  124
CONSTANT: SSL_CTRL_SET_SPLIT_SEND_FRAGMENT                125
CONSTANT: SSL_CTRL_SET_MAX_PIPELINES                      126
CONSTANT: SSL_CTRL_GET_TLSEXT_STATUS_REQ_TYPE             127
CONSTANT: SSL_CTRL_GET_TLSEXT_STATUS_REQ_CB               128
CONSTANT: SSL_CTRL_GET_TLSEXT_STATUS_REQ_CB_ARG           129
CONSTANT: SSL_CTRL_GET_MIN_PROTO_VERSION                  130
CONSTANT: SSL_CTRL_GET_MAX_PROTO_VERSION                  131
CONSTANT: SSL_CTRL_GET_SIGNATURE_NID                      132
CONSTANT: SSL_CTRL_GET_TMP_KEY                            133
CONSTANT: SSL_CTRL_GET_NEGOTIATED_GROUP                   134
CONSTANT: SSL_CTRL_SET_RETRY_VERIFY                       136

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

CONSTANT: SSL_OP_NO_EXTENDED_MASTER_SECRET 0x00000001
CONSTANT: SSL_OP_CLEANSE_PLAINTEXT 0x00000002
CONSTANT: SSL_OP_LEGACY_SERVER_CONNECT 0x00000004
CONSTANT: SSL_OP_ENABLE_KTLS 0x00000008
CONSTANT: SSL_OP_TLSEXT_PADDING 0x00000010
CONSTANT: SSL_OP_SAFARI_ECDHE_ECDSA_BUG 0x00000040
CONSTANT: SSL_OP_IGNORE_UNEXPECTED_EOF 0x00000080
CONSTANT: SSL_OP_ALLOW_CLIENT_RENEGOTIATION 0x00000100
CONSTANT: SSL_OP_DISABLE_TLSEXT_CA_NAMES 0x00000200
CONSTANT: SSL_OP_ALLOW_NO_DHE_KEX 0x00000400
CONSTANT: SSL_OP_DONT_INSERT_EMPTY_FRAGMENTS 0x00000800
CONSTANT: SSL_OP_NO_QUERY_MTU 0x00001000
CONSTANT: SSL_OP_COOKIE_EXCHANGE 0x00002000
CONSTANT: SSL_OP_NO_TICKET 0x00004000
CONSTANT: SSL_OP_CISCO_ANYCONNECT 0x00008000
CONSTANT: SSL_OP_NO_SESSION_RESUMPTION_ON_RENEGOTIATION 0x00010000
CONSTANT: SSL_OP_NO_COMPRESSION 0x00020000
CONSTANT: SSL_OP_ALLOW_UNSAFE_LEGACY_RENEGOTIATION 0x00040000
CONSTANT: SSL_OP_NO_ENCRYPT_THEN_MAC 0x00080000
CONSTANT: SSL_OP_ENABLE_MIDDLEBOX_COMPAT 0x00100000
CONSTANT: SSL_OP_PRIORITIZE_CHACHA 0x00200000
CONSTANT: SSL_OP_CIPHER_SERVER_PREFERENCE 0x00400000
CONSTANT: SSL_OP_TLS_ROLLBACK_BUG 0x00800000
CONSTANT: SSL_OP_NO_ANTI_REPLAY 0x01000000
CONSTANT: SSL_OP_NO_SSLv3 0x02000000
CONSTANT: SSL_OP_NO_TLSv1 0x04000000
CONSTANT: SSL_OP_NO_TLSv1_2 0x08000000
CONSTANT: SSL_OP_NO_TLSv1_1 0x10000000
CONSTANT: SSL_OP_NO_TLSv1_3 0x20000000
CONSTANT: SSL_OP_NO_DTLSv1 0x04000000
CONSTANT: SSL_OP_NO_DTLSv1_2 0x08000000
CONSTANT: SSL_OP_NO_RENEGOTIATION 0x40000000
CONSTANT: SSL_OP_CRYPTOPRO_TLSEXT_BUG 0x80000000
CONSTANT: SSL_OP_NO_TX_CERTIFICATE_COMPRESSION 0x100000000
CONSTANT: SSL_OP_NO_RX_CERTIFICATE_COMPRESSION 0x200000000
CONSTANT: SSL_OP_ENABLE_KTLS_TX_ZEROCOPY_SENDFILE 0x400000000

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

CONSTANT: SSL_ERROR_NONE                  0
CONSTANT: SSL_ERROR_SSL                   1
CONSTANT: SSL_ERROR_WANT_READ             2
CONSTANT: SSL_ERROR_WANT_WRITE            3
CONSTANT: SSL_ERROR_WANT_X509_LOOKUP      4
CONSTANT: SSL_ERROR_SYSCALL               5 ! consult errno for details
CONSTANT: SSL_ERROR_ZERO_RETURN           6
CONSTANT: SSL_ERROR_WANT_CONNECT          7
CONSTANT: SSL_ERROR_WANT_ACCEPT           8
CONSTANT: SSL_ERROR_WANT_ASYNC            9
CONSTANT: SSL_ERROR_WANT_ASYNC_JOB       10
CONSTANT: SSL_ERROR_WANT_CLIENT_HELLO_CB 11
CONSTANT: SSL_ERROR_WANT_RETRY_VERIFY    12

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

ENUM: OSSL_HANDSHAKE_STATE
    { TLS_ST_BEFORE 0 }
    { TLS_ST_OK 1 }
    { DTLS_ST_CR_HELLO_VERIFY_REQUEST 2 }
    { TLS_ST_CR_SRVR_HELLO 3 }
    { TLS_ST_CR_CERT 4 }
    { TLS_ST_CR_COMP_CERT 5 }
    { TLS_ST_CR_CERT_STATUS 6 }
    { TLS_ST_CR_KEY_EXCH 7 }
    { TLS_ST_CR_CERT_REQ 8 }
    { TLS_ST_CR_SRVR_DONE 9 }
    { TLS_ST_CR_SESSION_TICKET 10 }
    { TLS_ST_CR_CHANGE 11 }
    { TLS_ST_CR_FINISHED 12 }
    { TLS_ST_CW_CLNT_HELLO 13 }
    { TLS_ST_CW_CERT 14 }
    { TLS_ST_CW_COMP_CERT 15 }
    { TLS_ST_CW_KEY_EXCH 16 }
    { TLS_ST_CW_CERT_VRFY 17 }
    { TLS_ST_CW_CHANGE 18 }
    { TLS_ST_CW_NEXT_PROTO 19 }
    { TLS_ST_CW_FINISHED 20 }
    { TLS_ST_SW_HELLO_REQ 21 }
    { TLS_ST_SR_CLNT_HELLO 22 }
    { DTLS_ST_SW_HELLO_VERIFY_REQUEST 23 }
    { TLS_ST_SW_SRVR_HELLO 24 }
    { TLS_ST_SW_CERT 25 }
    { TLS_ST_SW_COMP_CERT 26 }
    { TLS_ST_SW_KEY_EXCH 27 }
    { TLS_ST_SW_CERT_REQ 28 }
    { TLS_ST_SW_SRVR_DONE 29 }
    { TLS_ST_SR_CERT 30 }
    { TLS_ST_SR_COMP_CERT 31 }
    { TLS_ST_SR_KEY_EXCH 32 }
    { TLS_ST_SR_CERT_VRFY 33 }
    { TLS_ST_SR_NEXT_PROTO 34 }
    { TLS_ST_SR_CHANGE 35 }
    { TLS_ST_SR_FINISHED 36 }
    { TLS_ST_SW_SESSION_TICKET 37 }
    { TLS_ST_SW_CERT_STATUS 38 }
    { TLS_ST_SW_CHANGE 39 }
    { TLS_ST_SW_FINISHED 40 }
    { TLS_ST_SW_ENCRYPTED_EXTENSIONS 41 }
    { TLS_ST_CR_ENCRYPTED_EXTENSIONS 42 }
    { TLS_ST_CR_CERT_VRFY 43 }
    { TLS_ST_SW_CERT_VRFY 44 }
    { TLS_ST_CR_HELLO_REQ 45 }
    { TLS_ST_SW_KEY_UPDATE 46 }
    { TLS_ST_CW_KEY_UPDATE 47 }
    { TLS_ST_SR_KEY_UPDATE 48 }
    { TLS_ST_CR_KEY_UPDATE 49 }
    { TLS_ST_EARLY_DATA 50 }
    { TLS_ST_PENDING_EARLY_DATA_END 51 }
    { TLS_ST_CW_END_OF_EARLY_DATA 52 }
    { TLS_ST_SR_END_OF_EARLY_DATA 53 } ;

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

FUNCTION: int ASN1_STRING_cmp ( ASN1_STRING* a, ASN1_STRING* b )
FUNCTION: ASN1_VALUE* ASN1_item_d2i ( ASN1_VALUE** val, uchar** in, long len, ASN1_ITEM* it )

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


FUNCTION: int OPENSSL_init_ssl ( uint64_t opts, void* settings )
! ------------------------------------------------------------------------------
! API < 1.1.0, removed in new versions
! ------------------------------------------------------------------------------
! Initialization functions
FUNCTION: int SSL_library_init ( )

! Maps OpenSSL errors to strings
FUNCTION: void SSL_load_error_strings ( )
! ------------------------------------------------------------------------------

! Sets the default SSL version (deprecated)
FUNCTION: ssl-method SSLv2_client_method ( )
FUNCTION: ssl-method SSLv23_client_method ( )
FUNCTION: ssl-method SSLv23_server_method ( )
FUNCTION: ssl-method SSLv23_method ( ) ! SSLv3 but can rollback to v2
FUNCTION: ssl-method SSLv3_client_method ( )
FUNCTION: ssl-method SSLv3_server_method ( )
FUNCTION: ssl-method SSLv3_method ( )
FUNCTION: ssl-method TLSv1_client_method ( )
FUNCTION: ssl-method TLSv1_server_method ( )
FUNCTION: ssl-method TLSv1_method ( )
FUNCTION: ssl-method TLSv1_1_method ( )
FUNCTION: ssl-method TLSv1_2_method ( )
! Preferred, uses TLSv1.3 if available
FUNCTION: ssl-method TLS_method ( )
FUNCTION: ssl-method TLS_client_method ( )
FUNCTION: ssl-method TLS_server_method ( )

CONSTANT: DTLS1_VERSION_MAJOR 0xfe
CONSTANT: SSL3_VERSION_MAJOR 0x03
CONSTANT: SSL3_VERSION 0x0300
CONSTANT: TLS1_VERSION 0x0301
CONSTANT: TLS1_1_VERSION 0x0302
CONSTANT: TLS1_2_VERSION 0x0303
CONSTANT: TLS1_3_VERSION 0x0304
CONSTANT: DTLS1_VERSION 0xfeff
CONSTANT: DTLS1_2_VERSION 0xfefd

FUNCTION: int SSL_CTX_set_min_proto_version ( SSL_CTX* ctx, uint16_t version )
FUNCTION: int SSL_CTX_set_max_proto_version ( SSL_CTX* ctx, uint16_t version )
FUNCTION: uint16_t SSL_CTX_get_min_proto_version ( SSL_CTX* ctx )
FUNCTION: uint16_t SSL_CTX_get_max_proto_version ( SSL_CTX* ctx )

FUNCTION: int SSL_set_min_proto_version ( SSL* ssl, uint16_t version )
FUNCTION: int SSL_set_max_proto_version ( SSL* ssl, uint16_t version )
FUNCTION: uint16_t SSL_get_min_proto_version ( SSL* ssl )
FUNCTION: uint16_t SSL_get_max_proto_version ( SSL* ssl )

FUNCTION: int SSL_version ( SSL *ssl )

FUNCTION: void SSL_SESSION_free ( SSL_SESSION* ses )
FUNCTION: void RAND_seed ( void* buf, int num )
FUNCTION: void* BIO_f_ssl ( )

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
FUNCTION: int SSL_write_ex ( SSL* ssl, void* buf, size_t num, size_t* written )
FUNCTION: long SSL_ctrl ( SSL* ssl, int cmd, long larg, void* parg )

FUNCTION: int SSL_shutdown ( SSL* ssl )
FUNCTION: int SSL_get_shutdown ( SSL* ssl )

FUNCTION: int SSL_want ( SSL* ssl )
FUNCTION: long SSL_get_verify_result ( SSL* ssl )
FUNCTION: X509* SSL_get_peer_certificate ( SSL* ssl )
FUNCTION: X509* SSL_get0_peer_certificate ( SSL* ssl )
FUNCTION: X509* SSL_get1_peer_certificate ( SSL* ssl )

: get-ssl-peer-certificate ( ssl -- x509 )
    "SSL_get1_peer_certificate" "libssl" library-dll dlsym
    [ SSL_get1_peer_certificate ] [ SSL_get_peer_certificate ] if ; inline

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

FUNCTION: ulong SSL_CTX_set_options ( SSL_CTX* ctx, ulong options )
FUNCTION: ulong SSL_set_options ( SSL* ssl, ulong options )

FUNCTION: ulong SSL_CTX_clear_options ( SSL_CTX* ctx, ulong options )
FUNCTION: ulong SSL_clear_options ( SSL* ssl, ulong options )

FUNCTION: ulong SSL_CTX_get_options ( SSL_CTX* ctx )
FUNCTION: ulong SSL_get_options ( SSL* ssl )

FUNCTION: ulong SSL_get_secure_renegotiation_support ( SSL* ssl )

! -----------------------------
! tls alpn extension
! -----------------------------

! values from https://github.com/openssl/openssl/blob/master/include/openssl/tls1.h
CONSTANT: SSL_TLSEXT_ERR_OK 0
CONSTANT: SSL_TLSEXT_ERR_ALERT_FATAL 2
CONSTANT: SSL_TLSEXT_ERR_NOACK 3
! values from https://github.com/openssl/openssl/blob/master/include/openssl/ssl.h.in
CONSTANT: OPENSSL_NPN_UNSUPPORTED 0
CONSTANT: OPENSSL_NPN_NEGOTIATED 1
CONSTANT: OPENSSL_NPN_NO_OVERLAP 2

! callback type
! CALLBACK: int SSL_CTX_alpn_select_cb_func ( SSL* ssl, const
! unsigned c-string* out, uchar* outlen, const unsigned c-string
! in, uint inlen, void* arg )
CALLBACK: int SSL_CTX_alpn_select_cb_func ( SSL* ssl,
c-string* out, uchar* outlen, c-string in, uint inlen, void* arg )
FUNCTION: void SSL_CTX_set_alpn_select_cb ( SSL_CTX* ctx,
SSL_CTX_alpn_select_cb_func cb, void* arg )
FUNCTION: int SSL_select_next_proto ( c-string* out, uchar*
outlen, c-string server, uint server_len, c-string client, uint
client_len )

FUNCTION: void SSL_get0_alpn_selected ( SSL* s,
c-string* data, uint* len )

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
FUNCTION: void* X509_get_ext_d2i ( X509* a, int nid, int* crit, int* idx )
FUNCTION: X509_NAME* X509_get_issuer_name ( X509* a )
FUNCTION: X509_NAME* X509_get_subject_name ( X509* a )
FUNCTION: int X509_check_trust ( X509* a, int id, int flags )
FUNCTION: X509_EXTENSION* X509_get_ext ( X509* a, int loc )
FUNCTION: void X509_free ( X509* a )
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
FUNCTION: int OPENSSL_sk_num ( _STACK* s )
FUNCTION: void* OPENSSL_sk_value ( _STACK* s, int v )

! ------------------------------------------------------------------------------
! API < 1.1.0, removed in new versions
! ------------------------------------------------------------------------------
FUNCTION: int sk_num ( _STACK* s )
FUNCTION: void* sk_value ( _STACK* s, int v )

! ------------------------------------------------------------------------------

! For TLSv1.3
FUNCTION: void SSL_CTX_set_ciphersuites ( SSL_CTX *ctx, char *ciphersuites )
FUNCTION: int SSL_set_ciphersuites ( SSL *ssl, char *ciphersuites )
FUNCTION: void SSL_set_SSL_CTX ( SSL *ssl, SSL_CTX *ctx )
FUNCTION: int SSL_set1_host ( SSL *ssl, char *hostname )
FUNCTION: int SSL_do_handshake ( SSL *ssl )

! State
FUNCTION: int SSL_get_state ( SSL *ssl )
FUNCTION: int SSL_in_init ( SSL *ssl )
FUNCTION: int SSL_in_before ( SSL *ssl )
FUNCTION: int SSL_is_init_finished ( SSL *ssl )
