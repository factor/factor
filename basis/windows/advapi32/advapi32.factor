USING: alien.c-types alien.syntax classes.struct kernel
literals math math.bitwise windows.kernel32 windows.types ;
IN: windows.advapi32

LIBRARY: advapi32

CONSTANT: MS_DEF_DH_SCHANNEL_PROV "Microsoft DH Schannel Cryptographic Provider"

CONSTANT: MS_DEF_DSS_DH_PROV
    "Microsoft Base DSS and Diffie-Hellman Cryptographic Provider"

CONSTANT: MS_DEF_DSS_PROV
    "Microsoft Base DSS Cryptographic Provider"

CONSTANT: MS_DEF_PROV
    "Microsoft Base Cryptographic Provider v1.0"

CONSTANT: MS_DEF_RSA_SCHANNEL_PROV
    "Microsoft RSA Schannel Cryptographic Provider"

! Unsupported (!)
CONSTANT: MS_DEF_RSA_SIG_PROV
    "Microsoft RSA Signature Cryptographic Provider"

CONSTANT: MS_ENH_DSS_DH_PROV
    "Microsoft Enhanced DSS and Diffie-Hellman Cryptographic Provider"

CONSTANT: MS_ENH_RSA_AES_PROV
    "Microsoft Enhanced RSA and AES Cryptographic Provider"

CONSTANT: MS_ENHANCED_PROV
    "Microsoft Enhanced Cryptographic Provider v1.0"

CONSTANT: MS_SCARD_PROV
    "Microsoft Base Smart Card Crypto Provider"

CONSTANT: MS_STRONG_PROV
    "Microsoft Strong Cryptographic Provider"

STRUCT: ACL
    { AclRevision BYTE }
    { Sbz1 BYTE }
    { AclSize WORD }
    { AceCount WORD }
    { Sbz2 WORD } ;

TYPEDEF: ACL* PACL

CONSTANT: ACCESS_ALLOWED_ACE_TYPE 0
CONSTANT: ACCESS_DENIED_ACE_TYPE 1
CONSTANT: SYSTEM_AUDIT_ACE_TYPE 2
CONSTANT: SYSTEM_ALARM_ACE_TYPE 3

CONSTANT: OBJECT_INHERIT_ACE 0x1
CONSTANT: CONTAINER_INHERIT_ACE 0x2
CONSTANT: NO_PROPAGATE_INHERIT_ACE 0x4
CONSTANT: INHERIT_ONLY_ACE 0x8
CONSTANT: VALID_INHERIT_FLAGS 0xf

STRUCT: ACE_HEADER
    { AceType BYTE }
    { AceFlags BYTE }
    { AceSize WORD } ;

TYPEDEF: ACE_HEADER* PACE_HEADER

STRUCT: ACCESS_ALLOWED_ACE
    { Header ACE_HEADER }
    { Mask DWORD }
    { SidStart DWORD } ;

TYPEDEF: ACCESS_ALLOWED_ACE* PACCESS_ALLOWED_ACE

STRUCT: ACCESS_DENIED_ACE
    { Header ACE_HEADER }
    { Mask DWORD }
    { SidStart DWORD } ;
TYPEDEF: ACCESS_DENIED_ACE* PACCESS_DENIED_ACE


STRUCT: SYSTEM_AUDIT_ACE
    { Header ACE_HEADER }
    { Mask DWORD }
    { SidStart DWORD } ;

TYPEDEF: SYSTEM_AUDIT_ACE* PSYSTEM_AUDIT_ACE

STRUCT: SYSTEM_ALARM_ACE
    { Header ACE_HEADER }
    { Mask DWORD }
    { SidStart DWORD } ;

TYPEDEF: SYSTEM_ALARM_ACE* PSYSTEM_ALARM_ACE

STRUCT: ACCESS_ALLOWED_CALLBACK_ACE
    { Header ACE_HEADER }
    { Mask DWORD }
    { SidStart DWORD } ;

TYPEDEF: ACCESS_ALLOWED_CALLBACK_ACE* PACCESS_ALLOWED_CALLBACK_ACE

STRUCT: SECURITY_DESCRIPTOR
    { Revision UCHAR }
    { Sbz1 UCHAR }
    { Control WORD }
    { Owner PVOID }
    { Group PVOID }
    { Sacl PACL }
    { Dacl PACL } ;

TYPEDEF: SECURITY_DESCRIPTOR* PSECURITY_DESCRIPTOR

CONSTANT: SE_OWNER_DEFAULTED 1
CONSTANT: SE_GROUP_DEFAULTED 2
CONSTANT: SE_DACL_PRESENT 4
CONSTANT: SE_DACL_DEFAULTED 8
CONSTANT: SE_SACL_PRESENT 16
CONSTANT: SE_SACL_DEFAULTED 32
CONSTANT: SE_DACL_AUTO_INHERIT_REQ 256
CONSTANT: SE_SACL_AUTO_INHERIT_REQ 512
CONSTANT: SE_DACL_AUTO_INHERITED 1024
CONSTANT: SE_SACL_AUTO_INHERITED 2048
CONSTANT: SE_DACL_PROTECTED 4096
CONSTANT: SE_SACL_PROTECTED 8192
CONSTANT: SE_SELF_RELATIVE 32768

TYPEDEF: DWORD SECURITY_DESCRIPTOR_CONTROL
TYPEDEF: SECURITY_DESCRIPTOR_CONTROL* PSECURITY_DESCRIPTOR_CONTROL

ENUM: ACCESS_MODE
    NOT_USED_ACCESS
    GRANT_ACCESS
    SET_ACCESS
    DENY_ACCESS
    REVOKE_ACCESS
    SET_AUDIT_SUCCESS
    SET_AUDIT_FAILURE ;

ENUM: MULTIPLE_TRUSTEE_OPERATION
    NO_MULTIPLE_TRUSTEE
    TRUSTEE_IS_IMPERSONATE ;

ENUM: TRUSTEE_FORM
  TRUSTEE_IS_SID
  TRUSTEE_IS_NAME
  TRUSTEE_BAD_FORM
  TRUSTEE_IS_OBJECTS_AND_SID
  TRUSTEE_IS_OBJECTS_AND_NAME ;

ENUM: TRUSTEE_TYPE
    TRUSTEE_IS_UNKNOWN
    TRUSTEE_IS_USER
    TRUSTEE_IS_GROUP
    TRUSTEE_IS_DOMAIN
    TRUSTEE_IS_ALIAS
    TRUSTEE_IS_WELL_KNOWN_GROUP
    TRUSTEE_IS_DELETED
    TRUSTEE_IS_INVALID
    TRUSTEE_IS_COMPUTER ;

ENUM: SE_OBJECT_TYPE
    SE_UNKNOWN_OBJECT_TYPE
    SE_FILE_OBJECT
    SE_SERVICE
    SE_PRINTER
    SE_REGISTRY_KEY
    SE_LMSHARE
    SE_KERNEL_OBJECT
    SE_WINDOW_OBJECT
    SE_DS_OBJECT
    SE_DS_OBJECT_ALL
    SE_PROVIDER_DEFINED_OBJECT
    SE_WMIGUID_OBJECT
    SE_REGISTRY_WOW64_32KEY ;

STRUCT: TRUSTEE
    { pMultipleTrustee TRUSTEE* }
    { MultipleTrusteeOperation MULTIPLE_TRUSTEE_OPERATION }
    { TrusteeForm TRUSTEE_FORM }
    { TrusteeType TRUSTEE_TYPE }
    { ptstrName LPTSTR } ;

TYPEDEF: TRUSTEE* PTRUSTEE

STRUCT: EXPLICIT_ACCESS
    { grfAccessPermissions DWORD }
    { grfAccessMode ACCESS_MODE }
    { grfInheritance DWORD }
    { Trustee TRUSTEE } ;

STRUCT: SID_IDENTIFIER_AUTHORITY
    { Value { BYTE 6 } } ;

TYPEDEF: SID_IDENTIFIER_AUTHORITY* PSID_IDENTIFIER_AUTHORITY

CONSTANT: SECURITY_NULL_SID_AUTHORITY 0
CONSTANT: SECURITY_WORLD_SID_AUTHORITY    1
CONSTANT: SECURITY_LOCAL_SID_AUTHORITY    2
CONSTANT: SECURITY_CREATOR_SID_AUTHORITY  3
CONSTANT: SECURITY_NON_UNIQUE_AUTHORITY   4
CONSTANT: SECURITY_NT_AUTHORITY   5
CONSTANT: SECURITY_RESOURCE_MANAGER_AUTHORITY 6

CONSTANT: SECURITY_NULL_RID 0
CONSTANT: SECURITY_WORLD_RID 0
CONSTANT: SECURITY_LOCAL_RID 0
CONSTANT: SECURITY_CREATOR_OWNER_RID 0
CONSTANT: SECURITY_CREATOR_GROUP_RID 1
CONSTANT: SECURITY_CREATOR_OWNER_SERVER_RID 2
CONSTANT: SECURITY_CREATOR_GROUP_SERVER_RID 3
CONSTANT: SECURITY_DIALUP_RID 1
CONSTANT: SECURITY_NETWORK_RID 2
CONSTANT: SECURITY_BATCH_RID 3
CONSTANT: SECURITY_INTERACTIVE_RID 4
CONSTANT: SECURITY_SERVICE_RID 6
CONSTANT: SECURITY_ANONYMOUS_LOGON_RID 7
CONSTANT: SECURITY_PROXY_RID 8
CONSTANT: SECURITY_SERVER_LOGON_RID 9
CONSTANT: SECURITY_PRINCIPAL_SELF_RID 10
CONSTANT: SECURITY_AUTHENTICATED_USER_RID 11
CONSTANT: SECURITY_LOGON_IDS_RID 5
CONSTANT: SECURITY_LOGON_IDS_RID_COUNT 3
CONSTANT: SECURITY_LOCAL_SYSTEM_RID 18
CONSTANT: SECURITY_NT_NON_UNIQUE 21
CONSTANT: SECURITY_BUILTIN_DOMAIN_RID 32
CONSTANT: DOMAIN_USER_RID_ADMIN 500
CONSTANT: DOMAIN_USER_RID_GUEST 501
CONSTANT: DOMAIN_GROUP_RID_ADMINS 512
CONSTANT: DOMAIN_GROUP_RID_USERS 513
CONSTANT: DOMAIN_GROUP_RID_GUESTS 514
CONSTANT: DOMAIN_ALIAS_RID_ADMINS 544
CONSTANT: DOMAIN_ALIAS_RID_USERS 545
CONSTANT: DOMAIN_ALIAS_RID_GUESTS 546
CONSTANT: DOMAIN_ALIAS_RID_POWER_USERS 547
CONSTANT: DOMAIN_ALIAS_RID_ACCOUNT_OPS 548
CONSTANT: DOMAIN_ALIAS_RID_SYSTEM_OPS 549
CONSTANT: DOMAIN_ALIAS_RID_PRINT_OPS 550
CONSTANT: DOMAIN_ALIAS_RID_BACKUP_OPS 551
CONSTANT: DOMAIN_ALIAS_RID_REPLICATOR 552
CONSTANT: SE_GROUP_MANDATORY 1
CONSTANT: SE_GROUP_ENABLED_BY_DEFAULT 2
CONSTANT: SE_GROUP_ENABLED 4
CONSTANT: SE_GROUP_OWNER 8
CONSTANT: SE_GROUP_LOGON_ID -1073741824

