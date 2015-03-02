USING: accessors arrays assocs combinators compiler.cfg.dataflow-analysis
compiler.cfg.instructions compiler.cfg.linearization compiler.cfg.registers fry
kernel math math.order namespaces sequences ;
QUALIFIED: sets
IN: compiler.cfg.stacks.map

! Operations on the stack info
: register-write ( n stack -- stack' )
    first2 rot suffix sets:members 2array ;

: adjust-stack ( n stack -- stack' )
    first2 pick '[ _ + ] map [ + ] dip 2array ;

: stack>vacant ( stack -- seq )
    first2 [ 0 max iota ] dip sets:diff ;

: classify-read ( stack n -- val )
    swap 2dup second member? [ 2drop 0 ] [ first >= [ 1 ] [ 2 ] if ] if ;

CONSTANT: initial-state { { 0 { } } { 0 { } } }

: insn>location ( insn -- n ds? )
    loc>> [ n>> ] [ ds-loc? ] bi ;

: mark-location ( state insn -- state' )
    [ first2 ] dip insn>location
    [ rot register-write swap ] [ swap register-write ] if 2array ;

: fill-vacancies ( state -- state' )
    [ [ first2 ] [ stack>vacant ] bi append 2array ] map ;

GENERIC: visit-insn ( state insn -- state' )

M: ##inc-d visit-insn ( state insn -- state' )
    n>> swap first2 [ adjust-stack ] dip 2array ;

M: ##inc-r visit-insn ( state insn -- state' )
    n>> swap first2 swapd adjust-stack 2array ;

M: ##replace-imm visit-insn mark-location ;
M: ##replace visit-insn mark-location ;

M: ##call visit-insn ( state insn -- state' )
    ! A call instruction may increase the stack height. Then issue a
    ! minor-gc with some of the stack locations scrubbed which would
    ! overwrite the overinitialized locations we're tracking. That is
    ! why they need to be cleared here.
    drop [ first2 [ 0 >= ] filter 2array ] map ;

ERROR: vacant-peek insn ;

: underflowable-peek? ( state peek -- ? )
    2dup insn>location swap [ 0 1 ? swap nth ] dip classify-read
    dup 2 = [ drop vacant-peek ] [ 2nip 1 = ] if ;

M: ##peek visit-insn ( state insn -- state' )
    2dup underflowable-peek? [ [ fill-vacancies ] dip ] when mark-location ;

M: insn visit-insn ( state insn -- state' )
    drop ;

FORWARD-ANALYSIS: map

SYMBOL: stack-record

: register-stack-state ( state insn -- )
    insn#>> stack-record get 2dup at f assert= set-at ;

M: map-analysis transfer-set ( in-set bb dfa -- out-set )
    drop instructions>> swap [
        [ register-stack-state ] [ visit-insn ] 2bi
    ] reduce ;

M: map-analysis ignore-block? ( bb dfa -- ? )
    2drop f ;

! Picking the first means that a block will only be analyzed once.
M: map-analysis join-sets ( sets bb dfa -- set )
    2drop [ initial-state ] [ first ] if-empty ;

: uniquely-number-instructions ( cfg -- )
    cfg>insns [ swap insn#<< ] each-index ;

: trace-stack-state ( cfg -- assoc )
    H{ } clone stack-record set
    [ uniquely-number-instructions ] [ compute-map-sets ] bi
    stack-record get ;
