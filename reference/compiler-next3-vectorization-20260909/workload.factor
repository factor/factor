! Definitions only. Load after kernels.factor, before freezing the word scope.
USING: benchmark.scalar-mixing kernel locals math namespaces sequences ;
IN: benchmark.scalar-mixing

SYMBOL: expected-mixing-checksum

:: mixing-oracle-checksum ( count -- sum )
    count <iota> [| i |
        i 0x13579 17 scalar-oracle
        i 1 + 0x13579 17 scalar-oracle +
    ] map-sum ;

: prepare-mixing-oracle ( -- )
    200000 mixing-oracle-checksum expected-mixing-checksum set-global ;

:: mixing-work ( -- )
    0 :> checksum!
    200000 [| i |
        i i 1 + 0x13579 17 invoke-mixing + checksum + checksum!
    ] each-integer
    checksum expected-mixing-checksum get assert= ;
