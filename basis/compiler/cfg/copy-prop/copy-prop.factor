! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces assocs accessors sequences grouping
combinators compiler.cfg.rpo compiler.cfg.renaming
compiler.cfg.instructions compiler.cfg.predecessors ;
IN: compiler.cfg.copy-prop

! The first three definitions are also used in compiler.cfg.alias-analysis.
SYMBOL: copies

! Initialized per-basic-block; a mapping from inputs to dst for eliminating
! redundant phi instructions
SYMBOL: phis

: resolve ( vreg -- vreg )
    copies get ?at drop ;

: (record-copy) ( dst src -- )
    swap copies get set-at ; inline

: record-copy ( ##copy -- )
    [ dst>> ] [ src>> resolve ] bi (record-copy) ; inline

<PRIVATE

GENERIC: visit-insn ( insn -- )

M: ##copy visit-insn record-copy ;

: useless-phi ( dst inputs -- ) first (record-copy) ;

: redundant-phi ( dst inputs -- ) phis get at (record-copy) ;

: record-phi ( dst inputs -- ) phis get set-at ;

M: ##phi visit-insn
    [ dst>> ] [ inputs>> values [ resolve ] map ] bi
    {
        { [ dup all-equal? ] [ useless-phi ] }
        { [ dup phis get key? ] [ redundant-phi ] }
        [ record-phi ]
    } cond ;

M: insn visit-insn drop ;

: collect-copies ( cfg -- )
    H{ } clone copies set
    [
        H{ } clone phis set
        instructions>> [ visit-insn ] each
    ] each-basic-block ;

GENERIC: update-insn ( insn -- keep? )

M: ##copy update-insn drop f ;

M: ##phi update-insn
    dup dst>> copies get key? [ drop f ] [ call-next-method ] if ;

M: insn update-insn rename-insn-uses t ;

: rename-copies ( cfg -- )
    copies get dup assoc-empty? [ 2drop ] [
        renamings set
        [
            instructions>> [ update-insn ] filter! drop
        ] each-basic-block
    ] if ;

PRIVATE>

: copy-propagation ( cfg -- cfg' )
    needs-predecessors

    [ collect-copies ]
    [ rename-copies ]
    [ ]
    tri ;
