! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.loop-detection compiler.cfg.registers
compiler.cfg.representations.preferred compiler.cfg.rpo
compiler.cfg.utilities compiler.utilities cpu.architecture
deques dlists fry kernel locals math namespaces sequences sets ;
FROM: namespaces => set ;
IN: compiler.cfg.representations.selection

! For every vreg, compute possible representations.
SYMBOL: possibilities

: possible ( vreg -- reps ) possibilities get at ;

: compute-possibilities ( cfg -- )
    H{ } clone [ '[ swap _ adjoin-at ] with-vreg-reps ] keep
    [ members ] assoc-map possibilities set ;

! Compute vregs which must remain tagged for their lifetime.
SYMBOL: always-boxed

:: (compute-always-boxed) ( vreg rep assoc -- )
    rep tagged-rep eq? [
        tagged-rep vreg assoc set-at
    ] when ;

: compute-always-boxed ( cfg -- assoc )
    H{ } clone [
        '[
            [
                dup ##load-reference?
                [ drop ] [ [ _ (compute-always-boxed) ] each-def-rep ] if
            ] each-non-phi
        ] each-basic-block
    ] keep ;

! For every vreg, compute the cost of keeping it in every possible
! representation.

! Cost map maps vreg to representation to cost.
SYMBOL: costs

: init-costs ( -- )
    possibilities get [ drop H{ } clone ] assoc-map costs set ;

: record-possibility ( rep vreg -- )
    costs get at [ 0 or ] change-at ;

: increase-cost ( rep vreg -- )
    ! Increase cost of keeping vreg in rep, making a choice of rep less
    ! likely.
    costs get at [ 0 or basic-block get loop-nesting-at 1 + + ] change-at ;

: maybe-increase-cost ( possible vreg preferred -- )
    pick eq? [ record-possibility ] [ increase-cost ] if ;

: representation-cost ( vreg preferred -- )
    ! 'preferred' is a representation that the instruction can accept with no cost.
    ! So, for each representation that's not preferred, increase the cost of keeping
    ! the vreg in that representation.
    [ drop possible ]
    [ '[ _ _ maybe-increase-cost ] ]
    2bi each ;

GENERIC: compute-insn-costs ( insn -- )

! There's no cost to converting a constant's representation
M: ##load-integer compute-insn-costs drop ;
M: ##load-reference compute-insn-costs drop ;

M: insn compute-insn-costs [ representation-cost ] each-rep ;

: compute-costs ( cfg -- costs )
    init-costs
    [
        [ basic-block set ]
        [
            [
                compute-insn-costs
            ] each-non-phi
        ] bi
    ] each-basic-block
    costs get ;

! For every vreg, compute preferred representation, that minimizes costs.
: minimize-costs ( costs -- representations )
    [ nip assoc-empty? not ] assoc-filter
    [ >alist alist-min first ] assoc-map ;

: compute-representations ( cfg -- )
    [ compute-costs minimize-costs ]
    [ compute-always-boxed ]
    bi assoc-union
    representations set ;

! PHI nodes require special treatment
! If the output of a phi instruction is only used as the input to another
! phi instruction, then we want to use the same representation for both
! if possible.
SYMBOL: phis

: collect-phis ( cfg -- )
    H{ } clone phis set
    [
        phis get
        '[ [ inputs>> values ] [ dst>> ] bi _ set-at ] each-phi
    ] each-basic-block ;

SYMBOL: work-list

: add-to-work-list ( vregs -- )
    work-list get push-all-front ;

: rep-assigned ( vregs -- vregs' )
    representations get '[ _ key? ] filter ;

: rep-not-assigned ( vregs -- vregs' )
    representations get '[ _ key? not ] filter ;

: add-ready-phis ( -- )
    phis get keys rep-assigned add-to-work-list ;

: process-phi ( dst -- )
    ! If dst = phi(src1,src2,...) and dst's representation has been
    ! determined, assign that representation to each one of src1,...
    ! that does not have a representation yet, and process those, too.
    dup phis get at* [
        [ rep-of ] [ rep-not-assigned ] bi*
        [ [ set-rep-of ] with each ] [ add-to-work-list ] bi
    ] [ 2drop ] if ;

: remaining-phis ( -- )
    phis get keys rep-not-assigned { } assert-sequence= ;

: process-phis ( -- )
    <hashed-dlist> work-list set
    add-ready-phis
    work-list get [ process-phi ] slurp-deque
    remaining-phis ;

: compute-phi-representations ( cfg -- )
    collect-phis process-phis ;
