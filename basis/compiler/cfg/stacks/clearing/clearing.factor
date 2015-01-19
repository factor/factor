USING: accessors arrays assocs combinators.short-circuit
compiler.cfg.instructions compiler.cfg.registers compiler.cfg.rpo
compiler.cfg.stacks.map kernel math sequences ;
IN: compiler.cfg.stacks.clearing

: state>replaces ( state -- replaces )
    [ stack>vacant ] map first2
    [ [ <ds-loc> ] map ] [ [ <rs-loc> ] map ] bi* append
    [ 17 swap f ##replace-imm boa ] map ;

: dangerous-insn? ( state insn -- ? )
    { [ nip ##peek? ] [ underflowable-peek? ] } 2&& ;

: clearing-replaces ( assoc insn -- insns' )
    [ insn#>> of ] keep 2dup dangerous-insn? [
        drop state>replaces
    ] [ 2drop { } ] if ;

: visit-insns ( assoc insns -- insns' )
    [ [ clearing-replaces ] keep suffix ] with map V{ } concat-as ;

: clear-uninitialized ( cfg -- )
    [ trace-stack-state ] keep [
        [ visit-insns ] change-instructions drop
    ] with each-basic-block ;
