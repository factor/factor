! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Run with a compiler-loaded MIPS image. This checks generated Factor code
! and real libc calls; it does not replace full compiler and I/O acceptance.
USING: alien.accessors compiler.units continuations cpu.architecture
io kernel libc math memory words ;
IN: mips.compiler-runtime

: check-result ( actual expected -- )
    = [ "MIPS generated runtime mismatch" throw ] unless ;

: generated-add ( a b -- c ) + ;
: generated-multiply ( a b -- c ) * ;

: generated-native-memory ( -- byte )
    16 malloc dup 90 16 memset dup 0 alien-unsigned-1 swap free ;

{
    (malloc) (free) memset strlen malloc free
    generated-add generated-multiply generated-native-memory
} compile

\ generated-add word-optimized? t check-result
\ generated-multiply word-optimized? t check-result
\ generated-native-memory word-optimized? t check-result
7 8 generated-add 15 check-result
3.25 2.0 generated-multiply 6.5 check-result
generated-native-memory 90 check-result
"mips-native-ffi" strlen 15 check-result
gc
2 3 generated-add 5 check-result
[ 1 0 /i drop 0 ] [ drop 99 ] recover 99 check-result
"MIPS generated integer/FP/GC/FFI/recover passed" print flush
