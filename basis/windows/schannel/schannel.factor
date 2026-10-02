! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax classes.struct windows
windows.crypt32 windows.types ;
IN: windows.schannel

<<
"secur32" "secur32.dll" stdcall add-library
"ncrypt" "ncrypt.dll" stdcall add-library
>>
LIBRARY: secur32

STRUCT: SecHandle { lower ULONG_PTR } { upper ULONG_PTR } ;
STRUCT: SecBuffer
    { cbBuffer ULONG } { BufferType ULONG } { pvBuffer void* } ;
STRUCT: SecBufferDesc
    { ulVersion ULONG } { cBuffers ULONG } { pBuffers SecBuffer* } ;
STRUCT: SecPkgContext_StreamSizes
    { cbHeader ULONG } { cbTrailer ULONG } { cbMaximumMessage ULONG }
    { cBuffers ULONG } { cbBlockSize ULONG } ;
STRUCT: SecPkgContext_ApplicationProtocol
    { ProtoNegoStatus int } { ProtoNegoExt int }
    { ProtocolIdSize BYTE } { ProtocolId BYTE[255] } ;
STRUCT: TLS_PARAMETERS
    { cAlpnIds DWORD } { rgstrAlpnIds void* }
    { grbitDisabledProtocols DWORD } { cDisabledCrypto DWORD }
    { pDisabledCrypto void* } { dwFlags DWORD } ;
STRUCT: SCH_CREDENTIALS
    { dwVersion DWORD } { dwCredFormat DWORD } { cCreds DWORD }
    { paCred PCCERT_CONTEXT* } { hRootStore HCERTSTORE }
    { cMappers DWORD } { aphMappers void* } { dwSessionLifespan DWORD }
    { dwFlags DWORD } { cTlsParameters DWORD }
    { pTlsParameters TLS_PARAMETERS* } ;

CONSTANT: SEC_E_OK 0
CONSTANT: SEC_I_CONTINUE_NEEDED 0x00090312
CONSTANT: SEC_I_CONTEXT_EXPIRED 0x00090317
CONSTANT: SEC_I_RENEGOTIATE 0x00090321
CONSTANT: SEC_E_INCOMPLETE_MESSAGE 0x80090318
CONSTANT: SEC_E_UNTRUSTED_ROOT 0x80090325
CONSTANT: SECBUFFER_EMPTY 0
CONSTANT: SECBUFFER_DATA 1
CONSTANT: SECBUFFER_TOKEN 2
CONSTANT: SECBUFFER_EXTRA 5
CONSTANT: SECBUFFER_STREAM_TRAILER 6
CONSTANT: SECBUFFER_STREAM_HEADER 7
CONSTANT: SECBUFFER_APPLICATION_PROTOCOLS 18
CONSTANT: SECPKG_ATTR_STREAM_SIZES 4
CONSTANT: SECPKG_ATTR_APPLICATION_PROTOCOL 35
CONSTANT: SECPKG_CRED_INBOUND 1
CONSTANT: SECPKG_CRED_OUTBOUND 2
CONSTANT: SCH_CREDENTIALS_VERSION 5
CONSTANT: SCH_CRED_MANUAL_CRED_VALIDATION 0x00000008
CONSTANT: SCH_CRED_NO_DEFAULT_CREDS 0x00000010
CONSTANT: SCH_CRED_AUTO_CRED_VALIDATION 0x00000020
CONSTANT: SCH_USE_STRONG_CRYPTO 0x00400000
CONSTANT: ISC_REQ_CONFIDENTIALITY 0x00000010
CONSTANT: ISC_REQ_ALLOCATE_MEMORY 0x00000100
CONSTANT: ISC_REQ_EXTENDED_ERROR 0x00004000
CONSTANT: ISC_REQ_STREAM 0x00008000
CONSTANT: ASC_REQ_CONFIDENTIALITY 0x00000010
CONSTANT: ASC_REQ_ALLOCATE_MEMORY 0x00000100
CONSTANT: ASC_REQ_EXTENDED_ERROR 0x00008000
CONSTANT: ASC_REQ_STREAM 0x00010000
CONSTANT: SCHANNEL_SHUTDOWN 1

FUNCTION: LONG AcquireCredentialsHandleW (
    LPWSTR principal, LPWSTR package, ULONG use, void* logon,
    SCH_CREDENTIALS* auth, void* get-key, void* argument,
    SecHandle* credential, void* expiry )
FUNCTION: LONG FreeCredentialsHandle ( SecHandle* credential )
FUNCTION: LONG InitializeSecurityContextW (
    SecHandle* credential, SecHandle* context, LPWSTR target,
    ULONG requirements, ULONG reserved1, ULONG representation,
    SecBufferDesc* input, ULONG reserved2, SecHandle* new-context,
    SecBufferDesc* output, ULONG* attributes, void* expiry )
FUNCTION: LONG AcceptSecurityContext (
    SecHandle* credential, SecHandle* context, SecBufferDesc* input,
    ULONG requirements, ULONG representation, SecHandle* new-context,
    SecBufferDesc* output, ULONG* attributes, void* expiry )
FUNCTION: LONG DeleteSecurityContext ( SecHandle* context )
FUNCTION: LONG QueryContextAttributesW (
    SecHandle* context, ULONG attribute, void* buffer )
FUNCTION: LONG FreeContextBuffer ( void* buffer )
FUNCTION: LONG EncryptMessage (
    SecHandle* context, ULONG quality, SecBufferDesc* message, ULONG sequence )
FUNCTION: LONG DecryptMessage (
    SecHandle* context, SecBufferDesc* message, ULONG sequence, ULONG* quality )
FUNCTION: LONG ApplyControlToken ( SecHandle* context, SecBufferDesc* input )

LIBRARY: crypt32
CONSTANT: PKCS12_ALWAYS_CNG_KSP 0x00000200
FUNCTION: HCERTSTORE PFXImportCertStore (
    CRYPT_DATA_BLOB* data, LPCWSTR password, DWORD flags )
FUNCTION: PCCERT_CONTEXT CertDuplicateCertificateContext ( PCCERT_CONTEXT cert )
FUNCTION: BOOL CertGetCertificateContextProperty (
    PCCERT_CONTEXT cert, DWORD property, void* data, DWORD* size )
CONSTANT: CERT_KEY_PROV_INFO_PROP_ID 2
CONSTANT: CRYPT_ACQUIRE_SILENT_FLAG 0x00000040
CONSTANT: CRYPT_ACQUIRE_ONLY_NCRYPT_KEY_FLAG 0x00040000
FUNCTION: BOOL CryptAcquireCertificatePrivateKey (
    PCCERT_CONTEXT cert, DWORD flags, void* reserved,
    ULONG_PTR* key, DWORD* spec, BOOL* caller-free )

LIBRARY: ncrypt
FUNCTION: LONG NCryptDeleteKey ( ULONG_PTR key, DWORD flags )
