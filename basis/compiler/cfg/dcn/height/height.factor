! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs accessors sequences kernel math locals fry
compiler.cfg.instructions compiler.cfg.rpo compiler.cfg.registers ;
IN: compiler.cfg.dcn.height

! Compute block in-height and out-height sets. These are relative to the
! stack height from the start of the procedure.

<PRIVATE

SYMBOLS: in-ds-heights out-ds-heights in-rs-heights out-rs-heights ;

GENERIC: ds-height-change ( insn -- n )

M: insn ds-height-change drop 0 ;

M: ##inc-d ds-height-change n>> ;

M: ##call ds-height-change height>> ;

: alien-node-height ( node -- n )
    params>> [ out-d>> length ] [ in-d>> length ] bi - ;

M: ##alien-invoke ds-height-change alien-node-height ;

M: ##alien-indirect ds-height-change alien-node-height ;

GENERIC: rs-height-change ( insn -- n )

M: insn rs-height-change drop 0 ;

M: ##inc-r rs-height-change n>> ;

:: compute-in-height ( bb in out -- )
    bb predecessors>> [ out at ] map-find drop 0 or
    bb in set-at ;

:: compute-out-height ( bb in out quot -- )
    bb instructions>>
    bb in at
    [ quot call + ] reduce
    bb out set-at ; inline

:: compute-height ( bb in out quot -- )
    bb in get out get
    [ compute-in-height ]
    [ quot compute-out-height ] 3bi ; inline

: compute-ds-height ( bb -- )
    in-ds-heights out-ds-heights [ ds-height-change ] compute-height ;

: compute-rs-height ( bb -- )
    in-rs-heights out-rs-heights [ rs-height-change ] compute-height ;

GENERIC# translate-loc 1 ( loc bb -- loc' )

M: ds-loc translate-loc [ n>> ] [ in-ds-heights get at ] bi* - <ds-loc> ;
M: rs-loc translate-loc [ n>> ] [ in-rs-heights get at ] bi* - <ds-loc> ;

GENERIC# untranslate-loc 1 ( loc bb -- loc' )

M: ds-loc untranslate-loc [ n>> ] [ in-ds-heights get at ] bi* + <ds-loc> ;
M: rs-loc untranslate-loc [ n>> ] [ in-rs-heights get at ] bi* + <ds-loc> ;

PRIVATE>

: compute-heights ( cfg -- )
    H{ } clone in-ds-heights set
    H{ } clone out-ds-heights set
    H{ } clone in-rs-heights set
    H{ } clone out-rs-heights set
    [
        [ compute-rs-height ]
        [ compute-ds-height ] bi
    ] each-basic-block ;

: translate-locs ( assoc bb -- assoc' )
    '[ [ _ translate-loc ] dip ] assoc-map ;

: untranslate-locs ( assoc bb -- assoc' )
    '[ [ _ untranslate-loc ] dip ] assoc-map ;
