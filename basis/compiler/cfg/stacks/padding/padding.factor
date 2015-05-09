! Copyright (C) 2015 Björn Lindqvist.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg.dataflow-analysis
compiler.cfg.instructions compiler.cfg.linearization compiler.cfg.predecessors
compiler.cfg.registers compiler.cfg.stacks compiler.cfg.stacks.local
compiler.cfg.stacks.global fry grouping kernel math math.order namespaces
sequences ;
QUALIFIED: sets
IN: compiler.cfg.stacks.padding

ERROR: overinitialized-when-gc seq ;
ERROR: vacant-when-calling seq ;

: safe-iota ( n -- seq )
    0 max iota ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! !! Stack
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ERROR: height-mismatches seq ;

: register-write ( n stack -- stack' )
    first2 rot suffix sets:members 2array ;

: adjust-stack ( n stack -- stack' )
    first2 pick '[ _ + ] map [ + ] dip 2array ;

: stack>vacant ( stack -- seq )
    first2 [ safe-iota ] dip sets:diff ;

: combine-stacks ( stacks -- stack )
    [ [ first ] map dup all-equal? [ first ] [ height-mismatches ] if ]
    [ [ second ] map refine ] bi 2array ;

: fill-stack ( stack -- stack' )
    first2 over safe-iota sets:union 2array ;

: classify-read ( stack n -- val )
    swap 2dup second member? [ 2drop 0 ] [ first >= [ 1 ] [ 2 ] if ] if ;

: push-items ( n stack -- stack' )
    first2 pick '[ _ + ] map pick safe-iota sets:union [ + ] dip 2array ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! !! States
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
CONSTANT: initial-state { { 0 { } } { 0 { } } }

: apply-stack-op ( state insn quote: ( n stack -- stack' ) -- state' )
    [ [ first2 ] dip loc>> >loc< ] dip
    [ '[ rot @ swap ] ] [ '[ swap @ ] ] bi if 2array ; inline

: combine-states ( states -- state )
    [ initial-state ] [ flip [ combine-stacks ] map ] if-empty ;

: mark-location ( state insn -- state' )
    [ register-write ] apply-stack-op ;

: ensure-no-vacant ( state -- )
    [ stack>vacant ] map dup { { } { } } =
    [ drop ] [ vacant-when-calling ] if ;

: ensure-no-overinitialized ( state -- )
    [ second [ 0 < ] filter ] map dup { { } { } } =
    [ drop ] [ overinitialized-when-gc ] if ;

: fill-vacancies ( state -- state' )
    [ fill-stack ] map ;

GENERIC: visit-insn ( state insn -- state' )

M: ##inc visit-insn ( state insn -- state' )
    [ adjust-stack ] apply-stack-op
    [ first2 [ 0 >= ] filter 2array ] map ;

M: ##replace-imm visit-insn mark-location ;
M: ##replace visit-insn mark-location ;

M: ##call visit-insn ( state insn -- state' )
    over ensure-no-vacant
    height>> swap first2 [ push-items ] dip 2array
    [ first2 [ 0 >= ] filter 2array ] map ;

M: ##call-gc visit-insn ( state insn -- state' )
    drop dup ensure-no-overinitialized fill-vacancies ;

M: gc-map-insn visit-insn ( state insn -- state' )
    drop ;

ERROR: vacant-peek insn ;

: underflowable-peek? ( state peek -- ? )
    2dup loc>> >loc< swap [ 0 1 ? swap nth ] dip classify-read
    dup 2 = [ drop vacant-peek ] [ 2nip 1 = ] if ;

M: ##peek visit-insn ( state insn -- state )
    2dup underflowable-peek? [ [ fill-vacancies ] dip ] when mark-location ;

M: insn visit-insn ( state insn -- state' )
    drop ;

FORWARD-ANALYSIS: padding

SYMBOL: stack-record

: register-stack-state ( state insn -- )
    insn#>> stack-record get set-at ;

: visit-insns ( insns state -- state' )
    [ [ register-stack-state ] [ visit-insn ] 2bi ] reduce ;

M: padding-analysis transfer-set ( in-set bb dfa -- out-set )
    drop instructions>> swap visit-insns ;

M: padding-analysis ignore-block? ( bb dfa -- ? )
    2drop f ;

M: padding-analysis join-sets ( sets bb dfa -- set )
    2drop combine-states ;

: uniquely-number-instructions ( cfg -- )
    cfg>insns [ swap insn#<< ] each-index ;

: trace-stack-state2 ( cfg -- assoc )
    H{ } clone stack-record set
    [ uniquely-number-instructions ] [ compute-padding-sets ] bi
    stack-record get ;
