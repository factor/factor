! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces assocs accessors sequences
compiler.cfg.rpo compiler.cfg.renaming compiler.cfg.instructions ;
IN: compiler.cfg.copy-prop

! The first three definitions are also used in compiler.cfg.alias-analysis.
SYMBOL: copies

: resolve ( vreg -- vreg )
    [ copies get at ] keep or ;

: record-copy ( ##copy -- )
    [ src>> resolve ] [ dst>> ] bi copies get set-at ; inline

<PRIVATE

GENERIC: visit-insn ( insn -- )

M: ##copy visit-insn record-copy ;

M: ##phi visit-insn inputs>> values [ resolve ] map all-equal? [ "BLAH!" print ] when ;

M: insn visit-insn drop ;

: collect-copies ( cfg -- )
    H{ } clone copies set
    [
        instructions>>
        [ visit-insn ] each
    ] each-basic-block ;

GENERIC: update-insn ( insn -- keep? )

M: ##copy update-insn drop f ;

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
