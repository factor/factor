IN: scratchpad
USING: kernel parser sequences words compiler ;

{
    "common"
    "base64"
    "barrett"
    "montgomery"
    "random"
    "miller-rabin"

! Rngs
    "blum-blum-shub"

! Hash
    "crc32"
    "md5"
    "sha1"

! Block ciphers
    "rc4"

! Public key
    "rsa"

} [ "/contrib/crypto/" swap ".factor" append3 run-resource ] each
