! Copyright (C) 2016 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.syntax classes.struct windows.kernel32
windows.types ;
IN: windows.crypt32

LIBRARY: crypt32

TYPEDEF: HANDLE HCERTSTORE
TYPEDEF: ULONG_PTR HCRYPTPROV
TYPEDEF: HANDLE HCRYPTPROV_LEGACY

STRUCT: CRYPT_BIT_BLOB
    { cbData DWORD }
    { pbData BYTE* }
    { cUnusedBits DWORD } ;
TYPEDEF: CRYPT_BIT_BLOB* PCRYPT_BIT_BLOB

STRUCT: CRYPTOAPI_BLOB 
    { cbData DWORD }
    { pbData BYTE* } ;

TYPEDEF: CRYPTOAPI_BLOB CRYPT_INTEGER_BLOB
TYPEDEF: CRYPTOAPI_BLOB CRYPT_UINT_BLOB
TYPEDEF: CRYPTOAPI_BLOB CRYPT_OBJID_BLOB
TYPEDEF: CRYPTOAPI_BLOB CERT_NAME_BLOB
TYPEDEF: CRYPTOAPI_BLOB CERT_RDN_VALUE_BLOB
TYPEDEF: CRYPTOAPI_BLOB CERT_BLOB
TYPEDEF: CRYPTOAPI_BLOB CRL_BLOB
TYPEDEF: CRYPTOAPI_BLOB DATA_BLOB
TYPEDEF: CRYPTOAPI_BLOB CRYPT_DATA_BLOB
TYPEDEF: CRYPTOAPI_BLOB CRYPT_HASH_BLOB
TYPEDEF: CRYPTOAPI_BLOB CRYPT_DIGEST_BLOB
TYPEDEF: CRYPTOAPI_BLOB CRYPT_DER_BLOB
TYPEDEF: CRYPTOAPI_BLOB CRYPT_ATTR_BLOB

STRUCT: CRYPT_ALGORITHM_IDENTIFIER
    { pszObjId LPSTR }
    { Parameters CRYPT_OBJID_BLOB } ;
TYPEDEF: CRYPT_ALGORITHM_IDENTIFIER* PCRYPT_ALGORITHM_IDENTIFIER

STRUCT: CERT_PUBLIC_KEY_INFO
    { Algorithm CRYPT_ALGORITHM_IDENTIFIER }
    { PublicKey CRYPT_BIT_BLOB } ;
TYPEDEF: CERT_PUBLIC_KEY_INFO* PCERT_PUBLIC_KEY_INFO

STRUCT: CERT_EXTENSION
    { pszObjId LPSTR }
    { fCritical BOOL }
    { Value CRYPT_OBJID_BLOB } ;
TYPEDEF: CERT_EXTENSION* PCERT_EXTENSION

STRUCT: CERT_INFO
    { dwVersion DWORD }
    { SerialNumber CRYPT_INTEGER_BLOB }
    { SignatureAlgorithm CRYPT_ALGORITHM_IDENTIFIER }
    { Issuer CERT_NAME_BLOB }
    { NotBefore FILETIME }
    { NotAfter FILETIME }
    { Subject CERT_NAME_BLOB }
    { SubjectPublicKeyInfo CERT_PUBLIC_KEY_INFO }
    { IssuerUniqueId CRYPT_BIT_BLOB }
    { SubjectUniqueId CRYPT_BIT_BLOB }
    { cExtension DWORD }
    { rgExtension PCERT_EXTENSION } ;
TYPEDEF: CERT_INFO* PCERT_INFO

STRUCT: CERT_CONTEXT
    { dwCertEncodingType DWORD }
    { pbCertEncoded BYTE* }
    { cbCertEncoded DWORD }
    { pCertInfo PCERT_INFO }
    { hCertStore HCERTSTORE } ;
TYPEDEF: CERT_CONTEXT* PCCERT_CONTEXT


