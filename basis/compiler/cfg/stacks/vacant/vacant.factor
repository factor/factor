USING: accessors arrays assocs compiler.cfg.instructions
compiler.cfg.linearization compiler.cfg.stacks.padding fry kernel math
sequences ;
IN: compiler.cfg.stacks.vacant

: vacant>bits ( vacant --  bits )
    [ { } ] [
        dup supremum 1 + 1 <array>
        [ '[ _ 0 -rot set-nth ] each ] keep
    ] if-empty ;

: state>gc-data ( state -- gc-data )
    [ stack>vacant vacant>bits ] map ;

: set-gc-map ( state gc-map -- )
    swap state>gc-data first2 -rot >>scrub-d swap >>scrub-r drop ;

: fill-gc-maps ( cfg -- )
    [ trace-stack-state2 ] [ cfg>insns [ gc-map-insn? ] filter ] bi
    [ [ insn#>> of ] [ gc-map>> ] bi set-gc-map ] with each ;
