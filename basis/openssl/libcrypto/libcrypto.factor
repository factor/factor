! Copyright (C) 2007 Elie CHAFTARI, 2009 Maxim Savchenko
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax classes.struct combinators kernel literals
sequences system ;

IN: openssl.libcrypto

C-LIBRARY: libcrypto cdecl {
    { windows $[ cpu x86.64 = "-x64" "" ? "libcrypto-3" ".dll" surround ] }
    { macos "libcrypto.35.dylib" }
    { unix "libcrypto.so" }
}

STRUCT: bio-method
    { type int }
    { name void* }
    { bwrite void* }
    { bread void* }
    { bputs void* }
    { bgets void* }
    { ctrl void* }
    { create void* }
    { destroy void* }
    { callback-ctrl void* } ;

CONSTANT: BIO_NOCLOSE       0x00
CONSTANT: BIO_CLOSE         0x01

CONSTANT: RSA_3             0x3
CONSTANT: RSA_F4            0x10001

CONSTANT: BIO_C_SET_CONNECT         100
CONSTANT: BIO_C_DO_STATE_MACHINE    101
CONSTANT: BIO_C_SET_NBIO            102
CONSTANT: BIO_C_SET_PROXY_PARAM     103
CONSTANT: BIO_C_SET_FD              104
CONSTANT: BIO_C_GET_FD              105
CONSTANT: BIO_C_SET_FILE_PTR        106
CONSTANT: BIO_C_GET_FILE_PTR        107
CONSTANT: BIO_C_SET_FILENAME        108
CONSTANT: BIO_C_SET_SSL             109
CONSTANT: BIO_C_GET_SSL             110

LIBRARY: libcrypto

! ===============================================
! crypto.h
! ===============================================
STRUCT: crypto_ex_data_st
    { sk void* }
    { dummy int } ;
TYPEDEF: crypto_ex_data_st CRYPTO_EX_DATA

! ===============================================
! bio.h
! ===============================================
STRUCT: bio_method_st
    { type int }
    { name c-string }
    { bwrite void* }
    { bread void* }
    { bputs void* }
    { bgets void* }
    { ctrl void* }
    { create void* }
    { destroy void* }
    { callback_ctrl void* } ;
TYPEDEF: bio_method_st BIO_METHOD

STRUCT: bio_st
    { method BIO_METHOD* }
    { callback void* }
    { cb_arg c-string }
    { init int }
    { shutdown int }
    { flags int }
    { retry-reason int }
    { num int }
    { ptr void* }
    { next-bio bio_st* }
    { prev-bio bio_st* }
    { references int }
    { num-read ulong }
    { num-write ulong }
    { ex-data CRYPTO_EX_DATA } ;
TYPEDEF: bio_st BIO

FUNCTION: BIO* BIO_new_file ( c-string filename, c-string mode )

FUNCTION: int BIO_printf ( BIO* bio, c-string format )

FUNCTION: long BIO_ctrl ( void* bio, int cmd, long larg, void* parg )

FUNCTION: BIO* BIO_new_socket ( int fd, int close-flag )

FUNCTION: BIO* BIO_new_connect ( c-string name )

FUNCTION: void* BIO_new ( void* method )

FUNCTION: int BIO_set ( void* bio, void* method )

FUNCTION: int BIO_free ( void* bio )

FUNCTION: void* BIO_push ( void* bio, void* append )

FUNCTION: int BIO_read ( BIO* bio, void* buf, int len )

FUNCTION: int BIO_gets ( void* b, c-string buf, int size )

FUNCTION: int BIO_write ( void* b, void* buf, int len )

FUNCTION: int BIO_puts ( BIO* bio, c-string buf )

FUNCTION: ulong ERR_get_error ( )

FUNCTION: void ERR_clear_error ( )

FUNCTION: c-string ERR_error_string ( ulong e, void* buf )

FUNCTION: void* BIO_f_buffer ( )

! ===============================================
! evp.h
! ===============================================

CONSTANT: EVP_MAX_MD_SIZE 64

C-TYPE: EVP_MD
C-TYPE: ENGINE

STRUCT: EVP_MD_CTX
    { digest EVP_MD* }
    { engine ENGINE* }
    { flags ulong }
    { md_data void* } ;

! ------------------------------------------------------------------------------
! API >= 1.1.0
! ------------------------------------------------------------------------------
FUNCTION: ulong OpenSSL_version_num ( )
FUNCTION: EVP_MD_CTX* EVP_MD_CTX_new ( )
FUNCTION: void EVP_MD_CTX_free ( EVP_MD_CTX* ctx )

