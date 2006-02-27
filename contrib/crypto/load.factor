IN: scratchpad
USING: kernel parser sequences words compiler ;

"/contrib/math/load.factor" run-resource

{
    "common"
    "base64"
    "barrett"
    "montgomery"
    "random"
    "miller-rabin"
    "blum-blum-shub"
    "md5"
    "sha1"
    "rsa"
    "rc4"
} [ "/contrib/crypto/" swap ".factor" append3 run-resource ] each