CONSTANT: NTE_BAD_UID 0x80090001
CONSTANT: NTE_BAD_HASH 0x80090002
CONSTANT: NTE_BAD_KEY 0x80090003
CONSTANT: NTE_BAD_LEN 0x80090004
CONSTANT: NTE_BAD_DATA 0x80090005
CONSTANT: NTE_BAD_SIGNATURE 0x80090006
CONSTANT: NTE_BAD_VER 0x80090007
CONSTANT: NTE_BAD_ALGID 0x80090008
CONSTANT: NTE_BAD_FLAGS 0x80090009
CONSTANT: NTE_BAD_TYPE 0x8009000A
CONSTANT: NTE_BAD_KEY_STATE 0x8009000B
CONSTANT: NTE_BAD_HASH_STATE 0x8009000C
CONSTANT: NTE_NO_KEY 0x8009000D
CONSTANT: NTE_NO_MEMORY 0x8009000E
CONSTANT: NTE_EXISTS 0x8009000F
CONSTANT: NTE_PERM 0x80090010
CONSTANT: NTE_NOT_FOUND 0x80090011
CONSTANT: NTE_DOUBLE_ENCRYPT 0x80090012
CONSTANT: NTE_BAD_PROVIDER 0x80090013
CONSTANT: NTE_BAD_PROV_TYPE 0x80090014
CONSTANT: NTE_BAD_PUBLIC_KEY 0x80090015
CONSTANT: NTE_BAD_KEYSET 0x80090016
CONSTANT: NTE_PROV_TYPE_NOT_DEF 0x80090017
CONSTANT: NTE_PROV_TYPE_ENTRY_BAD 0x80090018
CONSTANT: NTE_KEYSET_NOT_DEF 0x80090019
CONSTANT: NTE_KEYSET_ENTRY_BAD 0x8009001A
CONSTANT: NTE_PROV_TYPE_NO_MATCH 0x8009001B
CONSTANT: NTE_SIGNATURE_FILE_BAD 0x8009001C
CONSTANT: NTE_PROVIDER_DLL_FAIL 0x8009001D
CONSTANT: NTE_PROV_DLL_NOT_FOUND 0x8009001E
CONSTANT: NTE_BAD_KEYSET_PARAM 0x8009001F
CONSTANT: NTE_FAIL 0x80090020
CONSTANT: NTE_SYS_ERR 0x80090021

! SID is a variable length structure
TYPEDEF: void* PSID

TYPEDEF: EXPLICIT_ACCESS* PEXPLICIT_ACCESS

TYPEDEF: DWORD SECURITY_INFORMATION
TYPEDEF: SECURITY_INFORMATION* PSECURITY_INFORMATION

CONSTANT: OWNER_SECURITY_INFORMATION 1
CONSTANT: GROUP_SECURITY_INFORMATION 2
CONSTANT: DACL_SECURITY_INFORMATION 4
CONSTANT: SACL_SECURITY_INFORMATION 8

CONSTANT: DELETE                     0x00010000
CONSTANT: READ_CONTROL               0x00020000
CONSTANT: WRITE_DAC                  0x00040000
CONSTANT: WRITE_OWNER                0x00080000
CONSTANT: SYNCHRONIZE                0x00100000
CONSTANT: STANDARD_RIGHTS_REQUIRED   0x000f0000

ALIAS: STANDARD_RIGHTS_READ       READ_CONTROL
ALIAS: STANDARD_RIGHTS_WRITE      READ_CONTROL
ALIAS: STANDARD_RIGHTS_EXECUTE    READ_CONTROL

CONSTANT: TOKEN_TOKEN_ADJUST_DEFAULT   0x0080
CONSTANT: TOKEN_ADJUST_GROUPS          0x0040
CONSTANT: TOKEN_ADJUST_PRIVILEGES      0x0020
CONSTANT: TOKEN_ADJUST_SESSIONID       0x0100
CONSTANT: TOKEN_ASSIGN_PRIMARY         0x0001
CONSTANT: TOKEN_DUPLICATE              0x0002
ALIAS: TOKEN_EXECUTE                STANDARD_RIGHTS_EXECUTE
CONSTANT: TOKEN_IMPERSONATE            0x0004
CONSTANT: TOKEN_QUERY                  0x0008
CONSTANT: TOKEN_QUERY_SOURCE           0x0010
CONSTANT: TOKEN_ADJUST_DEFAULT         0x0080
CONSTANT: TOKEN_READ flags{ STANDARD_RIGHTS_READ TOKEN_QUERY }

CONSTANT: TOKEN_WRITE
    flags{
        STANDARD_RIGHTS_WRITE
        TOKEN_ADJUST_PRIVILEGES
        TOKEN_ADJUST_GROUPS
        TOKEN_ADJUST_DEFAULT
    }

CONSTANT: TOKEN_ALL_ACCESS
    flags{
        STANDARD_RIGHTS_REQUIRED
        TOKEN_ASSIGN_PRIMARY
        TOKEN_DUPLICATE
        TOKEN_IMPERSONATE
        TOKEN_QUERY
        TOKEN_QUERY_SOURCE
        TOKEN_ADJUST_PRIVILEGES
        TOKEN_ADJUST_GROUPS
        TOKEN_ADJUST_SESSIONID
        TOKEN_ADJUST_DEFAULT
    }

CONSTANT: HKEY_CLASSES_ROOT        0x80000000
CONSTANT: HKEY_CURRENT_USER        0x80000001
CONSTANT: HKEY_LOCAL_MACHINE       0x80000002
CONSTANT: HKEY_USERS               0x80000003
CONSTANT: HKEY_PERFORMANCE_DATA    0x80000004
CONSTANT: HKEY_CURRENT_CONFIG      0x80000005
CONSTANT: HKEY_DYN_DATA            0x80000006
CONSTANT: HKEY_PERFORMANCE_TEXT    0x80000050
CONSTANT: HKEY_PERFORMANCE_NLSTEXT 0x80000060

CONSTANT: KEY_QUERY_VALUE         0x0001
CONSTANT: KEY_SET_VALUE           0x0002
CONSTANT: KEY_CREATE_SUB_KEY      0x0004
CONSTANT: KEY_ENUMERATE_SUB_KEYS  0x0008
CONSTANT: KEY_NOTIFY              0x0010
CONSTANT: KEY_CREATE_LINK         0x0020
CONSTANT: KEY_READ                0x20019
CONSTANT: KEY_WOW64_32KEY         0x0200
CONSTANT: KEY_WOW64_64KEY         0x0100
CONSTANT: KEY_WRITE               0x20006
ALIAS: KEY_EXECUTE             KEY_READ
CONSTANT: KEY_ALL_ACCESS          0xF003F

CONSTANT: REG_NONE                         0
CONSTANT: REG_SZ                           1
CONSTANT: REG_EXPAND_SZ                    2
CONSTANT: REG_BINARY                       3
CONSTANT: REG_DWORD                        4
CONSTANT: REG_DWORD_LITTLE_ENDIAN          4
CONSTANT: REG_DWORD_BIG_ENDIAN             5
CONSTANT: REG_LINK                         6
CONSTANT: REG_MULTI_SZ                     7
CONSTANT: REG_RESOURCE_LIST                8
CONSTANT: REG_FULL_RESOURCE_DESCRIPTOR     9
CONSTANT: REG_RESOURCE_REQUIREMENTS_LIST  10
CONSTANT: REG_QWORD                       11
CONSTANT: REG_QWORD_LITTLE_ENDIAN         11

CONSTANT: REG_CREATED_NEW_KEY     1
CONSTANT: REG_OPENED_EXISTING_KEY 2



