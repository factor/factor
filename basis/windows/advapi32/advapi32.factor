USING: alien.syntax kernel math windows.types math.bitwise ;
IN: windows.advapi32

LIBRARY: advapi32

CONSTANT: PROV_RSA_FULL       1
CONSTANT: PROV_RSA_SIG        2
CONSTANT: PROV_DSS            3
CONSTANT: PROV_FORTEZZA       4
CONSTANT: PROV_MS_EXCHANGE    5
CONSTANT: PROV_SSL            6
CONSTANT: PROV_RSA_SCHANNEL  12
CONSTANT: PROV_DSS_DH        13
CONSTANT: PROV_EC_ECDSA_SIG  14
CONSTANT: PROV_EC_ECNRA_SIG  15
CONSTANT: PROV_EC_ECDSA_FULL 16
CONSTANT: PROV_EC_ECNRA_FULL 17
CONSTANT: PROV_DH_SCHANNEL   18
CONSTANT: PROV_SPYRUS_LYNKS  20
CONSTANT: PROV_RNG           21
CONSTANT: PROV_INTEL_SEC     22
CONSTANT: PROV_REPLACE_OWF   23
CONSTANT: PROV_RSA_AES       24

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

CONSTANT: CRYPT_VERIFYCONTEXT  HEX: F0000000
CONSTANT: CRYPT_NEWKEYSET      HEX: 8
CONSTANT: CRYPT_DELETEKEYSET   HEX: 10
CONSTANT: CRYPT_MACHINE_KEYSET HEX: 20
CONSTANT: CRYPT_SILENT         HEX: 40

C-STRUCT: ACL
    { "BYTE" "AclRevision" }
    { "BYTE" "Sbz1" }
    { "WORD" "AclSize" }
    { "WORD" "AceCount" }
    { "WORD" "Sbz2" } ;

TYPEDEF: ACL* PACL

CONSTANT: ACCESS_ALLOWED_ACE_TYPE 0
CONSTANT: ACCESS_DENIED_ACE_TYPE 1
CONSTANT: SYSTEM_AUDIT_ACE_TYPE 2
CONSTANT: SYSTEM_ALARM_ACE_TYPE 3

CONSTANT: OBJECT_INHERIT_ACE HEX: 1
CONSTANT: CONTAINER_INHERIT_ACE HEX: 2
CONSTANT: NO_PROPAGATE_INHERIT_ACE HEX: 4
CONSTANT: INHERIT_ONLY_ACE HEX: 8
CONSTANT: VALID_INHERIT_FLAGS HEX: f

C-STRUCT: ACE_HEADER
    { "BYTE" "AceType" }
    { "BYTE" "AceFlags" }
    { "WORD" "AceSize" } ;

TYPEDEF: ACE_HEADER* PACE_HEADER

C-STRUCT: ACCESS_ALLOWED_ACE
    { "ACE_HEADER" "Header" }
    { "DWORD" "Mask" }
    { "DWORD" "SidStart" } ;

TYPEDEF: ACCESS_ALLOWED_ACE* PACCESS_ALLOWED_ACE

C-STRUCT: ACCESS_DENIED_ACE
    { "ACE_HEADER" "Header" }
    { "DWORD" "Mask" }
    { "DWORD" "SidStart" } ;
TYPEDEF: ACCESS_DENIED_ACE* PACCESS_DENIED_ACE


C-STRUCT: SYSTEM_AUDIT_ACE
    { "ACE_HEADER" "Header" }
    { "DWORD" "Mask" }
    { "DWORD" "SidStart" } ;

TYPEDEF: SYSTEM_AUDIT_ACE* PSYSTEM_AUDIT_ACE

C-STRUCT: SYSTEM_ALARM_ACE
    { "ACE_HEADER" "Header" }
    { "DWORD" "Mask" }
    { "DWORD" "SidStart" } ;

TYPEDEF: SYSTEM_ALARM_ACE* PSYSTEM_ALARM_ACE

C-STRUCT: ACCESS_ALLOWED_CALLBACK_ACE
    { "ACE_HEADER" "Header" }
    { "DWORD" "Mask" }
    { "DWORD" "SidStart" } ;

TYPEDEF: ACCESS_ALLOWED_CALLBACK_ACE* PACCESS_ALLOWED_CALLBACK_ACE

C-STRUCT: SECURITY_DESCRIPTOR
    { "UCHAR" "Revision" }
    { "UCHAR" "Sbz1" }
    { "WORD" "Control" }
    { "PVOID" "Owner" }
    { "PVOID" "Group" }
    { "PACL" "Sacl" }
    { "PACL" "Dacl" } ;

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


