! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs sequences alien alien.c-types
combinators compiler compiler.codegen.fixup compiler.units
cpu.architecture cpu.x86.assembler cpu.x86.assembler.operands
init io kernel locals math math.order math.parser memoize
namespaces system ;
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

[ \ sse-version reset-memoized ] "cpu.x86.features" add-startup-hook

: sse? ( -- ? ) sse-version 10 >= ;
: sse2? ( -- ? ) sse-version 20 >= ;
: sse3? ( -- ? ) sse-version 30 >= ;
: ssse3? ( -- ? ) sse-version 33 >= ;
: sse4.1? ( -- ? ) sse-version 41 >= ;
: sse4.2? ( -- ? ) sse-version 42 >= ;

: popcnt? ( -- ? )
    bool { } cdecl [
        return-reg 1 MOV
        CPUID
        ECX 23 BT
        return-reg dup XOR
        return-reg SETB
    ] alien-assembly ;

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