CONSTANT: ALG_CLASS_ANY 0
CONSTANT: ALG_CLASS_SIGNATURE  8192
CONSTANT: ALG_CLASS_MSG_ENCRYPT  16384
CONSTANT: ALG_CLASS_DATA_ENCRYPT  24576
CONSTANT: ALG_CLASS_HASH  32768
CONSTANT: ALG_CLASS_KEY_EXCHANGE  40960
CONSTANT: ALG_CLASS_ALL 57344
CONSTANT: ALG_TYPE_ANY 0
CONSTANT: ALG_TYPE_DSS 512
CONSTANT: ALG_TYPE_RSA 1024
CONSTANT: ALG_TYPE_BLOCK 1536
CONSTANT: ALG_TYPE_STREAM  2048
CONSTANT: ALG_TYPE_DH 2560
CONSTANT: ALG_TYPE_SECURECHANNEL 3072
CONSTANT: ALG_SID_ANY 0
CONSTANT: ALG_SID_RSA_ANY 0
CONSTANT: ALG_SID_RSA_PKCS 1
CONSTANT: ALG_SID_RSA_MSATWORK 2
CONSTANT: ALG_SID_RSA_ENTRUST 3
CONSTANT: ALG_SID_RSA_PGP 4
CONSTANT: ALG_SID_DSS_ANY 0
CONSTANT: ALG_SID_DSS_PKCS 1
CONSTANT: ALG_SID_DSS_DMS 2
CONSTANT: ALG_SID_DES 1
CONSTANT: ALG_SID_3DES 3
CONSTANT: ALG_SID_DESX 4
CONSTANT: ALG_SID_IDEA 5
CONSTANT: ALG_SID_CAST 6
CONSTANT: ALG_SID_SAFERSK64 7
CONSTANT: ALG_SID_SAFERSK128 8
CONSTANT: ALG_SID_3DES_112 9
CONSTANT: ALG_SID_SKIPJACK 10
CONSTANT: ALG_SID_TEK 11
CONSTANT: ALG_SID_CYLINK_MEK 12
CONSTANT: ALG_SID_RC5 13
CONSTANT: ALG_SID_RC2 2
CONSTANT: ALG_SID_RC4 1
CONSTANT: ALG_SID_SEAL 2
CONSTANT: ALG_SID_MD2 1
CONSTANT: ALG_SID_MD4 2
CONSTANT: ALG_SID_MD5 3
CONSTANT: ALG_SID_SHA 4
CONSTANT: ALG_SID_MAC 5
CONSTANT: ALG_SID_RIPEMD 6
CONSTANT: ALG_SID_RIPEMD160 7
CONSTANT: ALG_SID_SSL3SHAMD5 8
CONSTANT: ALG_SID_HMAC 9
CONSTANT: ALG_SID_TLS1PRF 10
CONSTANT: ALG_SID_EXAMPLE 80

CONSTANT: CALG_MD2 flags{ ALG_CLASS_HASH ALG_TYPE_ANY ALG_SID_MD2 }
CONSTANT: CALG_MD4 flags{ ALG_CLASS_HASH ALG_TYPE_ANY ALG_SID_MD4 }
CONSTANT: CALG_MD5 flags{ ALG_CLASS_HASH ALG_TYPE_ANY ALG_SID_MD5 }
CONSTANT: CALG_SHA flags{ ALG_CLASS_HASH ALG_TYPE_ANY ALG_SID_SHA }
CONSTANT: CALG_MAC flags{ ALG_CLASS_HASH ALG_TYPE_ANY ALG_SID_MAC }
CONSTANT: CALG_3DES flags{ ALG_CLASS_DATA_ENCRYPT ALG_TYPE_BLOCK 3 }
CONSTANT: CALG_CYLINK_MEK flags{ ALG_CLASS_DATA_ENCRYPT ALG_TYPE_BLOCK 12 }
CONSTANT: CALG_SKIPJACK flags{ ALG_CLASS_DATA_ENCRYPT ALG_TYPE_BLOCK 10 }
CONSTANT: CALG_KEA_KEYX flags{ ALG_CLASS_KEY_EXCHANGE ALG_TYPE_STREAM ALG_TYPE_DSS 4 }
CONSTANT: CALG_RSA_SIGN flags{ ALG_CLASS_SIGNATURE ALG_TYPE_RSA ALG_SID_RSA_ANY }
CONSTANT: CALG_DSS_SIGN flags{ ALG_CLASS_SIGNATURE ALG_TYPE_DSS ALG_SID_DSS_ANY }
CONSTANT: CALG_RSA_KEYX flags{ ALG_CLASS_KEY_EXCHANGE ALG_TYPE_RSA ALG_SID_RSA_ANY }
CONSTANT: CALG_DES flags{ ALG_CLASS_DATA_ENCRYPT ALG_TYPE_BLOCK ALG_SID_DES }
CONSTANT: CALG_RC2 flags{ ALG_CLASS_DATA_ENCRYPT ALG_TYPE_BLOCK ALG_SID_RC2 }
CONSTANT: CALG_RC4 flags{ ALG_CLASS_DATA_ENCRYPT ALG_TYPE_STREAM ALG_SID_RC4 }
CONSTANT: CALG_SEAL flags{ ALG_CLASS_DATA_ENCRYPT ALG_TYPE_STREAM ALG_SID_SEAL }
CONSTANT: CALG_DH_EPHEM flags{ ALG_CLASS_KEY_EXCHANGE ALG_TYPE_STREAM ALG_TYPE_DSS ALG_SID_DSS_DMS }
CONSTANT: CALG_DESX flags{ ALG_CLASS_DATA_ENCRYPT ALG_TYPE_BLOCK ALG_SID_DESX }
! CONSTANT: CALG_TLS1PRF flags{ ALG_CLASS_DHASH ALG_TYPE_ANY ALG_SID_TLS1PRF }

