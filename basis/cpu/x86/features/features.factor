! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data arrays assocs combinators
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
: sse1? ( -- ? ) sse-version 10 >= ;
: sse2? ( -- ? ) sse-version 20 >= ;
: sse3? ( -- ? ) sse-version 30 >= ;
: ssse3? ( -- ? ) sse-version 33 >= ;
: sse4.1? ( -- ? ) sse-version 41 >= ;
: sse4.2? ( -- ? ) sse-version 42 >= ;

HOOK: (cpuid) cpu ( rax rcx regs -- )


: cpuid-extended ( rax rcx -- 4array )
   4 uint <c-array> [ (cpuid) ] keep >array ;

: cpuid ( rax -- 4array ) 0 cpuid-extended ;

: cpuid-processor-info ( -- eax ) 1 cpuid first ; inline

: parse-stepping ( eax -- n ) 3 0 bit-range ; inline
: parse-model ( eax -- n ) 7 4 bit-range ; inline
: parse-family ( eax -- n ) 11 8 bit-range ; inline
: parse-processor-type ( eax -- n ) 13 12 bit-range ; inline
: parse-extended-model ( eax -- n ) 19 16 bit-range ; inline
: parse-extended-family ( eax -- n ) 27 20 bit-range ; inline

: cpu-stepping ( -- n ) cpuid-processor-info parse-stepping ;
: cpu-model ( -- n ) cpuid-processor-info parse-model ;
: cpu-family ( -- n ) cpuid-processor-info parse-family ;
: cpu-processor-type ( -- n ) cpuid-processor-info parse-processor-type ;
: cpu-extended-model ( -- n ) cpuid-processor-info parse-extended-model ;
: cpu-extended-family ( -- n ) cpuid-processor-info parse-extended-family ;

: cpu-family-model-string ( -- string )
    [
        cpuid-processor-info {
            [ parse-extended-family >hex ]
            [ parse-family >hex ]
            [ drop "_" ]
            [ parse-extended-model >hex ]
            [ parse-model >hex ]
        } cleave
    ] "" append-outputs-as ;

: popcnt? ( -- ? )
    bool { } cdecl [
        return-reg 1 MOV
        CPUID
        return-reg dup XOR
        ECX 23 BT
        return-reg SETB
    ] alien-assembly ;

: tscdeadline? ( -- ? ) 1 cpuid third 24 bit? ;
: aes? ( -- ? ) 1 cpuid third 25 bit? ;
: xsave? ( -- ? ) 1 cpuid third 26 bit? ;
: osxsave? ( -- ? ) 1 cpuid third 27 bit? ;
: avx? ( -- ? ) 1 cpuid third 28 bit? ;
: f16c? ( -- ? ) 1 cpuid third 29 bit? ;
: rdrand? ( -- ? ) 1 cpuid third 30 bit? ;

: msr? ( -- ? ) 1 cpuid fourth 5 bit? ;
: tm1? ( -- ? ) 1 cpuid fourth 29 bit? ;
: tm2? ( -- ? ) 1 cpuid third 8 bit? ;

! Additional CPUID features from ECX (third)
: pclmulqdq? ( -- ? ) 1 cpuid third 1 bit? ;
: dtes64? ( -- ? ) 1 cpuid third 2 bit? ;
: monitor? ( -- ? ) 1 cpuid third 3 bit? ;
: ds-cpl? ( -- ? ) 1 cpuid third 4 bit? ;
: vmx? ( -- ? ) 1 cpuid third 5 bit? ;
: smx? ( -- ? ) 1 cpuid third 6 bit? ;
: est? ( -- ? ) 1 cpuid third 7 bit? ;
: cnxt-id? ( -- ? ) 1 cpuid third 10 bit? ;
: sdbg? ( -- ? ) 1 cpuid third 11 bit? ;
: fma? ( -- ? ) 1 cpuid third 12 bit? ;
: cx16? ( -- ? ) 1 cpuid third 13 bit? ;
: xtpr? ( -- ? ) 1 cpuid third 14 bit? ;
: pdcm? ( -- ? ) 1 cpuid third 15 bit? ;
: pcid? ( -- ? ) 1 cpuid third 17 bit? ;
: dca? ( -- ? ) 1 cpuid third 18 bit? ;
: x2apic? ( -- ? ) 1 cpuid third 21 bit? ;
: movbe? ( -- ? ) 1 cpuid third 22 bit? ;

