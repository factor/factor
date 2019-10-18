USING: accessors arrays assocs classes.tuple compiler.cfg.dataflow-analysis
compiler.cfg.instructions compiler.cfg.registers fry kernel math math.order
sequences sets ;
IN: compiler.cfg.stacks.vacant

! Utils
: write-slots ( tuple values slots -- )
    [ execute( x y -- z ) ] 2each drop ;

! Operations on the stack info
: register-write ( n stack -- stack' )
    first2 rot suffix members 2array ;

: adjust-stack ( n stack -- stack' )
    first2 pick '[ _ + ] map [ + ] dip 2array ;

: read-ok? ( n stack -- ? )
    [ first >= ] [ second in? ] 2bi or ;

: stack>vacant ( stack -- seq )
    first2 [ 0 max iota ] dip diff ;

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

CONSTANT: initial-state { { 0 { } } { 0 { } } }

: insn>location ( insn -- n ds? )
    loc>> [ n>> ] [ ds-loc? ] bi ;

: visit-replace ( state insn -- state' )
    [ first2 ] dip insn>location
    [ rot register-write swap ] [ swap register-write ] if 2array ;

ERROR: vacant-peek insn ;

: peek-loc-ok? ( state insn -- ? )
    insn>location 0 1 ? rot nth read-ok? ;

GENERIC: visit-insn ( state insn -- state' )

M: ##inc-d visit-insn ( state insn -- state' )
    n>> swap first2 [ adjust-stack ] dip 2array ;

M: ##inc-r visit-insn ( state insn -- state' )
    n>> swap first2 swapd adjust-stack 2array ;

M: ##replace-imm visit-insn visit-replace ;
M: ##replace visit-insn visit-replace ;

M: ##peek visit-insn ( state insn -- state' )
    2dup peek-loc-ok? [ drop ] [ vacant-peek ] if ;

M: ##call visit-insn ( state insn -- state' )
    ! After a word call, we can't trust any overinitialized locations
    ! to contain valid pointers anymore.
    drop [ first2 [ 0 >= ] filter 2array ] map ;

: set-gc-map ( state gc-map -- )
    swap state>gc-data concat
    { >>scrub-d >>check-d >>scrub-r >>check-r } write-slots ;

M: gc-map-insn visit-insn ( state insn -- state' )
    dupd gc-map>> set-gc-map ;

M: insn visit-insn ( state insn -- state' )
    drop ;

FORWARD-ANALYSIS: vacant

M: vacant-analysis transfer-set ( in-set bb dfa -- out-set )
    drop instructions>> swap [ visit-insn ] reduce ;

M: vacant-analysis ignore-block? ( bb dfa -- ? )
    2drop f ;

! Picking the first means that a block will only be analyzed once.
M: vacant-analysis join-sets ( sets bb dfa -- set )
    2drop [ initial-state ] [ first ] if-empty ;