CONSTANT: CRYPT_VERIFYCONTEXT 0xF0000000
CONSTANT: CRYPT_NEWKEYSET 8
CONSTANT: CRYPT_DELETEKEYSET 16
CONSTANT: CRYPT_MACHINE_KEYSET 32
CONSTANT: CRYPT_SILENT 64
CONSTANT: CRYPT_EXPORTABLE 1
CONSTANT: CRYPT_USER_PROTECTED 2
CONSTANT: CRYPT_CREATE_SALT 4
CONSTANT: CRYPT_UPDATE_KEY 8
CONSTANT: AT_KEYEXCHANGE 1
CONSTANT: AT_SIGNATURE 2
CONSTANT: CRYPT_USERDATA 1
CONSTANT: KP_IV 1
CONSTANT: KP_SALT 2
CONSTANT: KP_PADDING 3
CONSTANT: KP_MODE 4
CONSTANT: KP_MODE_BITS 5
CONSTANT: KP_PERMISSIONS 6
CONSTANT: KP_ALGID 7
CONSTANT: KP_BLOCKLEN 8
CONSTANT: PKCS5_PADDING 1
CONSTANT: CRYPT_MODE_CBC 1
CONSTANT: CRYPT_MODE_ECB 2
CONSTANT: CRYPT_MODE_OFB 3
CONSTANT: CRYPT_MODE_CFB 4
CONSTANT: CRYPT_MODE_CTS 5
CONSTANT: CRYPT_MODE_CBCI 6
CONSTANT: CRYPT_MODE_CFBP 7
CONSTANT: CRYPT_MODE_OFBP 8
CONSTANT: CRYPT_MODE_CBCOFM 9
CONSTANT: CRYPT_MODE_CBCOFMI 10
CONSTANT: CRYPT_ENCRYPT 1
CONSTANT: CRYPT_DECRYPT 2
CONSTANT: CRYPT_EXPORT 4
CONSTANT: CRYPT_READ 8
CONSTANT: CRYPT_WRITE 16
CONSTANT: CRYPT_MAC 32
CONSTANT: HP_ALGID 1
CONSTANT: HP_HASHVAL 2
CONSTANT: HP_HASHSIZE 4
CONSTANT: PP_ENUMALGS 1
CONSTANT: PP_ENUMCONTAINERS 2
CONSTANT: PP_IMPTYPE 3
CONSTANT: PP_NAME 4
CONSTANT: PP_VERSION 5
CONSTANT: PP_CONTAINER 6
CONSTANT: PP_ENUMMANDROOTS 25
CONSTANT: PP_ENUMELECTROOTS 26
CONSTANT: PP_KEYSET_TYPE 27
CONSTANT: PP_ADMIN_PIN 31
CONSTANT: PP_KEYEXCHANGE_PIN 32
CONSTANT: PP_SIGNATURE_PIN 33
CONSTANT: PP_SIG_KEYSIZE_INC 34
CONSTANT: PP_KEYX_KEYSIZE_INC 35
CONSTANT: PP_UNIQUE_CONTAINER 36
CONSTANT: PP_SGC_INFO 37
CONSTANT: PP_USE_HARDWARE_RNG 38
CONSTANT: PP_KEYSPEC 39
CONSTANT: PP_ENUMEX_SIGNING_PROT 40
CONSTANT: CRYPT_FIRST 1
CONSTANT: CRYPT_NEXT 2
CONSTANT: CRYPT_IMPL_HARDWARE 1
CONSTANT: CRYPT_IMPL_SOFTWARE 2
CONSTANT: CRYPT_IMPL_MIXED 3
CONSTANT: CRYPT_IMPL_UNKNOWN 4
CONSTANT: PROV_RSA_FULL 1
CONSTANT: PROV_RSA_SIG 2
CONSTANT: PROV_DSS 3
CONSTANT: PROV_FORTEZZA 4
CONSTANT: PROV_MS_MAIL 5
CONSTANT: PROV_SSL 6
CONSTANT: PROV_STT_MER 7
CONSTANT: PROV_STT_ACQ 8
CONSTANT: PROV_STT_BRND 9
CONSTANT: PROV_STT_ROOT 10
CONSTANT: PROV_STT_ISS 11
CONSTANT: PROV_RSA_SCHANNEL 12
CONSTANT: PROV_DSS_DH 13
CONSTANT: PROV_EC_ECDSA_SIG 14
CONSTANT: PROV_EC_ECNRA_SIG 15
CONSTANT: PROV_EC_ECDSA_FULL 16
CONSTANT: PROV_EC_ECNRA_FULL 17
CONSTANT: PROV_DH_SCHANNEL 18
CONSTANT: PROV_SPYRUS_LYNKS 20
CONSTANT: PROV_RNG 21
CONSTANT: PROV_INTEL_SEC 22
CONSTANT: PROV_REPLACE_OWF 23
CONSTANT: PROV_RSA_AES 24
CONSTANT: MAXUIDLEN 64
CONSTANT: CUR_BLOB_VERSION 2
CONSTANT: X509_ASN_ENCODING 1
CONSTANT: PKCS_7_ASN_ENCODING  65536
CONSTANT: CERT_V1 0
CONSTANT: CERT_V2 1
CONSTANT: CERT_V3 2
CONSTANT: CERT_E_CHAINING -2146762486
CONSTANT: CERT_E_CN_NO_MATCH -2146762481
CONSTANT: CERT_E_EXPIRED -2146762495
CONSTANT: CERT_E_PURPOSE -2146762490
CONSTANT: CERT_E_REVOCATION_FAILURE -2146762482
CONSTANT: CERT_E_REVOKED -2146762484
CONSTANT: CERT_E_ROLE -2146762493
CONSTANT: CERT_E_UNTRUSTEDROOT -2146762487
CONSTANT: CERT_E_UNTRUSTEDTESTROOT -2146762483
CONSTANT: CERT_E_VALIDITYPERIODNESTING -2146762494
CONSTANT: CERT_E_WRONG_USAGE -2146762480
CONSTANT: CERT_E_PATHLENCONST -2146762492
CONSTANT: CERT_E_CRITICAL -2146762491
CONSTANT: CERT_E_ISSUERCHAINING -2146762489
CONSTANT: CERT_E_MALFORMED -2146762488
CONSTANT: CRYPT_E_REVOCATION_OFFLINE -2146885613
CONSTANT: CRYPT_E_REVOKED -2146885616
CONSTANT: TRUST_E_BASIC_CONSTRAINTS -2146869223
CONSTANT: TRUST_E_CERT_SIGNATURE -2146869244
CONSTANT: TRUST_E_FAIL -2146762485
CONSTANT: CERT_TRUST_NO_ERROR 0
CONSTANT: CERT_TRUST_IS_NOT_TIME_VALID 1
CONSTANT: CERT_TRUST_IS_NOT_TIME_NESTED 2
CONSTANT: CERT_TRUST_IS_REVOKED 4
CONSTANT: CERT_TRUST_IS_NOT_SIGNATURE_VALID 8
CONSTANT: CERT_TRUST_IS_NOT_VALID_FOR_USAGE 16
CONSTANT: CERT_TRUST_IS_UNTRUSTED_ROOT 32
CONSTANT: CERT_TRUST_REVOCATION_STATUS_UNKNOWN 64
CONSTANT: CERT_TRUST_IS_CYCLIC 128
CONSTANT: CERT_TRUST_IS_PARTIAL_CHAIN 65536
CONSTANT: CERT_TRUST_CTL_IS_NOT_TIME_VALID 131072
CONSTANT: CERT_TRUST_CTL_IS_NOT_SIGNATURE_VALID 262144
CONSTANT: CERT_TRUST_CTL_IS_NOT_VALID_FOR_USAGE 524288
CONSTANT: CERT_TRUST_HAS_EXACT_MATCH_ISSUER 1
CONSTANT: CERT_TRUST_HAS_KEY_MATCH_ISSUER 2
CONSTANT: CERT_TRUST_HAS_NAME_MATCH_ISSUER 4
CONSTANT: CERT_TRUST_IS_SELF_SIGNED 8
CONSTANT: CERT_TRUST_IS_COMPLEX_CHAIN 65536
CONSTANT: CERT_CHAIN_POLICY_BASE 1
CONSTANT: CERT_CHAIN_POLICY_AUTHENTICODE 2
CONSTANT: CERT_CHAIN_POLICY_AUTHENTICODE_TS 3
CONSTANT: CERT_CHAIN_POLICY_SSL 4
CONSTANT: CERT_CHAIN_POLICY_BASIC_CONSTRAINTS 5
CONSTANT: CERT_CHAIN_POLICY_NT_AUTH 6
CONSTANT: USAGE_MATCH_TYPE_AND 0
CONSTANT: USAGE_MATCH_TYPE_OR 1
CONSTANT: CERT_SIMPLE_NAME_STR 1
CONSTANT: CERT_OID_NAME_STR 2
CONSTANT: CERT_X500_NAME_STR 3
CONSTANT: CERT_NAME_STR_SEMICOLON_FLAG 1073741824
CONSTANT: CERT_NAME_STR_CRLF_FLAG 134217728
CONSTANT: CERT_NAME_STR_NO_PLUS_FLAG 536870912
CONSTANT: CERT_NAME_STR_NO_QUOTING_FLAG 268435456
CONSTANT: CERT_NAME_STR_REVERSE_FLAG 33554432
CONSTANT: CERT_NAME_STR_ENABLE_T61_UNICODE_FLAG 131072
CONSTANT: CERT_FIND_ANY 0
CONSTANT: CERT_FIND_CERT_ID 1048576
CONSTANT: CERT_FIND_CTL_USAGE 655360
CONSTANT: CERT_FIND_ENHKEY_USAGE 655360
CONSTANT: CERT_FIND_EXISTING 851968
CONSTANT: CERT_FIND_HASH 65536
CONSTANT: CERT_FIND_ISSUER_ATTR 196612
CONSTANT: CERT_FIND_ISSUER_NAME 131076
CONSTANT: CERT_FIND_ISSUER_OF 786432
CONSTANT: CERT_FIND_KEY_IDENTIFIER 983040
CONSTANT: CERT_FIND_KEY_SPEC 589824
CONSTANT: CERT_FIND_MD5_HASH 262144
CONSTANT: CERT_FIND_PROPERTY 327680
CONSTANT: CERT_FIND_PUBLIC_KEY 393216
CONSTANT: CERT_FIND_SHA1_HASH 65536
CONSTANT: CERT_FIND_SIGNATURE_HASH 917504
CONSTANT: CERT_FIND_SUBJECT_ATTR 196615
CONSTANT: CERT_FIND_SUBJECT_CERT 720896
CONSTANT: CERT_FIND_SUBJECT_NAME 131079
CONSTANT: CERT_FIND_SUBJECT_STR_A 458759
CONSTANT: CERT_FIND_SUBJECT_STR_W 524295
CONSTANT: CERT_FIND_ISSUER_STR_A 458756
CONSTANT: CERT_FIND_ISSUER_STR_W 524292
CONSTANT: CERT_FIND_OR_ENHKEY_USAGE_FLAG 16
CONSTANT: CERT_FIND_OPTIONAL_ENHKEY_USAGE_FLAG  1
CONSTANT: CERT_FIND_NO_ENHKEY_USAGE_FLAG  8
CONSTANT: CERT_FIND_VALID_ENHKEY_USAGE_FLAG  32
CONSTANT: CERT_FIND_EXT_ONLY_ENHKEY_USAGE_FLAG  2
CONSTANT: CERT_CASE_INSENSITIVE_IS_RDN_ATTRS_FLAG  2
CONSTANT: CERT_UNICODE_IS_RDN_ATTRS_FLAG 1
CONSTANT: CERT_CHAIN_FIND_BY_ISSUER 1
CONSTANT: CERT_CHAIN_FIND_BY_ISSUER_COMPARE_KEY_FLAG 1
CONSTANT: CERT_CHAIN_FIND_BY_ISSUER_COMPLEX_CHAIN_FLAG 2
CONSTANT: CERT_CHAIN_FIND_BY_ISSUER_CACHE_ONLY_FLAG 32768
CONSTANT: CERT_CHAIN_FIND_BY_ISSUER_CACHE_ONLY_URL_FLAG 4
CONSTANT: CERT_CHAIN_FIND_BY_ISSUER_LOCAL_MACHINE_FLAG 8
CONSTANT: CERT_CHAIN_FIND_BY_ISSUER_NO_KEY_FLAG 16384
CONSTANT: CERT_STORE_PROV_SYSTEM 10
CONSTANT: CERT_SYSTEM_STORE_LOCAL_MACHINE 131072
CONSTANT: szOID_PKIX_KP_SERVER_AUTH "4235600"
CONSTANT: szOID_SERVER_GATED_CRYPTO "4235658"
CONSTANT: szOID_SGC_NETSCAPE "2.16.840.1.113730.4.1"
CONSTANT: szOID_PKIX_KP_CLIENT_AUTH "1.3.6.1.5.5.7.3.2"

CONSTANT: CRYPT_NOHASHOID 0x00000001
CONSTANT: CRYPT_NO_SALT 0x10
CONSTANT: CRYPT_PREGEN 0x40
CONSTANT: CRYPT_RECIPIENT 0x10
CONSTANT: CRYPT_INITIATOR 0x40
CONSTANT: CRYPT_ONLINE 0x80
CONSTANT: CRYPT_SF 0x100
CONSTANT: CRYPT_CREATE_IV 0x200
CONSTANT: CRYPT_KEK 0x400
CONSTANT: CRYPT_DATA_KEY 0x800
CONSTANT: CRYPT_VOLATILE 0x1000
CONSTANT: CRYPT_SGCKEY 0x2000

CONSTANT: KEYSTATEBLOB 0xC
CONSTANT: OPAQUEKEYBLOB 0x9
CONSTANT: PLAINTEXTKEYBLOB 0x8
CONSTANT: PRIVATEKEYBLOB 0x7
CONSTANT: PUBLICKEYBLOB 0x6
CONSTANT: PUBLICKEYBLOBEX 0xA
CONSTANT: SIMPLEBLOB 0x1
CONSTANT: SYMMETRICWRAPKEYBLOB 0xB

TYPEDEF: void* SID

CONSTANT: SECURITY_MAX_SID_SIZE 68

