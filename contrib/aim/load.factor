IN: scratchpad
USING: kernel parser sequences words compiler ;
"contrib/crypto/load.factor" run-file

{ "net-bytes" "aim" }
[ "contrib/aim/" swap ".factor" append3 run-file ]

{ "aim-internals" "aim" }
[ words [ try-compile ] each ] each
