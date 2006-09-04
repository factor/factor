IN: scratchpad
USING: alien compiler kernel namespaces parser sequences words ;

{ 
    "errors"
    "winsock"
    "io-internals"
    "stream"
    "server"
    "io-last"
} [ "/library/io/windows/" swap ".factor" append3 run-resource ] each
