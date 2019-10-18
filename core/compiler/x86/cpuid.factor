! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: command-line assembler-x86 compiler generator
sequences modules kernel math io ;
IN: cpuid

: (cpuid) ( a -- d c b a ) drop 0 0 0 0 ;

\ (cpuid) [
    "a" operand %untag-fixnum
    CPUID
    "d" operand dup %allot-bignum-signed-1
    "c" operand dup %allot-bignum-signed-1
    "b" operand dup %allot-bignum-signed-1
    "a" operand dup %allot-bignum-signed-1
] H{
    { +input+ { { 0 "a" } } }
    { +scratch+ { { 3 "b" } { 1 "c" } { 2 "d" } } }
    { +output+ { "d" "c" "b" "a" } }
} define-intrinsic

: cpuid ( n -- d c b a ) (cpuid) ;

: sse2? ( -- ? )
    1 cpuid 3drop 26 2^ bitand 0 > ;

"-no-sse2" cli-args member? [
    \ cpuid compile

    "Checking if your CPU supports SSE2..." write flush
    sse2? [
        " yes" print
        "core/compiler/x86/sse2" require
    ] [
        " no" print
    ] if
] unless

PROVIDE: core/compiler/x86/cpuid ;
