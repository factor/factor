! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit compiler.cfg
compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.utilities kernel sequences vectors ;
IN: compiler.cfg.useless-conditionals

: delete-conditional? ( bb -- ? )
    {
        [
            instructions>> last {
                [ ##compare-branch? ]
                [ ##compare-imm-branch? ]
                [ ##compare-integer-branch? ]
                [ ##compare-integer-imm-branch? ]
                [ ##compare-float-ordered-branch? ]
                [ ##compare-float-unordered-branch? ]
            } 1||
        ]
        [ successors>> first2 [ skip-empty-blocks ] bi@ eq? ]
    } 1&& ;

: delete-conditional ( bb -- )
    [ first skip-empty-blocks 1vector ] change-successors
    instructions>> [ pop* ] [ [ ##branch new-insn ] dip push ] bi ;

: delete-useless-conditionals ( cfg -- )
    [
        [
            dup delete-conditional? [ delete-conditional ] [ drop ] if
        ] each-basic-block
    ]
    [ cfg-changed ] [ predecessors-changed ] tri ;