ENUM: WELL_KNOWN_SID_TYPE
    { WinNullSid                                     0 }
    { WinWorldSid                                    1 }
    { WinLocalSid                                    2 }
    { WinCreatorOwnerSid                             3 }
    { WinCreatorGroupSid                             4 }
    { WinCreatorOwnerServerSid                       5 }
    { WinCreatorGroupServerSid                       6 }
    { WinNtAuthoritySid                              7 }
    { WinDialupSid                                   8 }
    { WinNetworkSid                                  9 }
    { WinBatchSid                                    10 }
    { WinInteractiveSid                              11 }
    { WinServiceSid                                  12 }
    { WinAnonymousSid                                13 }
    { WinProxySid                                    14 }
    { WinEnterpriseControllersSid                    15 }
    { WinSelfSid                                     16 }
    { WinAuthenticatedUserSid                        17 }
    { WinRestrictedCodeSid                           18 }
    { WinTerminalServerSid                           19 }
    { WinRemoteLogonIdSid                            20 }
    { WinLogonIdsSid                                 21 }
    { WinLocalSystemSid                              22 }
    { WinLocalServiceSid                             23 }
    { WinNetworkServiceSid                           24 }
    { WinBuiltinDomainSid                            25 }
    { WinBuiltinAdministratorsSid                    26 }
    { WinBuiltinUsersSid                             27 }
    { WinBuiltinGuestsSid                            28 }
    { WinBuiltinPowerUsersSid                        29 }
    { WinBuiltinAccountOperatorsSid                  30 }
    { WinBuiltinSystemOperatorsSid                   31 }
    { WinBuiltinPrintOperatorsSid                    32 }
    { WinBuiltinBackupOperatorsSid                   33 }
    { WinBuiltinReplicatorSid                        34 }
    { WinBuiltinPreWindows2000CompatibleAccessSid    35 }
    { WinBuiltinRemoteDesktopUsersSid                36 }
    { WinBuiltinNetworkConfigurationOperatorsSid     37 }
    { WinAccountAdministratorSid                     38 }
    { WinAccountGuestSid                             39 }
    { WinAccountKrbtgtSid                            40 }
    { WinAccountDomainAdminsSid                      41 }
    { WinAccountDomainUsersSid                       42 }
    { WinAccountDomainGuestsSid                      43 }
    { WinAccountComputersSid                         44 }
    { WinAccountControllersSid                       45 }
    { WinAccountCertAdminsSid                        46 }
    { WinAccountSchemaAdminsSid                      47 }
    { WinAccountEnterpriseAdminsSid                  48 }
    { WinAccountPolicyAdminsSid                      49 }
    { WinAccountRasAndIasServersSid                  50 }
    { WinNTLMAuthenticationSid                       51 }
    { WinDigestAuthenticationSid                     52 }
    { WinSChannelAuthenticationSid                   53 }
    { WinThisOrganizationSid                         54 }
    { WinOtherOrganizationSid                        55 }
    { WinBuiltinIncomingForestTrustBuildersSid       56 }
    { WinBuiltinPerfMonitoringUsersSid               57 }
    { WinBuiltinPerfLoggingUsersSid                  58 }
    { WinBuiltinAuthorizationAccessSid               59 }
    { WinBuiltinTerminalServerLicenseServersSid      60 }
    { WinBuiltinDCOMUsersSid                         61 }
    { WinBuiltinIUsersSid                            62 }
    { WinIUserSid                                    63 }
    { WinBuiltinCryptoOperatorsSid                   64 }
    { WinUntrustedLabelSid                           65 }
    { WinLowLabelSid                                 66 }
    { WinMediumLabelSid                              67 }
    { WinHighLabelSid                                68 }
    { WinSystemLabelSid                              69 }
    { WinWriteRestrictedCodeSid                      70 }
    { WinCreatorOwnerRightsSid                       71 }
    { WinCacheablePrincipalsGroupSid                 72 }
    { WinNonCacheablePrincipalsGroupSid              73 }
    { WinEnterpriseReadonlyControllersSid            74 }
    { WinAccountReadonlyControllersSid               75 }
    { WinBuiltinEventLogReadersGroup                 76 }
    { WinNewEnterpriseReadonlyControllersSid         77 }
    { WinBuiltinCertSvcDComAccessGroup               78 } ;

ENUM: TOKEN_INFORMATION_CLASS
    { TokenUser    1 }
    TokenGroups
    TokenPrivileges
    TokenOwner
    TokenPrimaryGroup
    TokenDefaultDacl
    TokenSource
    TokenType
    TokenImpersonationLevel
    TokenStatistics
    TokenRestrictedSids
    TokenSessionId
    TokenGroupsAndPrivileges
    TokenSessionReference
    TokenSandBoxInert
    TokenAuditPolicy
    TokenOrigin
    TokenElevationType
    TokenLinkedToken
    TokenElevation
    TokenHasRestrictions
    TokenAccessInformation
    TokenVirtualizationAllowed
    TokenVirtualizationEnabled
    TokenIntegrityLevel
    TokenUIAccess
    TokenMandatoryPolicy
    TokenLogonSid
    MaxTokenInfoClass ;

TYPEDEF: TOKEN_INFORMATION_CLASS* PTOKEN_INFORMATION_CLASS

TYPEDEF: uint ALG_ID

STRUCT: PUBLICKEYSTRUC
    { bType BYTE }
    { bVersion BYTE }
    { reserved WORD }
    { aiKeyAlg ALG_ID } ;

TYPEDEF: PUBLICKEYSTRUC BLOBHEADER
TYPEDEF: LONG HCRYPTHASH
TYPEDEF: LONG HCRYPTKEY
TYPEDEF: DWORD REGSAM

! : I_ScGetCurrentGroupStateW ;
! : A_SHAFinal ;
! : A_SHAInit ;
! : A_SHAUpdate ;
! : AbortSystemShutdownA ;
! : AbortSystemShutdownW ;
! : AccessCheck ;
! : AccessCheckAndAuditAlarmA ;
! : AccessCheckAndAuditAlarmW ;
! : AccessCheckByType ;
! : AccessCheckByTypeAndAuditAlarmA ;
! : AccessCheckByTypeAndAuditAlarmW ;
! : AccessCheckByTypeResultList ;
! : AccessCheckByTypeResultListAndAuditAlarmA ;
! : AccessCheckByTypeResultListAndAuditAlarmByHandleA ;
! : AccessCheckByTypeResultListAndAuditAlarmByHandleW ;
! : AccessCheckByTypeResultListAndAuditAlarmW ;
! : AddAccessAllowedAce ;
! : AddAccessAllowedAceEx ;
! : AddAccessAllowedObjectAce ;
! : AddAccessDeniedAce ;
! : AddAccessDeniedAceEx ;
! : AddAccessDeniedObjectAce ;
FUNCTION: BOOL AddAce ( PACL pAcl, DWORD dwAceRevision, DWORD dwStartingAceIndex, LPVOID pAceList, DWORD nAceListLength )
! : AddAuditAccessAce ;
! : AddAuditAccessAceEx ;
! : AddAuditAccessObjectAce ;
! : AddUsersToEncryptedFile ;
! : AdjustTokenGroups ;
FUNCTION: BOOL AdjustTokenPrivileges ( HANDLE TokenHandle,
                               BOOL DisableAllPrivileges,
                               PTOKEN_PRIVILEGES NewState,
                               DWORD BufferLength,
                               PTOKEN_PRIVILEGES PreviousState,
                               PDWORD ReturnLength )

FUNCTION: BOOL AllocateAndInitializeSid (
                PSID_IDENTIFIER_AUTHORITY pIdentifierAuthority,
                BYTE nSubAuthorityCount,
                DWORD dwSubAuthority0,
                DWORD dwSubAuthority1,
                DWORD dwSubAuthority2,
                DWORD dwSubAuthority3,
                DWORD dwSubAuthority4,
                DWORD dwSubAuthority5,
                DWORD dwSubAuthority6,
                DWORD dwSubAuthority7,
                PSID* pSid )

! : AllocateLocallyUniqueId ;
! : AreAllAccessesGranted ;
! : AreAnyAccessesGranted ;
! : BackupEventLogA ;
! : BackupEventLogW ;
! : BuildExplicitAccessWithNameA ;
! : BuildExplicitAccessWithNameW ;
! : BuildImpersonateExplicitAccessWithNameA ;
! : BuildImpersonateExplicitAccessWithNameW ;
! : BuildImpersonateTrusteeA ;
! : BuildImpersonateTrusteeW ;
! : BuildSecurityDescriptorA ;
! : BuildSecurityDescriptorW ;
! : BuildTrusteeWithNameA ;
! : BuildTrusteeWithNameW ;
! : BuildTrusteeWithObjectsAndNameA ;
! : BuildTrusteeWithObjectsAndNameW ;
! : BuildTrusteeWithObjectsAndSidA ;
! : BuildTrusteeWithObjectsAndSidW ;
! : BuildTrusteeWithSidA ;
! : BuildTrusteeWithSidW ;
! : CancelOverlappedAccess ;
! : ChangeServiceConfig2A ;
! : ChangeServiceConfig2W ;
! : ChangeServiceConfigA ;
! : ChangeServiceConfigW ;
! : CheckTokenMembership ;
! : ClearEventLogA ;
! : ClearEventLogW ;
! : CloseCodeAuthzLevel ;
! : CloseEncryptedFileRaw ;
! : CloseEventLog ;
! : CloseServiceHandle ;
! : CloseTrace ;
! : CommandLineFromMsiDescriptor ;
! : ComputeAccessTokenFromCodeAuthzLevel ;
! : ControlService ;
! : ControlTraceA ;
! : ControlTraceW ;
! : ConvertAccessToSecurityDescriptorA ;
! : ConvertAccessToSecurityDescriptorW ;
! : ConvertSDToStringSDRootDomainA ;
! : ConvertSDToStringSDRootDomainW ;
! : ConvertSecurityDescriptorToAccessA ;
! : ConvertSecurityDescriptorToAccessNamedA ;
! : ConvertSecurityDescriptorToAccessNamedW ;
! : ConvertSecurityDescriptorToAccessW ;
! : ConvertSecurityDescriptorToStringSecurityDescriptorA ;
! : ConvertSecurityDescriptorToStringSecurityDescriptorW ;
! : ConvertSidToStringSidA ;
! : ConvertSidToStringSidW ;
! : ConvertStringSDToSDDomainA ;
! : ConvertStringSDToSDDomainW ;
! : ConvertStringSDToSDRootDomainA ;
! : ConvertStringSDToSDRootDomainW ;
! : ConvertStringSecurityDescriptorToSecurityDescriptorA ;
! : ConvertStringSecurityDescriptorToSecurityDescriptorW ;
! : ConvertStringSidToSidA ;
! : ConvertStringSidToSidW ;
! : ConvertToAutoInheritPrivateObjectSecurity ;
! : CopySid ;
! : CreateCodeAuthzLevel ;
! : CreatePrivateObjectSecurity ;
! : CreatePrivateObjectSecurityEx ;
! : CreatePrivateObjectSecurityWithMultipleInheritance ;
! : CreateProcessAsUserA ;
! : CreateProcessAsUserSecure ;
! : CreateProcessAsUserW ;
! : CreateProcessWithLogonW ;
! : CreateRestrictedToken ;
! : CreateServiceA ;
! : CreateServiceW ;
! : CreateTraceInstanceId ;
FUNCTION: BOOL CreateWellKnownSid ( WELL_KNOWN_SID_TYPE WellKnownSidType, PSID DomainSid, PSID pSid, DWORD *cbSid )
! : CredDeleteA ;
! : CredDeleteW ;
! : CredEnumerateA ;
! : CredEnumerateW ;
! : CredFree ;
! : CredGetSessionTypes ;
! : CredGetTargetInfoA ;
! : CredGetTargetInfoW ;
! : CredIsMarshaledCredentialA ;
! : CredIsMarshaledCredentialW ;
! : CredMarshalCredentialA ;
! : CredMarshalCredentialW ;
! : CredProfileLoaded ;
! : CredReadA ;
! : CredReadDomainCredentialsA ;
! : CredReadDomainCredentialsW ;
! : CredReadW ;
! : CredRenameA ;
! : CredRenameW ;
! : CredUnmarshalCredentialA ;
! : CredUnmarshalCredentialW ;
! : CredWriteA ;
! : CredWriteDomainCredentialsA ;
! : CredWriteDomainCredentialsW ;
! : CredWriteW ;
! : CredpConvertCredential ;
! : CredpConvertTargetInfo ;
! : CredpDecodeCredential ;
! : CredpEncodeCredential ;
! : CryptAcquireContextA ;
FUNCTION: BOOL CryptAcquireContextW ( HCRYPTPROV* phProv,
                                      LPCTSTR pszContainer,
                                      LPCTSTR pszProvider,
                                      DWORD dwProvType,
                                      DWORD dwFlags )