! Additional CPUID features from EDX (fourth)
: fpu? ( -- ? ) 1 cpuid fourth 0 bit? ;
: vme? ( -- ? ) 1 cpuid fourth 1 bit? ;
: de? ( -- ? ) 1 cpuid fourth 2 bit? ;
: pse? ( -- ? ) 1 cpuid fourth 3 bit? ;
: tsc? ( -- ? ) 1 cpuid fourth 4 bit? ;
: pae? ( -- ? ) 1 cpuid fourth 6 bit? ;
: mce? ( -- ? ) 1 cpuid fourth 7 bit? ;
: cx8? ( -- ? ) 1 cpuid fourth 8 bit? ;
: apic? ( -- ? ) 1 cpuid fourth 9 bit? ;
: sep? ( -- ? ) 1 cpuid fourth 11 bit? ;
: mtrr? ( -- ? ) 1 cpuid fourth 12 bit? ;
: pge? ( -- ? ) 1 cpuid fourth 13 bit? ;
: mca? ( -- ? ) 1 cpuid fourth 14 bit? ;
: cmov? ( -- ? ) 1 cpuid fourth 15 bit? ;
: pat? ( -- ? ) 1 cpuid fourth 16 bit? ;
: pse-36? ( -- ? ) 1 cpuid fourth 17 bit? ;
: psn? ( -- ? ) 1 cpuid fourth 18 bit? ;
: clfsh? ( -- ? ) 1 cpuid fourth 19 bit? ;
: ds? ( -- ? ) 1 cpuid fourth 21 bit? ;
: acpi? ( -- ? ) 1 cpuid fourth 22 bit? ;
: mmx? ( -- ? ) 1 cpuid fourth 23 bit? ;
: fxsr? ( -- ? ) 1 cpuid fourth 24 bit? ;
: ss? ( -- ? ) 1 cpuid fourth 27 bit? ;
: htt? ( -- ? ) 1 cpuid fourth 28 bit? ;
: ia64? ( -- ? ) 1 cpuid fourth 30 bit? ;
: pbe? ( -- ? ) 1 cpuid fourth 31 bit? ;

! Extended features (EAX=7, ECX=0)
: fsgsbase? ( -- ? ) 7 0 cpuid-extended second 0 bit? ;
: bmi1? ( -- ? ) 7 0 cpuid-extended second 3 bit? ;
: hle? ( -- ? ) 7 0 cpuid-extended second 4 bit? ;
: avx2? ( -- ? ) 7 0 cpuid-extended second 5 bit? ;
: smep? ( -- ? ) 7 0 cpuid-extended second 7 bit? ;
: bmi2? ( -- ? ) 7 0 cpuid-extended second 8 bit? ;
: erms? ( -- ? ) 7 0 cpuid-extended second 9 bit? ;
: invpcid? ( -- ? ) 7 0 cpuid-extended second 10 bit? ;
: rtm? ( -- ? ) 7 0 cpuid-extended second 11 bit? ;
: mpx? ( -- ? ) 7 0 cpuid-extended second 14 bit? ;
: avx512f? ( -- ? ) 7 0 cpuid-extended second 16 bit? ;
: avx512dq? ( -- ? ) 7 0 cpuid-extended second 17 bit? ;
: rdseed? ( -- ? ) 7 0 cpuid-extended second 18 bit? ;
: adx? ( -- ? ) 7 0 cpuid-extended second 19 bit? ;
: smap? ( -- ? ) 7 0 cpuid-extended second 20 bit? ;
: avx512ifma? ( -- ? ) 7 0 cpuid-extended second 21 bit? ;
: clflushopt? ( -- ? ) 7 0 cpuid-extended second 23 bit? ;
: clwb? ( -- ? ) 7 0 cpuid-extended second 24 bit? ;
: avx512pf? ( -- ? ) 7 0 cpuid-extended second 26 bit? ;
: avx512er? ( -- ? ) 7 0 cpuid-extended second 27 bit? ;
: avx512cd? ( -- ? ) 7 0 cpuid-extended second 28 bit? ;
: sha? ( -- ? ) 7 0 cpuid-extended second 29 bit? ;
: avx512bw? ( -- ? ) 7 0 cpuid-extended second 30 bit? ;
: avx512vl? ( -- ? ) 7 0 cpuid-extended second 31 bit? ;