! typedef enum _TOKEN_INFORMATION_CLASS {
CONSTANT: TokenUser 1
CONSTANT: TokenGroups 2
CONSTANT: TokenPrivileges 3
CONSTANT: TokenOwner 4
CONSTANT: TokenPrimaryGroup 5
CONSTANT: TokenDefaultDacl 6
CONSTANT: TokenSource 7
CONSTANT: TokenType 8
CONSTANT: TokenImpersonationLevel 9
CONSTANT: TokenStatistics 10
CONSTANT: TokenRestrictedSids 11
CONSTANT: TokenSessionId 12
CONSTANT: TokenGroupsAndPrivileges 13
CONSTANT: TokenSessionReference 14
CONSTANT: TokenSandBoxInert 15
! } TOKEN_INFORMATION_CLASS;

TYPEDEF: DWORD ACCESS_MODE
C-ENUM:
    NOT_USED_ACCESS
    GRANT_ACCESS
    SET_ACCESS
    DENY_ACCESS
    REVOKE_ACCESS
    SET_AUDIT_SUCCESS
    SET_AUDIT_FAILURE ;

TYPEDEF: DWORD MULTIPLE_TRUSTEE_OPERATION
C-ENUM:
    NO_MULTIPLE_TRUSTEE
    TRUSTEE_IS_IMPERSONATE ;

TYPEDEF: DWORD TRUSTEE_FORM
C-ENUM:
  TRUSTEE_IS_SID
  TRUSTEE_IS_NAME
  TRUSTEE_BAD_FORM
  TRUSTEE_IS_OBJECTS_AND_SID
  TRUSTEE_IS_OBJECTS_AND_NAME ;

TYPEDEF: DWORD TRUSTEE_TYPE
C-ENUM:
    TRUSTEE_IS_UNKNOWN
    TRUSTEE_IS_USER
    TRUSTEE_IS_GROUP
    TRUSTEE_IS_DOMAIN
    TRUSTEE_IS_ALIAS
    TRUSTEE_IS_WELL_KNOWN_GROUP
    TRUSTEE_IS_DELETED
    TRUSTEE_IS_INVALID
    TRUSTEE_IS_COMPUTER ;

TYPEDEF: DWORD SE_OBJECT_TYPE
C-ENUM:
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

TYPEDEF: TRUSTEE* PTRUSTEE

C-STRUCT: TRUSTEE
    { "PTRUSTEE" "pMultipleTrustee" }
    { "MULTIPLE_TRUSTEE_OPERATION" "MultipleTrusteeOperation" }
    { "TRUSTEE_FORM" "TrusteeForm" }
    { "TRUSTEE_TYPE" "TrusteeType" }
    { "LPTSTR" "ptstrName" } ;

C-STRUCT: EXPLICIT_ACCESS
    { "DWORD" "grfAccessPermissions" }
    { "ACCESS_MODE" "grfAccessMode" }
    { "DWORD" "grfInheritance" }
    { "TRUSTEE" "Trustee" } ;

C-STRUCT: SID_IDENTIFIER_AUTHORITY
    { { "BYTE" 6 } "Value" } ;

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

! SID is a variable length structure
TYPEDEF: void* PSID

TYPEDEF: EXPLICIT_ACCESS* PEXPLICIT_ACCESS

TYPEDEF: DWORD SECURITY_INFORMATION
TYPEDEF: SECURITY_INFORMATION* PSECURITY_INFORMATION

CONSTANT: OWNER_SECURITY_INFORMATION 1
CONSTANT: GROUP_SECURITY_INFORMATION 2
CONSTANT: DACL_SECURITY_INFORMATION 4
CONSTANT: SACL_SECURITY_INFORMATION 8

CONSTANT: DELETE                     HEX: 00010000
CONSTANT: READ_CONTROL               HEX: 00020000
CONSTANT: WRITE_DAC                  HEX: 00040000
CONSTANT: WRITE_OWNER                HEX: 00080000
CONSTANT: SYNCHRONIZE                HEX: 00100000
CONSTANT: STANDARD_RIGHTS_REQUIRED   HEX: 000f0000

ALIAS: STANDARD_RIGHTS_READ       READ_CONTROL
ALIAS: STANDARD_RIGHTS_WRITE      READ_CONTROL
ALIAS: STANDARD_RIGHTS_EXECUTE    READ_CONTROL

