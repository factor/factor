! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays assocs combinators
compiler.codegen.labels cpu.architecture cpu.x86.assembler
cpu.x86.assembler.operands init kernel math math.order
math.parser memoize namespaces sequences
specialized-arrays system math.bitwise combinators.smart ;
SPECIALIZED-ARRAY: uint
IN: cpu.x86.features

<PRIVATE

: return-reg ( -- reg ) int-regs return-regs at first ;

: (sse-version) ( -- n )
    int { } cdecl [
        "sse-42" define-label
        "sse-41" define-label
        "ssse-3" define-label
        "sse-3" define-label
        "sse-2" define-label
        "sse-1" define-label
        "end" define-label

        return-reg 1 MOV

        CPUID

        ECX 20 BT
        "sse-42" get JB

        ECX 19 BT
        "sse-41" get JB

        ECX  9 BT
        "ssse-3" get JB

        ECX  0 BT
        "sse-3" get JB

        EDX 26 BT
        "sse-2" get JB

        EDX 25 BT
        "sse-1" get JB

        return-reg 0 MOV
        "end" get JMP

        "sse-42" resolve-label
        return-reg 42 MOV
        "end" get JMP

        "sse-41" resolve-label
        return-reg 41 MOV
        "end" get JMP

        "ssse-3" resolve-label
        return-reg 33 MOV
        "end" get JMP

        "sse-3" resolve-label
        return-reg 30 MOV
        "end" get JMP

        "sse-2" resolve-label
        return-reg 20 MOV
        "end" get JMP

        "sse-1" resolve-label
        return-reg 10 MOV

        "end" resolve-label
    ] alien-assembly ;

PRIVATE>

MEMO: sse-version ( -- n )
    (sse-version) "sse-version" get string>number [ min ] when* ;

: sse? ( -- ? ) sse-version 10 >= ;
: sse2? ( -- ? ) sse-version 20 >= ;
: sse3? ( -- ? ) sse-version 30 >= ;
: ssse3? ( -- ? ) sse-version 33 >= ;
: sse4.1? ( -- ? ) sse-version 41 >= ;
: sse4.2? ( -- ? ) sse-version 42 >= ;

HOOK: (cpuid) cpu ( n regs -- )

: cpuid ( n -- 4array )
   4 <uint-array> [ (cpuid) ] keep >array ;

: cpu-stepping ( -- n ) 1 cpuid first 4 bits ;
: cpu-model ( -- n ) 1 cpuid first -4 shift 4 bits ;
: cpu-family ( -- n ) 1 cpuid first -8 shift 4 bits ;
: cpu-processor-type ( -- n ) 1 cpuid first -12 shift 2 bits ;
: cpu-extended-model ( -- n ) 1 cpuid first -16 shift 4 bits ;
: cpu-extended-family ( -- n ) 1 cpuid first -20 shift 8 bits ;

: cpu-family-model-string ( -- string )
    [
        cpu-extended-family cpu-family [ >hex ] bi@
        "_"
        cpu-extended-model cpu-model [ >hex ] bi@
    ] "" append-outputs-as ;

: popcnt? ( -- ? ) 1 cpuid third 23 bit? ;
: tscdeadline? ( -- ? ) 1 cpuid third 24 bit? ;
: aes? ( -- ? ) 1 cpuid third 25 bit? ;
: xsave? ( -- ? ) 1 cpuid third 26 bit? ;
: osxsave? ( -- ? ) 1 cpuid third 27 bit? ;
: avx? ( -- ? ) 1 cpuid third 28 bit? ;
: f16c? ( -- ? ) 1 cpuid third 29 bit? ;
: rdrnd? ( -- ? ) 1 cpuid third 30 bit? ;

: msr? ( -- ? ) 1 cpuid fourth 5 bit? ;
: tm1? ( -- ? ) 1 cpuid fourth 29 bit? ;
: tm2? ( -- ? ) 1 cpuid third 8 bit? ;

MEMO: enable-popcnt? ( -- ? )
    popcnt? "disable-popcnt" get not and ;

[ { sse-version enable-popcnt? } [ reset-memoized ] each ]
"cpu.x86.features" add-startup-hook

: sse-string ( version -- string )
    {
        { 00 [ "no SSE" ] }
        { 10 [ "SSE1" ] }
        { 20 [ "SSE2" ] }
        { 30 [ "SSE3" ] }
        { 33 [ "SSSE3" ] }
        { 41 [ "SSE4.1" ] }
        { 42 [ "SSE4.2" ] }
    } case ;

HOOK: instruction-count cpu ( -- n )

M: x86.32 instruction-count
    longlong { } cdecl [
        RDTSC
    ] alien-assembly ;

M: x86.64 instruction-count
    longlong { } cdecl [
        RAX 0 MOV
        RDTSC
        RDX 32 SHL
        RAX RDX OR
    ] alien-assembly ;

: count-instructions ( quot -- n )
    instruction-count [ call instruction-count ] dip - ; inline
