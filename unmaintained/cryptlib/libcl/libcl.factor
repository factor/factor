! Copyright (C) 2007 Elie CHAFTARI
! See http://factorcode.org/license.txt for BSD license.

! libs/cryptlib/libcl.factor

! Adapted from cryptlib.h
! Tested with cryptlib 3.3.1.0

! export LD_LIBRARY_PATH=/opt/local/lib

USING: alien kernel system combinators alien.syntax ;

IN: cryptlib.libcl

<< "libcl" {
        { [ win32? ] [ "cl32.dll" stdcall ] }
        { [ macosx? ] [ "libcl.dylib" cdecl ] }
        { [ unix? ] [ "libcl.so" cdecl ] }
    } cond add-library >>

! ===============================================
! Machine-dependant types
! ===============================================

TYPEDEF: int C_RET

! ===============================================
! Algorithm and Object Types
! ===============================================

! Algorithm and mode types

! CRYPT_ALGO_TYPE
: CRYPT_ALGO_NONE                    0   ; inline ! No encryption
: CRYPT_ALGO_DES                     1   ; inline ! DES
: CRYPT_ALGO_3DES                    2   ; inline ! Triple DES
: CRYPT_ALGO_IDEA                    3   ; inline ! IDEA
: CRYPT_ALGO_CAST                    4   ; inline ! CAST-128
: CRYPT_ALGO_RC2                     5   ; inline ! RC2
: CRYPT_ALGO_RC4                     6   ; inline ! RC4
: CRYPT_ALGO_RC5                     7   ; inline ! RC5
: CRYPT_ALGO_AES                     8   ; inline ! AES
: CRYPT_ALGO_BLOWFISH                9   ; inline ! Blowfish
: CRYPT_ALGO_SKIPJACK                10  ; inline ! Skipjack
: CRYPT_ALGO_DH                      100 ; inline ! Diffie-Hellman
: CRYPT_ALGO_RSA                     101 ; inline ! RSA
: CRYPT_ALGO_DSA                     102 ; inline ! DSA
: CRYPT_ALGO_ELGAMAL                 103 ; inline ! ElGamal
: CRYPT_ALGO_KEA                     104 ; inline ! KEA
: CRYPT_ALGO_ECDSA                   105 ; inline ! ECDSA
: CRYPT_ALGO_MD2                     200 ; inline ! MD2
: CRYPT_ALGO_MD4                     201 ; inline ! MD4
: CRYPT_ALGO_MD5                     202 ; inline ! MD5
: CRYPT_ALGO_SHA                     203 ; inline ! SHA/SHA1
: CRYPT_ALGO_RIPEMD160               204 ; inline ! RIPE-MD 160
: CRYPT_ALGO_SHA2                    205 ; inline ! SHA2 (SHA-256/384/512)
: CRYPT_ALGO_HMAC_MD5                300 ; inline ! HMAC-MD5
: CRYPT_ALGO_HMAC_SHA1               301 ; inline ! HMAC-SHA
: CRYPT_ALGO_HMAC_SHA                301 ; inline ! Older form
: CRYPT_ALGO_HMAC_RIPEMD160          302 ; inline ! HMAC-RIPEMD-160
: CRYPT_ALGO_LAST                    303 ; inline ! Last possible crypt algo value
: CRYPT_ALGO_FIRST_CONVENTIONAL      1   ; inline
: CRYPT_ALGO_LAST_CONVENTIONAL       99  ; inline
: CRYPT_ALGO_FIRST_PKC               100 ; inline
: CRYPT_ALGO_LAST_PKC                199 ; inline
: CRYPT_ALGO_FIRST_HASH              200 ; inline
: CRYPT_ALGO_LAST_HASH               299 ; inline
: CRYPT_ALGO_FIRST_MAC               300 ; inline
: CRYPT_ALGO_LAST_MAC                399 ; inline ! End of mac algo.range

TYPEDEF: int CRYPT_ALGO_TYPE

! CRYPT_MODE_TYPE
: CRYPT_MODE_NONE                    0 ; inline ! No encryption mode
: CRYPT_MODE_ECB                     1 ; inline ! ECB
: CRYPT_MODE_CBC                     2 ; inline ! CBC
: CRYPT_MODE_CFB                     3 ; inline ! CFB
: CRYPT_MODE_OFB                     4 ; inline ! OFB
: CRYPT_MODE_LAST                    5 ; inline ! Last possible crypt mode value


! Keyset subtypes

! CRYPT_KEYSET_TYPE
: CRYPT_KEYSET_NONE                   0  ; inline ! No keyset type
: CRYPT_KEYSET_FILE                   1  ; inline ! Generic flat file keyset
: CRYPT_KEYSET_HTTP                   2  ; inline ! Web page containing cert/CRL
: CRYPT_KEYSET_LDAP                   3  ; inline ! LDAP directory service
: CRYPT_KEYSET_ODBC                   4  ; inline ! Generic ODBC interface
: CRYPT_KEYSET_DATABASE               5  ; inline ! Generic RDBMS interface
: CRYPT_KEYSET_PLUGIN                 6  ; inline ! Generic database plugin
: CRYPT_KEYSET_ODBC_STORE             7  ; inline ! ODBC certificate store
: CRYPT_KEYSET_DATABASE_STORE         8  ; inline ! Database certificate store
: CRYPT_KEYSET_PLUGIN_STORE           9  ; inline ! Database plugin certificate store
: CRYPT_KEYSET_LAST                   10 ; inline ! Last possible keyset type

TYPEDEF: int CRYPT_KEYSET_TYPE

! Device subtypes

! CRYPT_DEVICE_TYPE
: CRYPT_DEVICE_NONE                   0 ; inline ! No crypto device
: CRYPT_DEVICE_FORTEZZA               1 ; inline ! Fortezza card
: CRYPT_DEVICE_PKCS11                 2 ; inline ! PKCS #11 crypto token
: CRYPT_DEVICE_CRYPTOAPI              3 ; inline ! Microsoft CryptoAPI
: CRYPT_DEVICE_LAST                   4 ; inline ! Last possible crypto device type

! Certificate subtypes

! CRYPT_CERTTYPE_TYPE
: CRYPT_CERTTYPE_NONE                 0  ; inline ! No certificate type
: CRYPT_CERTTYPE_CERTIFICATE          1  ; inline ! Certificate
: CRYPT_CERTTYPE_ATTRIBUTE_CERT       2  ; inline ! Attribute certificate
: CRYPT_CERTTYPE_CERTCHAIN            3  ; inline ! PKCS #7 certificate chain
: CRYPT_CERTTYPE_CERTREQUEST          4  ; inline ! PKCS #10 certification request
: CRYPT_CERTTYPE_REQUEST_CERT         5  ; inline ! CRMF certification request
: CRYPT_CERTTYPE_REQUEST_REVOCATION   6  ; inline ! CRMF revocation request
: CRYPT_CERTTYPE_CRL                  7  ; inline ! CRL
: CRYPT_CERTTYPE_CMS_ATTRIBUTES       8  ; inline ! CMS attributes
: CRYPT_CERTTYPE_RTCS_REQUEST         9  ; inline ! RTCS request
: CRYPT_CERTTYPE_RTCS_RESPONSE        10 ; inline ! RTCS response
: CRYPT_CERTTYPE_OCSP_REQUEST         11 ; inline ! OCSP request
: CRYPT_CERTTYPE_OCSP_RESPONSE        12 ; inline ! OCSP response
: CRYPT_CERTTYPE_PKIUSER              13 ; inline ! PKI user information
: CRYPT_CERTTYPE_LAST                 14 ; inline ! Last possible cert.type

TYPEDEF: int CRYPT_CERTTYPE_TYPE

! Envelope/data format subtypes

! CRYPT_FORMAT_TYPE
: CRYPT_FORMAT_NONE                   0 ; inline ! No format type
: CRYPT_FORMAT_AUTO                   1 ; inline ! Deenv, auto-determine type
: CRYPT_FORMAT_CRYPTLIB               2 ; inline ! cryptlib native format
: CRYPT_FORMAT_CMS                    3 ; inline ! PKCS #7 / CMS / S/MIME fmt.
: CRYPT_FORMAT_PKCS7                  3 ; inline
: CRYPT_FORMAT_SMIME                  4 ; inline ! As CMS with MSG-style behaviour
: CRYPT_FORMAT_PGP                    5 ; inline ! PGP format
: CRYPT_FORMAT_LAST                   6 ; inline ! Last possible format type

TYPEDEF: int CRYPT_FORMAT_TYPE

! Session subtypes

! CRYPT_SESSION_TYPE
: CRYPT_SESSION_NONE                  0  ; inline ! No session type
: CRYPT_SESSION_SSH                   1  ; inline ! SSH
: CRYPT_SESSION_SSH_SERVER            2  ; inline ! SSH server
: CRYPT_SESSION_SSL                   3  ; inline ! SSL/TLS
: CRYPT_SESSION_SSL_SERVER            4  ; inline ! SSL/TLS server
: CRYPT_SESSION_RTCS                  5  ; inline ! RTCS
: CRYPT_SESSION_RTCS_SERVER           6  ; inline ! RTCS server
: CRYPT_SESSION_OCSP                  7  ; inline ! OCSP
: CRYPT_SESSION_OCSP_SERVER           8  ; inline ! OCSP server
: CRYPT_SESSION_TSP                   9  ; inline ! TSP
: CRYPT_SESSION_TSP_SERVER            10 ; inline ! TSP server
: CRYPT_SESSION_CMP                   11 ; inline ! CMP
: CRYPT_SESSION_CMP_SERVER            12 ; inline ! CMP server
: CRYPT_SESSION_SCEP                  13 ; inline ! SCEP
: CRYPT_SESSION_SCEP_SERVER           14 ; inline ! SCEP server
: CRYPT_SESSION_CERTSTORE_SERVER      15 ; inline ! HTTP cert store interface
: CRYPT_SESSION_LAST                  16 ; inline ! Last possible session type

TYPEDEF: int CRYPT_SESSION_TYPE

! User subtypes

! CRYPT_USER_TYPE
: CRYPT_USER_NONE                     0 ; inline ! No user type
: CRYPT_USER_NORMAL                   1 ; inline ! Normal user
: CRYPT_USER_SO                       2 ; inline ! Security officer
: CRYPT_USER_CA                       3 ; inline ! CA user
: CRYPT_USER_LAST                     4 ; inline ! Last possible user type

! ===============================================
! Attribute Types
! ===============================================

! Attribute types.  These are arranged in the following order:
!
!   PROPERTY    - Object property
!   ATTRIBUTE   - Generic attributes
!   OPTION      - Global or object-specific config.option
!   CTXINFO     - Context-specific attribute
!   CERTINFO    - Certificate-specific attribute
!   KEYINFO     - Keyset-specific attribute
!   DEVINFO     - Device-specific attribute
!   ENVINFO     - Envelope-specific attribute
!   SESSINFO    - Session-specific attribute
!   USERINFO    - User-specific attribute

