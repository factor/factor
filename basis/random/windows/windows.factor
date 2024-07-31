USING: accessors alien.data byte-arrays continuations
destructors init kernel literals locals namespaces random
sequences windows.advapi32 windows.errors windows.handles
windows.types ;
IN: random.windows

TUPLE: windows-crypto-context < win32-handle provider type ;

M: windows-crypto-context dispose*
    [ handle>> 0 CryptReleaseContext win32-error=0/f ]
    [ f >>handle drop ] bi ;

CONSTANT: factor-crypto-container "FactorCryptoContainer"

:: (acquire-crypto-context) ( provider type flags -- handle )
    { HCRYPTPROV } [
        factor-crypto-container
        provider
        type
        flags
        CryptAcquireContextW win32-error=0/f
    ] with-out-parameters ;

: acquire-crypto-context ( provider type -- handle )
    CRYPT_MACHINE_KEYSET (acquire-crypto-context) ;

: create-crypto-context ( provider type -- handle )
    flags{ CRYPT_MACHINE_KEYSET CRYPT_NEWKEYSET } (acquire-crypto-context) ;

ERROR: acquire-crypto-context-failed provider type error ;

: attempt-crypto-context ( provider type -- handle )
    [ acquire-crypto-context ]
    [
        drop [ create-crypto-context ]
        [ acquire-crypto-context-failed ] recover
    ] recover ;

: initialize-crypto-context ( crypto-context -- crypto-context )
    dup [ provider>> ] [ type>> ] bi attempt-crypto-context >>handle ;

: <windows-crypto-context> ( provider type -- windows-crypto-type )
    windows-crypto-context new-disposable
        swap >>type
        swap >>provider
        initialize-crypto-context ; inline

M: windows-crypto-context random-bytes*
    handle>> swap dup <byte-array>
    [ CryptGenRandom win32-error=0/f ] keep ;

INSTANCE: windows-crypto-context base-random

! Some Windows installations still don't work, so just set
! system and secure rngs to f
: try-crypto-providers ( seq -- windows-crypto-context/f )
    [
        [ first2 <windows-crypto-context> ] attempt-all
    ] [ 2drop f ] recover ;

STARTUP-HOOK: [
    {
        ${ MS_ENHANCED_PROV PROV_RSA_FULL }
        ${ MS_DEF_PROV PROV_RSA_FULL }
    } try-crypto-providers system-random-generator set-global

    {
        ${ MS_STRONG_PROV PROV_RSA_FULL }
        ${ MS_ENH_RSA_AES_PROV PROV_RSA_AES }
    } try-crypto-providers secure-random-generator set-global
]