CONSTANT: TOKEN_TOKEN_ADJUST_DEFAULT   HEX: 0080
CONSTANT: TOKEN_ADJUST_GROUPS          HEX: 0040
CONSTANT: TOKEN_ADJUST_PRIVILEGES      HEX: 0020
CONSTANT: TOKEN_ADJUST_SESSIONID       HEX: 0100
CONSTANT: TOKEN_ASSIGN_PRIMARY         HEX: 0001
CONSTANT: TOKEN_DUPLICATE              HEX: 0002
ALIAS: TOKEN_EXECUTE                STANDARD_RIGHTS_EXECUTE
CONSTANT: TOKEN_IMPERSONATE            HEX: 0004
CONSTANT: TOKEN_QUERY                  HEX: 0008
CONSTANT: TOKEN_QUERY_SOURCE           HEX: 0010
CONSTANT: TOKEN_ADJUST_DEFAULT         HEX: 0080
: TOKEN_READ ( -- n ) { STANDARD_RIGHTS_READ TOKEN_QUERY } flags ;

: TOKEN_WRITE ( -- n )
    {
        STANDARD_RIGHTS_WRITE
        TOKEN_ADJUST_PRIVILEGES
        TOKEN_ADJUST_GROUPS
        TOKEN_ADJUST_DEFAULT
    } flags ; foldable

: TOKEN_ALL_ACCESS ( -- n )
    {
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
    } flags ; foldable

CONSTANT: HKEY_CLASSES_ROOT        HEX: 80000000
CONSTANT: HKEY_CURRENT_USER        HEX: 80000001
CONSTANT: HKEY_LOCAL_MACHINE       HEX: 80000002
CONSTANT: HKEY_USERS               HEX: 80000003
CONSTANT: HKEY_PERFORMANCE_DATA    HEX: 80000004
CONSTANT: HKEY_CURRENT_CONFIG      HEX: 80000005
CONSTANT: HKEY_DYN_DATA            HEX: 80000006
CONSTANT: HKEY_PERFORMANCE_TEXT    HEX: 80000050
CONSTANT: HKEY_PERFORMANCE_NLSTEXT HEX: 80000060

CONSTANT: KEY_QUERY_VALUE         HEX: 0001
CONSTANT: KEY_SET_VALUE           HEX: 0002
CONSTANT: KEY_CREATE_SUB_KEY      HEX: 0004
CONSTANT: KEY_ENUMERATE_SUB_KEYS  HEX: 0008
CONSTANT: KEY_NOTIFY              HEX: 0010
CONSTANT: KEY_CREATE_LINK         HEX: 0020
CONSTANT: KEY_READ                HEX: 20019
CONSTANT: KEY_WOW64_32KEY         HEX: 0200
CONSTANT: KEY_WOW64_64KEY         HEX: 0100
CONSTANT: KEY_WRITE               HEX: 20006
CONSTANT: KEY_EXECUTE             KEY_READ
CONSTANT: KEY_ALL_ACCESS          HEX: F003F

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
FUNCTION: BOOL AddAce ( PACL pAcl, DWORD dwAceRevision, DWORD dwStartingAceIndex, LPVOID pAceList, DWORD nAceListLength ) ;
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
                               PDWORD ReturnLength ) ;

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
                PSID* pSid ) ;

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
! : CreateWellKnownSid ;
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
                                      DWORD dwFlags ) ;

ALIAS: CryptAcquireContext CryptAcquireContextW

