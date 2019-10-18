USING: kernel math sequences namespaces ;

IN: crypto-internals
: crc32-polynomial HEX: edb88320 ; inline

: crc32-init ( -- table )
    256 [
        8 [
            dup 1 bitand 0 >
            [ -1 shift crc32-polynomial bitxor ] [ -1 shift ] if
        ] times
    ] map ;

SYMBOL: crc32-table crc32-init global [ crc32-table set ] bind

: calc-crc32 ( crc ch -- crc )
    over bitxor HEX: ff bitand crc32-table get nth swap -8 shift bitxor ;

IN: crypto
: >crc32 ( seq -- n ) HEX: ffffffff [ swap [ calc-crc32 ] each ] keep bitxor ;