! ------------------------------------------------------------------------------
! API < 1.1.0, removed in new versions
! ------------------------------------------------------------------------------
FUNCTION: void OpenSSL_add_all_ciphers ( )
FUNCTION: void OpenSSL_add_all_digests ( )
FUNCTION: EVP_MD_CTX* EVP_MD_CTX_create ( )
FUNCTION: void EVP_MD_CTX_destroy ( EVP_MD_CTX* ctx )
! ------------------------------------------------------------------------------

! Clean them up before exiting
FUNCTION: void EVP_cleanup ( )

FUNCTION: EVP_MD* EVP_get_digestbyname ( c-string name )

FUNCTION: void EVP_MD_CTX_init ( EVP_MD* ctx )

FUNCTION: int EVP_MD_CTX_cleanup ( EVP_MD_CTX* ctx )
FUNCTION: int EVP_MD_CTX_copy_ex ( EVP_MD_CTX* out, EVP_MD_CTX* in )

FUNCTION: int EVP_DigestInit_ex ( EVP_MD_CTX* ctx, EVP_MD* type, ENGINE* impl )

FUNCTION: int EVP_DigestUpdate ( EVP_MD_CTX* ctx, void* d, uint cnt )

FUNCTION: int EVP_DigestFinal_ex ( EVP_MD_CTX* ctx, void* md, uint* s )

FUNCTION: int EVP_Digest ( void* data, uint count, void* md, uint* size, EVP_MD* type, ENGINE* impl )

FUNCTION: int EVP_MD_CTX_copy ( EVP_MD_CTX* out, EVP_MD_CTX* in )

FUNCTION: int EVP_DigestInit ( EVP_MD_CTX* ctx, EVP_MD* type )

FUNCTION: int EVP_DigestFinal ( EVP_MD_CTX* ctx, void* md, uint* s )

FUNCTION: void* PEM_read_bio_DHparams ( void* bp, void* x, void* cb,
                                        void* u )

! ===============================================
! rsa.h
! ===============================================

FUNCTION: void* RSA_new ( )

FUNCTION: int RSA_generate_key_ex ( void* rsa int bits, void* e, void* cb )

FUNCTION: int RSA_check_key ( void* rsa )

FUNCTION: void RSA_free ( void* rsa )

FUNCTION: int RSA_print_fp ( void* fp, void* x, int offset )

! ===============================================
! objects.h
! ===============================================

FUNCTION: int OBJ_sn2nid ( c-string s )

! ===============================================
! bn.h
! ===============================================

FUNCTION: int BN_num_bits ( void* a )

FUNCTION: void* BN_bin2bn ( void* s, int len, void* ret )

FUNCTION: int BN_bn2bin ( void* a, void* to )

FUNCTION: void BN_clear_free ( void* a )
DESTRUCTOR: BN_clear_free

! ===============================================
! ec.h
! ===============================================

CONSTANT: POINT_CONVERSION_COMPRESSED 2
CONSTANT: POINT_CONVERSION_UNCOMPRESSED 4
CONSTANT: POINT_CONVERSION_HYBRID 6

FUNCTION: int EC_GROUP_get_degree ( void* group )

FUNCTION: void* EC_POINT_new ( void* group )

FUNCTION: void EC_POINT_clear_free ( void* point )

FUNCTION: int EC_POINT_point2oct ( void* group, void* point, int form, void* buf, int len, void* ctx )

FUNCTION: int EC_POINT_oct2point ( void* group, void* point, void* buf, int len, void* ctx )

FUNCTION: void* EC_KEY_new_by_curve_name ( int nid )

FUNCTION: void EC_KEY_free ( void* r )

FUNCTION: int EC_KEY_set_private_key ( void* key, void* priv_key )

FUNCTION: int EC_KEY_set_public_key ( void* key, void* pub_key )

FUNCTION: int EC_KEY_generate_key ( void* eckey )

FUNCTION: void* EC_KEY_get0_group ( void* key )

FUNCTION: void* EC_KEY_get0_private_key ( void* key )

FUNCTION: void* EC_KEY_get0_public_key ( void* key )

! ===============================================
! ecdsa.h
! ===============================================

FUNCTION: int ECDSA_size ( void* eckey )

FUNCTION: int ECDSA_sign ( int type, void* dgst, int dgstlen, void* sig, void* siglen, void* eckey )

FUNCTION: int ECDSA_verify ( int type, void* dgst, int dgstlen, void* sig, int siglen, void* eckey )
