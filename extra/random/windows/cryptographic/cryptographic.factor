USING: accessors alien.c-types byte-arrays continuations
kernel random windows windows.advapi32 ;
IN: random.windows.cryptographic

TUPLE: windows-crypto-context handle ;

C: <windows-crypto-context> windows-crypto-context

M: windows-crypto-context dispose ( tuple -- )
    handle>> 0 CryptReleaseContext win32-error=0/f ;


TUPLE: windows-cryptographic-rng context ;

C: <windows-cryptographic-rng> windows-cryptographic-rng

M: windows-cryptographic-rng dispose ( tuple -- )
    context>> dispose ;

M: windows-cryptographic-rng random-bytes* ( tuple n -- bytes )
    >r context>> r> dup <byte-array>
    [ CryptGenRandom win32-error=0/f ] keep ;

: acquire-aes-context ( -- bytes )
    "HCRYPTPROV" <c-object>
    dup f f PROV_RSA_AES CRYPT_NEWKEYSET
    CryptAcquireContextW win32-error=0/f *void*
    <windows-crypto-context> ;

