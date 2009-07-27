! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces assocs accessors sequences grouping
compiler.cfg.rpo compiler.cfg.renaming compiler.cfg.instructions ;
IN: compiler.cfg.copy-prop

! The first three definitions are also used in compiler.cfg.alias-analysis.
SYMBOL: copies

: resolve ( vreg -- vreg )
    copies get ?at drop ;

: (record-copy) ( dst src -- )
    swap copies get set-at ; inline

: record-copy ( ##copy -- )
    [ dst>> ] [ src>> resolve ] bi (record-copy) ; inline

<PRIVATE

GENERIC: visit-insn ( insn -- )

M: ##copy visit-insn record-copy ;

M: ##phi visit-insn
    [ dst>> ] [ inputs>> values [ resolve ] map ] bi
    dup all-equal? [ first (record-copy) ] [ 2drop ] if ;

M: insn visit-insn drop ;

: collect-copies ( cfg -- )
    H{ } clone copies set
    [
        instructions>>
        [ visit-insn ] each
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
            instructions>>
            [ update-insn ] filter-here
        ] each-basic-block
    ] if ;

PRIVATE>

: copy-propagation ( cfg -- cfg' )
    [ collect-copies ]
    [ rename-copies ]
    [ ]
    tri ;
