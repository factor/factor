! Copyright (C) 2009, 2010 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit kernel
locals math math.order sequences assocs namespaces vectors fry
arrays splitting compiler.cfg.def-use compiler.cfg
compiler.cfg.rpo compiler.cfg.predecessors compiler.cfg.renaming
compiler.cfg.instructions compiler.cfg.utilities ;
IN: compiler.cfg.branch-splitting

: clone-instructions ( insns -- insns' )
    [ clone dup rename-insn-temps ] map ;

: clone-basic-block ( bb -- bb' )
    ! The new block temporarily gets the same RPO number as the old one,
    ! until the next time RPO is computed. This is just to make
    ! 'back-edge?' work.
    <basic-block>
        swap
        {
            [ instructions>> clone-instructions >>instructions ]
            [ successors>> clone >>successors ]
            [ kill-block?>> >>kill-block? ]
            [ number>> >>number ]
        } cleave ;

: new-blocks ( bb -- copies )
    dup predecessors>> [
        [ clone-basic-block ] dip
        1vector >>predecessors
    ] with map ;

: update-predecessor-successors ( copies old-bb -- )
    [ predecessors>> swap ] keep
    '[ [ _ ] 2dip update-predecessors ] 2each ;

:: update-successor-predecessor ( copies old-bb succ -- )
    succ
    [ { old-bb } split copies join V{ } like ] change-predecessors
    drop ;

: update-successor-predecessors ( copies old-bb -- )
    dup successors>>
    [ update-successor-predecessor ] with with each ;

: split-branch ( bb -- )
    [ new-blocks ] keep
    [ update-predecessor-successors ]
    [ update-successor-predecessors ]
    2bi ;

UNION: irrelevant ##peek ##replace ##inc-d ##inc-r ;

: split-instructions? ( insns -- ? ) [ irrelevant? not ] count 5 <= ;

: short-tail-block? ( bb -- ? )
    [ successors>> empty? ] [ instructions>> length 2 = ] bi and ;

: short-block? ( bb -- ? )
    ! If block is empty, always split
    [ predecessors>> length ] [ instructions>> length 1 - ] bi * 10 <= ;

: cond-cond-block? ( bb -- ? )
    {
        [ predecessors>> length 2 = ]
        [ successors>> length 2 = ]
        [ instructions>> length 20 <= ]
    } 1&& ;

: split-branch? ( bb -- ? )
    dup loop-entry? [ drop f ] [
        dup predecessors>> length 1 <= [ drop f ] [
            {
                [ short-block? ]
                [ short-tail-block? ]
                [ cond-cond-block? ]
            } 1||
        ] if
    ] if ;

: split-branches ( cfg -- cfg' )
    needs-predecessors
    
    dup [
        dup split-branch? [ split-branch ] [ drop ] if
    ] each-basic-block

    cfg-changed ;
