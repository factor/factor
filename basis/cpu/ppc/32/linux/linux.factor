! Copyright (C) 2011 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.
USING: accessors system kernel layouts combinators
compiler.cfg.builder.alien.boxing sequences arrays
alien.c-types cpu.architecture cpu.ppc alien.complex ;
IN: cpu.ppc.32.linux

M: linux lr-save 1 cells ;

M: linux has-toc f ;

M: linux reserved-area-size 2 cells ;

M: linux allows-null-dereference f ;

M: ppc param-regs
    drop {
        { int-regs { 3 4 5 6 7 8 9 10 } }
        { float-regs { 1 2 3 4 5 6 7 8 } }
    } ;

M: ppc value-struct?
    lookup-c-type [ complex-double lookup-c-type = ]
    [ complex-float lookup-c-type = ] bi or ;

M: ppc dummy-stack-params? f ;

M: ppc dummy-int-params? f ;

M: ppc dummy-fp-params? f ;

M: ppc long-long-on-stack? f ;

M: ppc long-long-odd-register? t ;

M: ppc float-right-align-on-stack? f ;

M: ppc flatten-struct-type
    {
        { [ dup lookup-c-type complex-double lookup-c-type = ]
          [ drop { { int-rep f f } { int-rep f f }
                   { int-rep f f } { int-rep f f } } ] }
        { [ dup lookup-c-type complex-float lookup-c-type = ]
          [ drop { { int-rep f f } { int-rep f f } } ] }
        [ call-next-method [ first t f 3array ] map ]
    } cond ;
