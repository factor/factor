! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel namespaces math sequences fry grouping
sets make combinators compiler.cfg.copy-prop compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.registers compiler.cfg.rpo
compiler.cfg.hats compiler.cfg ;
IN: compiler.cfg.stack-analysis

! Convert stack operations to register operations

! If 'poisoned' is set, disregard height information. This is set if we don't have
! height change information for an instruction.
TUPLE: state locs>vregs actual-locs>vregs changed-locs ds-height rs-height poisoned? ;

: <state> ( -- state )
    state new
        H{ } clone >>locs>vregs
        H{ } clone >>actual-locs>vregs
        H{ } clone >>changed-locs
        0 >>ds-height
        0 >>rs-height ;

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

: record-replace ( src loc -- )
    dup changed-loc state get locs>vregs>> set-at ;

GENERIC: height-for ( loc -- n )

M: ds-loc height-for drop state get ds-height>> ;
M: rs-loc height-for drop state get rs-height>> ;

: (translate-loc) ( loc -- n height ) [ n>> ] [ height-for ] bi ; inline

GENERIC: translate-loc ( loc -- loc' )

M: ds-loc translate-loc (translate-loc) - <ds-loc> ;
M: rs-loc translate-loc (translate-loc) - <rs-loc> ;

GENERIC: untranslate-loc ( loc -- loc' )

M: ds-loc untranslate-loc (translate-loc) + <ds-loc> ;
M: rs-loc untranslate-loc (translate-loc) + <rs-loc> ;

: redundant-replace? ( vreg loc -- ? )
    dup untranslate-loc n>> 0 <
    [ 2drop t ] [ state get actual-locs>vregs>> at = ] if ;

: save-changed-locs ( state -- )
    [ changed-locs>> ] [ locs>vregs>> ] bi '[
        _ at swap 2dup redundant-replace?
        [ 2drop ] [ untranslate-loc ##replace ] if
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

! Abstract interpretation
GENERIC: visit ( insn -- )

! Instructions which don't have any effect on the stack
UNION: neutral-insn
    ##flushable
    ##effect ;

M: neutral-insn visit , ;

UNION: sync-if-back-edge
    ##branch
    ##conditional-branch
    ##compare-imm-branch
    ##dispatch
    ##loop-entry ;

SYMBOL: local-only?

t local-only? set-global

: back-edge? ( from to -- ? )
    [ number>> ] bi@ > ;

: sync-state? ( -- ? )
    basic-block get successors>>
    [ [ predecessors>> ] keep '[ _ back-edge? ] any? ] any?
    local-only? get or ;

M: sync-if-back-edge visit
    sync-state? [ sync-state ] when , ;

: adjust-d ( n -- ) state get [ + ] change-ds-height drop ;

M: ##inc-d visit [ , ] [ n>> adjust-d ] bi ;

: adjust-r ( n -- ) state get [ + ] change-rs-height drop ;

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
    [ call-next-method ] [ height>> adjust-d ] bi ;

! Instructions that poison the stack state
UNION: poison-insn
    ##jump
    ##return
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

! Maps basic-blocks to states
SYMBOLS: state-in state-out ;

: initial-state ( bb states -- state ) 2drop <state> ;

: single-predecessor ( bb states -- state ) nip first clone ;

ERROR: must-equal-failed seq ;

: must-equal ( seq -- elt )
    dup all-equal? [ first ] [ must-equal-failed ] if ;

: merge-heights ( state predecessors states -- state )
    nip
    [ [ ds-height>> ] map must-equal >>ds-height ]
    [ [ rs-height>> ] map must-equal >>rs-height ] bi ;

: insert-peek ( predecessor loc -- vreg )
    ! XXX critical edges
    '[ _ ^^peek ] add-instructions ;

: merge-loc ( predecessors locs>vregs loc -- vreg )
    ! Insert a ##phi in the current block where the input
    ! is the vreg storing loc from each predecessor block
    [ '[ [ _ ] dip at ] map ] keep
    '[ [ ] [ _ insert-peek ] ?if ] 2map
    dup all-equal? [ first ] [ ^^phi ] if ;

: (merge-locs) ( predecessors assocs -- assoc )
    dup [ keys ] map concat prune
    [ [ 2nip ] [ merge-loc ] 3bi ] with with
    H{ } map>assoc ;

: merge-locs ( state predecessors states -- state )
    [ locs>vregs>> ] map (merge-locs) >>locs>vregs ;

: merge-loc' ( locs>vregs loc -- vreg )
    ! Insert a ##phi in the current block where the input
    ! is the vreg storing loc from each predecessor block
    '[ [ _ ] dip at ] map
    dup all-equal? [ first ] [ drop f ] if ;

: merge-actual-locs ( state predecessors states -- state )
    nip
    [ actual-locs>vregs>> ] map
    dup [ keys ] map concat prune
    [ [ nip ] [ merge-loc' ] 2bi ] with
    H{ } map>assoc
    [ nip ] assoc-filter
    >>actual-locs>vregs ;

: merge-changed-locs ( state predecessors states -- state )
    nip [ changed-locs>> ] map assoc-combine >>changed-locs ;

ERROR: cannot-merge-poisoned states ;

: multiple-predecessors ( bb states -- state )
    dup [ not ] any? [
        [ <state> ] 2dip
        sift merge-heights
    ] [
        dup [ poisoned?>> ] any? [
            cannot-merge-poisoned
        ] [
            [ state new ] 2dip
            [ predecessors>> ] dip
            {
                [ merge-locs ]
                [ merge-actual-locs ]
                [ merge-heights ]
                [ merge-changed-locs ]
            } 2cleave
        ] if
    ] if ;

: merge-states ( bb states -- state )
    ! If any states are poisoned, save all registers
    ! to the stack in each branch
    dup length {
        { 0 [ initial-state ] }
        { 1 [ single-predecessor ] }
        [ drop multiple-predecessors ]
    } case ;

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
        H{ } clone copies set
        H{ } clone state-in set
        H{ } clone state-out set
        dup [ visit-block ] each-basic-block
    ] with-scope ;
