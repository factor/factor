! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces assocs accessors sequences
compiler.cfg.rpo compiler.cfg.renaming compiler.cfg.instructions ;
IN: compiler.cfg.copy-prop

! The first three definitions are also used in compiler.cfg.alias-analysis.
SYMBOL: copies

: resolve ( vreg -- vreg )
    [ copies get at ] keep or ;

: record-copy ( insn -- )
    [ src>> resolve ] [ dst>> ] bi copies get set-at ; inline

: collect-copies ( cfg -- )
    H{ } clone copies set
    [
        instructions>>
        [ dup ##copy? [ record-copy ] [ drop ] if ] each
    ] each-basic-block ;

: rename-copies ( cfg -- )
    copies get dup assoc-empty? [ 2drop ] [
        renamings set
        [
            instructions>>
            [ dup ##copy? [ drop f ] [ rename-insn-uses t ] if ] filter-here
        ] each-basic-block
    ] if ;

: copy-propagation ( cfg -- cfg' )
    [ collect-copies ]
    [ rename-copies ]
    [ ]
    tri ;
