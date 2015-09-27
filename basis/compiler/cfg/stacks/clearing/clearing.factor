USING: accessors arrays assocs combinators.short-circuit
compiler.cfg.instructions compiler.cfg.registers compiler.cfg.rpo
compiler.cfg.stacks compiler.cfg.stacks.padding kernel math sequences ;
IN: compiler.cfg.stacks.clearing

: state>clears ( state -- clears )
    [ second ] map { ds-loc rs-loc } [ swap create-locs ] 2map concat
    [ f ##clear boa ] map ;

: dangerous-insn? ( state insn -- ? )
    { [ nip ##peek? ] [ underflowable-peek? ] } 2&& ;

: clearing-insns ( assoc insn -- insns' )
    [ insn#>> of ] keep 2dup dangerous-insn? [
        drop state>clears
    ] [ 2drop { } ] if ;

: visit-insns ( assoc insns -- insns' )
    [ [ clearing-insns ] keep suffix ] with map V{ } concat-as ;

: clear-uninitialized ( cfg -- )
    [ trace-stack-state2 ] keep [
        [ visit-insns ] change-instructions drop
    ] with each-basic-block ;
