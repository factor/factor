! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel namespaces math sequences fry grouping
sets make combinators dlists deques
compiler.cfg
compiler.cfg.copy-prop
compiler.cfg.def-use
compiler.cfg.instructions
compiler.cfg.registers
compiler.cfg.rpo
compiler.cfg.hats
compiler.cfg.stack-analysis.state
compiler.cfg.stack-analysis.merge
compiler.cfg.utilities ;
IN: compiler.cfg.stack-analysis

SYMBOL: global-optimization?

: redundant-replace? ( vreg loc -- ? )
    dup state get untranslate-loc n>> 0 <
    [ 2drop t ] [ state get actual-locs>vregs>> at = ] if ;

: save-changed-locs ( state -- )
    [ changed-locs>> keys ] [ locs>vregs>> ] bi '[
        dup _ at swap 2dup redundant-replace?
        [ 2drop ] [ state get untranslate-loc ##replace ] if
    ] each ;

ERROR: poisoned-state state ;

: sync-state ( -- )
    state get {
        [ dup poisoned?>> [ poisoned-state ] [ drop ] if ]
        [ ds-height>> save-ds-height ]
        [ rs-height>> save-rs-height ]
        [ save-changed-locs ]
        [ clear-state ]
    } cleave ;

: poison-state ( -- ) state get t >>poisoned? drop ;

! Abstract interpretation
GENERIC: visit ( insn -- )

M: ##inc-d visit
    n>> state get [ + ] change-ds-height drop ;

M: ##inc-r visit
    n>> state get [ + ] change-rs-height drop ;

! Instructions which don't have any effect on the stack
UNION: neutral-insn
    ##effect
    ##flushable
    ##no-tco ;

M: neutral-insn visit , ;

UNION: sync-if-back-edge
    ##branch
    ##conditional-branch
    ##compare-imm-branch
    ##dispatch
    ##loop-entry
    ##fixnum-overflow ;

: sync-state? ( -- ? )
    basic-block get successors>>
    [ [ predecessors>> ] keep '[ _ back-edge? ] any? ] any? ;

M: sync-if-back-edge visit
    global-optimization? get [ sync-state? [ sync-state ] when ] unless
    , ;

: eliminate-peek ( dst src -- )
    ! the requested stack location is already in 'src'
    [ ##copy ] [ swap copies get set-at ] 2bi ;

M: ##peek visit
    [ dst>> ] [ loc>> state get translate-loc ] bi dup loc>vreg
    [ eliminate-peek ] [ [ record-peek ] [ ##peek ] 2bi ] ?if ;

M: ##replace visit
    [ src>> resolve ] [ loc>> state get translate-loc ] bi
    record-replace ;

M: ##copy visit
    [ call-next-method ] [ record-copy ] bi ;

M: poison-insn visit call-next-method poison-state ;

M: kill-vreg-insn visit sync-state , ;

! Maps basic-blocks to states
SYMBOLS: state-in state-out ;

: block-in-state ( bb -- states )
    dup predecessors>> state-out get '[ _ at ] map merge-states ;

: set-block-in-state ( state bb -- )
    [ clone ] dip state-in get set-at ;

: set-block-out-state ( state bb -- )
    [ clone ] dip state-out get set-at ;

: visit-block ( bb -- )
    ! block-in-state may add phi nodes at the start of the basic block
    ! so we wrap the whole thing with a 'make'
    [
        dup basic-block set
        dup block-in-state
        [ swap set-block-in-state ] [
            state [
                [ instructions>> [ visit ] each ]
                [ [ state get ] dip set-block-out-state ]
                [ ]
                tri
            ] with-variable
        ] 2bi
    ] V{ } make >>instructions drop ;

: stack-analysis ( cfg -- cfg' )
    [
        <hashed-dlist> work-list set
        H{ } clone copies set
        H{ } clone state-in set
        H{ } clone state-out set
        dup [ visit-block ] each-basic-block
        global-optimization? get [ work-list get [ visit-block ] slurp-deque ] when
        cfg-changed
    ] with-scope ;
