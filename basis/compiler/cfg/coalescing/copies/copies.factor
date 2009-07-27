! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators fry kernel namespaces sequences
compiler.cfg.def-use compiler.cfg.dominance compiler.cfg.instructions
compiler.cfg.renaming ;
IN: compiler.cfg.coalescing.copies

SYMBOLS: stacks visited pushed ;

: compute-renaming ( insn -- assoc )
    uses-vregs stacks get
    '[ dup dup _ at [ nip last ] unless-empty ]
    H{ } map>assoc ;

: rename-operands ( bb -- )
    instructions>> [
        dup ##phi? [ drop ] [
            dup compute-renaming renamings set
            [ rename-insn-uses ] [ rename-insn-defs ] bi
        ] if
    ] each ;

: schedule-copies ( bb -- )
    ! FIXME
    drop ;

: pop-stacks ( -- )
    pushed get stacks get '[ drop _ at pop* ] assoc-each ;

: (insert-copies) ( bb -- )
    H{ } clone pushed [
        [ rename-operands ]
        [ schedule-copies ]
        [ dom-children [ (insert-copies) ] each ] tri
        pop-stacks
    ] with-variable ;

: insert-copies ( cfg -- )
    entry>> (insert-copies) ;