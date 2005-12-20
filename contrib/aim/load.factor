IN: network-util
USING: parser sequences words compiler ;

[
    "contrib/crypto/load.factor"
    "contrib/aim/net-bytes.factor"
    "contrib/aim/aim.factor"
] [ run-file ] each

"aim-internals" words [ try-compile ] each
"aim" words [ try-compile ] each
