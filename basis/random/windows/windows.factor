USING: accessors alien.c-types alien.data byte-arrays
combinators.short-circuit continuations destructors init kernel
locals namespaces random windows.advapi32 windows.errors
windows.kernel32 windows.types math.bitwise sequences fry
literals ;
IN: random.windows

TUPLE: windows-crypto-context < disposable provider type handle ;

M: windows-crypto-context dispose* ( tuple -- )
    [ handle>> 0 CryptReleaseContext win32-error=0/f ]
    [ f >>handle drop ] bi ;

CONSTANT: factor-crypto-container "FactorCryptoContainer"

:: (acquire-crypto-context) ( provider type flags -- ret handle )
    { HCRYPTPROV } [
        factor-crypto-container
        provider
        type
        flags
        CryptAcquireContextW
    ] with-out-parameters ;

: acquire-crypto-context ( provider type -- handle )
    CRYPT_MACHINE_KEYSET
    (acquire-crypto-context)
    swap 0 = [
        GetLastError NTE_BAD_KEYSET =
        [ drop f ] [ win32-error-string throw ] if
    ] when ;

: create-crypto-context ( provider type -- handle )
    flags{ CRYPT_MACHINE_KEYSET CRYPT_NEWKEYSET }
    (acquire-crypto-context) win32-error=0/f *void* ;

ERROR: acquire-crypto-context-failed provider type ;

: attempt-crypto-context ( provider type -- handle )
    {
        [ acquire-crypto-context ] 
        [ create-crypto-context ] 
        [ acquire-crypto-context-failed ]
    } 2|| ;

: initialize-crypto-context ( crypto-context -- crypto-context )
    dup [ provider>> ] [ type>> ] bi attempt-crypto-context >>handle ;

: <windows-crypto-context> ( provider type -- windows-crypto-type )
    windows-crypto-context new
        swap >>type
        swap >>provider
        initialize-crypto-context ; inline

M: windows-crypto-context random-bytes* ( n windows-crypto-context -- bytes )
    dup already-disposed? [ initialize-crypto-context f >>disposed ] when
    [
        |dispose
        handle>> swap dup <byte-array>
        [ CryptGenRandom win32-error=0/f ] keep
    ] with-destructors ;
    
: with-windows-rng ( windows-rng quot -- )
    [ windows-crypto-context ] dip with-disposal
    ; inline

ERROR: no-windows-crypto-provider error ;
        
: try-crypto-providers ( seq -- windows-crypto-context )
    [ first2 <windows-crypto-context> ] attempt-all
    dup windows-crypto-context? [ no-windows-crypto-provider ] unless ;

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
