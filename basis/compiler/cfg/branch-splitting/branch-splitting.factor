! Copyright (C) 2009, 2011 Doug Coleman, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.short-circuit
compiler.cfg compiler.cfg.instructions compiler.cfg.predecessors
compiler.cfg.renaming compiler.cfg.rpo compiler.cfg.utilities
deques dlists kernel math namespaces sequences sets vectors ;
IN: compiler.cfg.branch-splitting

: clone-instructions ( insns -- insns' )
    [ clone dup rename-insn-temps ] map ;

: clone-basic-block ( bb -- bb' )
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
        [ clone-basic-block ] [ 1vector ] bi*
        >>predecessors
    ] with map ;

: update-predecessor-successors ( copies old-bb -- )
    [ predecessors>> swap ] keep
    '[ [ _ ] dip update-successors ] 2each ;

:: update-successor-predecessor ( copies old-bb succ -- )
    succ predecessors>> dup >array :> ( preds preds' )
    preds delete-all
    preds' [
        dup old-bb eq?
        [ drop copies preds push-all ] [ preds push ] if
    ] each ;

: update-successor-predecessors ( copies old-bb -- )
    dup successors>>
    [ update-successor-predecessor ] 2with each ;

: split-branch ( bb -- )
    [ new-blocks ] keep
    [ update-predecessor-successors ]
    [ update-successor-predecessors ]
    2bi ;

UNION: irrelevant ##peek ##replace ##inc ;

: split-instructions? ( insns -- ? ) [ irrelevant? not ] count 5 <= ;

: short-tail-block? ( bb -- ? )
    { [ successors>> empty? ] [ instructions>> length 2 = ] } 1&& ;

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

SYMBOL: worklist
SYMBOL: visited

: add-to-worklist ( bb -- )
    dup visited get ?adjoin
    [ worklist get push-front ] [ drop ] if ;

: init-worklist ( cfg -- )
    <dlist> worklist namespaces:set
    HS{ } clone visited namespaces:set
    entry>> add-to-worklist ;

: split-branches ( cfg -- )
    {
        [ needs-predecessors ]
        [ init-worklist ]
        [
            ! For back-edge?
            post-order drop
            worklist get [
                dup split-branch? [ dup split-branch ] when
                successors>> [ add-to-worklist ] each
            ] slurp-deque
        ]
        [ cfg-changed ]
    } cleave ;
