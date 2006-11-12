REQUIRES: contrib/math ;

PROVIDE: contrib/crypto
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

! Block ciphers
    "rc4.factor"

! Public key
    "rsa.factor"

} }
{ +tests+ {
    "test/common.factor"
    "test/md5.factor"
    "test/sha1.factor"
    "test/sha2.factor"
    "test/miller-rabin.factor"
    "test/crc32.factor"
    "test/rsa.factor"
    "test/barrett.factor"
    "test/montgomery.factor"
    "test/blum-blum-shub.factor"
} } ;
