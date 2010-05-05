! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays sequences math splitting make assocs
kernel layouts system alien.c-types classes.struct
cpu.architecture cpu.x86.assembler cpu.x86.assembler.operands
cpu.x86 compiler.codegen.alien compiler.cfg.registers ;
IN: cpu.x86.64.unix

M: int-regs param-regs
    2drop { RDI RSI RDX RCX R8 R9 } ;

M: float-regs param-regs
    2drop { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } ;

M: x86.64 reserved-stack-space 0 ;

: struct-types&offset ( struct-type -- pairs )
    fields>> [
        [ type>> ] [ offset>> ] bi 2array
    ] map ;

: split-struct ( pairs -- seq )
    [
        [ 8 mod zero? [ t , ] when , ] assoc-each
    ] { } make { t } split harvest ;

: flatten-small-struct ( c-type -- seq )
    struct-types&offset split-struct [
        [ c-type c-type-rep reg-class-of ] map
        int-regs swap member? int-rep double-rep ?
    ] map ;

: flatten-large-struct ( c-type -- seq )
    stack-params (flatten-c-type) ;

M: x86.64 flatten-struct-type ( c-type -- seq )
    dup heap-size 16 >
    [ flatten-large-struct ]
    [ flatten-small-struct ] if ;

M: x86.64 return-struct-in-registers? ( c-type -- ? )
    heap-size 2 cells <= ;

M: x86.64 dummy-stack-params? f ;

M: x86.64 dummy-int-params? f ;

M: x86.64 dummy-fp-params? f ;

M: x86.64 temp-reg R8 ;