! : CryptContextAddRef ;
! : CryptCreateHash ;
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
FUNCTION: BOOL CryptGenRandom ( HCRYPTPROV hProv, DWORD dwLen, BYTE* pbBuffer ) ;
! : CryptGetDefaultProviderA ;
! : CryptGetDefaultProviderW ;
! : CryptGetHashParam ;
! : CryptGetKeyParam ;
! : CryptGetProvParam ;
! : CryptGetUserKey ;
! : CryptHashData ;
! : CryptHashSessionKey ;
! : CryptImportKey ;
FUNCTION: BOOL CryptReleaseContext ( HCRYPTPROV hProv, DWORD dwFlags ) ;
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
FUNCTION: BOOL GetFileSecurityW ( LPCTSTR lpFileName, SECURITY_INFORMATION RequestedInformation, PSECURITY_DESCRIPTOR pSecurityDescriptor, DWORD nLength, LPDWORD lpnLengthNeeded ) ;
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
FUNCTION: DWORD GetNamedSecurityInfoW ( LPTSTR pObjectName, SE_OBJECT_TYPE ObjectType, SECURITY_INFORMATION SecurityInfo, PSID* ppsidOwner, PSID* ppsidGroup, PACL* ppDacl, PACL* ppSacl, PSECURITY_DESCRIPTOR* ppSecurityDescriptor ) ;
ALIAS: GetNamedSecurityInfo GetNamedSecurityInfoW
! : GetNumberOfEventLogRecords ;
! : GetOldestEventLogRecord ;
! : GetOverlappedAccessResults ;
! : GetPrivateObjectSecurity ;
FUNCTION: BOOL GetSecurityDescriptorControl ( PSECURITY_DESCRIPTOR pSecurityDescriptor, PSECURITY_DESCRIPTOR_CONTROL pControl, LPDWORD lpdwRevision ) ;
FUNCTION: BOOL GetSecurityDescriptorDacl ( PSECURITY_DESCRIPTOR pSecurityDescriptor, LPBOOL lpbDaclPresent, PACL* pDacl, LPBOOL lpDaclDefaulted ) ;
FUNCTION: BOOL GetSecurityDescriptorGroup ( PSECURITY_DESCRIPTOR pSecurityDescriptor, PSID* pGroup, LPBOOL lpGroupDefaulted ) ;
FUNCTION: BOOL GetSecurityDescriptorLength ( PSECURITY_DESCRIPTOR pSecurityDescriptor ) ;
FUNCTION: BOOL GetSecurityDescriptorOwner ( PSECURITY_DESCRIPTOR pSecurityDescriptor, PSID* pOwner, LPBOOL lpOwnerDefaulted ) ;
FUNCTION: BOOL GetSecurityDescriptorRMControl ( PSECURITY_DESCRIPTOR pSecurityDescriptor, PUCHAR RMControl ) ;
FUNCTION: BOOL GetSecurityDescriptorSacl ( PSECURITY_DESCRIPTOR pSecurityDescriptor, LPBOOL lpbSaclPresent, PACL* pSacl, LPBOOL lpSaclDefaulted ) ;
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
! : GetTokenInformation ;
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
FUNCTION: BOOL GetUserNameW ( LPCTSTR lpBuffer, LPDWORD lpnSize ) ;
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
FUNCTION: BOOL InitializeAcl ( PACL pAcl, DWORD nAclLength, DWORD dwAclRevision ) ;
FUNCTION: BOOL InitializeSecurityDescriptor ( PSECURITY_DESCRIPTOR pSecurityDescriptor, DWORD dwRevision ) ;
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
                               PLUID lpLuid ) ;
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
                                  PHANDLE TokenHandle ) ;
! : OpenSCManagerA ;
! : OpenSCManagerW ;
! : OpenServiceA ;
! : OpenServiceW ;
FUNCTION: BOOL OpenThreadToken ( HANDLE ThreadHandle, DWORD DesiredAccess, BOOL OpenAsSelf, PHANDLE TokenHandle ) ;
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
FUNCTION: LONG RegCloseKey ( HKEY hKey ) ;
! : RegConnectRegistryA ;
! : RegConnectRegistryW ;
! : RegCreateKeyA ;
! : RegCreateKeyExA ;
FUNCTION: LONG RegCreateKeyExW ( HKEY hKey, LPCTSTR lpSubKey, DWORD Reserved, LPTSTR lpClass, DWORD dwOptions, REGSAM samDesired, LPSECURITY_ATTRIBUTES lpSecurityAttributes, PHKEY phkResult, LPDWORD lpdwDisposition ) ;
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
    ) ;

ALIAS: RegDeleteKeyEx RegDeleteKeyExW

! : RegDeleteValueA ;
! : RegDeleteValueW ;
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
    ) ;
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
    ) ;

ALIAS: RegEnumValue RegEnumValueW

! : RegFlushKey ;
! : RegGetKeySecurity ;
! : RegLoadKeyA ;
! : RegLoadKeyW ;
! : RegNotifyChangeKeyValue ;
FUNCTION: LONG RegOpenCurrentUser ( REGSAM samDesired, PHKEY phkResult ) ;
! : RegOpenKeyA ;
! : RegOpenKeyExA ;
FUNCTION: LONG RegOpenKeyExW ( HKEY hKey, LPCTSTR lpSubKey, DWORD ulOptions, REGSAM samDesired, PHKEY phkResult ) ;
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
    ) ;
ALIAS: RegQueryInfoKey RegQueryInfoKeyW
! : RegQueryMultipleValuesA ;
! : RegQueryMultipleValuesW ;
! : RegQueryValueA ;
! : RegQueryValueExA ;
FUNCTION: LONG RegQueryValueExW ( HKEY hKey, LPCTSTR lpValueName, LPDWORD lpReserved, LPDWORD lpType, LPBYTE lpData, LPDWORD lpcbData ) ;
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
! : RegSetValueW ;
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
FUNCTION: DWORD SetEntriesInAclW ( ULONG cCountOfExplicitEntries, PEXPLICIT_ACCESS pListOfExplicitEntries, PACL OldAcl, PACL* NewAcl ) ;
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
FUNCTION: DWORD SetNamedSecurityInfoW ( LPTSTR pObjectName, SE_OBJECT_TYPE ObjectType, SECURITY_INFORMATION SecurityInfo, PSID psidOwner, PSID psidGroup, PACL pDacl, PACL pSacl ) ;
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


