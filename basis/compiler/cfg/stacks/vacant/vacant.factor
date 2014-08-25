USING: accessors arrays compiler.cfg.dataflow-analysis
compiler.cfg.instructions compiler.cfg.registers fry kernel math math.order
sequences sets ;
IN: compiler.cfg.stacks.vacant

! Operations on the stack info
: register-write ( n stack -- stack' )
    first2 rot suffix members 2array ;

: adjust-stack ( n stack -- stack' )
    first2 pick '[ _ + ] map [ + ] dip 2array ;

: read-ok? ( n stack -- ? )
    [ first >= ] [ second in? ] 2bi or ;

! After a gc, negative writes have been erased.
: register-gc ( stack -- stack' )
    first2 [ 0 >= ] filter 2array ;

: stack>vacant ( stack -- seq )
    first2 [ 0 max iota ] dip diff ;

: vacant>bit-pattern ( vacant --  bit-pattern )
    [ { } ] [
        dup supremum 1 + 1 <array>
        [ '[ _ 0 -rot set-nth ] each ] keep
    ] if-empty ;

! Operations on the analysis state
: state>gc-map ( state -- pair )
    [ stack>vacant vacant>bit-pattern ] map ;

CONSTANT: initial-state { { 0 { } } { 0 { } } }

: insn>gc-map ( insn -- pair )
    gc-map>> [ scrub-d>> ] [ scrub-r>> ] bi 2array ;

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

! Disabled for now until support is added for tracking overinitialized
! stack locations.
M: ##peek visit-insn ( state insn -- state' )
    drop ;
    ! 2dup peek-loc-ok? [ drop ] [ vacant-peek ] if ;

: set-gc-map ( state insn -- )
    gc-map>> swap state>gc-map first2 [ >>scrub-d ] [ >>scrub-r ] bi* drop ;

M: gc-map-insn visit-insn ( state insn -- state' )
    dupd set-gc-map [ register-gc ] map ;

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
