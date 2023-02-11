! Copyright (C) 2015 Björn Lindqvist.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg.dataflow-analysis
compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.stacks.local kernel math math.order namespaces
sequences ;
QUALIFIED: sets
IN: compiler.cfg.stacks.padding

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! !! Stack
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: register-write ( n stack -- stack' )
    first2 swapd remove 2array ;

: combine-stacks ( stacks -- stack )
    [ first first ] [ [ second ] map sets:union-all ] bi 2array ;

: classify-read ( stack n -- val )
    swap 2dup second member? [ 2drop 2 ] [ first >= [ 1 ] [ 0 ] if ] if ;

: shift-stack ( n stack -- stack' )
    first2 pick '[ _ + ] map [ 0 >= ] filter pick 0 max <iota> sets:union
    [ + ] dip 2array ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! !! States
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ERROR: vacant-when-calling seq ;

CONSTANT: initial-state { { 0 { } } { 0 { } } }

: apply-stack-op ( state insn quote: ( n stack -- stack' ) -- state' )
    [ [ first2 ] dip loc>> >loc< ] dip
    [ '[ rot @ swap ] ] [ '[ swap @ ] ] bi if 2array ; inline

: combine-states ( states -- state )
    [ initial-state ] [ flip [ combine-stacks ] map ] if-empty ;

: live-location ( state insn -- state' )
    [ register-write ] apply-stack-op ;

: ensure-no-vacant ( state -- )
    [ second ] map dup { { } { } } = [ drop ] [ vacant-when-calling ] if ;

: all-live ( state -- state' )
    [ first { } 2array ] map ;

GENERIC: visit-insn ( state insn -- state' )

M: ##inc visit-insn ( state insn -- state' )
    [ shift-stack ] apply-stack-op ;

M: ##replace-imm visit-insn live-location ;
M: ##replace visit-insn live-location ;

M: ##call visit-insn ( state insn -- state' )
    drop dup ensure-no-vacant ;

M: ##call-gc visit-insn ( state insn -- state' )
    drop all-live ;

M: gc-map-insn visit-insn ( state insn -- state' )
    drop ;

ERROR: vacant-peek insn ;

: underflowable-peek? ( state peek -- ? )
    2dup loc>> >loc< swap [ 0 1 ? swap nth ] dip classify-read
    dup 2 = [ drop vacant-peek ] [ 2nip 1 = ] if ;

M: ##peek visit-insn ( state insn -- state )
    dup loc>> n>> 0 >= t assert=
    dupd underflowable-peek? [ all-live ] when ;

M: insn visit-insn ( state insn -- state' )
    drop ;

FORWARD-ANALYSIS: padding

SYMBOL: stack-record

: register-stack-state ( state insn -- )
    insn#>> stack-record get set-at ;

: visit-insns ( insns state -- state' )
    [ [ register-stack-state ] [ visit-insn ] 2bi ] reduce ;

M: padding transfer-set ( in-set bb dfa -- out-set )
    drop instructions>> swap visit-insns ;

M: padding ignore-block? ( bb dfa -- ? )
    2drop f ;

M: padding join-sets ( sets bb dfa -- set )
    2drop combine-states ;

: uniquely-number-instructions ( cfg -- )
    cfg>insns [ swap insn#<< ] each-index ;

: trace-stack-state ( cfg -- assoc )
    H{ } clone stack-record set
    [ uniquely-number-instructions ] [ compute-padding-sets ] bi
    stack-record get ;
