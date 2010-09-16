USING: accessors alien.c-types alien.data byte-arrays
combinators.short-circuit continuations destructors init kernel
locals namespaces random windows.advapi32 windows.errors
windows.kernel32 windows.types math.bitwise sequences fry
literals io.backend.windows ;
IN: random.windows

TUPLE: windows-crypto-context < win32-handle provider type ;

M: windows-crypto-context dispose* ( tuple -- )
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
    [ drop [ create-crypto-context ] [ acquire-crypto-context-failed ] recover ] recover ;

: initialize-crypto-context ( crypto-context -- crypto-context )
    dup [ provider>> ] [ type>> ] bi attempt-crypto-context >>handle ;

: <windows-crypto-context> ( provider type -- windows-crypto-type )
    windows-crypto-context new-disposable
        swap >>type
        swap >>provider
        initialize-crypto-context ; inline

M: windows-crypto-context random-bytes* ( n windows-crypto-context -- bytes )    
    handle>> swap [ ] [ <byte-array> ] bi
    [ CryptGenRandom win32-error=0/f ] keep ;

: try-crypto-providers ( seq -- windows-crypto-context )
    [ first2 <windows-crypto-context> ] attempt-all ;

[
    {
        ${ MS_ENHANCED_PROV PROV_RSA_FULL }
        ${ MS_DEF_PROV PROV_RSA_FULL }
    } try-crypto-providers system-random-generator set-global

    {
        ${ MS_STRONG_PROV PROV_RSA_FULL }
        ${ MS_ENH_RSA_AES_PROV PROV_RSA_AES }
    } try-crypto-providers secure-random-generator set-global
] "random.windows" add-startup-hook
