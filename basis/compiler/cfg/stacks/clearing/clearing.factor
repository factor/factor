USING: accessors assocs combinators.short-circuit
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.rpo compiler.cfg.stacks compiler.cfg.stacks.padding
kernel sequences ;
IN: compiler.cfg.stacks.clearing

: state>clears ( state -- clears )
    [ second ] map { ds-loc rs-loc } [ swap create-locs ] 2map concat
    [ f ##clear boa ] map ;

: dangerous-insn? ( state insn -- ? )
    {
        [ { [ nip ##peek? ] [ underflowable-peek? ] } 2&& ]
        [ gc-map-insn? ]
    } 1|| ;

: clearing-insns ( assoc insn -- insns' )
    [ insn#>> of ] keep
    [ dangerous-insn? ]
    [ drop state>clears ]
    [ 2drop { } ] 2if ;

: visit-insns ( assoc insns -- insns' )
    [ [ clearing-insns ] keep suffix ] with map V{ } concat-as ;

: clear-uninitialized ( cfg -- )
    [ trace-stack-state ] keep [
        [ visit-insns ] change-instructions drop
    ] with each-basic-block ;
