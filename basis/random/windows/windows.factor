USING: accessors alien.c-types alien.data byte-arrays
combinators.short-circuit continuations destructors init kernel
locals namespaces random windows.advapi32 windows.errors
windows.kernel32 windows.types math.bitwise ;
IN: random.windows

TUPLE: windows-rng provider type ;
C: <windows-rng> windows-rng

TUPLE: windows-crypto-context handle ;
C: <windows-crypto-context> windows-crypto-context

M: windows-crypto-context dispose ( tuple -- )
    handle>> 0 CryptReleaseContext win32-error=0/f ;

CONSTANT: factor-crypto-container "FactorCryptoContainer"

:: (acquire-crypto-context) ( provider type flags -- handle ret )
    HCRYPTPROV <c-object> :> handle
    handle
    factor-crypto-container
    provider
    type
    flags
    CryptAcquireContextW handle swap ;

: acquire-crypto-context ( provider type -- handle )
    CRYPT_MACHINE_KEYSET
    (acquire-crypto-context)
    0 = [
        GetLastError NTE_BAD_KEYSET =
        [ drop f ] [ win32-error-string throw ] if
    ] [
        *void*
    ] if ;

: create-crypto-context ( provider type -- handle )
    { CRYPT_MACHINE_KEYSET CRYPT_NEWKEYSET } flags
    (acquire-crypto-context) win32-error=0/f *void* ;

ERROR: acquire-crypto-context-failed provider type ;

: attempt-crypto-context ( provider type -- handle )
    {
        [ acquire-crypto-context ] 
        [ create-crypto-context ] 
        [ acquire-crypto-context-failed ]
    } 2|| ;

: windows-crypto-context ( provider type -- context )
    attempt-crypto-context <windows-crypto-context> ;

M: windows-rng random-bytes* ( n tuple -- bytes )
    [
        [ provider>> ] [ type>> ] bi
        windows-crypto-context &dispose
        handle>> swap dup <byte-array>
        [ CryptGenRandom win32-error=0/f ] keep
    ] with-destructors ;

[
    MS_DEF_PROV
    PROV_RSA_FULL <windows-rng> system-random-generator set-global

    [ MS_STRONG_PROV PROV_RSA_FULL <windows-rng> ]
    [ drop MS_ENH_RSA_AES_PROV PROV_RSA_AES <windows-rng> ] recover
    secure-random-generator set-global
] "random.windows" add-startup-hook

[
    [
        ! system-random-generator get-global &dispose drop
        ! secure-random-generator get-global &dispose drop
    ] with-destructors
] "random.windows" add-shutdown-hook
