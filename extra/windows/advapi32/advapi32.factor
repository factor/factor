USING: alien.syntax kernel math windows.types math.bitfields ;
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

: CRYPT_VERIFYCONTEXT  HEX: F0000000 ; inline
: CRYPT_NEWKEYSET      HEX: 8 ; inline
: CRYPT_DELETEKEYSET   HEX: 10 ; inline
: CRYPT_MACHINE_KEYSET HEX: 20 ; inline
: CRYPT_SILENT         HEX: 40 ; inline


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
! : AddAce ;
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

: CryptAcquireContext CryptAcquireContextW ;
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
: GetUserName GetUserNameW ;

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
! : InitializeAcl ;
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
: LookupPrivilegeValue LookupPrivilegeValueW ;

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

! typedef enum _TOKEN_INFORMATION_CLASS {
: TokenUser 1 ;
: TokenGroups 2 ;
: TokenPrivileges 3 ;
: TokenOwner 4 ;
: TokenPrimaryGroup 5 ;
: TokenDefaultDacl 6 ;
: TokenSource 7 ;
: TokenType 8 ;
: TokenImpersonationLevel 9 ;
: TokenStatistics 10 ;
: TokenRestrictedSids 11 ;
: TokenSessionId 12 ;
: TokenGroupsAndPrivileges 13 ;
: TokenSessionReference 14 ;
: TokenSandBoxInert 15 ;
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
: TOKEN_READ STANDARD_RIGHTS_READ TOKEN_QUERY bitor ;

: TOKEN_WRITE
    {
        STANDARD_RIGHTS_WRITE
        TOKEN_ADJUST_PRIVILEGES
        TOKEN_ADJUST_GROUPS
        TOKEN_ADJUST_DEFAULT
    } flags ; foldable

: TOKEN_ALL_ACCESS
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


