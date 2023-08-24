! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.predecessors
compiler.cfg.renaming compiler.cfg.rpo compiler.cfg.utilities
grouping kernel namespaces sequences ;
IN: compiler.cfg.copy-prop

<PRIVATE

SYMBOL: changed?

SYMBOL: copies

! Initialized per-basic-block; a mapping from inputs to dst for
! eliminating redundant ##phi instructions
SYMBOL: phis

: resolve ( vreg -- vreg )
    copies get at ;

: (record-copy) ( dst src copies -- )
    swapd maybe-set-at [ changed? on ] when ; inline

: record-copy ( dst src -- )
    copies get (record-copy) ; inline

: record-copies ( seq -- )
    copies get '[ dup _ (record-copy) ] each ; inline

GENERIC: visit-insn ( insn -- )

M: ##copy visit-insn
    [ dst>> ] [ src>> resolve ] bi
    [ record-copy ] [ drop ] if* ;

: useless-phi ( dst inputs -- ) first record-copy ;

: redundant-phi ( dst inputs -- ) phis get at record-copy ;

: record-phi ( dst inputs -- )
    [ phis get set-at ] [ drop dup record-copy ] 2bi ;

M: ##phi visit-insn
    [ dst>> ] [ inputs>> values [ resolve ] map ] bi
    dup phis get key? [ redundant-phi ] [
        dup sift
        dup all-equal?
        [ nip useless-phi ]
        [ drop record-phi ] if
    ] if ;

M: vreg-insn visit-insn
    defs-vregs record-copies  ;

M: insn visit-insn drop ;

: (collect-copies) ( cfg -- )
    [
        phis get clear-assoc
        [ visit-insn ] each
    ] simple-analysis ;

: collect-copies ( cfg -- )
    H{ } clone copies set
    H{ } clone phis set
    '[
        changed? off
        _ (collect-copies)
        changed? get
    ] loop ;

GENERIC: update-insn ( insn -- keep? )

M: ##copy update-insn drop f ;

M: ##phi update-insn
    dup call-next-method drop
    [ dst>> ] [ inputs>> values ] bi [ = not ] with any? ;

M: vreg-insn update-insn rename-insn-uses t ;

M: insn update-insn drop t ;

: rename-copies ( cfg -- )
    copies get renamings set
    [ [ update-insn ] filter! ] simple-optimization ;

PRIVATE>

! Certain parts of the GVN pass may come together here and
! sabotage the correctness of the CFG:
!
!   1) compiler.cfg.gvn.comparisons:fold-branch may remove some
!   predecessors of a block (hence predecessors-changed at the
!   end of compiler.cfg.gvn:value-numbering).
!
!   2) At the moment in compiler.cfg.gvn:value-numbering,
!   ##phis with equivalent inputs (i.e., identical value
!   numbers) will be converted into ##copy insns; thus, some
!   ##copies may show up *before* ##phis within a basic block,
!   even though ##phis should come at the very beginning of a
!   block.
!
! Thus, the call to needs-predecessors in copy-propagation may
! wind up failing to prune dead inputs to particular ##phis in
! a block (if they're preceded by ##copies).  However,
! copy-propagation will remove the ##copies that
! value-numbering introduces.  So, a band-aid solution is to
! suffix a predecessors-changed to copy-propagation, so that
! future calls to needs-predecessors (particularly in
! compiler.cfg.dce:eliminate-dead-code) will finally correct
! the ##phi nodes left over after value-numbering.
!
! A better solution (and the eventual goal) would be to have
! value-numbering subsume copy-propagation, thus eliminating
! this pass altogether.

USE: compiler.cfg

: copy-propagation ( cfg -- )
    {
        needs-predecessors
        collect-copies
        rename-copies
        predecessors-changed
    } apply-passes ;
