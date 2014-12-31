USING: accessors arrays assocs compiler.cfg.dataflow-analysis
compiler.cfg.instructions compiler.cfg.registers fry kernel math math.order
namespaces sequences ;
QUALIFIED: sets
IN: compiler.cfg.stacks.map

! Operations on the stack info
: register-write ( n stack -- stack' )
    first2 rot suffix sets:members 2array ;

: adjust-stack ( n stack -- stack' )
    first2 pick '[ _ + ] map [ + ] dip 2array ;

: stack>vacant ( stack -- seq )
    first2 [ 0 max iota ] dip sets:diff ;

CONSTANT: initial-state { { 0 { } } { 0 { } } }

: insn>location ( insn -- n ds? )
    loc>> [ n>> ] [ ds-loc? ] bi ;

: mark-location ( state insn -- state' )
    [ first2 ] dip insn>location
    [ rot register-write swap ] [ swap register-write ] if 2array ;

: state>vacancies ( state -- vacants )
    [ stack>vacant ] map ;

: fill-vacancies ( state -- state' )
    dup state>vacancies [ [ first2 ] dip append 2array ] 2map ;

GENERIC: visit-insn ( state insn -- state' )

M: ##inc-d visit-insn ( state insn -- state' )
    n>> swap first2 [ adjust-stack ] dip 2array ;

M: ##inc-r visit-insn ( state insn -- state' )
    n>> swap first2 swapd adjust-stack 2array ;

M: ##replace-imm visit-insn mark-location ;
M: ##replace visit-insn mark-location ;

M: ##call visit-insn ( state insn -- state' )
    ! After a word call, we can't trust any overinitialized locations
    ! to contain valid pointers anymore.
    drop [ first2 [ 0 >= ] filter 2array ] map ;

: dangerous-peek? ( state peek -- ? )
    loc>> [ ds-loc? 0 1 ? swap nth first ] keep n>> <= ;

M: ##peek visit-insn ( state insn -- state' )
    2dup dangerous-peek? [ [ fill-vacancies ] dip ] when mark-location ;

M: insn visit-insn ( state insn -- state' )
    drop ;

FORWARD-ANALYSIS: map

SYMBOL: stack-record

M: map-analysis transfer-set ( in-set bb dfa -- out-set )
    drop instructions>> swap [
        [ stack-record get set-at ] [ visit-insn ] 2bi
    ] reduce ;

M: map-analysis ignore-block? ( bb dfa -- ? )
    2drop f ;

! Picking the first means that a block will only be analyzed once.
M: map-analysis join-sets ( sets bb dfa -- set )
    2drop [ initial-state ] [ first ] if-empty ;

: trace-stack-state ( cfg -- assoc )
    H{ } clone stack-record set compute-map-sets stack-record get ;