! CRYPT_ATTRIBUTE_TYPE
: CRYPT_ATTRIBUTE_NONE                                0    ; inline ! Non-value
: CRYPT_PROPERTY_FIRST                                1    ; inline ! *******************
: CRYPT_PROPERTY_HIGHSECURITY                         2    ; inline ! Owned+non-forwardcount+locked
: CRYPT_PROPERTY_OWNER                                3    ; inline ! Object owner
: CRYPT_PROPERTY_FORWARDCOUNT                         4    ; inline ! No.of times object can be forwarded
: CRYPT_PROPERTY_LOCKED                               5    ; inline ! Whether properties can be chged/read
: CRYPT_PROPERTY_USAGECOUNT                           6    ; inline ! Usage count before object expires
: CRYPT_PROPERTY_NONEXPORTABLE                        7    ; inline ! Whether key is nonexp.from context
: CRYPT_PROPERTY_LAST                                 8    ; inline
: CRYPT_GENERIC_FIRST                                 9    ; inline ! Extended error information
: CRYPT_ATTRIBUTE_ERRORTYPE                           10   ; inline ! Type of last error
: CRYPT_ATTRIBUTE_ERRORLOCUS                          11   ; inline ! Locus of last error
: CRYPT_ATTRIBUTE_INT_ERRORCODE                       12   ; inline ! Low-level software-specific
: CRYPT_ATTRIBUTE_INT_ERRORMESSAGE                    13   ; inline ! error code and message
: CRYPT_ATTRIBUTE_CURRENT_GROUP                       14   ; inline ! Cursor mgt: Group in attribute list
: CRYPT_ATTRIBUTE_CURRENT                             15   ; inline ! Cursor mgt: Entry in attribute list
: CRYPT_ATTRIBUTE_CURRENT_INSTANCE                    16   ; inline ! Cursor mgt: Instance in attribute list
: CRYPT_ATTRIBUTE_BUFFERSIZE                          17   ; inline ! Internal data buffer size
: CRYPT_GENERIC_LAST                                  18   ; inline
: CRYPT_OPTION_FIRST                                  100  ; inline ! **************************
: CRYPT_OPTION_INFO_DESCRIPTION                       101  ; inline ! Text description
: CRYPT_OPTION_INFO_COPYRIGHT                         102  ; inline ! Copyright notice
: CRYPT_OPTION_INFO_MAJORVERSION                      103  ; inline ! Major release version
: CRYPT_OPTION_INFO_MINORVERSION                      104  ; inline ! Minor release version
: CRYPT_OPTION_INFO_STEPPING                          105  ; inline ! Release stepping
: CRYPT_OPTION_ENCR_ALGO                              106  ; inline ! Encryption algorithm
: CRYPT_OPTION_ENCR_HASH                              107  ; inline ! Hash algorithm
: CRYPT_OPTION_ENCR_MAC                               108  ; inline ! MAC algorithm
: CRYPT_OPTION_PKC_ALGO                               109  ; inline ! Public-key encryption algorithm
: CRYPT_OPTION_PKC_KEYSIZE                            110  ; inline ! Public-key encryption key size
: CRYPT_OPTION_SIG_ALGO                               111  ; inline ! Signature algorithm
: CRYPT_OPTION_SIG_KEYSIZE                            112  ; inline ! Signature keysize
: CRYPT_OPTION_KEYING_ALGO                            113  ; inline ! Key processing algorithm
: CRYPT_OPTION_KEYING_ITERATIONS                      114  ; inline ! Key processing iterations
: CRYPT_OPTION_CERT_SIGNUNRECOGNISEDATTRIBUTES        115  ; inline ! Whether to sign unrecog.attrs
: CRYPT_OPTION_CERT_VALIDITY                          116  ; inline ! Certificate validity period
: CRYPT_OPTION_CERT_UPDATEINTERVAL                    117  ; inline ! CRL update interval
: CRYPT_OPTION_CERT_COMPLIANCELEVEL                   118  ; inline ! PKIX compliance level for cert chks.
: CRYPT_OPTION_CERT_REQUIREPOLICY                     119  ; inline ! Whether explicit policy req'd for certs
: CRYPT_OPTION_CMS_DEFAULTATTRIBUTES                  120  ; inline ! Add default CMS attributes
: CRYPT_OPTION_SMIME_DEFAULTATTRIBUTES                120  ; inline ! LDAP keyset options
: CRYPT_OPTION_KEYS_LDAP_OBJECTCLASS                  121  ; inline ! Object class
: CRYPT_OPTION_KEYS_LDAP_OBJECTTYPE                   122  ; inline ! Object type to fetch
: CRYPT_OPTION_KEYS_LDAP_FILTER                       123  ; inline ! Query filter
: CRYPT_OPTION_KEYS_LDAP_CACERTNAME                   124  ; inline ! CA certificate attribute name
: CRYPT_OPTION_KEYS_LDAP_CERTNAME                     125  ; inline ! Certificate attribute name
: CRYPT_OPTION_KEYS_LDAP_CRLNAME                      126  ; inline ! CRL attribute name
: CRYPT_OPTION_KEYS_LDAP_EMAILNAME                    127  ; inline ! Email attribute name
: CRYPT_OPTION_DEVICE_PKCS11_DVR01                    128  ; inline ! Name of first PKCS #11 driver
: CRYPT_OPTION_DEVICE_PKCS11_DVR02                    129  ; inline ! Name of second PKCS #11 driver
: CRYPT_OPTION_DEVICE_PKCS11_DVR03                    130  ; inline ! Name of third PKCS #11 driver
: CRYPT_OPTION_DEVICE_PKCS11_DVR04                    131  ; inline ! Name of fourth PKCS #11 driver
: CRYPT_OPTION_DEVICE_PKCS11_DVR05                    132  ; inline ! Name of fifth PKCS #11 driver
: CRYPT_OPTION_DEVICE_PKCS11_HARDWAREONLY             133  ; inline ! Use only hardware mechanisms
: CRYPT_OPTION_NET_SOCKS_SERVER                       134  ; inline ! Socks server name
: CRYPT_OPTION_NET_SOCKS_USERNAME                     135  ; inline ! Socks user name
: CRYPT_OPTION_NET_HTTP_PROXY                         136  ; inline ! Web proxy server
: CRYPT_OPTION_NET_CONNECTTIMEOUT                     137  ; inline ! Timeout for network connection setup
: CRYPT_OPTION_NET_READTIMEOUT                        138  ; inline ! Timeout for network reads
: CRYPT_OPTION_NET_WRITETIMEOUT                       139  ; inline ! Timeout for network writes
: CRYPT_OPTION_MISC_ASYNCINIT                         140  ; inline ! Whether to init cryptlib async'ly
: CRYPT_OPTION_MISC_SIDECHANNELPROTECTION             141  ; inline ! Protect against side-channel attacks
: CRYPT_OPTION_CONFIGCHANGED                          142  ; inline ! Whether in-mem.opts match on-disk ones
: CRYPT_OPTION_SELFTESTOK                             143  ; inline ! Whether self-test was completed and OK
: CRYPT_OPTION_LAST                                   144  ; inline
: CRYPT_CTXINFO_FIRST                                 1000 ; inline ! ********************
: CRYPT_CTXINFO_ALGO                                  1001 ; inline ! Algorithm
: CRYPT_CTXINFO_MODE                                  1002 ; inline ! Mode
: CRYPT_CTXINFO_NAME_ALGO                             1003 ; inline ! Algorithm name
: CRYPT_CTXINFO_NAME_MODE                             1004 ; inline ! Mode name
: CRYPT_CTXINFO_KEYSIZE                               1005 ; inline ! Key size in bytes
: CRYPT_CTXINFO_BLOCKSIZE                             1006 ; inline ! Block size
: CRYPT_CTXINFO_IVSIZE                                1007 ; inline ! IV size
: CRYPT_CTXINFO_KEYING_ALGO                           1008 ; inline ! Key processing algorithm
: CRYPT_CTXINFO_KEYING_ITERATIONS                     1009 ; inline ! Key processing iterations
: CRYPT_CTXINFO_KEYING_SALT                           1010 ; inline ! Key processing salt
: CRYPT_CTXINFO_KEYING_VALUE                          1011 ; inline ! Value used to derive key
: CRYPT_CTXINFO_KEY                                   1012 ; inline ! Key
: CRYPT_CTXINFO_KEY_COMPONENTS                        1013 ; inline ! Public-key components
: CRYPT_CTXINFO_IV                                    1014 ; inline ! IV
: CRYPT_CTXINFO_HASHVALUE                             1015 ; inline ! Hash value
: CRYPT_CTXINFO_LABEL                                 1016 ; inline ! Label for private/secret key
: CRYPT_CTXINFO_PERSISTENT                            1017 ; inline ! Obj.is backed by device or keyset
: CRYPT_CTXINFO_LAST                                  1018 ; inline
: CRYPT_CERTINFO_FIRST                                2000 ; inline ! ************************
: CRYPT_CERTINFO_SELFSIGNED                           2001 ; inline ! Cert is self-signed
: CRYPT_CERTINFO_IMMUTABLE                            2002 ; inline ! Cert is signed and immutable
: CRYPT_CERTINFO_XYZZY                                2003 ; inline ! Cert is a magic just-works cert
: CRYPT_CERTINFO_CERTTYPE                             2004 ; inline ! Certificate object type
: CRYPT_CERTINFO_FINGERPRINT                          2005 ; inline ! Certificate fingerprints
: CRYPT_CERTINFO_FINGERPRINT_MD5                      2005 ; inline
: CRYPT_CERTINFO_FINGERPRINT_SHA                      2006 ; inline
: CRYPT_CERTINFO_CURRENT_CERTIFICATE                  2007 ; inline ! Cursor mgt: Rel.pos in chain/CRL/OCSP
: CRYPT_CERTINFO_TRUSTED_USAGE                        2008 ; inline ! Usage that cert is trusted for
: CRYPT_CERTINFO_TRUSTED_IMPLICIT                     2009 ; inline ! Whether cert is implicitly trusted
: CRYPT_CERTINFO_SIGNATURELEVEL                       2010 ; inline ! Amount of detail to include in sigs.
: CRYPT_CERTINFO_VERSION                              2011 ; inline ! Cert.format version
: CRYPT_CERTINFO_SERIALNUMBER                         2012 ; inline ! Serial number
: CRYPT_CERTINFO_SUBJECTPUBLICKEYINFO                 2013 ; inline ! Public key
: CRYPT_CERTINFO_CERTIFICATE                          2014 ; inline ! User certificate
: CRYPT_CERTINFO_USERCERTIFICATE                      2014 ; inline
: CRYPT_CERTINFO_CACERTIFICATE                        2015 ; inline ! CA certificate
: CRYPT_CERTINFO_ISSUERNAME                           2016 ; inline ! Issuer DN
: CRYPT_CERTINFO_VALIDFROM                            2017 ; inline ! Cert valid-from time
: CRYPT_CERTINFO_VALIDTO                              2018 ; inline ! Cert valid-to time
: CRYPT_CERTINFO_SUBJECTNAME                          2019 ; inline ! Subject DN
: CRYPT_CERTINFO_ISSUERUNIQUEID                       2020 ; inline ! Issuer unique ID
: CRYPT_CERTINFO_SUBJECTUNIQUEID                      2021 ; inline ! Subject unique ID
: CRYPT_CERTINFO_CERTREQUEST                          2022 ; inline ! Cert.request (DN + public key)
: CRYPT_CERTINFO_THISUPDATE                           2023 ; inline ! CRL/OCSP current-update time
: CRYPT_CERTINFO_NEXTUPDATE                           2024 ; inline ! CRL/OCSP next-update time
: CRYPT_CERTINFO_REVOCATIONDATE                       2025 ; inline ! CRL/OCSP cert-revocation time
: CRYPT_CERTINFO_REVOCATIONSTATUS                     2026 ; inline ! OCSP revocation status
: CRYPT_CERTINFO_CERTSTATUS                           2027 ; inline ! RTCS certificate status
: CRYPT_CERTINFO_DN                                   2028 ; inline ! Currently selected DN in string form
: CRYPT_CERTINFO_PKIUSER_ID                           2029 ; inline ! PKI user ID
: CRYPT_CERTINFO_PKIUSER_ISSUEPASSWORD                2030 ; inline ! PKI user issue password
: CRYPT_CERTINFO_PKIUSER_REVPASSWORD                  2031 ; inline ! PKI user revocation password
: CRYPT_CERTINFO_COUNTRYNAME                          2100 ; inline ! countryName
: CRYPT_CERTINFO_STATEORPROVINCENAME                  2101 ; inline ! stateOrProvinceName
: CRYPT_CERTINFO_LOCALITYNAME                         2102 ; inline ! localityName
: CRYPT_CERTINFO_ORGANIZATIONNAME                     2103 ; inline ! organizationName
: CRYPT_CERTINFO_ORGANISATIONNAME                     2103 ; inline
: CRYPT_CERTINFO_ORGANIZATIONALUNITNAME               2104 ; inline ! organizationalUnitName
: CRYPT_CERTINFO_ORGANISATIONALUNITNAME               2104 ; inline
: CRYPT_CERTINFO_COMMONNAME                           2105 ; inline ! commonName
: CRYPT_CERTINFO_OTHERNAME_TYPEID                     2106 ; inline ! otherName.typeID
: CRYPT_CERTINFO_OTHERNAME_VALUE                      2107 ; inline ! otherName.value
: CRYPT_CERTINFO_RFC822NAME                           2108 ; inline ! rfc822Name
: CRYPT_CERTINFO_EMAIL                                2108 ; inline
: CRYPT_CERTINFO_DNSNAME                              2109 ; inline ! dNSName
: CRYPT_CERTINFO_DIRECTORYNAME                        2110 ; inline ! directoryName
: CRYPT_CERTINFO_EDIPARTYNAME_NAMEASSIGNER            2111 ; inline ! ediPartyName.nameAssigner
: CRYPT_CERTINFO_EDIPARTYNAME_PARTYNAME               2112 ; inline ! ediPartyName.partyName
: CRYPT_CERTINFO_UNIFORMRESOURCEIDENTIFIER            2113 ; inline ! uniformResourceIdentifier
: CRYPT_CERTINFO_IPADDRESS                            2114 ; inline ! iPAddress
: CRYPT_CERTINFO_REGISTEREDID                         2115 ; inline ! registeredID
: CRYPT_CERTINFO_CHALLENGEPASSWORD                    2200 ; inline ! 1 3 6 1 4 1 3029 3 1 4 cRLExtReason
: CRYPT_CERTINFO_CRLEXTREASON                         2201 ; inline ! 1 3 6 1 4 1 3029 3 1 5 keyFeatures
: CRYPT_CERTINFO_KEYFEATURES                          2202 ; inline ! 1 3 6 1 5 5 7 1 1 authorityInfoAccess
: CRYPT_CERTINFO_AUTHORITYINFOACCESS                  2203 ; inline
: CRYPT_CERTINFO_AUTHORITYINFO_RTCS                   2204 ; inline ! accessDescription.accessLocation
: CRYPT_CERTINFO_AUTHORITYINFO_OCSP                   2205 ; inline ! accessDescription.accessLocation
: CRYPT_CERTINFO_AUTHORITYINFO_CAISSUERS              2206 ; inline ! accessDescription.accessLocation
: CRYPT_CERTINFO_AUTHORITYINFO_CERTSTORE              2207 ; inline ! accessDescription.accessLocation
: CRYPT_CERTINFO_AUTHORITYINFO_CRLS                   2208 ; inline ! accessDescription.accessLocation
: CRYPT_CERTINFO_BIOMETRICINFO                        2209 ; inline
: CRYPT_CERTINFO_BIOMETRICINFO_TYPE                   2210 ; inline ! biometricData.typeOfData
: CRYPT_CERTINFO_BIOMETRICINFO_HASHALGO               2211 ; inline ! biometricData.hashAlgorithm
: CRYPT_CERTINFO_BIOMETRICINFO_HASH                   2212 ; inline ! biometricData.dataHash
: CRYPT_CERTINFO_BIOMETRICINFO_URL                    2213 ; inline ! biometricData.sourceDataUri
: CRYPT_CERTINFO_QCSTATEMENT                          2214 ; inline
: CRYPT_CERTINFO_QCSTATEMENT_SEMANTICS                2215 ; inline ! qcStatement.statementInfo.semanticsIdentifier
: CRYPT_CERTINFO_QCSTATEMENT_REGISTRATIONAUTHORITY    2216 ; inline ! qcStatement.statementInfo.nameRegistrationAuthorities
: CRYPT_CERTINFO_OCSP_NONCE                           2217 ; inline ! nonce
: CRYPT_CERTINFO_OCSP_RESPONSE                        2218 ; inline
: CRYPT_CERTINFO_OCSP_RESPONSE_OCSP                   2219 ; inline ! OCSP standard response
: CRYPT_CERTINFO_OCSP_NOCHECK                         2220 ; inline ! 1 3 6 1 5 5 7 48 1 6 ocspArchiveCutoff
: CRYPT_CERTINFO_OCSP_ARCHIVECUTOFF                   2221 ; inline ! 1 3 6 1 5 5 7 48 1 11 subjectInfoAccess
: CRYPT_CERTINFO_SUBJECTINFOACCESS                    2222 ; inline
: CRYPT_CERTINFO_SUBJECTINFO_CAREPOSITORY             2223 ; inline ! accessDescription.accessLocation
: CRYPT_CERTINFO_SUBJECTINFO_TIMESTAMPING             2224 ; inline ! accessDescription.accessLocation
: CRYPT_CERTINFO_SIGG_DATEOFCERTGEN                   2225 ; inline ! 1 3 36 8 3 2 siggProcuration
: CRYPT_CERTINFO_SIGG_PROCURATION                     2226 ; inline
: CRYPT_CERTINFO_SIGG_PROCURE_COUNTRY                 2227 ; inline ! country
: CRYPT_CERTINFO_SIGG_PROCURE_TYPEOFSUBSTITUTION      2228 ; inline ! typeOfSubstitution
: CRYPT_CERTINFO_SIGG_PROCURE_SIGNINGFOR              2229 ; inline ! signingFor.thirdPerson
: CRYPT_CERTINFO_SIGG_MONETARYLIMIT                   2230 ; inline
: CRYPT_CERTINFO_SIGG_MONETARY_CURRENCY               2231 ; inline ! currency
: CRYPT_CERTINFO_SIGG_MONETARY_AMOUNT                 2232 ; inline ! amount
: CRYPT_CERTINFO_SIGG_MONETARY_EXPONENT               2233 ; inline ! exponent
: CRYPT_CERTINFO_SIGG_RESTRICTION                     2234 ; inline ! 1 3 101 1 4 1 strongExtranet
: CRYPT_CERTINFO_STRONGEXTRANET                       2235 ; inline
: CRYPT_CERTINFO_STRONGEXTRANET_ZONE                  2236 ; inline ! sxNetIDList.sxNetID.zone
: CRYPT_CERTINFO_STRONGEXTRANET_ID                    2237 ; inline ! sxNetIDList.sxNetID.id
: CRYPT_CERTINFO_SUBJECTDIRECTORYATTRIBUTES           2238 ; inline
: CRYPT_CERTINFO_SUBJECTDIR_TYPE                      2239 ; inline ! attribute.type
: CRYPT_CERTINFO_SUBJECTDIR_VALUES                    2240 ; inline ! attribute.values
: CRYPT_CERTINFO_SUBJECTKEYIDENTIFIER                 2241 ; inline ! 2 5 29 15 keyUsage
: CRYPT_CERTINFO_KEYUSAGE                             2242 ; inline ! 2 5 29 16 privateKeyUsagePeriod
: CRYPT_CERTINFO_PRIVATEKEYUSAGEPERIOD                2243 ; inline
: CRYPT_CERTINFO_PRIVATEKEY_NOTBEFORE                 2244 ; inline ! notBefore
: CRYPT_CERTINFO_PRIVATEKEY_NOTAFTER                  2245 ; inline ! notAfter
: CRYPT_CERTINFO_SUBJECTALTNAME                       2246 ; inline ! 2 5 29 18 issuerAltName
: CRYPT_CERTINFO_ISSUERALTNAME                        2247 ; inline ! 2 5 29 19 basicConstraints
: CRYPT_CERTINFO_BASICCONSTRAINTS                     2248 ; inline
: CRYPT_CERTINFO_CA                                   2249 ; inline ! cA
: CRYPT_CERTINFO_AUTHORITY                            2249 ; inline
: CRYPT_CERTINFO_PATHLENCONSTRAINT                    2250 ; inline ! pathLenConstraint
: CRYPT_CERTINFO_CRLNUMBER                            2251 ; inline ! 2 5 29 21 cRLReason
: CRYPT_CERTINFO_CRLREASON                            2252 ; inline ! 2 5 29 23 holdInstructionCode
: CRYPT_CERTINFO_HOLDINSTRUCTIONCODE                  2253 ; inline ! 2 5 29 24 invalidityDate
: CRYPT_CERTINFO_INVALIDITYDATE                       2254 ; inline ! 2 5 29 27 deltaCRLIndicator
: CRYPT_CERTINFO_DELTACRLINDICATOR                    2255 ; inline ! 2 5 29 28 issuingDistributionPoint
: CRYPT_CERTINFO_ISSUINGDISTRIBUTIONPOINT             2256 ; inline
: CRYPT_CERTINFO_ISSUINGDIST_FULLNAME                 2257 ; inline ! distributionPointName.fullName
: CRYPT_CERTINFO_ISSUINGDIST_USERCERTSONLY            2258 ; inline ! onlyContainsUserCerts
: CRYPT_CERTINFO_ISSUINGDIST_CACERTSONLY              2259 ; inline ! onlyContainsCACerts
: CRYPT_CERTINFO_ISSUINGDIST_SOMEREASONSONLY          2260 ; inline ! onlySomeReasons
: CRYPT_CERTINFO_ISSUINGDIST_INDIRECTCRL              2261 ; inline ! indirectCRL
: CRYPT_CERTINFO_CERTIFICATEISSUER                    2262 ; inline ! 2 5 29 30 nameConstraints
: CRYPT_CERTINFO_NAMECONSTRAINTS                      2263 ; inline
: CRYPT_CERTINFO_PERMITTEDSUBTREES                    2264 ; inline ! permittedSubtrees
: CRYPT_CERTINFO_EXCLUDEDSUBTREES                     2265 ; inline ! excludedSubtrees
: CRYPT_CERTINFO_CRLDISTRIBUTIONPOINT                 2266 ; inline
: CRYPT_CERTINFO_CRLDIST_FULLNAME                     2267 ; inline ! distributionPointName.fullName
: CRYPT_CERTINFO_CRLDIST_REASONS                      2268 ; inline ! reasons
: CRYPT_CERTINFO_CRLDIST_CRLISSUER                    2269 ; inline ! cRLIssuer
: CRYPT_CERTINFO_CERTIFICATEPOLICIES                  2270 ; inline
: CRYPT_CERTINFO_CERTPOLICYID                         2271 ; inline ! policyInformation.policyIdentifier
: CRYPT_CERTINFO_CERTPOLICY_CPSURI                    2272 ; inline ! policyInformation.policyQualifiers.qualifier.cPSuri
: CRYPT_CERTINFO_CERTPOLICY_ORGANIZATION              2273 ; inline ! policyInformation.policyQualifiers.qualifier.userNotice.noticeRef.organization
: CRYPT_CERTINFO_CERTPOLICY_NOTICENUMBERS             2274 ; inline ! policyInformation.policyQualifiers.qualifier.userNotice.noticeRef.noticeNumbers
: CRYPT_CERTINFO_CERTPOLICY_EXPLICITTEXT              2275 ; inline ! policyInformation.policyQualifiers.qualifier.userNotice.explicitText
: CRYPT_CERTINFO_POLICYMAPPINGS                       2276 ; inline
: CRYPT_CERTINFO_ISSUERDOMAINPOLICY                   2277 ; inline ! policyMappings.issuerDomainPolicy
: CRYPT_CERTINFO_SUBJECTDOMAINPOLICY                  2278 ; inline ! policyMappings.subjectDomainPolicy
: CRYPT_CERTINFO_AUTHORITYKEYIDENTIFIER               2279 ; inline
: CRYPT_CERTINFO_AUTHORITY_KEYIDENTIFIER              2280 ; inline ! keyIdentifier
: CRYPT_CERTINFO_AUTHORITY_CERTISSUER                 2281 ; inline ! authorityCertIssuer
: CRYPT_CERTINFO_AUTHORITY_CERTSERIALNUMBER           2282 ; inline ! authorityCertSerialNumber
: CRYPT_CERTINFO_POLICYCONSTRAINTS                    2283 ; inline
: CRYPT_CERTINFO_REQUIREEXPLICITPOLICY                2284 ; inline ! policyConstraints.requireExplicitPolicy
: CRYPT_CERTINFO_INHIBITPOLICYMAPPING                 2285 ; inline ! policyConstraints.inhibitPolicyMapping
: CRYPT_CERTINFO_EXTKEYUSAGE                          2286 ; inline
: CRYPT_CERTINFO_EXTKEY_MS_INDIVIDUALCODESIGNING      2287 ; inline ! individualCodeSigning
: CRYPT_CERTINFO_EXTKEY_MS_COMMERCIALCODESIGNING      2288 ; inline ! commercialCodeSigning
: CRYPT_CERTINFO_EXTKEY_MS_CERTTRUSTLISTSIGNING       2289 ; inline ! certTrustListSigning
: CRYPT_CERTINFO_EXTKEY_MS_TIMESTAMPSIGNING           2290 ; inline ! timeStampSigning
: CRYPT_CERTINFO_EXTKEY_MS_SERVERGATEDCRYPTO          2291 ; inline ! serverGatedCrypto
: CRYPT_CERTINFO_EXTKEY_MS_ENCRYPTEDFILESYSTEM        2292 ; inline ! encrypedFileSystem
: CRYPT_CERTINFO_EXTKEY_SERVERAUTH                    2293 ; inline ! serverAuth
: CRYPT_CERTINFO_EXTKEY_CLIENTAUTH                    2294 ; inline ! clientAuth
: CRYPT_CERTINFO_EXTKEY_CODESIGNING                   2295 ; inline ! codeSigning
: CRYPT_CERTINFO_EXTKEY_EMAILPROTECTION               2296 ; inline ! emailProtection
: CRYPT_CERTINFO_EXTKEY_IPSECENDSYSTEM                2297 ; inline ! ipsecEndSystem
: CRYPT_CERTINFO_EXTKEY_IPSECTUNNEL                   2298 ; inline ! ipsecTunnel
: CRYPT_CERTINFO_EXTKEY_IPSECUSER                     2299 ; inline ! ipsecUser
: CRYPT_CERTINFO_EXTKEY_TIMESTAMPING                  2300 ; inline ! timeStamping
: CRYPT_CERTINFO_EXTKEY_OCSPSIGNING                   2301 ; inline ! ocspSigning
: CRYPT_CERTINFO_EXTKEY_DIRECTORYSERVICE              2302 ; inline ! directoryService
: CRYPT_CERTINFO_EXTKEY_ANYKEYUSAGE                   2303 ; inline ! anyExtendedKeyUsage
: CRYPT_CERTINFO_EXTKEY_NS_SERVERGATEDCRYPTO          2304 ; inline ! serverGatedCrypto
: CRYPT_CERTINFO_EXTKEY_VS_SERVERGATEDCRYPTO_CA       2305 ; inline ! serverGatedCrypto CA
: CRYPT_CERTINFO_FRESHESTCRL                          2306 ; inline
: CRYPT_CERTINFO_FRESHESTCRL_FULLNAME                 2307 ; inline ! distributionPointName.fullName
: CRYPT_CERTINFO_FRESHESTCRL_REASONS                  2308 ; inline ! reasons
: CRYPT_CERTINFO_FRESHESTCRL_CRLISSUER                2309 ; inline ! cRLIssuer
: CRYPT_CERTINFO_INHIBITANYPOLICY                     2310 ; inline ! 2 16 840 1 113730 1 x Netscape extensions
: CRYPT_CERTINFO_NS_CERTTYPE                          2311 ; inline ! netscape-cert-type
: CRYPT_CERTINFO_NS_BASEURL                           2312 ; inline ! netscape-base-url
: CRYPT_CERTINFO_NS_REVOCATIONURL                     2313 ; inline ! netscape-revocation-url
: CRYPT_CERTINFO_NS_CAREVOCATIONURL                   2314 ; inline ! netscape-ca-revocation-url
: CRYPT_CERTINFO_NS_CERTRENEWALURL                    2315 ; inline ! netscape-cert-renewal-url
: CRYPT_CERTINFO_NS_CAPOLICYURL                       2316 ; inline ! netscape-ca-policy-url
: CRYPT_CERTINFO_NS_SSLSERVERNAME                     2317 ; inline ! netscape-ssl-server-name
: CRYPT_CERTINFO_NS_COMMENT                           2318 ; inline ! netscape-comment
: CRYPT_CERTINFO_SET_HASHEDROOTKEY                    2319 ; inline
: CRYPT_CERTINFO_SET_ROOTKEYTHUMBPRINT                2320 ; inline ! rootKeyThumbPrint
: CRYPT_CERTINFO_SET_CERTIFICATETYPE                  2321 ; inline ! 2 23 42 7 2 SET merchantData
: CRYPT_CERTINFO_SET_MERCHANTDATA                     2322 ; inline
: CRYPT_CERTINFO_SET_MERID                            2323 ; inline ! merID
: CRYPT_CERTINFO_SET_MERACQUIRERBIN                   2324 ; inline ! merAcquirerBIN
: CRYPT_CERTINFO_SET_MERCHANTLANGUAGE                 2325 ; inline ! merNames.language
: CRYPT_CERTINFO_SET_MERCHANTNAME                     2326 ; inline ! merNames.name
: CRYPT_CERTINFO_SET_MERCHANTCITY                     2327 ; inline ! merNames.city
: CRYPT_CERTINFO_SET_MERCHANTSTATEPROVINCE            2328 ; inline ! merNames.stateProvince
: CRYPT_CERTINFO_SET_MERCHANTPOSTALCODE               2329 ; inline ! merNames.postalCode
: CRYPT_CERTINFO_SET_MERCHANTCOUNTRYNAME              2330 ; inline ! merNames.countryName
: CRYPT_CERTINFO_SET_MERCOUNTRY                       2331 ; inline ! merCountry
: CRYPT_CERTINFO_SET_MERAUTHFLAG                      2332 ; inline ! merAuthFlag
: CRYPT_CERTINFO_SET_CERTCARDREQUIRED                 2333 ; inline ! 2 23 42 7 4 SET tunneling
: CRYPT_CERTINFO_SET_TUNNELING                        2334 ; inline
: CRYPT_CERTINFO_SET_TUNNELLING                       2334 ; inline
: CRYPT_CERTINFO_SET_TUNNELINGFLAG                    2335 ; inline ! tunneling
: CRYPT_CERTINFO_SET_TUNNELLINGFLAG                   2335 ; inline
: CRYPT_CERTINFO_SET_TUNNELINGALGID                   2336 ; inline ! tunnelingAlgID
: CRYPT_CERTINFO_SET_TUNNELLINGALGID                  2336 ; inline ! S/MIME attributes
: CRYPT_CERTINFO_CMS_CONTENTTYPE                      2500 ; inline ! 1 2 840 113549 1 9 4 messageDigest
: CRYPT_CERTINFO_CMS_MESSAGEDIGEST                    2501 ; inline ! 1 2 840 113549 1 9 5 signingTime
: CRYPT_CERTINFO_CMS_SIGNINGTIME                      2502 ; inline ! 1 2 840 113549 1 9 6 counterSignature
: CRYPT_CERTINFO_CMS_COUNTERSIGNATURE                 2503 ; inline ! counterSignature
: CRYPT_CERTINFO_CMS_SIGNINGDESCRIPTION               2504 ; inline ! 1 2 840 113549 1 9 15 sMIMECapabilities
: CRYPT_CERTINFO_CMS_SMIMECAPABILITIES                2505 ; inline
: CRYPT_CERTINFO_CMS_SMIMECAP_3DES                    2506 ; inline ! 3DES encryption
: CRYPT_CERTINFO_CMS_SMIMECAP_AES                     2507 ; inline ! AES encryption
: CRYPT_CERTINFO_CMS_SMIMECAP_CAST128                 2508 ; inline ! CAST-128 encryption
: CRYPT_CERTINFO_CMS_SMIMECAP_IDEA                    2509 ; inline ! IDEA encryption
: CRYPT_CERTINFO_CMS_SMIMECAP_RC2                     2510 ; inline ! RC2 encryption (w.128 key)
: CRYPT_CERTINFO_CMS_SMIMECAP_RC5                     2511 ; inline ! RC5 encryption (w.128 key)
: CRYPT_CERTINFO_CMS_SMIMECAP_SKIPJACK                2512 ; inline ! Skipjack encryption
: CRYPT_CERTINFO_CMS_SMIMECAP_DES                     2513 ; inline ! DES encryption
: CRYPT_CERTINFO_CMS_SMIMECAP_PREFERSIGNEDDATA        2514 ; inline ! preferSignedData
: CRYPT_CERTINFO_CMS_SMIMECAP_CANNOTDECRYPTANY        2515 ; inline ! canNotDecryptAny
: CRYPT_CERTINFO_CMS_RECEIPTREQUEST                   2516 ; inline
: CRYPT_CERTINFO_CMS_RECEIPT_CONTENTIDENTIFIER        2517 ; inline ! contentIdentifier
: CRYPT_CERTINFO_CMS_RECEIPT_FROM                     2518 ; inline ! receiptsFrom
: CRYPT_CERTINFO_CMS_RECEIPT_TO                       2519 ; inline ! receiptsTo
: CRYPT_CERTINFO_CMS_SECURITYLABEL                    2520 ; inline
: CRYPT_CERTINFO_CMS_SECLABEL_POLICY                  2521 ; inline ! securityPolicyIdentifier
: CRYPT_CERTINFO_CMS_SECLABEL_CLASSIFICATION          2522 ; inline ! securityClassification
: CRYPT_CERTINFO_CMS_SECLABEL_PRIVACYMARK             2523 ; inline ! privacyMark
: CRYPT_CERTINFO_CMS_SECLABEL_CATTYPE                 2524 ; inline ! securityCategories.securityCategory.type
: CRYPT_CERTINFO_CMS_SECLABEL_CATVALUE                2525 ; inline ! securityCategories.securityCategory.value
: CRYPT_CERTINFO_CMS_MLEXPANSIONHISTORY               2526 ; inline
: CRYPT_CERTINFO_CMS_MLEXP_ENTITYIDENTIFIER           2527 ; inline ! mlData.mailListIdentifier.issuerAndSerialNumber
: CRYPT_CERTINFO_CMS_MLEXP_TIME                       2528 ; inline ! mlData.expansionTime
: CRYPT_CERTINFO_CMS_MLEXP_NONE                       2529 ; inline ! mlData.mlReceiptPolicy.none
: CRYPT_CERTINFO_CMS_MLEXP_INSTEADOF                  2530 ; inline ! mlData.mlReceiptPolicy.insteadOf.generalNames.generalName
: CRYPT_CERTINFO_CMS_MLEXP_INADDITIONTO               2531 ; inline ! mlData.mlReceiptPolicy.inAdditionTo.generalNames.generalName
: CRYPT_CERTINFO_CMS_CONTENTHINTS                     2532 ; inline
: CRYPT_CERTINFO_CMS_CONTENTHINT_DESCRIPTION          2533 ; inline ! contentDescription
: CRYPT_CERTINFO_CMS_CONTENTHINT_TYPE                 2534 ; inline ! contentType
: CRYPT_CERTINFO_CMS_EQUIVALENTLABEL                  2535 ; inline
: CRYPT_CERTINFO_CMS_EQVLABEL_POLICY                  2536 ; inline ! securityPolicyIdentifier
: CRYPT_CERTINFO_CMS_EQVLABEL_CLASSIFICATION          2537 ; inline ! securityClassification
: CRYPT_CERTINFO_CMS_EQVLABEL_PRIVACYMARK             2538 ; inline ! privacyMark
: CRYPT_CERTINFO_CMS_EQVLABEL_CATTYPE                 2539 ; inline ! securityCategories.securityCategory.type
: CRYPT_CERTINFO_CMS_EQVLABEL_CATVALUE                2540 ; inline ! securityCategories.securityCategory.value
: CRYPT_CERTINFO_CMS_SIGNINGCERTIFICATE               2541 ; inline
: CRYPT_CERTINFO_CMS_SIGNINGCERT_ESSCERTID            2542 ; inline ! certs.essCertID
: CRYPT_CERTINFO_CMS_SIGNINGCERT_POLICIES             2543 ; inline ! policies.policyInformation.policyIdentifier
: CRYPT_CERTINFO_CMS_SIGNATUREPOLICYID                2544 ; inline
: CRYPT_CERTINFO_CMS_SIGPOLICYID                      2545 ; inline ! sigPolicyID
: CRYPT_CERTINFO_CMS_SIGPOLICYHASH                    2546 ; inline ! sigPolicyHash
: CRYPT_CERTINFO_CMS_SIGPOLICY_CPSURI                 2547 ; inline ! sigPolicyQualifiers.sigPolicyQualifier.cPSuri
: CRYPT_CERTINFO_CMS_SIGPOLICY_ORGANIZATION           2548 ; inline ! sigPolicyQualifiers.sigPolicyQualifier.userNotice.noticeRef.organization
: CRYPT_CERTINFO_CMS_SIGPOLICY_NOTICENUMBERS          2549 ; inline ! sigPolicyQualifiers.sigPolicyQualifier.userNotice.noticeRef.noticeNumbers
: CRYPT_CERTINFO_CMS_SIGPOLICY_EXPLICITTEXT           2550 ; inline ! sigPolicyQualifiers.sigPolicyQualifier.userNotice.explicitText
: CRYPT_CERTINFO_CMS_SIGTYPEIDENTIFIER                2551 ; inline
: CRYPT_CERTINFO_CMS_SIGTYPEID_ORIGINATORSIG          2552 ; inline ! originatorSig
: CRYPT_CERTINFO_CMS_SIGTYPEID_DOMAINSIG              2553 ; inline ! domainSig
: CRYPT_CERTINFO_CMS_SIGTYPEID_ADDITIONALATTRIBUTES   2554 ; inline ! additionalAttributesSig
: CRYPT_CERTINFO_CMS_SIGTYPEID_REVIEWSIG              2555 ; inline ! reviewSig
: CRYPT_CERTINFO_CMS_NONCE                            2556 ; inline ! randomNonce
: CRYPT_CERTINFO_SCEP_MESSAGETYPE                     2557 ; inline ! messageType
: CRYPT_CERTINFO_SCEP_PKISTATUS                       2558 ; inline ! pkiStatus
: CRYPT_CERTINFO_SCEP_FAILINFO                        2559 ; inline ! failInfo
: CRYPT_CERTINFO_SCEP_SENDERNONCE                     2560 ; inline ! senderNonce
: CRYPT_CERTINFO_SCEP_RECIPIENTNONCE                  2561 ; inline ! recipientNonce
: CRYPT_CERTINFO_SCEP_TRANSACTIONID                   2562 ; inline ! transID
: CRYPT_CERTINFO_CMS_SPCAGENCYINFO                    2563 ; inline
: CRYPT_CERTINFO_CMS_SPCAGENCYURL                     2564 ; inline ! spcAgencyInfo.url
: CRYPT_CERTINFO_CMS_SPCSTATEMENTTYPE                 2565 ; inline
: CRYPT_CERTINFO_CMS_SPCSTMT_INDIVIDUALCODESIGNING    2566 ; inline ! individualCodeSigning
: CRYPT_CERTINFO_CMS_SPCSTMT_COMMERCIALCODESIGNING    2567 ; inline ! commercialCodeSigning
: CRYPT_CERTINFO_CMS_SPCOPUSINFO                      2568 ; inline
: CRYPT_CERTINFO_CMS_SPCOPUSINFO_NAME                 2569 ; inline ! spcOpusInfo.name
: CRYPT_CERTINFO_CMS_SPCOPUSINFO_URL                  2570 ; inline ! spcOpusInfo.url
: CRYPT_CERTINFO_LAST                                 2571 ; inline
: CRYPT_KEYINFO_FIRST                                 3000 ; inline ! *******************
: CRYPT_KEYINFO_QUERY                                 3001 ; inline ! Keyset query
: CRYPT_KEYINFO_QUERY_REQUESTS                        3002 ; inline ! Query of requests in cert store
: CRYPT_KEYINFO_LAST                                  3003 ; inline
: CRYPT_DEVINFO_FIRST                                 4000 ; inline ! *******************
: CRYPT_DEVINFO_INITIALISE                            4001 ; inline ! Initialise device for use
: CRYPT_DEVINFO_INITIALIZE                            4001 ; inline
: CRYPT_DEVINFO_AUTHENT_USER                          4002 ; inline ! Authenticate user to device
: CRYPT_DEVINFO_AUTHENT_SUPERVISOR                    4003 ; inline ! Authenticate supervisor to dev.
: CRYPT_DEVINFO_SET_AUTHENT_USER                      4004 ; inline ! Set user authent.value
: CRYPT_DEVINFO_SET_AUTHENT_SUPERVISOR                4005 ; inline ! Set supervisor auth.val.
: CRYPT_DEVINFO_ZEROISE                               4006 ; inline ! Zeroise device
: CRYPT_DEVINFO_ZEROIZE                               4006 ; inline
: CRYPT_DEVINFO_LOGGEDIN                              4007 ; inline ! Whether user is logged in
: CRYPT_DEVINFO_LABEL                                 4008 ; inline ! Device/token label
: CRYPT_DEVINFO_LAST                                  4009 ; inline
: CRYPT_ENVINFO_FIRST                                 5000 ; inline ! *********************
: CRYPT_ENVINFO_DATASIZE                              5001 ; inline ! Data size information
: CRYPT_ENVINFO_COMPRESSION                           5002 ; inline ! Compression information
: CRYPT_ENVINFO_CONTENTTYPE                           5003 ; inline ! Inner CMS content type
: CRYPT_ENVINFO_DETACHEDSIGNATURE                     5004 ; inline ! Generate CMS detached signature
: CRYPT_ENVINFO_SIGNATURE_RESULT                      5005 ; inline ! Signature check result
: CRYPT_ENVINFO_MAC                                   5006 ; inline ! Use MAC instead of encrypting
: CRYPT_ENVINFO_PASSWORD                              5007 ; inline ! User password
: CRYPT_ENVINFO_KEY                                   5008 ; inline ! Conventional encryption key
: CRYPT_ENVINFO_SIGNATURE                             5009 ; inline ! Signature/signature check key
: CRYPT_ENVINFO_SIGNATURE_EXTRADATA                   5010 ; inline ! Extra information added to CMS sigs
: CRYPT_ENVINFO_RECIPIENT                             5011 ; inline ! Recipient email address
: CRYPT_ENVINFO_PUBLICKEY                             5012 ; inline ! PKC encryption key
: CRYPT_ENVINFO_PRIVATEKEY                            5013 ; inline ! PKC decryption key
: CRYPT_ENVINFO_PRIVATEKEY_LABEL                      5014 ; inline ! Label of PKC decryption key
: CRYPT_ENVINFO_ORIGINATOR                            5015 ; inline ! Originator info/key
: CRYPT_ENVINFO_SESSIONKEY                            5016 ; inline ! Session key
: CRYPT_ENVINFO_HASH                                  5017 ; inline ! Hash value
: CRYPT_ENVINFO_TIMESTAMP                             5018 ; inline ! Timestamp information
: CRYPT_ENVINFO_KEYSET_SIGCHECK                       5019 ; inline ! Signature check keyset
: CRYPT_ENVINFO_KEYSET_ENCRYPT                        5020 ; inline ! PKC encryption keyset
: CRYPT_ENVINFO_KEYSET_DECRYPT                        5021 ; inline ! PKC decryption keyset
: CRYPT_ENVINFO_LAST                                  5022 ; inline
: CRYPT_SESSINFO_FIRST                                6000 ; inline ! ********************
: CRYPT_SESSINFO_ACTIVE                               6001 ; inline ! Whether session is active
: CRYPT_SESSINFO_CONNECTIONACTIVE                     6002 ; inline ! Whether network connection is active
: CRYPT_SESSINFO_USERNAME                             6003 ; inline ! User name
: CRYPT_SESSINFO_PASSWORD                             6004 ; inline ! Password
: CRYPT_SESSINFO_PRIVATEKEY                           6005 ; inline ! Server/client private key
: CRYPT_SESSINFO_KEYSET                               6006 ; inline ! Certificate store
: CRYPT_SESSINFO_AUTHRESPONSE                         6007 ; inline ! Session authorisation OK
: CRYPT_SESSINFO_SERVER_NAME                          6008 ; inline ! Server name
: CRYPT_SESSINFO_SERVER_PORT                          6009 ; inline ! Server port number
: CRYPT_SESSINFO_SERVER_FINGERPRINT                   6010 ; inline ! Server key fingerprint
: CRYPT_SESSINFO_CLIENT_NAME                          6011 ; inline ! Client name
: CRYPT_SESSINFO_CLIENT_PORT                          6012 ; inline ! Client port number
: CRYPT_SESSINFO_SESSION                              6013 ; inline ! Transport mechanism
: CRYPT_SESSINFO_NETWORKSOCKET                        6014 ; inline ! User-supplied network socket
: CRYPT_SESSINFO_VERSION                              6015 ; inline ! Protocol version
: CRYPT_SESSINFO_REQUEST                              6016 ; inline ! Cert.request object
: CRYPT_SESSINFO_RESPONSE                             6017 ; inline ! Cert.response object
: CRYPT_SESSINFO_CACERTIFICATE                        6018 ; inline ! Issuing CA certificate
: CRYPT_SESSINFO_TSP_MSGIMPRINT                       6019 ; inline ! TSP message imprint
: CRYPT_SESSINFO_CMP_REQUESTTYPE                      6020 ; inline ! Request type
: CRYPT_SESSINFO_CMP_PKIBOOT                          6021 ; inline ! Enable PKIBoot facility
: CRYPT_SESSINFO_CMP_PRIVKEYSET                       6022 ; inline ! Private-key keyset
: CRYPT_SESSINFO_SSH_CHANNEL                          6023 ; inline ! SSH current channel
: CRYPT_SESSINFO_SSH_CHANNEL_TYPE                     6024 ; inline ! SSH channel type
: CRYPT_SESSINFO_SSH_CHANNEL_ARG1                     6025 ; inline ! SSH channel argument 1
: CRYPT_SESSINFO_SSH_CHANNEL_ARG2                     6026 ; inline ! SSH channel argument 2
: CRYPT_SESSINFO_SSH_CHANNEL_ACTIVE                   6027 ; inline ! SSH channel active
: CRYPT_SESSINFO_LAST                                 6028 ; inline
: CRYPT_USERINFO_FIRST                                7000 ; inline ! ********************
: CRYPT_USERINFO_PASSWORD                             7001 ; inline ! Password
: CRYPT_USERINFO_CAKEY_CERTSIGN                       7002 ; inline ! CA cert signing key
: CRYPT_USERINFO_CAKEY_CRLSIGN                        7003 ; inline ! CA CRL signing key
: CRYPT_USERINFO_CAKEY_RTCSSIGN                       7004 ; inline ! CA RTCS signing key
: CRYPT_USERINFO_CAKEY_OCSPSIGN                       7005 ; inline ! CA OCSP signing key
: CRYPT_USERINFO_LAST                                 7006 ; inline
: CRYPT_ATTRIBUTE_LAST                                7006 ; inline