! CryptObjectLocatorFree
! CryptObjectLocatorGet
! CryptObjectLocatorGetContent
! CryptObjectLocatorGetUpdated
! CryptObjectLocatorInitialize
! CryptObjectLocatorIsChanged
! CryptObjectLocatorRelease
! I_PFXImportCertStoreEx
! CertAddCRLContextToStore
! CertAddCRLLinkToStore
! CertAddCTLContextToStore
! CertAddCTLLinkToStore
! CertAddCertificateContextToStore
! CertAddCertificateLinkToStore
! CertAddEncodedCRLToStore
! CertAddEncodedCTLToStore
! CertAddEncodedCertificateToStore
! CertAddEncodedCertificateToSystemStoreA
! CertAddEncodedCertificateToSystemStoreW
! CertAddEnhancedKeyUsageIdentifier
! CertAddRefServerOcspResponse
! CertAddRefServerOcspResponseContext
! CertAddSerializedElementToStore
! CertAddStoreToCollection
! CertAlgIdToOID
! CertCloseServerOcspResponse
FUNCTION: BOOL CertCloseStore ( HCERTSTORE hCertStore, DWORD dwFlags )
! CertCompareCertificate
! CertCompareCertificateName
! CertCompareIntegerBlob
! CertComparePublicKeyInfo
! CertControlStore
! CertCreateCRLContext
! CertCreateCTLContext
! CertCreateCTLEntryFromCertificateContextProperties
! CertCreateCertificateChainEngine
! CertCreateCertificateContext
! CertCreateContext
! CertCreateSelfSignCertificate
! CertDeleteCRLFromStore
! CertDeleteCTLFromStore
! CertDeleteCertificateFromStore
! CertDuplicateCRLContext
! CertDuplicateCTLContext
! CertDuplicateCertificateChain
! CertDuplicateCertificateContext
! CertDuplicateStore
! CertEnumCRLContextProperties
! CertEnumCRLsInStore
! CertEnumCTLContextProperties
! CertEnumCTLsInStore
! CertEnumCertificateContextProperties
FUNCTION: PCCERT_CONTEXT CertEnumCertificatesInStore (
    HCERTSTORE     hCertStore,
    PCCERT_CONTEXT pPrevCertContext
)
! CertEnumPhysicalStore
! CertEnumSubjectInSortedCTL
! CertEnumSystemStore
! CertEnumSystemStoreLocation
! CertFindAttribute
! CertFindCRLInStore
! CertFindCTLInStore
! CertFindCertificateInCRL
! CertFindCertificateInStore
! CertFindChainInStore
! CertFindExtension
! CertFindRDNAttr
! CertFindSubjectInCTL
! CertFindSubjectInSortedCTL
! CertFreeCRLContext
! CertFreeCTLContext
! CertFreeCertificateChain
! CertFreeCertificateChainEngine
! CertFreeCertificateChainList
FUNCTION: BOOL CertFreeCertificateContext ( PCCERT_CONTEXT pCertContext )
! CertFreeServerOcspResponseContext
! CertGetCRLContextProperty
! CertGetCRLFromStore
! CertGetCTLContextProperty
! CertGetCertificateChain
! CertGetCertificateContextProperty
! CertGetEnhancedKeyUsage
! CertGetIntendedKeyUsage
! CertGetIssuerCertificateFromStore
! CertGetNameStringA
! CertGetNameStringW
! CertGetPublicKeyLength
! CertGetServerOcspResponseContext
! CertGetStoreProperty
! CertGetSubjectCertificateFromStore
! CertGetValidUsages
! CertIsRDNAttrsInCertificateName
! CertIsStrongHashToSign
! CertIsValidCRLForCertificate
! CertIsWeakHash
! CertNameToStrA
! CertNameToStrW
! CertOIDToAlgId
! CertOpenServerOcspResponse
! CertOpenStore
! protocols: CA, MY, ROOT, SPC

FUNCTION: HCERTSTORE CertOpenSystemStoreW (
    HCRYPTPROV_LEGACY hprov,
    LPTCSTR szSubsystemProtocol
)

ALIAS: CertOpenSystemStore CertOpenSystemStoreW

