REQUIRES: libs/math libs/memoize libs/shuffle libs/sequences ;

PROVIDE: libs/crypto
{ +files+ {

    "common.factor"
    "timing.factor"
    "barrett.factor"
    "montgomery.factor"
    "random.factor"
    "miller-rabin.factor"

! Rngs
    "blum-blum-shub.factor"

! Hash
    "crc32.factor"
    "md5.factor"
    "sha1.factor"
    "sha2.factor"

    "hmac.factor"


! Block ciphers
    "rc4.factor"

! Public key
    "rsa.factor"

! Other
    "xor.factor"

} }
{ +tests+ {
    "test/common.factor"
    "test/md5.factor"
    "test/sha1.factor"
    "test/sha2.factor"
    "test/hmac.factor"
    "test/miller-rabin.factor"
    "test/crc32.factor"
    "test/rsa.factor"
    "test/barrett.factor"
    "test/montgomery.factor"
    "test/blum-blum-shub.factor"
    "test/xor.factor"
} } ;
