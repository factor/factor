! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel compiler.cfg.instructions compiler.cfg.rpo sequences
combinators.short-circuit accessors ;
IN: compiler.cfg.checker

ERROR: last-insn-not-a-jump insn ;

: check-basic-block ( bb -- )
    peek dup {
        [ ##branch? ]
        [ ##conditional-branch? ]
        [ ##compare-imm-branch? ]
        [ ##return? ]
        [ ##callback-return? ]
        [ ##jump? ]
        [ ##call? ]
        [ ##dispatch-label? ]
    } 1|| [ drop ] [ last-insn-not-a-jump ] if ;

: check-rpo ( rpo -- )
    [ instructions>> check-basic-block ] each ;

: check-cfg ( cfg -- )
    entry>> reverse-post-order check-rpo ;