ALIAS: CryptAcquireContext CryptAcquireContextW

! : CryptContextAddRef ;
FUNCTION: BOOL CryptCreateHash ( HCRYPTPROV hProv, ALG_ID Algid, HCRYPTKEY hKey, DWORD dwFlags, HCRYPTHASH *pHash )
! : CryptDecrypt ;
! : CryptDeriveKey ;
! : CryptDestroyHash ;
! : CryptDestroyKey ;
! : CryptDuplicateHash ;
! : CryptDuplicateKey ;
! : CryptEncrypt ;
! : CryptEnumProviderTypesA ;
! : CryptEnumProviderTypesW ;
! : CryptEnumProvidersA ;
! : CryptEnumProvidersW ;
! : CryptExportKey ;
! : CryptGenKey ;
FUNCTION: BOOL CryptGenRandom ( HCRYPTPROV hProv, DWORD dwLen, BYTE* pbBuffer )
! : CryptGetDefaultProviderA ;
! : CryptGetDefaultProviderW ;
! : CryptGetHashParam ;
! : CryptGetKeyParam ;
! : CryptGetProvParam ;
! : CryptGetUserKey ;
! : CryptHashData ;
! : CryptHashSessionKey ;
FUNCTION: BOOL CryptImportKey ( HCRYPTPROV hProv, BYTE *pbData, DWORD dwDataLen, HCRYPTKEY hPubKey, DWORD dwFlags, HCRYPTKEY *phKey )
FUNCTION: BOOL CryptReleaseContext ( HCRYPTPROV hProv, DWORD dwFlags )
! : CryptSetHashParam ;
! : CryptSetKeyParam ;
! : CryptSetProvParam ;
! : CryptSetProviderA ;
! : CryptSetProviderExA ;
! : CryptSetProviderExW ;
! : CryptSetProviderW ;
! : CryptSignHashA ;
! : CryptSignHashW ;
! : CryptVerifySignatureA ;
! : CryptVerifySignatureW ;
! : DecryptFileA ;
! : DecryptFileW ;
! : DeleteAce ;
! : DeleteService ;
! : DeregisterEventSource ;
! : DestroyPrivateObjectSecurity ;
! : DuplicateEncryptionInfoFile ;
! : DuplicateToken ;
! : DuplicateTokenEx ;
! : ElfBackupEventLogFileA ;
! : ElfBackupEventLogFileW ;
! : ElfChangeNotify ;
! : ElfClearEventLogFileA ;
! : ElfClearEventLogFileW ;
! : ElfCloseEventLog ;
! : ElfDeregisterEventSource ;
! : ElfFlushEventLog ;
! : ElfNumberOfRecords ;
! : ElfOldestRecord ;
! : ElfOpenBackupEventLogA ;
! : ElfOpenBackupEventLogW ;
! : ElfOpenEventLogA ;
! : ElfOpenEventLogW ;
! : ElfReadEventLogA ;
! : ElfReadEventLogW ;
! : ElfRegisterEventSourceA ;
! : ElfRegisterEventSourceW ;
! : ElfReportEventA ;
! : ElfReportEventW ;
! : EnableTrace ;
! : EncryptFileA ;
! : EncryptFileW ;
! : EncryptedFileKeyInfo ;
! : EncryptionDisable ;
! : EnumDependentServicesA ;
! : EnumDependentServicesW ;
! : EnumServiceGroupW ;
! : EnumServicesStatusA ;
! : EnumServicesStatusExA ;
! : EnumServicesStatusExW ;
! : EnumServicesStatusW ;
! : EnumerateTraceGuids ;
! : EqualDomainSid ;
! : EqualPrefixSid ;
! : EqualSid ;
! : FileEncryptionStatusA ;
! : FileEncryptionStatusW ;
! : FindFirstFreeAce ;
! : FlushTraceA ;
! : FlushTraceW ;
! : FreeEncryptedFileKeyInfo ;
! : FreeEncryptionCertificateHashList ;
! : FreeInheritedFromArray ;
! : FreeSid ;
! : GetAccessPermissionsForObjectA ;
! : GetAccessPermissionsForObjectW ;
! : GetAce ;
! : GetAclInformation ;
! : GetAuditedPermissionsFromAclA ;
! : GetAuditedPermissionsFromAclW ;
! : GetCurrentHwProfileA ;
! : GetCurrentHwProfileW ;
! : GetEffectiveRightsFromAclA ;
! : GetEffectiveRightsFromAclW ;
! : GetEventLogInformation ;
! : GetExplicitEntriesFromAclA ;
! : GetExplicitEntriesFromAclW ;
! : GetFileSecurityA ;
FUNCTION: BOOL GetFileSecurityW ( LPCTSTR lpFileName, SECURITY_INFORMATION RequestedInformation, PSECURITY_DESCRIPTOR pSecurityDescriptor, DWORD nLength, LPDWORD lpnLengthNeeded )
ALIAS: GetFileSecurity GetFileSecurityW
! : GetInformationCodeAuthzLevelW ;
! : GetInformationCodeAuthzPolicyW ;
! : GetInheritanceSourceA ;
! : GetInheritanceSourceW ;
! : GetKernelObjectSecurity ;
! : GetLengthSid ;
! : GetLocalManagedApplicationData ;
! : GetLocalManagedApplications ;
! : GetManagedApplicationCategories ;
! : GetManagedApplications ;
! : GetMultipleTrusteeA ;
! : GetMultipleTrusteeOperationA ;
! : GetMultipleTrusteeOperationW ;
! : GetMultipleTrusteeW ;
! : GetNamedSecurityInfoA ;
! : GetNamedSecurityInfoExA ;
! FUNCTION: DWORD GetNamedSecurityInfoExW
FUNCTION: DWORD GetNamedSecurityInfoW ( LPTSTR pObjectName, SE_OBJECT_TYPE ObjectType, SECURITY_INFORMATION SecurityInfo, PSID* ppsidOwner, PSID* ppsidGroup, PACL* ppDacl, PACL* ppSacl, PSECURITY_DESCRIPTOR* ppSecurityDescriptor )
ALIAS: GetNamedSecurityInfo GetNamedSecurityInfoW
! : GetNumberOfEventLogRecords ;
! : GetOldestEventLogRecord ;
! : GetOverlappedAccessResults ;
! : GetPrivateObjectSecurity ;
FUNCTION: BOOL GetSecurityDescriptorControl ( PSECURITY_DESCRIPTOR pSecurityDescriptor, PSECURITY_DESCRIPTOR_CONTROL pControl, LPDWORD lpdwRevision )
FUNCTION: BOOL GetSecurityDescriptorDacl ( PSECURITY_DESCRIPTOR pSecurityDescriptor, LPBOOL lpbDaclPresent, PACL* pDacl, LPBOOL lpDaclDefaulted )
FUNCTION: BOOL GetSecurityDescriptorGroup ( PSECURITY_DESCRIPTOR pSecurityDescriptor, PSID* pGroup, LPBOOL lpGroupDefaulted )
FUNCTION: BOOL GetSecurityDescriptorLength ( PSECURITY_DESCRIPTOR pSecurityDescriptor )
FUNCTION: BOOL GetSecurityDescriptorOwner ( PSECURITY_DESCRIPTOR pSecurityDescriptor, PSID* pOwner, LPBOOL lpOwnerDefaulted )
FUNCTION: BOOL GetSecurityDescriptorRMControl ( PSECURITY_DESCRIPTOR pSecurityDescriptor, PUCHAR RMControl )
FUNCTION: BOOL GetSecurityDescriptorSacl ( PSECURITY_DESCRIPTOR pSecurityDescriptor, LPBOOL lpbSaclPresent, PACL* pSacl, LPBOOL lpSaclDefaulted )
! : GetSecurityInfo ;
! : GetSecurityInfoExA ;
! : GetSecurityInfoExW ;
! : GetServiceDisplayNameA ;
! : GetServiceDisplayNameW ;
! : GetServiceKeyNameA ;
! : GetServiceKeyNameW ;
! : GetSidIdentifierAuthority ;
! : GetSidLengthRequired ;
! : GetSidSubAuthority ;
! : GetSidSubAuthorityCount ;
FUNCTION: BOOL GetTokenInformation ( HANDLE TokenHandle, TOKEN_INFORMATION_CLASS TokenInformationClass, LPVOID TokenInformation, DWORD TokenInformationLenghth, PWORD ReturnLength )
! : GetTraceEnableFlags ;
! : GetTraceEnableLevel ;
! : GetTraceLoggerHandle ;
! : GetTrusteeFormA ;
! : GetTrusteeFormW ;
! : GetTrusteeNameA ;
! : GetTrusteeNameW ;
! : GetTrusteeTypeA ;
! : GetTrusteeTypeW ;

