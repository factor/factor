USING: alien errors io kernel libs-io mmap namespaces test ;

IN: temporary
SYMBOL: mmap "mmap-test.txt" \ mmap set

[ \ mmap get delete-file ] catch drop
\ mmap get <file-writer> [
    "Four" write
] with-stream

\ mmap get [
    >r CHAR: R r> mmap-address 3 set-alien-unsigned-1
] with-mmap

\ mmap get [
    mmap-address 3 alien-unsigned-1 CHAR: R = [
        "mmap test failed" throw
    ] unless
] with-mmap

[ \ mmap get delete-file ] catch drop
