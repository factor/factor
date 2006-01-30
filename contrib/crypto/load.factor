IN: scratchpad
USING: kernel parser sequences words compiler ;

"/contrib/math/load.factor" run-resource

{
    "common"
    "random"
    "miller-rabin"
    "md5"
    "sha1"
    "rsa"
} [ "/contrib/crypto/" swap ".factor" append3 run-resource ] each
