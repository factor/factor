USING: accessors alien alien.data compiler.cfg.instructions compiler.test cpu.architecture
io io.encodings.binary io.files kernel kernel.private locals math math.vectors
math.vectors.conversion math.vectors.simd prettyprint sequences system
 tools.time words ;
IN: arm64-gap-simd.bench
: signed-loop ( n -- result )
    longlong-2{ -9223372036854775808 123456789012345 }
    swap [ longlong-2{ 9223372036854775807 987654321098765 } vmin
           longlong-2{ 1 -1 } v+ ] times ;
: unsigned-loop ( n -- result )
    ulonglong-2{ 9223372036854775808 123456789012345 }
    swap [ ulonglong-2{ 9223372036854775807 987654321098765 } vmax
           ulonglong-2{ 1 -1 } v+ ] times ;
: conversion-loop ( n -- result )
    float-4{ 1234.5 -1024.25 2147483648 4294967808 } int-4{ 0 0 0 0 }
    rot [ swap float-4{ 0.25 -0.25 256 -512 } v+
        dup float-4 int-4 vconvert rot v+ ] times nip ;
:: measure ( quot -- )
    quot call( -- result ) .
    7 [ [ quot call( -- result ) drop ] benchmark . flush ] times ;
"signed min nanoseconds / 1000000 iterations" print
[ 1000000 signed-loop ] measure
"unsigned max nanoseconds / 1000000 iterations" print
[ 1000000 unsigned-loop ] measure
"float to int nanoseconds / 1000000 iterations" print
[ 1000000 conversion-loop ] measure
"float conversion reps: " write %float>integer-vector-reps .
"signed min CFG: " write
[ { longlong-2 longlong-2 } declare vmin ] [ ##min-vector? ] contains-insn? .
"unsigned max CFG: " write
[ { ulonglong-2 ulonglong-2 } declare vmax ] [ ##max-vector? ] contains-insn? .
"float conversion CFG: " write
[ { float-4 } declare float-4 int-4 vconvert ] [ ##float>integer-vector? ] contains-insn? .
: dump-code ( word path -- )
    [ word-code over - [ <alien> ] dip memory>byte-array ] dip binary set-file-contents ;
\ signed-loop "reference/arm64-gap-simd-20260908/signed-loop.bin" dump-code
\ unsigned-loop "reference/arm64-gap-simd-20260908/unsigned-loop.bin" dump-code
\ conversion-loop "reference/arm64-gap-simd-20260908/conversion-loop.bin" dump-code
0 exit