! : GetUserNameA ;
FUNCTION: BOOL GetUserNameW ( LPCTSTR lpBuffer, LPDWORD lpnSize )
ALIAS: GetUserName GetUserNameW

! : GetWindowsAccountDomainSid ;
! : I_ScIsSecurityProcess ;
! : I_ScPnPGetServiceName ;
! : I_ScSendTSMessage ;
! : I_ScSetServiceBitsA ;
! : I_ScSetServiceBitsW ;
! : IdentifyCodeAuthzLevelW ;
! : ImpersonateAnonymousToken ;
! : ImpersonateLoggedOnUser ;
! : ImpersonateNamedPipeClient ;
! : ImpersonateSelf ;
FUNCTION: BOOL InitializeAcl ( PACL pAcl, DWORD nAclLength, DWORD dwAclRevision )
FUNCTION: BOOL InitializeSecurityDescriptor ( PSECURITY_DESCRIPTOR pSecurityDescriptor, DWORD dwRevision )
! : InitializeSid ;
! : InitiateSystemShutdownA ;
! : InitiateSystemShutdownExA ;
! : InitiateSystemShutdownExW ;
! : InitiateSystemShutdownW ;
! : InstallApplication ;
! : IsTextUnicode ;
! : IsTokenRestricted ;
! : IsTokenUntrusted ;
! : IsValidAcl ;
! : IsValidSecurityDescriptor ;
! : IsValidSid ;
! : IsWellKnownSid ;
! : LockServiceDatabase ;
! : LogonUserA ;
! : LogonUserExA ;
! : LogonUserExW ;
! : LogonUserW ;
! : LookupAccountNameA ;
! : LookupAccountNameW ;
! : LookupAccountSidA ;
! : LookupAccountSidW ;
! : LookupPrivilegeDisplayNameA ;
! : LookupPrivilegeDisplayNameW ;
! : LookupPrivilegeNameA ;
! : LookupPrivilegeNameW ;
! : LookupPrivilegeValueA ;
FUNCTION: BOOL LookupPrivilegeValueW ( LPCTSTR lpSystemName,
                               LPCTSTR lpName,
                               PLUID lpLuid )
ALIAS: LookupPrivilegeValue LookupPrivilegeValueW

! : LookupSecurityDescriptorPartsA ;
! : LookupSecurityDescriptorPartsW ;
! : LsaAddAccountRights ;
! : LsaAddPrivilegesToAccount ;
! : LsaClearAuditLog ;
! : LsaClose ;
! : LsaCreateAccount ;
! : LsaCreateSecret ;
! : LsaCreateTrustedDomain ;
! : LsaCreateTrustedDomainEx ;
! : LsaDelete ;
! : LsaDeleteTrustedDomain ;
! : LsaEnumerateAccountRights ;
! : LsaEnumerateAccounts ;
! : LsaEnumerateAccountsWithUserRight ;
! : LsaEnumeratePrivileges ;
! : LsaEnumeratePrivilegesOfAccount ;
! : LsaEnumerateTrustedDomains ;
! : LsaEnumerateTrustedDomainsEx ;
! : LsaFreeMemory ;
! : LsaGetQuotasForAccount ;
! : LsaGetRemoteUserName ;
! : LsaGetSystemAccessAccount ;
! : LsaGetUserName ;
! : LsaICLookupNames ;
! : LsaICLookupNamesWithCreds ;
! : LsaICLookupSids ;
! : LsaICLookupSidsWithCreds ;
! : LsaLookupNames2 ;
! : LsaLookupNames ;
! : LsaLookupPrivilegeDisplayName ;
! : LsaLookupPrivilegeName ;
! : LsaLookupPrivilegeValue ;
! : LsaLookupSids ;
! : LsaNtStatusToWinError ;
! : LsaOpenAccount ;
! : LsaOpenPolicy ;
! : LsaOpenPolicySce ;
! : LsaOpenSecret ;
! : LsaOpenTrustedDomain ;
! : LsaOpenTrustedDomainByName ;
! : LsaQueryDomainInformationPolicy ;
! : LsaQueryForestTrustInformation ;
! : LsaQueryInfoTrustedDomain ;
! : LsaQueryInformationPolicy ;
! : LsaQuerySecret ;
! : LsaQuerySecurityObject ;
! : LsaQueryTrustedDomainInfo ;
! : LsaQueryTrustedDomainInfoByName ;
! : LsaRemoveAccountRights ;
! : LsaRemovePrivilegesFromAccount ;
! : LsaRetrievePrivateData ;
! : LsaSetDomainInformationPolicy ;
! : LsaSetForestTrustInformation ;
! : LsaSetInformationPolicy ;
! : LsaSetInformationTrustedDomain ;
! : LsaSetQuotasForAccount ;
! : LsaSetSecret ;
! : LsaSetSecurityObject ;
! : LsaSetSystemAccessAccount ;
! : LsaSetTrustedDomainInfoByName ;
! : LsaSetTrustedDomainInformation ;
! : LsaStorePrivateData ;
! : MD4Final ;
! : MD4Init ;
! : MD4Update ;
! : MD5Final ;
! : MD5Init ;
! : MD5Update ;
! : MSChapSrvChangePassword2 ;
! : MSChapSrvChangePassword ;
! : MakeAbsoluteSD2 ;
! : MakeAbsoluteSD ;
! : MakeSelfRelativeSD ;
! : MapGenericMask ;
! : NotifyBootConfigStatus ;
! : NotifyChangeEventLog ;
! : ObjectCloseAuditAlarmA ;
! : ObjectCloseAuditAlarmW ;
! : ObjectDeleteAuditAlarmA ;
! : ObjectDeleteAuditAlarmW ;
! : ObjectOpenAuditAlarmA ;
! : ObjectOpenAuditAlarmW ;
! : ObjectPrivilegeAuditAlarmA ;
! : ObjectPrivilegeAuditAlarmW ;
! : OpenBackupEventLogA ;
! : OpenBackupEventLogW ;
! : OpenEncryptedFileRawA ;
! : OpenEncryptedFileRawW ;
! : OpenEventLogA ;
! : OpenEventLogW ;

FUNCTION: BOOL OpenProcessToken ( HANDLE ProcessHandle,
                                  DWORD DesiredAccess,
                                  PHANDLE TokenHandle )
! : OpenSCManagerA ;
! : OpenSCManagerW ;
! : OpenServiceA ;
! : OpenServiceW ;
FUNCTION: BOOL OpenThreadToken ( HANDLE ThreadHandle, DWORD DesiredAccess, BOOL OpenAsSelf, PHANDLE TokenHandle )
! : OpenTraceA ;
! : OpenTraceW ;
! : PrivilegeCheck ;
! : PrivilegedServiceAuditAlarmA ;
! : PrivilegedServiceAuditAlarmW ;
! : ProcessIdleTasks ;
! : ProcessTrace ;
! : QueryAllTracesA ;
! : QueryAllTracesW ;
! : QueryRecoveryAgentsOnEncryptedFile ;
! : QueryServiceConfig2A ;
! : QueryServiceConfig2W ;
! : QueryServiceConfigA ;
! : QueryServiceConfigW ;
! : QueryServiceLockStatusA ;
! : QueryServiceLockStatusW ;
! : QueryServiceObjectSecurity ;
! : QueryServiceStatus ;
! : QueryServiceStatusEx ;
! : QueryTraceA ;
! : QueryTraceW ;
! : QueryUsersOnEncryptedFile ;
! : QueryWindows31FilesMigration ;
! : ReadEncryptedFileRaw ;
! : ReadEventLogA ;
! : ReadEventLogW ;
FUNCTION: LONG RegCloseKey ( HKEY hKey )
! : RegConnectRegistryA ;
! : RegConnectRegistryW ;
! : RegCreateKeyA ;
! : RegCreateKeyExA ;
FUNCTION: LONG RegCreateKeyExW ( HKEY hKey, LPCTSTR lpSubKey, DWORD Reserved, LPTSTR lpClass, DWORD dwOptions, REGSAM samDesired, LPSECURITY_ATTRIBUTES lpSecurityAttributes, PHKEY phkResult, LPDWORD lpdwDisposition )
ALIAS: RegCreateKeyEx RegCreateKeyExW
! : RegCreateKeyW
! : RegDeleteKeyA ;
! : RegDeleteKeyW ;

FUNCTION: LONG RegDeleteKeyExW (
        HKEY hKey,
        LPCTSTR lpSubKey,
        DWORD Reserved,
        LPTSTR lpClass,
        DWORD dwOptions,
        REGSAM samDesired,
        LPSECURITY_ATTRIBUTES lpSecurityAttributes,
        PHKEY phkResult,
        LPDWORD lpdwDisposition
    )

ALIAS: RegDeleteKeyEx RegDeleteKeyExW

! : RegDeleteValueA ;

FUNCTION: LONG RegDeleteValueW (
        HKEY    hKey,
        LPCWSTR lpValueName
    )

ALIAS: RegDeleteValue RegDeleteValueW

! : RegDisablePredefinedCache ;
! : RegEnumKeyA ;
! : RegEnumKeyExA ;

FUNCTION: LONG RegEnumKeyExW (
        HKEY hKey,
        DWORD dwIndex,
        LPTSTR lpName,
        LPDWORD lpcName,
        LPDWORD lpReserved,
        LPTSTR lpClass,
        LPDWORD lpcClass,
        PFILETIME lpftLastWriteTime
    )
ALIAS: RegEnumKeyEx RegEnumKeyExW

! : RegEnumKeyW ;
! : RegEnumValueA ;

