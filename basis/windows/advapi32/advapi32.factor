USING: alias alien.syntax kernel math windows.types math.bitfields ;
IN: windows.advapi32
LIBRARY: advapi32

: PROV_RSA_FULL       1 ; inline
: PROV_RSA_SIG        2 ; inline
: PROV_DSS            3 ; inline
: PROV_FORTEZZA       4 ; inline
: PROV_MS_EXCHANGE    5 ; inline
: PROV_SSL            6 ; inline
: PROV_RSA_SCHANNEL  12 ; inline
: PROV_DSS_DH        13 ; inline
: PROV_EC_ECDSA_SIG  14 ; inline
: PROV_EC_ECNRA_SIG  15 ; inline
: PROV_EC_ECDSA_FULL 16 ; inline
: PROV_EC_ECNRA_FULL 17 ; inline
: PROV_DH_SCHANNEL   18 ; inline
: PROV_SPYRUS_LYNKS  20 ; inline
: PROV_RNG           21 ; inline
: PROV_INTEL_SEC     22 ; inline
: PROV_REPLACE_OWF   23 ; inline
: PROV_RSA_AES       24 ; inline

: MS_DEF_DH_SCHANNEL_PROV
    "Microsoft DH Schannel Cryptographic Provider" ; inline

: MS_DEF_DSS_DH_PROV
    "Microsoft Base DSS and Diffie-Hellman Cryptographic Provider" ; inline

: MS_DEF_DSS_PROV
    "Microsoft Base DSS Cryptographic Provider" ; inline

: MS_DEF_PROV
    "Microsoft Base Cryptographic Provider v1.0" ; inline

: MS_DEF_RSA_SCHANNEL_PROV
    "Microsoft RSA Schannel Cryptographic Provider" ; inline

! Unsupported (!)
: MS_DEF_RSA_SIG_PROV
    "Microsoft RSA Signature Cryptographic Provider" ; inline

: MS_ENH_DSS_DH_PROV
    "Microsoft Enhanced DSS and Diffie-Hellman Cryptographic Provider" ; inline

: MS_ENH_RSA_AES_PROV
    "Microsoft Enhanced RSA and AES Cryptographic Provider" ; inline

: MS_ENHANCED_PROV
    "Microsoft Enhanced Cryptographic Provider v1.0" ; inline

: MS_SCARD_PROV
    "Microsoft Base Smart Card Crypto Provider" ; inline

: MS_STRONG_PROV
    "Microsoft Strong Cryptographic Provider" ; inline

: CRYPT_VERIFYCONTEXT  HEX: F0000000 ; inline
: CRYPT_NEWKEYSET      HEX: 8 ; inline
: CRYPT_DELETEKEYSET   HEX: 10 ; inline
: CRYPT_MACHINE_KEYSET HEX: 20 ; inline
: CRYPT_SILENT         HEX: 40 ; inline

C-STRUCT: ACL
    { "BYTE" "AclRevision" }
    { "BYTE" "Sbz1" }
    { "WORD" "AclSize" }
    { "WORD" "AceCount" }
    { "WORD" "Sbz2" } ;

TYPEDEF: ACL* PACL

: ACCESS_ALLOWED_ACE_TYPE 0 ; inline
: ACCESS_DENIED_ACE_TYPE 1 ; inline
: SYSTEM_AUDIT_ACE_TYPE 2 ; inline
: SYSTEM_ALARM_ACE_TYPE 3 ; inline

: OBJECT_INHERIT_ACE HEX: 1 ; inline
: CONTAINER_INHERIT_ACE HEX: 2 ; inline
: NO_PROPAGATE_INHERIT_ACE HEX: 4 ; inline
: INHERIT_ONLY_ACE HEX: 8 ; inline
: VALID_INHERIT_FLAGS HEX: f ; inline

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


! typedef enum _TOKEN_INFORMATION_CLASS {
: TokenUser 1 ; inline
: TokenGroups 2 ; inline
: TokenPrivileges 3 ; inline
: TokenOwner 4 ; inline
: TokenPrimaryGroup 5 ; inline
: TokenDefaultDacl 6 ; inline
: TokenSource 7 ; inline
: TokenType 8 ; inline
: TokenImpersonationLevel 9 ; inline
: TokenStatistics 10 ; inline
: TokenRestrictedSids 11 ; inline
: TokenSessionId 12 ; inline
: TokenGroupsAndPrivileges 13 ; inline
: TokenSessionReference 14 ; inline
: TokenSandBoxInert 15 ; inline
! } TOKEN_INFORMATION_CLASS;

