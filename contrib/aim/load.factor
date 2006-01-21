IN: scratchpad
USING: kernel parser sequences words compiler ;

"/contrib/crypto/load.factor" run-resource

{ 
    "net-bytes"
    "aim"
} [ "/contrib/aim/" swap ".factor" append3 run-resource ] each
