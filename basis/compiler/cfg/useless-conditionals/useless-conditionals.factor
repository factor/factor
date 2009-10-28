! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences math combinators combinators.short-circuit
classes vectors compiler.cfg compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.utilities ;
IN: compiler.cfg.useless-conditionals

: delete-conditional? ( bb -- ? )
    {
        [
            instructions>> last class {
                ##compare-branch
                ##compare-imm-branch
                ##compare-float-ordered-branch
                ##compare-float-unordered-branch
            } member-eq?
        ]
        [ successors>> first2 [ skip-empty-blocks ] bi@ eq? ]
    } 1&& ;

: delete-conditional ( bb -- )
    [ first skip-empty-blocks 1vector ] change-successors
    instructions>> [ pop* ] [ [ \ ##branch new-insn ] dip push ] bi ;

: delete-useless-conditionals ( cfg -- cfg' )
    dup [
        dup delete-conditional? [ delete-conditional ] [ drop ] if
    ] each-basic-block
    
    cfg-changed predecessors-changed ;