! CertRDNValueToStrA
! CertRDNValueToStrW
! CertRegisterPhysicalStore
! CertRegisterSystemStore
! CertRemoveEnhancedKeyUsageIdentifier
! CertRemoveStoreFromCollection
! CertResyncCertificateChainEngine
! CertRetrieveLogoOrBiometricInfo
! CertSaveStore
! CertSelectCertificateChains
! CertSerializeCRLStoreElement
! CertSerializeCTLStoreElement
! CertSerializeCertificateStoreElement
! CertSetCRLContextProperty
! CertSetCTLContextProperty
! CertSetCertificateContextPropertiesFromCTLEntry
! CertSetCertificateContextProperty
! CertSetEnhancedKeyUsage
! CertSetStoreProperty
! CertStrToNameA
! CertStrToNameW
! CertUnregisterPhysicalStore
! CertUnregisterSystemStore
! CertVerifyCRLRevocation
! CertVerifyCRLTimeValidity
! CertVerifyCTLUsage
! CertVerifyCertificateChainPolicy
! CertVerifyRevocation
! CertVerifySubjectCertificateContext
! CertVerifyTimeValidity
! CertVerifyValidityNesting
! CryptAcquireCertificatePrivateKey
! CryptBinaryToStringA
! CryptBinaryToStringW
! CryptCloseAsyncHandle
! CryptCreateAsyncHandle
! CryptCreateKeyIdentifierFromCSP
! CryptDecodeMessage
! CryptDecodeObject
! CryptDecodeObjectEx
! CryptDecryptAndVerifyMessageSignature
! CryptDecryptMessage
! CryptEncodeObject
! CryptEncodeObjectEx
! CryptEncryptMessage
! CryptEnumKeyIdentifierProperties
! CryptEnumOIDFunction
! CryptEnumOIDInfo
! CryptExportPKCS8
! CryptExportPublicKeyInfo
! CryptExportPublicKeyInfoEx
! CryptExportPublicKeyInfoFromBCryptKeyHandle
! CryptFindCertificateKeyProvInfo
! CryptFindLocalizedName
! CryptFindOIDInfo
! CryptFormatObject
! CryptFreeOIDFunctionAddress
! CryptGetAsyncParam
! CryptGetDefaultOIDDllList
! CryptGetDefaultOIDFunctionAddress
! CryptGetKeyIdentifierProperty
! CryptGetMessageCertificates
! CryptGetMessageSignerCount
! CryptGetOIDFunctionAddress
! CryptGetOIDFunctionValue
! CryptHashCertificate
! CryptHashCertificate2
! CryptHashMessage
! CryptHashPublicKeyInfo
! CryptHashToBeSigned
! CryptImportPKCS8
! CryptImportPublicKeyInfo
! CryptImportPublicKeyInfoEx
! CryptImportPublicKeyInfoEx2
! CryptInitOIDFunctionSet
! CryptInstallDefaultContext
! CryptInstallOIDFunctionAddress
! CryptLoadSip
! CryptMemAlloc
! CryptMemFree
! CryptMemRealloc
! CryptMsgCalculateEncodedLength
! CryptMsgClose
! CryptMsgControl
! CryptMsgCountersign
! CryptMsgCountersignEncoded
! CryptMsgDuplicate
! CryptMsgEncodeAndSignCTL
! CryptMsgGetAndVerifySigner
! CryptMsgGetParam
! CryptMsgOpenToDecode
! CryptMsgOpenToEncode
! CryptMsgSignCTL
! CryptMsgUpdate
! CryptMsgVerifyCountersignatureEncoded
! CryptMsgVerifyCountersignatureEncodedEx
! CryptProtectData
! CryptProtectMemory
! CryptQueryObject
! CryptRegisterDefaultOIDFunction
! CryptRegisterOIDFunction
! CryptRegisterOIDInfo
! CryptRetrieveTimeStamp
! CryptSIPAddProvider
! CryptSIPCreateIndirectData
! CryptSIPGetCaps
! CryptSIPGetSealedDigest
! CryptSIPGetSignedDataMsg
! CryptSIPLoad
! CryptSIPPutSignedDataMsg
! CryptSIPRemoveProvider
! CryptSIPRemoveSignedDataMsg
! CryptSIPRetrieveSubjectGuid
! CryptSIPRetrieveSubjectGuidForCatalogFile
! CryptSIPVerifyIndirectData
! CryptSetAsyncParam
! CryptSetKeyIdentifierProperty
! CryptSetOIDFunctionValue
! CryptSignAndEncodeCertificate
! CryptSignAndEncryptMessage
! CryptSignCertificate
! CryptSignMessage
! CryptSignMessageWithKey
! CryptStringToBinaryA
! CryptStringToBinaryW
! CryptUninstallDefaultContext
! CryptUnprotectData
! CryptUnprotectMemory
! CryptUnregisterDefaultOIDFunction
! CryptUnregisterOIDFunction
! CryptUnregisterOIDInfo
! CryptUpdateProtectedState
! CryptVerifyCertificateSignature
! CryptVerifyCertificateSignatureEx
! CryptVerifyDetachedMessageHash
! CryptVerifyDetachedMessageSignature
! CryptVerifyMessageHash
! CryptVerifyMessageSignature
! CryptVerifyMessageSignatureWithKey
! CryptVerifyTimeStampSignature
! I_CertChainEngineIsDisallowedCertificate
! I_CertDiagControl
! I_CertProtectFunction
! I_CertSrvProtectFunction
! I_CertSyncStore
! I_CertUpdateStore
! I_CryptAddRefLruEntry
! I_CryptAddSmartCardCertToStore
! I_CryptAllocTls
! I_CryptAllocTlsEx
! I_CryptCreateLruCache
! I_CryptCreateLruEntry
! I_CryptDetachTls
! I_CryptDisableLruOfEntries
! I_CryptEnableLruOfEntries
! I_CryptEnumMatchingLruEntries
! I_CryptFindLruEntry
! I_CryptFindLruEntryData
! I_CryptFindSmartCardCertInStore
! I_CryptFlushLruCache
! I_CryptFreeLruCache
! I_CryptFreeTls
! I_CryptGetAsn1Decoder
! I_CryptGetAsn1Encoder
! I_CryptGetDefaultCryptProv
! I_CryptGetDefaultCryptProvForEncrypt
! I_CryptGetFileVersion
! I_CryptGetLruEntryData
! I_CryptGetLruEntryIdentifier
! I_CryptGetOssGlobal
! I_CryptGetTls
! I_CryptInsertLruEntry
! I_CryptInstallAsn1Module
! I_CryptInstallOssGlobal
! I_CryptReadTrustedPublisherDWORDValueFromRegistry
! I_CryptRegisterSmartCardStore
! I_CryptReleaseLruEntry
! I_CryptRemoveLruEntry
! I_CryptSetTls
! I_CryptTouchLruEntry
! I_CryptUninstallAsn1Module
! I_CryptUninstallOssGlobal
! I_CryptUnregisterSmartCardStore
! I_CryptWalkAllLruCacheEntries
! PFXExportCertStore
! PFXExportCertStore2
! PFXExportCertStoreEx
! PFXImportCertStore
! PFXIsPFXBlob
! PFXVerifyPassword