TYPEDEF: int CRYPT_ATTRIBUTE_TYPE

! ===============================================
! Attribute Subtypes and Related Values
! ===============================================

! Flags for the X.509 keyUsage extension
: CRYPT_KEYUSAGE_NONE                            HEX: 000 ; inline
: CRYPT_KEYUSAGE_DIGITALSIGNATURE                HEX: 001 ; inline
: CRYPT_KEYUSAGE_NONREPUDIATION                  HEX: 002 ; inline
: CRYPT_KEYUSAGE_KEYENCIPHERMENT                 HEX: 004 ; inline
: CRYPT_KEYUSAGE_DATAENCIPHERMENT                HEX: 008 ; inline
: CRYPT_KEYUSAGE_KEYAGREEMENT                    HEX: 010 ; inline
: CRYPT_KEYUSAGE_KEYCERTSIGN                     HEX: 020 ; inline
: CRYPT_KEYUSAGE_CRLSIGN                         HEX: 040 ; inline
: CRYPT_KEYUSAGE_ENCIPHERONLY                    HEX: 080 ; inline
: CRYPT_KEYUSAGE_DECIPHERONLY                    HEX: 100 ; inline
: CRYPT_KEYUSAGE_LAST                            HEX: 200 ; inline ! Last possible value

! X.509 cRLReason and cryptlib cRLExtReason codes
: CRYPT_CRLREASON_UNSPECIFIED             0  ; inline
: CRYPT_CRLREASON_KEYCOMPROMISE           1  ; inline
: CRYPT_CRLREASON_CACOMPROMISE            2  ; inline
: CRYPT_CRLREASON_AFFILIATIONCHANGED      3  ; inline
: CRYPT_CRLREASON_SUPERSEDED              4  ; inline
: CRYPT_CRLREASON_CESSATIONOFOPERATION    5  ; inline
: CRYPT_CRLREASON_CERTIFICATEHOLD         6  ; inline
: CRYPT_CRLREASON_REMOVEFROMCRL           8  ; inline
: CRYPT_CRLREASON_PRIVILEGEWITHDRAWN      9  ; inline
: CRYPT_CRLREASON_AACOMPROMISE            10 ; inline
: CRYPT_CRLREASON_LAST                    11 ; inline ! End of standard CRL reasons
: CRYPT_CRLREASON_NEVERVALID              20 ; inline
: CRYPT_CRLEXTREASON_LAST                 21 ; inline