! Extended features (EAX=7, ECX=0) - ECX results
: prefetchwt1? ( -- ? ) 7 0 cpuid-extended third 0 bit? ;
: avx512vbmi? ( -- ? ) 7 0 cpuid-extended third 1 bit? ;
: umip? ( -- ? ) 7 0 cpuid-extended third 2 bit? ;
: pku? ( -- ? ) 7 0 cpuid-extended third 3 bit? ;
: ospke? ( -- ? ) 7 0 cpuid-extended third 4 bit? ;
: avx512vbmi2? ( -- ? ) 7 0 cpuid-extended third 6 bit? ;
: gfni? ( -- ? ) 7 0 cpuid-extended third 8 bit? ;
: vaes? ( -- ? ) 7 0 cpuid-extended third 9 bit? ;
: vpclmulqdq? ( -- ? ) 7 0 cpuid-extended third 10 bit? ;
: avx512vnni? ( -- ? ) 7 0 cpuid-extended third 11 bit? ;
: avx512bitalg? ( -- ? ) 7 0 cpuid-extended third 12 bit? ;
: avx512vpopcntdq? ( -- ? ) 7 0 cpuid-extended third 14 bit? ;
: rdpid? ( -- ? ) 7 0 cpuid-extended third 22 bit? ;

! Extended features (EAX=0x80000001)
: syscall? ( -- ? ) 0x80000001 cpuid fourth 11 bit? ;
: nx? ( -- ? ) 0x80000001 cpuid fourth 20 bit? ;
: pdpe1gb? ( -- ? ) 0x80000001 cpuid fourth 26 bit? ;
: rdtscp? ( -- ? ) 0x80000001 cpuid fourth 27 bit? ;
: lm? ( -- ? ) 0x80000001 cpuid fourth 29 bit? ;
: lahf-lm? ( -- ? ) 0x80000001 cpuid third 0 bit? ;
: cmp-legacy? ( -- ? ) 0x80000001 cpuid third 1 bit? ;
: svm? ( -- ? ) 0x80000001 cpuid third 2 bit? ;
: extapic? ( -- ? ) 0x80000001 cpuid third 3 bit? ;
: cr8-legacy? ( -- ? ) 0x80000001 cpuid third 4 bit? ;
: abm? ( -- ? ) 0x80000001 cpuid third 5 bit? ;
: sse4a? ( -- ? ) 0x80000001 cpuid third 6 bit? ;
: misalignsse? ( -- ? ) 0x80000001 cpuid third 7 bit? ;
: 3dnowprefetch? ( -- ? ) 0x80000001 cpuid third 8 bit? ;
: osvw? ( -- ? ) 0x80000001 cpuid third 9 bit? ;
: ibs? ( -- ? ) 0x80000001 cpuid third 10 bit? ;
: xop? ( -- ? ) 0x80000001 cpuid third 11 bit? ;
: skinit? ( -- ? ) 0x80000001 cpuid third 12 bit? ;
: wdt? ( -- ? ) 0x80000001 cpuid third 13 bit? ;
: lwp? ( -- ? ) 0x80000001 cpuid third 15 bit? ;
: fma4? ( -- ? ) 0x80000001 cpuid third 16 bit? ;
: tce? ( -- ? ) 0x80000001 cpuid third 17 bit? ;
: nodeid-msr? ( -- ? ) 0x80000001 cpuid third 19 bit? ;
: tbm? ( -- ? ) 0x80000001 cpuid third 21 bit? ;
: topoext? ( -- ? ) 0x80000001 cpuid third 22 bit? ;
: perfctr-core? ( -- ? ) 0x80000001 cpuid third 23 bit? ;
: perfctr-nb? ( -- ? ) 0x80000001 cpuid third 24 bit? ;
: dbx? ( -- ? ) 0x80000001 cpuid third 26 bit? ;
: perftsc? ( -- ? ) 0x80000001 cpuid third 27 bit? ;
: pcx-l2i? ( -- ? ) 0x80000001 cpuid third 28 bit? ;
: 3dnow? ( -- ? ) 0x80000001 cpuid fourth 31 bit? ;
: 3dnowext? ( -- ? ) 0x80000001 cpuid fourth 30 bit? ;

: rdrand8 ( -- x )
    uchar { } cdecl [
        AL RDRAND
    ] alien-assembly ;

: rdrand16 ( -- x )
    ushort { } cdecl [
        AX RDRAND
    ] alien-assembly ;

: rdrand32 ( -- x )
    uint { } cdecl [
        EAX RDRAND
    ] alien-assembly ;

: rdrand64 ( -- x )
    ulonglong { } cdecl [
        RAX RDRAND
    ] alien-assembly ;

MEMO: enable-popcnt? ( -- ? )
    popcnt? "disable-popcnt" get not and ;

STARTUP-HOOK: [
    { sse-version enable-popcnt? } [ reset-memoized ] each
]

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
