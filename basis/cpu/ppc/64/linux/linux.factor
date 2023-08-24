! Copyright (C) 2011 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.
USING: accessors system kernel layouts combinators
compiler.cfg.builder.alien.boxing sequences arrays math
alien.c-types cpu.architecture cpu.ppc alien.complex ;
IN: cpu.ppc.64.linux

M: linux lr-save 2 cells ;

M: linux has-toc t ;

M: linux reserved-area-size 6 cells ;

M: linux allows-null-dereference f ;

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

M: ppc float-right-align-on-stack? t ;

M: ppc flatten-struct-type
    {
        { [ dup lookup-c-type complex-double lookup-c-type = ]
          [ drop { { double-rep f f } { double-rep f f } } ] }
        { [ dup lookup-c-type complex-float lookup-c-type = ]
          [ drop { { float-rep f f } { float-rep f f } } ] }
        [ heap-size cell align cell /i { int-rep f f } <repetition> ]
    } cond ;

M: ppc flatten-struct-type-return
    {
        { [ dup lookup-c-type complex-double lookup-c-type = ]
          [ drop { { double-rep f f } { double-rep f f } } ] }
        { [ dup lookup-c-type complex-float lookup-c-type = ]
          [ drop { { float-rep f f } { float-rep f f } } ] }
        [ heap-size cell align cell /i { int-rep t f } <repetition> ]
    } cond ;
