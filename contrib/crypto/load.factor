IN: crypto
USING: parser sequences words compiler ;
[
    "contrib/math/load.factor"
    "contrib/crypto/common.factor"
    "contrib/crypto/md5.factor"
    "contrib/crypto/sha1.factor"
] [ run-file ] each

"crypto" words [ try-compile ] each

