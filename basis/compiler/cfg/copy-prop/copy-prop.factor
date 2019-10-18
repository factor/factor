! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sets kernel namespaces assocs accessors sequences grouping
combinators fry compiler.cfg.def-use compiler.cfg.rpo
compiler.cfg.renaming compiler.cfg.instructions
compiler.cfg.predecessors ;
FROM: namespaces => set ;
IN: compiler.cfg.copy-prop

<PRIVATE

SYMBOL: changed?

SYMBOL: copies

! Initialized per-basic-block; a mapping from inputs to dst for
! eliminating redundant ##phi instructions
SYMBOL: phis

: resolve ( vreg -- vreg )
    copies get at ;

: record-copy ( dst src -- )
    swap copies get maybe-set-at [ changed? on ] when ; inline

GENERIC: visit-insn ( insn -- )

M: ##copy visit-insn
    [ dst>> ] [ src>> resolve ] bi
    dup [ record-copy ] [ 2drop ] if ;

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
    defs-vregs [ dup record-copy ] each ;

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

: copy-propagation ( cfg -- cfg' )
    needs-predecessors

    dup collect-copies
    dup rename-copies ;
