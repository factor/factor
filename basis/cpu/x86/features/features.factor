! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs sequences alien alien.c-types
combinators compiler compiler.codegen.labels compiler.units
cpu.architecture cpu.x86.assembler cpu.x86.assembler.operands
init io kernel locals math math.order math.parser memoize
namespaces system arrays specialized-arrays cpu.x86.64 ;
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

M: x86.32 (cpuid) ( n regs -- )
    void { uint void* } cdecl [
        ! Save ds-reg, rs-reg
        EDI PUSH
        EAX ESP 4 [+] MOV
        CPUID
        EDI ESP 8 [+] MOV
        EDI [] EAX MOV
        EDI 4 [+] EBX MOV
        EDI 8 [+] ECX MOV
        EDI 12 [+] EDX MOV
        EDI POP
    ] alien-assembly ;

M: x86.64 (cpuid) ( n regs -- )
    void { uint void* } cdecl [
        RAX param-reg-0 MOV
        RSI param-reg-1 MOV
        CPUID
        RSI [] EAX MOV
        RSI 4 [+] EBX MOV
        RSI 8 [+] ECX MOV
        RSI 12 [+] EDX MOV
    ] alien-assembly ;

: cpuid ( n -- 4array )
   4 <uint-array> [ (cpuid) ] keep >array ;

: popcnt? ( -- ? )
    bool { } cdecl [
        return-reg 1 MOV
        CPUID
        return-reg dup XOR
        ECX 23 BT
        return-reg SETB
    ] alien-assembly ;

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