! X.509 CRL reason flags.  These identify the same thing as the cRLReason
! codes but allow for multiple reasons to be specified.  Note that these
! don't follow the X.509 naming since in that scheme the enumerated types
! and bitflags have the same names
: CRYPT_CRLREASONFLAG_UNUSED                     HEX: 001 ; inline
: CRYPT_CRLREASONFLAG_KEYCOMPROMISE              HEX: 002 ; inline
: CRYPT_CRLREASONFLAG_CACOMPROMISE               HEX: 004 ; inline
: CRYPT_CRLREASONFLAG_AFFILIATIONCHANGED         HEX: 008 ; inline
: CRYPT_CRLREASONFLAG_SUPERSEDED                 HEX: 010 ; inline
: CRYPT_CRLREASONFLAG_CESSATIONOFOPERATION       HEX: 020 ; inline
: CRYPT_CRLREASONFLAG_CERTIFICATEHOLD            HEX: 040 ; inline
: CRYPT_CRLREASONFLAG_LAST                       HEX: 080 ; inline ! Last poss.value

! X.509 CRL holdInstruction codes
: CRYPT_HOLDINSTRUCTION_NONE           0 ; inline
: CRYPT_HOLDINSTRUCTION_CALLISSUER     1 ; inline
: CRYPT_HOLDINSTRUCTION_REJECT         2 ; inline
: CRYPT_HOLDINSTRUCTION_PICKUPTOKEN    3 ; inline
: CRYPT_HOLDINSTRUCTION_LAST           4 ; inline

