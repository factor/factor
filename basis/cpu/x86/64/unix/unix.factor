! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays assocs
compiler.cfg.builder.alien.boxing cpu.architecture cpu.x86
cpu.x86.assembler cpu.x86.assembler.operands kernel layouts locals
make math math.order namespaces sequences splitting system ;
IN: cpu.x86.64.unix

M: x86.64 param-regs
    drop {
        { int-regs { RDI RSI RDX RCX R8 R9 } }
        { float-regs { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } }
    } ;

M: x86.64 reserved-stack-space 0 ;

: struct-types&offset ( struct-type -- pairs )
    fields>> [
        [ type>> ] [ offset>> ] bi 2array
    ] map ;

: split-struct ( pairs -- seq )
    [
        [ 8 mod zero? [ t , ] when , ] assoc-each
    ] { } make { t } split harvest ;

:: flatten-small-struct ( c-type -- seq )
    c-type struct-types&offset split-struct [
        [ lookup-c-type c-type-rep reg-class-of ] map
        int-regs swap member? int-rep double-rep ?
        f f 3array
    ] map :> reps
    int-reg-reps get float-reg-reps get and [
        reps reg-reps :> ( int-mems float-mems )
        int-reg-reps get int-mems + 6 >
        float-reg-reps get float-mems + 8 > or [
            reps [ first t f 3array ] map
        ] [ reps ] if
    ] [ reps ] if ;

M: x86.64 flatten-struct-type
    dup heap-size 16 <=
    [ flatten-small-struct record-reg-reps ] [
        call-next-method unrecord-reg-reps
        [ first t f 3array ] map
    ] if ;

M: x86.64 return-struct-in-registers?
    heap-size 2 cells <= ;

M: x86.64 dummy-stack-params? f ;

M: x86.64 dummy-int-params? f ;

M: x86.64 dummy-fp-params? f ;

M: x86.64 %prepare-var-args
    [ second reg-class-of float-regs? ] count 8 min
    [ EAX EAX XOR ] [ <byte> AL swap MOV ] if-zero ;
