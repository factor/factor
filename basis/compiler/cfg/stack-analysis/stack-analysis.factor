! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel namespaces math sequences fry deques grouping
search-deques dlists sets make combinators compiler.cfg.copy-prop
compiler.cfg.def-use compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.rpo compiler.cfg.hats ;
IN: compiler.cfg.stack-analysis

! Convert stack operations to register operations

! If 'poisoned' is set, disregard height information. This is set if we don't have
! height change information for an instruction.
TUPLE: state locs>vregs actual-locs>vregs changed-locs d-height r-height poisoned? ;

: <state> ( -- state )
    state new
        H{ } clone >>locs>vregs
        H{ } clone >>actual-locs>vregs
        H{ } clone >>changed-locs
        0 >>d-height
        0 >>r-height ;

M: state clone
    call-next-method
        [ clone ] change-locs>vregs
        [ clone ] change-actual-locs>vregs
        [ clone ] change-changed-locs ;

: loc>vreg ( loc -- vreg ) state get locs>vregs>> at ;

: record-peek ( dst loc -- )
    state get [ locs>vregs>> set-at ] [ actual-locs>vregs>> set-at ] 3bi ;

: changed-loc ( loc -- )
    state get changed-locs>> conjoin ;

: changed-loc? ( loc -- ? )
    state get changed-locs>> key? ;

: record-replace ( src loc -- )
    dup changed-loc state get locs>vregs>> set-at ;

: redundant-replace? ( vreg loc -- ? )
    state get actual-locs>vregs>> at = ;

: save-changed-locs ( state -- )
    [ changed-locs>> ] [ locs>vregs>> ] bi '[
        _ at swap 2dup redundant-replace?
        [ 2drop ] [ ##replace ] if
    ] assoc-each ;

: clear-state ( state -- )
    [ locs>vregs>> clear-assoc ]
    [ actual-locs>vregs>> clear-assoc ]
    [ changed-locs>> clear-assoc ]
    tri ;

ERROR: poisoned-state state ;

: sync-state ( -- )
    state get {
        [ dup poisoned?>> [ poisoned-state ] [ drop ] if ]
        [ save-changed-locs ]
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
    ##conditional-branch
    ##compare-imm-branch ;

M: neutral-insn visit , ;

: adjust-d ( n -- ) state get [ + ] change-d-height drop ;

M: ##inc-d visit [ , ] [ n>> adjust-d ] bi ;

: adjust-r ( n -- ) state get [ + ] change-r-height drop ;

M: ##inc-r visit [ , ] [ n>> adjust-r ] bi ;

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

M: ##alien-callback visit , ;

M: ##dispatch-label visit , ;

! Basic blocks we still need to look at
SYMBOL: work-list

: add-to-work-list ( basic-block -- )
    work-list get push-front ;

! Maps basic-blocks to states
SYMBOLS: state-in state-out ;

: modify-instructions ( predecessor quot -- )
    [ instructions>> building ] dip
    '[ building get pop _ dip building get push ] with-variable ; inline

: with-state ( state quot -- )
    [ state ] dip with-variable ; inline

: handle-back-edge ( bb states -- )
    [ predecessors>> ] dip [
        dup [
            [ [ sync-state ] modify-instructions ] with-state
        ] [ 2drop ] if
    ] 2each ;

ERROR: must-equal-failed seq ;

: must-equal ( seq -- elt )
    dup all-equal? [ first ] [ must-equal-failed ] if ;

: merge-heights ( state predecessors states -- state )
    nip
    [ [ d-height>> ] map must-equal >>d-height ]
    [ [ r-height>> ] map must-equal >>r-height ] bi ;

: insert-peek ( predecessor loc -- vreg )
    ! XXX critical edges
    '[ _ ^^peek ] modify-instructions ;

SYMBOL: phi-nodes

: find-phis ( insns -- assoc )
    [ ##phi? ] filter [ [ inputs>> ] [ dst>> ] bi ] H{ } map>assoc ;

: insert-phi ( inputs -- vreg )
    phi-nodes get [ ^^phi ] cache ;

: merge-loc ( predecessors locs>vregs loc -- vreg )
    ! Insert a ##phi in the current block where the input
    ! is the vreg storing loc from each predecessor block
    [ '[ [ _ ] dip at ] map ] keep
    '[ [ ] [ _ insert-peek ] ?if ] 2map
    dup all-equal? [ first ] [ insert-phi ] if ;

: (merge-locs) ( predecessors assocs -- assoc )
    dup [ keys ] map concat prune
    [ [ 2nip ] [ merge-loc ] 3bi ] with with
    H{ } map>assoc ;

: merge-locs ( state predecessors states -- state )
    [ locs>vregs>> ] map (merge-locs) >>locs>vregs ;

: merge-actual-locs ( state predecessors states -- state )
    [ actual-locs>vregs>> ] map (merge-locs) >>actual-locs>vregs ;

: merge-changed-locs ( state predecessors states -- state )
    nip [ changed-locs>> ] map assoc-combine >>changed-locs ;

ERROR: cannot-merge-poisoned states ;

: merge-states ( bb states -- state )
    ! If any states are poisoned, save all registers
    ! to the stack in each branch
    dup length {
        { 0 [ 2drop <state> ] }
        { 1 [ nip first clone ] }
        [
            drop
            dup [ not ] any? [
                handle-back-edge <state>
            ] [
                dup [ poisoned?>> ] any? [
                    cannot-merge-poisoned
                ] [
                    [ state new ] 2dip
                    [ [ instructions>> find-phis phi-nodes set ] [ predecessors>> ] bi ] dip
                    {
                        [ merge-locs ]
                        [ merge-actual-locs ]
                        [ merge-heights ]
                        [ merge-changed-locs ]
                    } 2cleave
                ] if
            ] if
        ]
    } case ;

: block-in-state ( bb -- states )
    dup predecessors>> state-out get '[ _ at ] map merge-states ;

: maybe-set-at ( value key assoc -- changed? )
    3dup at* [ = [ 3drop f ] [ set-at t ] if ] [ 2drop set-at t ] if ;

: set-block-in-state ( state bb -- )
    [ clone ] dip state-in get set-at ;

: set-block-out-state ( state bb -- changed? )
    [ clone ] dip state-out get maybe-set-at ;

: finish-block ( bb state -- )
    [ drop ] [ swap set-block-out-state ] 2bi
    [ successors>> [ add-to-work-list ] each ] [ drop ] if ;

: visit-block ( bb -- )
    ! block-in-state may add phi nodes at the start of the basic block
    ! so we wrap the whole thing with a 'make'
    [
        dup block-in-state
        [ swap set-block-in-state ] [
            [
                [ instructions>> [ visit ] each ]
                [ state get finish-block ]
                [ ]
                tri
            ] with-state
        ] 2bi
    ] V{ } make >>instructions drop ;

: visit-blocks ( bb -- )
    reverse-post-order [ visit-block ] each ;

: optimize-stack ( cfg -- cfg )
    [
        H{ } clone copies set
        H{ } clone state-in set
        H{ } clone state-out set
        <hashed-dlist> work-list set
        dup entry>> visit-blocks
    ] with-scope ;
