USING: accessors arrays assocs compiler.cfg.instructions
compiler.cfg.linearization compiler.cfg.stacks.map fry kernel math sequences ;
IN: compiler.cfg.stacks.vacant

! ! Utils
: write-slots ( tuple values slots -- )
    [ execute( x y -- z ) ] 2each drop ;

: vacant>bits ( vacant --  bits )
    [ { } ] [
        dup supremum 1 + 1 <array>
        [ '[ _ 0 -rot set-nth ] each ] keep
    ] if-empty ;

! Operations on the analysis state
: state>gc-data ( state -- gc-data )
    [ stack>vacant vacant>bits ] map ;

: set-gc-map ( state gc-map -- )
    swap state>gc-data { >>scrub-d >>scrub-r } write-slots ;
    ! swap state>gc-data { { } { } } append
    ! { >>scrub-d >>scrub-r >>check-d >>check-r } write-slots ;

: fill-gc-maps ( cfg -- )
    [ trace-stack-state ] [ cfg>insns [ gc-map-insn? ] filter ] bi
    [ [ insn#>> of ] [ gc-map>> ] bi set-gc-map ] with each ;
