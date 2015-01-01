USING: accessors arrays assocs compiler.cfg.instructions
compiler.cfg.stacks.map fry kernel math sequences ;
IN: compiler.cfg.stacks.vacant

! ! Utils
: write-slots ( tuple values slots -- )
    [ execute( x y -- z ) ] 2each drop ;

: vacant>bits ( vacant --  bits )
    [ { } ] [
        dup supremum 1 + 1 <array>
        [ '[ _ 0 -rot set-nth ] each ] keep
    ] if-empty ;

: stack>overinitialized ( stack -- seq )
    second [ 0 < ] filter ;

: overinitialized>bits ( overinitialized -- bits )
    [ neg 1 - ] map vacant>bits ;

: stack>scrub-and-check ( stack -- pair )
    [ stack>vacant vacant>bits ]
    [ stack>overinitialized overinitialized>bits ] bi 2array ;

! Operations on the analysis state
: state>gc-data ( state -- gc-data )
    [ stack>scrub-and-check ] map ;

: set-gc-map ( state gc-map -- )
    swap state>gc-data concat
    { >>scrub-d >>check-d >>scrub-r >>check-r } write-slots ;

: fill-gc-maps ( cfg -- )
    trace-stack-state [ drop gc-map-insn? ] assoc-filter
    [ swap gc-map>> set-gc-map ] assoc-each ;