! Certificate checking compliance levels
: CRYPT_COMPLIANCELEVEL_OBLIVIOUS       0 ; inline
: CRYPT_COMPLIANCELEVEL_REDUCED         1 ; inline
: CRYPT_COMPLIANCELEVEL_STANDARD        2 ; inline
: CRYPT_COMPLIANCELEVEL_PKIX_PARTIAL    3 ; inline
: CRYPT_COMPLIANCELEVEL_PKIX_FULL       4 ; inline
: CRYPT_COMPLIANCELEVEL_LAST            5 ; inline

! Flags for the Netscape netscape-cert-type extension
: CRYPT_NS_CERTTYPE_SSLCLIENT                    HEX: 001 ; inline
: CRYPT_NS_CERTTYPE_SSLSERVER                    HEX: 002 ; inline
: CRYPT_NS_CERTTYPE_SMIME                        HEX: 004 ; inline
: CRYPT_NS_CERTTYPE_OBJECTSIGNING                HEX: 008 ; inline
: CRYPT_NS_CERTTYPE_RESERVED                     HEX: 010 ; inline
: CRYPT_NS_CERTTYPE_SSLCA                        HEX: 020 ; inline
: CRYPT_NS_CERTTYPE_SMIMECA                      HEX: 040 ; inline
: CRYPT_NS_CERTTYPE_OBJECTSIGNINGCA              HEX: 080 ; inline
: CRYPT_NS_CERTTYPE_LAST                         HEX: 100 ; inline ! Last possible value

