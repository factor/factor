! Copyright (C) 2011 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.
USING: accessors system kernel layouts combinators locals
compiler.cfg.builder.alien.boxing sequences arrays math
alien.c-types cpu.architecture cpu.ppc alien.complex
cpu.ppc.64le.abi cpu.ppc.64le.abi.params cpu.ppc.64.varargs ;
IN: cpu.ppc.elfv2

M: ppc param-regs
    drop {
        { int-regs { 3 4 5 6 7 8 9 10 } }
        { float-regs { 1 2 3 4 5 6 7 8 9 10 11 12 13 } }
    } ;

M: ppc value-struct? drop t ;

M: ppc dummy-stack-params? t ;

M: ppc dummy-int-params? t ;

M: ppc dummy-fp-params? f ;

M: ppc long-long-on-stack? f ;

M: ppc long-long-odd-register? f ;

M: ppc64 return-regs
    {
        { int-regs { 3 4 } }
        { float-regs { 1 2 3 4 5 6 7 8 } }
    } ;

M: ppc64 return-struct-in-registers?
    lookup-c-type [ heap-size 16 <= ] [ ppc64le-hfa-members >boolean ] bi or ;

M: ppc flatten-struct-type
    dup ppc64le-hfa-param-reps [ nip ] [
        {
            { [ dup lookup-c-type complex-double lookup-c-type = ]
              [ drop { { double-rep f f } { double-rep f f } } ] }
            { [ dup lookup-c-type complex-float lookup-c-type = ]
              [ drop { { float-rep f f } { float-rep f f } } ] }
            [ heap-size cell align cell /i { int-rep f f } <repetition> ]
        } cond
    ] if* ;

M: ppc64 flatten-struct-type-return
    dup lookup-c-type ppc64le-hfa-members [
        nip [ third f f 3array ] map record-reg-reps
    ] [
        heap-size cell align cell /i { int-rep f f } <repetition> record-reg-reps
    ] if* ;

! ELFv2 pads a whole aggregate smaller than one doubleword at its head.
! Larger aggregate tail chunks retain their full doubleword positions.
M:: ppc64 struct-components ( reps c-type -- offsets types )
    cpu ppc.64? os freebsd? os openbsd? or and
    c-type heap-size 8 < and
    reps { int-rep } = and [
        reps component-offsets
        c-type heap-size <right-partial-struct-cell> 1array
    ] [ reps c-type call-next-method ] if ;