FUNCTION: LONG RegEnumValueW (
        HKEY hKey,
        DWORD dwIndex,
        LPTSTR lpValueName,
        LPDWORD lpcchValueName,
        LPDWORD lpReserved,
        LPDWORD lpType,
        LPBYTE lpData,
        LPDWORD lpcbData
    )

ALIAS: RegEnumValue RegEnumValueW

! : RegFlushKey ;
! : RegGetKeySecurity ;
! : RegLoadKeyA ;
! : RegLoadKeyW ;
! : RegNotifyChangeKeyValue ;
FUNCTION: LONG RegOpenCurrentUser ( REGSAM samDesired, PHKEY phkResult )
! : RegOpenKeyA ;
! : RegOpenKeyExA ;
FUNCTION: LONG RegOpenKeyExW ( HKEY hKey, LPCTSTR lpSubKey, DWORD ulOptions, REGSAM samDesired, PHKEY phkResult )
ALIAS: RegOpenKeyEx RegOpenKeyExW
! : RegOpenKeyW ;
! : RegOpenUserClassesRoot ;
! : RegOverridePredefKey ;
! : RegQueryInfoKeyA ;
FUNCTION: LONG RegQueryInfoKeyW (
        HKEY hKey,
        LPTSTR lpClass,
        LPDWORD lpcClass,
        LPDWORD lpReserved,
        LPDWORD lpcSubKeys,
        LPDWORD lpcMaxSubKeyLen,
        LPDWORD lpcMaxClassLen,
        LPDWORD lpcValues,
        LPDWORD lpcMaxValueNameLen,
        LPDWORD lpcMaxValueLen,
        LPDWORD lpcbSecurityDescriptor,
        PFILETIME lpftLastWriteTime
    )
ALIAS: RegQueryInfoKey RegQueryInfoKeyW
! : RegQueryMultipleValuesA ;
! : RegQueryMultipleValuesW ;
! : RegQueryValueA ;
! : RegQueryValueExA ;
FUNCTION: LONG RegQueryValueExW ( HKEY hKey, LPCTSTR lpValueName, LPDWORD lpReserved, LPDWORD lpType, LPBYTE lpData, LPDWORD lpcbData )
ALIAS: RegQueryValueEx RegQueryValueExW
! : RegQueryValueW ;
! : RegReplaceKeyA ;
! : RegReplaceKeyW ;
! : RegRestoreKeyA ;
! : RegRestoreKeyW ;
! : RegSaveKeyA ;
! : RegSaveKeyExA ;
! : RegSaveKeyExW ;
! : RegSaveKeyW ;
! : RegSetKeySecurity ;
! : RegSetValueA ;
! : RegSetValueExA ;
! : RegSetValueExW ;
FUNCTION: LONG RegSetValueExW ( HKEY hKey, LPCTSTR lpValueName, DWORD Reserved, DWORD dwType, BYTE* lpData, DWORD cbData )
ALIAS: RegSetValueEx RegSetValueExW
! : RegUnLoadKeyA ;
! : RegUnLoadKeyW ;
! : RegisterEventSourceA ;
! : RegisterEventSourceW ;
! : RegisterIdleTask ;
! : RegisterServiceCtrlHandlerA ;
! : RegisterServiceCtrlHandlerExA ;
! : RegisterServiceCtrlHandlerExW ;
! : RegisterServiceCtrlHandlerW ;
! : RegisterTraceGuidsA ;
! : RegisterTraceGuidsW ;
! : RemoveTraceCallback ;
! : RemoveUsersFromEncryptedFile ;
! : ReportEventA ;
! : ReportEventW ;
! : RevertToSelf ;
! : SaferCloseLevel ;
! : SaferComputeTokenFromLevel ;
! : SaferCreateLevel ;
! : SaferGetLevelInformation ;
! : SaferGetPolicyInformation ;
! : SaferIdentifyLevel ;
! : SaferRecordEventLogEntry ;
! : SaferSetLevelInformation ;
! : SaferSetPolicyInformation ;
! : SaferiChangeRegistryScope ;
! : SaferiCompareTokenLevels ;
! : SaferiIsExecutableFileType ;
! : SaferiPopulateDefaultsInRegistry ;
! : SaferiRecordEventLogEntry ;
! : SaferiReplaceProcessThreadTokens ;
! : SaferiSearchMatchingHashRules ;
! : SetAclInformation ;
! : SetEntriesInAccessListA ;
! : SetEntriesInAccessListW ;
! : SetEntriesInAclA ;
FUNCTION: DWORD SetEntriesInAclW ( ULONG cCountOfExplicitEntries, PEXPLICIT_ACCESS pListOfExplicitEntries, PACL OldAcl, PACL* NewAcl )
ALIAS: SetEntriesInAcl SetEntriesInAclW
! : SetEntriesInAuditListA ;
! : SetEntriesInAuditListW ;
! : SetFileSecurityA ;
! : SetFileSecurityW ;
! : SetInformationCodeAuthzLevelW ;
! : SetInformationCodeAuthzPolicyW ;
! : SetKernelObjectSecurity ;
! : SetNamedSecurityInfoA ;
! : SetNamedSecurityInfoExA ;
! : SetNamedSecurityInfoExW ;
FUNCTION: DWORD SetNamedSecurityInfoW ( LPTSTR pObjectName, SE_OBJECT_TYPE ObjectType, SECURITY_INFORMATION SecurityInfo, PSID psidOwner, PSID psidGroup, PACL pDacl, PACL pSacl )
ALIAS: SetNamedSecurityInfo SetNamedSecurityInfoW
! : SetPrivateObjectSecurity ;
! : SetPrivateObjectSecurityEx ;
! : SetSecurityDescriptorControl ;
! : SetSecurityDescriptorDacl ;
! : SetSecurityDescriptorGroup ;
! : SetSecurityDescriptorOwner ;
! : SetSecurityDescriptorRMControl ;
! : SetSecurityDescriptorSacl ;
! : SetSecurityInfo ;
! : SetSecurityInfoExA ;
! : SetSecurityInfoExW ;
! : SetServiceBits ;
! : SetServiceObjectSecurity ;
! : SetServiceStatus ;
! : SetThreadToken ;
! : SetTokenInformation ;
! : SetTraceCallback ;
! : SetUserFileEncryptionKey ;
! : StartServiceA ;
! : StartServiceCtrlDispatcherA ;
! : StartServiceCtrlDispatcherW ;
! : StartServiceW ;
! : StartTraceA ;
! : StartTraceW ;
! : StopTraceA ;
! : StopTraceW ;
! : SynchronizeWindows31FilesAndWindowsNTRegistry ;
! : SystemFunction001 ;
! : SystemFunction002 ;
! : SystemFunction003 ;
! : SystemFunction004 ;
! : SystemFunction005 ;
! : SystemFunction006 ;
! : SystemFunction007 ;
! : SystemFunction008 ;
! : SystemFunction009 ;
! : SystemFunction010 ;
! : SystemFunction011 ;
! : SystemFunction012 ;
! : SystemFunction013 ;
! : SystemFunction014 ;
! : SystemFunction015 ;
! : SystemFunction016 ;
! : SystemFunction017 ;
! : SystemFunction018 ;
! : SystemFunction019 ;
! : SystemFunction020 ;
! : SystemFunction021 ;
! : SystemFunction022 ;
! : SystemFunction023 ;
! : SystemFunction024 ;
! : SystemFunction025 ;
! : SystemFunction026 ;
! : SystemFunction027 ;
! : SystemFunction028 ;
! : SystemFunction029 ;
! : SystemFunction030 ;
! : SystemFunction031 ;
! : SystemFunction032 ;
! : SystemFunction033 ;
! : SystemFunction034 ;
! : SystemFunction035 ;
! : SystemFunction036 ;
! : SystemFunction040 ;
! : SystemFunction041 ;
! : TraceEvent ;
! : TraceEventInstance ;
! : TraceMessage ;
! : TraceMessageVa ;
! : TreeResetNamedSecurityInfoA ;
! : TreeResetNamedSecurityInfoW ;
! : TrusteeAccessToObjectA ;
! : TrusteeAccessToObjectW ;
! : UninstallApplication ;
! : UnlockServiceDatabase ;
! : UnregisterIdleTask ;
! : UnregisterTraceGuids ;
! : UpdateTraceA ;
! : UpdateTraceW ;
! : WdmWmiServiceMain ;
! : WmiCloseBlock ;
! : WmiCloseTraceWithCursor ;
! : WmiConvertTimestamp ;
! : WmiDevInstToInstanceNameA ;
! : WmiDevInstToInstanceNameW ;
! : WmiEnumerateGuids ;
! : WmiExecuteMethodA ;
! : WmiExecuteMethodW ;
! : WmiFileHandleToInstanceNameA ;
! : WmiFileHandleToInstanceNameW ;
! : WmiFreeBuffer ;
! : WmiGetFirstTraceOffset ;
! : WmiGetNextEvent ;
! : WmiGetTraceHeader ;
! : WmiMofEnumerateResourcesA ;
! : WmiMofEnumerateResourcesW ;
! : WmiNotificationRegistrationA ;
! : WmiNotificationRegistrationW ;
! : WmiOpenBlock ;
! : WmiOpenTraceWithCursor ;
! : WmiParseTraceEvent ;
! : WmiQueryAllDataA ;
! : WmiQueryAllDataMultipleA ;
! : WmiQueryAllDataMultipleW ;
! : WmiQueryAllDataW ;
! : WmiQueryGuidInformation ;
! : WmiQuerySingleInstanceA ;
! : WmiQuerySingleInstanceMultipleA ;
! : WmiQuerySingleInstanceMultipleW ;
! : WmiQuerySingleInstanceW ;
! : WmiReceiveNotificationsA ;
! : WmiReceiveNotificationsW ;
! : WmiSetSingleInstanceA ;
! : WmiSetSingleInstanceW ;
! : WmiSetSingleItemA ;
! : WmiSetSingleItemW ;
! : Wow64Win32ApiEntry ;
! : WriteEncryptedFileRaw ;