! Flags for the SET certificate-type extension
: CRYPT_SET_CERTTYPE_CARD                        HEX: 001 ; inline
: CRYPT_SET_CERTTYPE_MER                         HEX: 002 ; inline
: CRYPT_SET_CERTTYPE_PGWY                        HEX: 004 ; inline
: CRYPT_SET_CERTTYPE_CCA                         HEX: 008 ; inline
: CRYPT_SET_CERTTYPE_MCA                         HEX: 010 ; inline
: CRYPT_SET_CERTTYPE_PCA                         HEX: 020 ; inline
: CRYPT_SET_CERTTYPE_GCA                         HEX: 040 ; inline
: CRYPT_SET_CERTTYPE_BCA                         HEX: 080 ; inline
: CRYPT_SET_CERTTYPE_RCA                         HEX: 100 ; inline
: CRYPT_SET_CERTTYPE_ACQ                         HEX: 200 ; inline
: CRYPT_SET_CERTTYPE_LAST                        HEX: 400 ; inline ! Last possible value

! CMS contentType values
! CRYPT_CONTENT_TYPE
: CRYPT_CONTENT_NONE                        0  ; inline
: CRYPT_CONTENT_DATA                        1  ; inline
: CRYPT_CONTENT_SIGNEDDATA                  2  ; inline
: CRYPT_CONTENT_ENVELOPEDDATA               3  ; inline
: CRYPT_CONTENT_SIGNEDANDENVELOPEDDATA      4  ; inline
: CRYPT_CONTENT_DIGESTEDDATA                5  ; inline
: CRYPT_CONTENT_ENCRYPTEDDATA               6  ; inline
: CRYPT_CONTENT_COMPRESSEDDATA              7  ; inline
: CRYPT_CONTENT_TSTINFO                     8  ; inline
: CRYPT_CONTENT_SPCINDIRECTDATACONTEXT      9  ; inline
: CRYPT_CONTENT_RTCSREQUEST                 10 ; inline
: CRYPT_CONTENT_RTCSRESPONSE                11 ; inline
: CRYPT_CONTENT_RTCSRESPONSE_EXT            12 ; inline
: CRYPT_CONTENT_LAST                        13 ; inline

