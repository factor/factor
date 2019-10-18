USING: kernel math sequences namespaces ;

IN: crypto-internals
: crc32-polynomial HEX: edb88320 ; inline

: crc32-init ( -- table )
    256 [
        8 [
            dup 1 bitand zero? >r -1 shift r> [ crc32-polynomial bitxor ] unless
        ] times
    ] map ;

SYMBOL: crc32-table
crc32-init crc32-table set-global

: calc-crc32 ( ch crc -- crc )
    dupd bitxor HEX: ff bitand crc32-table get nth swap -8 shift bitxor ;

IN: crypto
: >crc32 ( seq -- n )
   >r HEX: ffffffff dup r> [ calc-crc32 ] each bitxor ;