: DELETE                     HEX: 00010000 ; inline
: READ_CONTROL               HEX: 00020000 ; inline
: WRITE_DAC                  HEX: 00040000 ; inline
: WRITE_OWNER                HEX: 00080000 ; inline
: SYNCHRONIZE                HEX: 00100000 ; inline
: STANDARD_RIGHTS_REQUIRED   HEX: 000f0000 ; inline

: STANDARD_RIGHTS_READ       READ_CONTROL ; inline
: STANDARD_RIGHTS_WRITE      READ_CONTROL ; inline
: STANDARD_RIGHTS_EXECUTE    READ_CONTROL ; inline

: TOKEN_TOKEN_ADJUST_DEFAULT   HEX: 0080 ; inline
: TOKEN_ADJUST_GROUPS          HEX: 0040 ; inline
: TOKEN_ADJUST_PRIVILEGES      HEX: 0020 ; inline
: TOKEN_ADJUST_SESSIONID       HEX: 0100 ; inline
: TOKEN_ASSIGN_PRIMARY         HEX: 0001 ; inline
: TOKEN_DUPLICATE              HEX: 0002 ; inline
: TOKEN_EXECUTE                STANDARD_RIGHTS_EXECUTE ; inline
: TOKEN_IMPERSONATE            HEX: 0004 ; inline
: TOKEN_QUERY                  HEX: 0008 ; inline
: TOKEN_QUERY_SOURCE           HEX: 0010 ; inline
: TOKEN_ADJUST_DEFAULT         HEX: 0080 ; inline
: TOKEN_READ ( -- n ) STANDARD_RIGHTS_READ TOKEN_QUERY bitor ;

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

! : AllocateAndInitializeSid ;
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
! : GetFileSecurityW ;
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
! : GetNamedSecurityInfoExW ;
! : GetNamedSecurityInfoW ;
! : GetNumberOfEventLogRecords ;
! : GetOldestEventLogRecord ;
! : GetOverlappedAccessResults ;
! : GetPrivateObjectSecurity ;
! : GetSecurityDescriptorControl ;
! : GetSecurityDescriptorDacl ;
! : GetSecurityDescriptorGroup ;
! : GetSecurityDescriptorLength ;
! : GetSecurityDescriptorOwner ;
! : GetSecurityDescriptorRMControl ;
! : GetSecurityDescriptorSacl ;
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
! : InitializeSecurityDescriptor ;
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
! : RegCloseKey ;
! : RegConnectRegistryA ;
! : RegConnectRegistryW ;
! : RegCreateKeyA ;
! : RegCreateKeyExA ;
! : RegCreateKeyExW ;
! : RegCreateKeyW ;
! : RegDeleteKeyA ;
! : RegDeleteKeyW ;
! : RegDeleteValueA ;
! : RegDeleteValueW ;
! : RegDisablePredefinedCache ;
! : RegEnumKeyA ;
! : RegEnumKeyExA ;
! : RegEnumKeyExW ;
! : RegEnumKeyW ;
! : RegEnumValueA ;
! : RegEnumValueW ;
! : RegFlushKey ;
! : RegGetKeySecurity ;
! : RegLoadKeyA ;
! : RegLoadKeyW ;
! : RegNotifyChangeKeyValue ;
! : RegOpenCurrentUser ;
! : RegOpenKeyA ;
! : RegOpenKeyExA ;
! : RegOpenKeyExW ;
! : RegOpenKeyW ;
! : RegOpenUserClassesRoot ;
! : RegOverridePredefKey ;
! : RegQueryInfoKeyA ;
! : RegQueryInfoKeyW ;
! : RegQueryMultipleValuesA ;
! : RegQueryMultipleValuesW ;
! : RegQueryValueA ;
! : RegQueryValueExA ;
! : RegQueryValueExW ;
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
! : SetEntriesInAclW ;
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
! : SetNamedSecurityInfoW ;
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