! ESS securityClassification codes
: CRYPT_CLASSIFICATION_UNMARKED            0   ; inline
: CRYPT_CLASSIFICATION_UNCLASSIFIED        1   ; inline
: CRYPT_CLASSIFICATION_RESTRICTED          2   ; inline
: CRYPT_CLASSIFICATION_CONFIDENTIAL        3   ; inline
: CRYPT_CLASSIFICATION_SECRET              4   ; inline
: CRYPT_CLASSIFICATION_TOP_SECRET          5   ; inline
: CRYPT_CLASSIFICATION_LAST                255 ; inline

! RTCS certificate status
: CRYPT_CERTSTATUS_VALID               0 ; inline
: CRYPT_CERTSTATUS_NOTVALID            1 ; inline
: CRYPT_CERTSTATUS_NONAUTHORITATIVE    2 ; inline
: CRYPT_CERTSTATUS_UNKNOWN             3 ; inline

! OCSP revocation status
: CRYPT_OCSPSTATUS_NOTREVOKED    0 ; inline
: CRYPT_OCSPSTATUS_REVOKED       1 ; inline
: CRYPT_OCSPSTATUS_UNKNOWN       2 ; inline

! The amount of detail to include in signatures when signing certificate
!  objects
! CRYPT_SIGNATURELEVEL_TYPE
: CRYPT_SIGNATURELEVEL_NONE          0 ; inline ! Include only signature
: CRYPT_SIGNATURELEVEL_SIGNERCERT    1 ; inline ! Include signer cert
: CRYPT_SIGNATURELEVEL_ALL           2 ; inline ! Include all relevant info
: CRYPT_SIGNATURELEVEL_LAST          3 ; inline ! Last possible sig.level type

! The certificate export format type, which defines the format in which a
!  certificate object is exported
! CRYPT_CERTFORMAT_TYPE
: CRYPT_CERTFORMAT_NONE                0 ; inline ! No certificate format
: CRYPT_CERTFORMAT_CERTIFICATE         1 ; inline ! DER-encoded certificate
: CRYPT_CERTFORMAT_CERTCHAIN           2 ; inline ! PKCS #7 certificate chain
: CRYPT_CERTFORMAT_TEXT_CERTIFICATE    3 ; inline ! base-64 wrapped cert
: CRYPT_CERTFORMAT_TEXT_CERTCHAIN      4 ; inline ! base-64 wrapped cert chain
: CRYPT_CERTFORMAT_XML_CERTIFICATE     5 ; inline ! XML wrapped cert
: CRYPT_CERTFORMAT_XML_CERTCHAIN       6 ; inline ! XML wrapped cert chain
: CRYPT_CERTFORMAT_LAST                7 ; inline ! Last possible cert.format type

TYPEDEF: int CRYPT_CERTFORMAT_TYPE

! CMP request types
! CRYPT_REQUESTTYPE_TYPE
: CRYPT_REQUESTTYPE_NONE              0 ; inline ! No request type
: CRYPT_REQUESTTYPE_INITIALISATION    1 ; inline ! Initialisation request
: CRYPT_REQUESTTYPE_INITIALIZATION    1 ; inline
: CRYPT_REQUESTTYPE_CERTIFICATE       2 ; inline ! Certification request
: CRYPT_REQUESTTYPE_KEYUPDATE         3 ; inline ! Key update request
: CRYPT_REQUESTTYPE_REVOCATION        4 ; inline ! Cert revocation request
: CRYPT_REQUESTTYPE_PKIBOOT           5 ; inline ! PKIBoot request
: CRYPT_REQUESTTYPE_LAST              6 ; inline ! Last possible request type

! Key ID types
! CRYPT_KEYID_TYPE
: CRYPT_KEYID_NONE      0 ; inline ! No key ID type
: CRYPT_KEYID_NAME      1 ; inline ! Key owner name
: CRYPT_KEYID_URI       2 ; inline ! Key owner URI
: CRYPT_KEYID_EMAIL     2 ; inline ! Synonym: owner email addr.
: CRYPT_KEYID_LAST      3 ; inline ! Last possible key ID type

TYPEDEF: int CRYPT_KEYID_TYPE

! The encryption object types
! CRYPT_OBJECT_TYPE
: CRYPT_OBJECT_NONE                0 ; inline ! No object type
: CRYPT_OBJECT_ENCRYPTED_KEY       1 ; inline ! Conventionally encrypted key
: CRYPT_OBJECT_PKCENCRYPTED_KEY    2 ; inline ! PKC-encrypted key
: CRYPT_OBJECT_KEYAGREEMENT        3 ; inline ! Key agreement information
: CRYPT_OBJECT_SIGNATURE           4 ; inline ! Signature
: CRYPT_OBJECT_LAST                5 ; inline ! Last possible object type

! Object/attribute error type information
! CRYPT_ERRTYPE_TYPE
: CRYPT_ERRTYPE_NONE                0 ; inline ! No error information
: CRYPT_ERRTYPE_ATTR_SIZE           1 ; inline ! Attribute data too small or large
: CRYPT_ERRTYPE_ATTR_VALUE          2 ; inline ! Attribute value is invalid
: CRYPT_ERRTYPE_ATTR_ABSENT         3 ; inline ! Required attribute missing
: CRYPT_ERRTYPE_ATTR_PRESENT        4 ; inline ! Non-allowed attribute present
: CRYPT_ERRTYPE_CONSTRAINT          5 ; inline ! Cert: Constraint violation in object
: CRYPT_ERRTYPE_ISSUERCONSTRAINT    6 ; inline ! Cert: Constraint viol.in issuing cert
: CRYPT_ERRTYPE_LAST                7 ; inline ! Last possible error info type

! Cert store management action type
! CRYPT_CERTACTION_TYPE
: CRYPT_CERTACTION_NONE                      0  ; inline ! No cert management action
: CRYPT_CERTACTION_CREATE                    1  ; inline ! Create cert store
: CRYPT_CERTACTION_CONNECT                   2  ; inline ! Connect to cert store
: CRYPT_CERTACTION_DISCONNECT                3  ; inline ! Disconnect from cert store
: CRYPT_CERTACTION_ERROR                     4  ; inline ! Error information
: CRYPT_CERTACTION_ADDUSER                   5  ; inline ! Add PKI user
: CRYPT_CERTACTION_DELETEUSER                6  ; inline ! Delete PKI user
: CRYPT_CERTACTION_REQUEST_CERT              7  ; inline ! Cert request
: CRYPT_CERTACTION_REQUEST_RENEWAL           8  ; inline ! Cert renewal request
: CRYPT_CERTACTION_REQUEST_REVOCATION        9  ; inline ! Cert revocation request
: CRYPT_CERTACTION_CERT_CREATION             10 ; inline ! Cert creation
: CRYPT_CERTACTION_CERT_CREATION_COMPLETE    11 ; inline ! Confirmation of cert creation
: CRYPT_CERTACTION_CERT_CREATION_DROP        12 ; inline ! Cancellation of cert creation
: CRYPT_CERTACTION_CERT_CREATION_REVERSE     13 ; inline ! Cancel of creation w.revocation
: CRYPT_CERTACTION_RESTART_CLEANUP           14 ; inline ! Delete reqs after restart
: CRYPT_CERTACTION_RESTART_REVOKE_CERT       15 ; inline ! Complete revocation after restart
: CRYPT_CERTACTION_ISSUE_CERT                16 ; inline ! Cert issue
: CRYPT_CERTACTION_ISSUE_CRL                 17 ; inline ! CRL issue
: CRYPT_CERTACTION_REVOKE_CERT               18 ; inline ! Cert revocation
: CRYPT_CERTACTION_EXPIRE_CERT               19 ; inline ! Cert expiry
: CRYPT_CERTACTION_CLEANUP                   20 ; inline ! Clean up on restart
: CRYPT_CERTACTION_LAST                      21 ; inline ! Last possible cert store log action

! ===============================================
! General Constants
! ===============================================

! The maximum user key size - 2048 bits
: CRYPT_MAX_KEYSIZE          256 ; inline

! The maximum IV size - 256 bits
: CRYPT_MAX_IVSIZE           32 ; inline

! The maximum public-key component size - 4096 bits, and maximum component
! size for ECCs - 256 bits
: CRYPT_MAX_PKCSIZE          512 ; inline
: CRYPT_MAX_PKCSIZE_ECC      32 ; inline

! The maximum hash size - 256 bits
: CRYPT_MAX_HASHSIZE         32 ; inline

! The maximum size of a text string (e.g.key owner name)
: CRYPT_MAX_TEXTSIZE         64 ; inline

! A magic value indicating that the default setting for this parameter
! should be used
: CRYPT_USE_DEFAULT         -100 ; inline

! A magic value for unused parameters
: CRYPT_UNUSED              -101 ; inline

! Cursor positioning codes for certificate/CRL extensions
: CRYPT_CURSOR_FIRST        -200 ; inline
: CRYPT_CURSOR_PREVIOUS     -201 ; inline
: CRYPT_CURSOR_NEXT         -202 ; inline
: CRYPT_CURSOR_LAST         -203 ; inline

! The type of information polling to perform to get random seed 
! information.  These values have to be negative because they're used
! as magic length values for cryptAddRandom()
: CRYPT_RANDOM_FASTPOLL     -300 ; inline
: CRYPT_RANDOM_SLOWPOLL     -301 ; inline

! Whether the PKC key is a public or private key
: CRYPT_KEYTYPE_PRIVATE      0 ; inline
: CRYPT_KEYTYPE_PUBLIC       1 ; inline

