! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel namespaces math sequences fry deques
search-deques dlists sets make combinators compiler.cfg.copy-prop
compiler.cfg.def-use compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.rpo ;
IN: compiler.cfg.stack-analysis

! Convert stack operations to register operations

! If 'poisoned' is set, disregard height information. This is set if we don't have
! height change information for an instruction.
TUPLE: state locs>vregs vregs>locs changed-locs d-height r-height poisoned? ;

: <state> ( -- state )
    state new
        H{ } clone >>locs>vregs
        H{ } clone >>vregs>locs
        H{ } clone >>changed-locs
        0 >>d-height
        0 >>r-height ;

M: state clone
    call-next-method
        [ clone ] change-locs>vregs
        [ clone ] change-vregs>locs
        [ clone ] change-changed-locs ;

: loc>vreg ( loc -- vreg ) state get locs>vregs>> at ;

: record-peek ( dst loc -- )
    state get
    [ locs>vregs>> set-at ]
    [ swapd vregs>locs>> set-at ]
    3bi ;

: delete-old-vreg ( loc -- )
    state get locs>vregs>> at [ state get vregs>locs>> delete-at ] when* ;

: changed-loc ( loc -- )
    state get changed-locs>> conjoin ;

: redundant-replace? ( src loc -- ? )
    loc>vreg = ;

: record-replace ( src loc -- )
    ! Locs are not single assignment, which means we have to forget
    ! that the previous vreg, if any, points at this loc. Also, record
    ! that the loc changed so that all the right ##replace instructions
    ! are emitted at a sync point.
    2dup redundant-replace? [ 2drop ] [
        dup delete-old-vreg dup changed-loc record-peek
    ] if ;

: save-changed-locs ( state -- )
    [ changed-locs>> ] [ locs>vregs>> ] bi '[
        _ at swap 2dup redundant-replace?
        [ 2drop ] [ ##replace ] if
    ] assoc-each ;

: clear-state ( state -- )
    {
        [ 0 >>d-height drop ]
        [ 0 >>r-height drop ]
        [ changed-locs>> clear-assoc ]
        [ locs>vregs>> clear-assoc ]
        [ vregs>locs>> clear-assoc ]
    } cleave ;

: sync-state ( -- )
    ! also: update height
    ! but first, sync outputs
    state get {
        [ save-changed-locs ]
        [ d-height>> dup 0 = [ drop ] [ ##inc-d ] if ]
        [ r-height>> dup 0 = [ drop ] [ ##inc-r ] if ]
        [ clear-state ]
    } cleave ;

: poison-state ( -- ) state get t >>poisoned? drop ;

GENERIC: translate-loc ( loc -- loc' )

M: ds-loc translate-loc n>> state get d-height>> + <ds-loc> ;

M: rs-loc translate-loc n>> state get r-height>> + <rs-loc> ;

! Abstract interpretation
GENERIC: visit ( insn -- )

! Instructions which don't have any effect on the stack
UNION: neutral-insn
    ##flushable
    ##effect
    ##branch
    ##loop-entry
    ##conditional-branch ;

M: neutral-insn visit , ;

: adjust-d ( n -- ) state get [ + ] change-d-height drop ;

M: ##inc-d visit n>> adjust-d ;

: adjust-r ( n -- ) state get [ + ] change-r-height drop ;

M: ##inc-r visit n>> adjust-r ;

: eliminate-peek ( dst src -- )
    ! the requested stack location is already in 'src'
    [ ##copy ] [ swap copies get set-at ] 2bi ;

M: ##peek visit
    dup
    [ dst>> ] [ loc>> translate-loc ] bi
    dup loc>vreg dup [ nip eliminate-peek drop ] [ drop record-peek , ] if ;

M: ##replace visit
    [ src>> resolve ] [ loc>> translate-loc ] bi
    record-replace ;

M: ##copy visit
    [ call-next-method ] [ record-copy ] bi ;

M: ##call visit
    [ call-next-method ] [ height>> [ adjust-d ] [ poison-state ] if* ] bi ;

M: ##fixnum-mul visit
    call-next-method -1 adjust-d ;

M: ##fixnum-add visit
    call-next-method -1 adjust-d ;

M: ##fixnum-sub visit
    call-next-method -1 adjust-d ;

! Instructions that poison the stack state
UNION: poison-insn
    ##jump
    ##return
    ##dispatch
    ##dispatch-label
    ##alien-callback
    ##callback-return
    ##fixnum-mul-tail
    ##fixnum-add-tail
    ##fixnum-sub-tail ;

M: poison-insn visit call-next-method poison-state ;

! Instructions that kill all live vregs
UNION: kill-vreg-insn
    poison-insn
    ##stack-frame
    ##call
    ##prologue
    ##epilogue
    ##fixnum-mul
    ##fixnum-add
    ##fixnum-sub
    ##alien-invoke
    ##alien-indirect ;

M: kill-vreg-insn visit sync-state , ;

: visit-alien-node ( node -- )
    params>> [ out-d>> length ] [ in-d>> length ] bi - adjust-d ;

M: ##alien-invoke visit
    [ call-next-method ] [ visit-alien-node ] bi ;

M: ##alien-indirect visit
    [ call-next-method ] [ visit-alien-node ] bi ;

! Basic blocks we still need to look at
SYMBOL: work-list

: add-to-work-list ( basic-block -- )
    work-list get push-front ;

! Maps basic-blocks to states
SYMBOLS: state-in state-out ;

: merge-states ( seq -- state )
    [ <state> ] [ first ] if-empty ;

: block-in-state ( bb -- states )
    predecessors>> state-out get '[ _ at ] map merge-states ;

: maybe-set-at ( value key assoc -- changed? )
    3dup at* [ = [ 3drop f ] [ set-at t ] if ] [ 2drop set-at t ] if ;

: set-block-in-state ( state b -- )
    state-in get set-at ;

: set-block-out-state ( bb state -- changed? )
    swap state-out get maybe-set-at ;

: finish-block ( bb state -- )
    [ drop ] [ set-block-out-state ] 2bi
    [ successors>> [ add-to-work-list ] each ] [ drop ] if ;

: visit-block ( bb -- )
    dup block-in-state
    [ swap set-block-in-state ] [
        state [
            [ [ [ [ visit ] each ] V{ } make ] change-instructions drop ]
            [ state get finish-block ]
            bi
        ] with-variable
    ] 2bi ;

: visit-blocks ( bb -- )
    reverse-post-order work-list get
    [ '[ _ push-front ] each ] [ [ visit-block ] slurp-deque ] bi ;

: optimize-stack ( cfg -- cfg )
    [
        H{ } clone copies set
        H{ } clone state-in set
        H{ } clone state-out set
        <hashed-dlist> work-list set
        dup entry>> visit-blocks
    ] with-scope ;

! To do:
! - implement merge-states
! - insert loads to convert partially available values into available values

! if any state is poisoned, then we need to sync in every predecessor that didn't sync
! and begin with a new state.

! if heights differ, throw an error.

! changed-locs is the union of the changed-locs of all predecessors
! locs>vregs: take the union, then for each predecessor, diff its locs>vregs against the union.
! those are the ones that need to be loaded in.
! think about phi insertion.