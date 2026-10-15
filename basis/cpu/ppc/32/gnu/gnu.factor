! GNU PowerPC32 SysV argument and aggregate classification.
USING: accessors system kernel layouts combinators
compiler.cfg.builder.alien.boxing sequences arrays
alien.c-types cpu.architecture cpu.ppc alien.complex
cpu.ppc.32.abi ;
IN: cpu.ppc.32.gnu

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
          [ drop { { int-rep f t } { int-rep f f } } ] }
        [ call-next-method [ first t f 3array ] map ]
    } cond ;