! Keyset open options
! CRYPT_KEYOPT_TYPE
! (No options, Open keyset in read-only mode, Create a new keyset)
! Internal keyset options
! (As _NONE but open for exclusive access, _CRYPT_DEFINED
! Last possible key option type, _CRYPT_DEFINED Last external keyset option)
CONSTANT: CRYPT_KEYOPT_NONE 0
CONSTANT: CRYPT_KEYOPT_READONLY 1
CONSTANT: CRYPT_KEYOPT_CREATE 2
CONSTANT: CRYPT_IKEYOPT_EXCLUSIVEACCESS 3
CONSTANT: CRYPT_KEYOPT_LAST 4

: CRYPT_KEYOPT_LAST_EXTERNAL   3 ; inline ! = CRYPT_KEYOPT_CREATE + 1

TYPEDEF: int CRYPT_KEYOPT_TYPE

! The various cryptlib objects - these are just integer handles
TYPEDEF: int CRYPT_CERTIFICATE
TYPEDEF: int CRYPT_CONTEXT
TYPEDEF: int CRYPT_DEVICE
TYPEDEF: int CRYPT_ENVELOPE
TYPEDEF: int CRYPT_KEYSET
TYPEDEF: int CRYPT_SESSION
TYPEDEF: int CRYPT_USER

! Sometimes we don't know the exact type of a cryptlib object, so we use a
! generic handle type to identify it
TYPEDEF: int CRYPT_HANDLE

! ===============================================
! Status Codes
! ===============================================

! No error in function call
: CRYPT_OK                   0 ; inline ! No error

! Error in parameters passed to function
: CRYPT_ERROR_PARAM1        -1 ; inline ! Bad argument, parameter 1
: CRYPT_ERROR_PARAM2        -2 ; inline ! Bad argument, parameter 2
: CRYPT_ERROR_PARAM3        -3 ; inline ! Bad argument, parameter 3
: CRYPT_ERROR_PARAM4        -4 ; inline ! Bad argument, parameter 4
: CRYPT_ERROR_PARAM5        -5 ; inline ! Bad argument, parameter 5
: CRYPT_ERROR_PARAM6        -6 ; inline ! Bad argument, parameter 6
: CRYPT_ERROR_PARAM7        -7 ; inline ! Bad argument, parameter 7

! Errors due to insufficient resources
: CRYPT_ERROR_MEMORY        -10 ; inline ! Out of memory
: CRYPT_ERROR_NOTINITED     -11 ; inline ! Data has not been initialised
: CRYPT_ERROR_INITED        -12 ; inline ! Data has already been init'd
: CRYPT_ERROR_NOSECURE      -13 ; inline ! Opn.not avail.at requested sec.level
: CRYPT_ERROR_RANDOM        -14 ; inline ! No reliable random data available
: CRYPT_ERROR_FAILED        -15 ; inline ! Operation failed
: CRYPT_ERROR_INTERNAL      -16 ; inline ! Internal consistency check failed

! Security violations
: CRYPT_ERROR_NOTAVAIL      -20 ; inline ! This type of opn.not available
: CRYPT_ERROR_PERMISSION    -21 ; inline ! No permiss.to perform this operation
: CRYPT_ERROR_WRONGKEY      -22 ; inline ! Incorrect key used to decrypt data
: CRYPT_ERROR_INCOMPLETE    -23 ; inline ! Operation incomplete/still in progress
: CRYPT_ERROR_COMPLETE      -24 ; inline ! Operation complete/can't continue
: CRYPT_ERROR_TIMEOUT       -25 ; inline ! Operation timed out before completion
: CRYPT_ERROR_INVALID       -26 ; inline ! Invalid/inconsistent information
: CRYPT_ERROR_SIGNALLED     -27 ; inline ! Resource destroyed by extnl.event

! High-level function errors
: CRYPT_ERROR_OVERFLOW      -30 ; inline ! Resources/space exhausted
: CRYPT_ERROR_UNDERFLOW     -31 ; inline ! Not enough data available
: CRYPT_ERROR_BADDATA       -32 ; inline ! Bad/unrecognised data format
: CRYPT_ERROR_SIGNATURE     -33 ; inline ! Signature/integrity check failed

! Data access function errors
: CRYPT_ERROR_OPEN          -40 ; inline ! Cannot open object
: CRYPT_ERROR_READ          -41 ; inline ! Cannot read item from object
: CRYPT_ERROR_WRITE         -42 ; inline ! Cannot write item to object
: CRYPT_ERROR_NOTFOUND      -43 ; inline ! Requested item not found in object
: CRYPT_ERROR_DUPLICATE     -44 ; inline ! Item already present in object

! Data enveloping errors
: CRYPT_ENVELOPE_RESOURCE    -50 ; inline ! Need resource to proceed

! Error messages sequence
: error-messages ( -- seq ) {
    { -1   "Bad argument, parameter 1" }
    { -2   "Bad argument, parameter 2" }
    { -3   "Bad argument, parameter 3" }
    { -4   "Bad argument, parameter 4" }
    { -5   "Bad argument, parameter 5" }
    { -6   "Bad argument, parameter 6" }
    { -7   "Bad argument, parameter 7" }
    { -10  "Out of memory" }
    { -11  "Data has not been initialised" }
    { -12  "Data has already been init'd" }
    { -13  "Opn.not avail.at requested sec.level" }
    { -14  "No reliable random data available" }
    { -15  "Operation failed" }
    { -16  "Internal consistency check failed" }
    { -20  "This type of opn.not available" }
    { -21  "No permiss.to perform this operation" }
    { -22  "Incorrect key used to decrypt data" }
    { -23  "Operation incomplete/still in progress" }
    { -24  "Operation complete/can't continue" }
    { -25  "Operation timed out before completion" }
    { -26  "Invalid/inconsistent information" }
    { -27  "Resource destroyed by extnl.event" }
    { -30  "Resources/space exhausted" }
    { -31  "Not enough data available" }
    { -32  "Bad/unrecognised data format" }
    { -33  "Signature/integrity check failed" }
    { -40  "Cannot open object" }
    { -41  "Cannot read item from object" }
    { -42  "Cannot write item to object" }
    { -43  "Requested item not found in object" }
    { -44  "Item already present in object" }
    { -50  "Need resource to proceed" }
} ;

LIBRARY: libcl

! ===============================================
! cryptlib.h
! ===============================================

! Initialise and shut down cryptlib
FUNCTION: C_RET cryptInit (  ) ;
FUNCTION: C_RET cryptEnd (  ) ;

! Create and destroy an encryption context

FUNCTION: C_RET cryptCreateContext ( CRYPT_CONTEXT* cryptContext, CRYPT_USER cryptUser, CRYPT_ALGO_TYPE cryptAlgo ) ;
FUNCTION: C_RET cryptDestroyContext ( CRYPT_CONTEXT cryptContext ) ;

! Create/destroy an envelope
FUNCTION: C_RET cryptCreateEnvelope ( CRYPT_ENVELOPE* envelope, CRYPT_USER cryptUser, CRYPT_FORMAT_TYPE formatType ) ;
FUNCTION: C_RET cryptDestroyEnvelope ( CRYPT_ENVELOPE envelope ) ;

! Add/remove data to/from and envelope or session
FUNCTION: C_RET cryptPushData ( CRYPT_HANDLE envelope, void* buffer, int length, int* bytesCopied ) ;
FUNCTION: C_RET cryptFlushData ( CRYPT_HANDLE envelope ) ;
FUNCTION: C_RET cryptPopData ( CRYPT_HANDLE envelope, void* buffer, int length, int* bytesCopied ) ;

! Get/set/delete attribute functions
FUNCTION: C_RET cryptSetAttribute ( CRYPT_HANDLE cryptHandle, CRYPT_ATTRIBUTE_TYPE attributeType, int value ) ;
FUNCTION: C_RET cryptSetAttributeString ( CRYPT_HANDLE cryptHandle, CRYPT_ATTRIBUTE_TYPE attributeType, void* value, int valueLength ) ;

! Generate a key into a context
FUNCTION: C_RET cryptGenerateKey ( CRYPT_CONTEXT cryptContext ) ;

! Open and close a keyset
FUNCTION: C_RET cryptKeysetOpen ( CRYPT_KEYSET* keyset, CRYPT_USER cryptUser, CRYPT_KEYSET_TYPE keysetType,
                                  char* name, CRYPT_KEYOPT_TYPE options ) ;
FUNCTION: C_RET cryptKeysetClose ( CRYPT_KEYSET keyset ) ;

! Add/delete a key to/from a keyset or device
FUNCTION: C_RET cryptAddPublicKey ( CRYPT_KEYSET keyset, CRYPT_CERTIFICATE certificate ) ;
FUNCTION: C_RET cryptAddPrivateKey ( CRYPT_KEYSET keyset, CRYPT_HANDLE cryptKey, char* password ) ;
FUNCTION: C_RET cryptDeleteKey ( CRYPT_KEYSET keyset, CRYPT_KEYID_TYPE keyIDtype, char* keyID ) ;

! Create/destroy a certificate
FUNCTION: C_RET cryptCreateCert ( CRYPT_CERTIFICATE* certificate, CRYPT_USER cryptUser, CRYPT_CERTTYPE_TYPE certType ) ;
FUNCTION: C_RET cryptDestroyCert ( CRYPT_CERTIFICATE certificate ) ;

! Sign/sig.check a certificate/certification request
FUNCTION: C_RET cryptSignCert ( CRYPT_CERTIFICATE certificate, CRYPT_CONTEXT signContext ) ;
FUNCTION: C_RET cryptCheckCert ( CRYPT_CERTIFICATE certificate, CRYPT_HANDLE sigCheckKey ) ;

! Import/export a certificate/certification request
FUNCTION: C_RET cryptImportCert ( void* certObject, int certObjectLength, CRYPT_USER cryptUser, CRYPT_CERTIFICATE* certificate ) ;
FUNCTION: C_RET cryptExportCert ( void* certObject, int certObjectMaxLength, int* certObjectLength,
                                  CRYPT_CERTFORMAT_TYPE certFormatType, CRYPT_CERTIFICATE certificate ) ;

! Get a key from a keyset or device
FUNCTION: C_RET cryptGetPublicKey ( CRYPT_KEYSET keyset, CRYPT_CONTEXT* cryptContext, CRYPT_KEYID_TYPE keyIDtype, char* keyID ) ;
FUNCTION: C_RET cryptGetPrivateKey ( CRYPT_KEYSET keyset, CRYPT_CONTEXT* cryptContext, CRYPT_KEYID_TYPE keyIDtype, char* keyID, char* password ) ;
FUNCTION: C_RET cryptGetKey ( CRYPT_KEYSET keyset, CRYPT_CONTEXT* cryptContext, CRYPT_KEYID_TYPE keyIDtype, char* keyID, char* password ) ;

! Create/destroy a session
FUNCTION: C_RET cryptCreateSession ( CRYPT_SESSION* session, CRYPT_USER cryptUser, CRYPT_SESSION_TYPE formatType ) ;
FUNCTION: C_RET cryptDestroySession ( CRYPT_SESSION session ) ;
