USING: accessors alien.c-types byte-arrays continuations
kernel windows.advapi32 init namespaces random destructors
locals windows.errors ;
IN: random.windows

TUPLE: windows-rng provider type ;
C: <windows-rng> windows-rng

TUPLE: windows-crypto-context handle ;
C: <windows-crypto-context> windows-crypto-context

M: windows-crypto-context dispose ( tuple -- )
    handle>> 0 CryptReleaseContext win32-error=0/f ;

: factor-crypto-container ( -- string ) "FactorCryptoContainer" ; inline

:: (acquire-crypto-context) ( provider type flags -- handle )
    [let | handle [ "HCRYPTPROV" <c-object> ] |
        handle
        factor-crypto-container
        provider
        type
        flags
        CryptAcquireContextW win32-error=0/f
        handle *void* ] ;

: acquire-crypto-context ( provider type -- handle )
    [ 0 (acquire-crypto-context) ]
    [ drop CRYPT_NEWKEYSET (acquire-crypto-context) ] recover ;


: windows-crypto-context ( provider type -- context )
    acquire-crypto-context <windows-crypto-context> ;

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

    MS_STRONG_PROV
    PROV_RSA_FULL <windows-rng> secure-random-generator set-global

    ! MS_ENH_RSA_AES_PROV
    ! PROV_RSA_AES <windows-rng> secure-random-generator set-global
] "random.windows" add-init-hook
