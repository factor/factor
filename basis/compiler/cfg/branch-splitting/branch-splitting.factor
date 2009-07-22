! Copyright (C) 2009 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit kernel math math.order
sequences assocs namespaces vectors fry arrays splitting
compiler.cfg.def-use compiler.cfg compiler.cfg.rpo
compiler.cfg.renaming compiler.cfg.instructions compiler.cfg.utilities ;
IN: compiler.cfg.branch-splitting

: clone-renamings ( insns -- assoc )
    [ defs-vregs ] map concat [ dup fresh-vreg ] H{ } map>assoc ;

: clone-instructions ( insns -- insns' )
    dup clone-renamings renamings [
        [
            clone
            dup rename-insn-defs
            dup rename-insn-uses
            dup fresh-insn-temps
        ] map
    ] with-variable ;

: clone-basic-block ( bb -- bb' )
    ! The new block gets the same RPO number as the old one.
    ! This is just to make 'back-edge?' work.
    <basic-block>
        swap
        [ instructions>> clone-instructions >>instructions ]
        [ successors>> clone >>successors ]
        [ number>> >>number ]
        tri ;

: new-blocks ( bb -- copies )
    dup predecessors>> [
        [ clone-basic-block ] dip
        1vector >>predecessors
    ] with map ;

: update-predecessor-successor ( pred copy old-bb -- )
    '[
        [ _ _ 3dup nip eq? [ drop nip ] [ 2drop ] if ] map
    ] change-successors drop ;

: update-predecessor-successors ( copies old-bb -- )
    [ predecessors>> swap ] keep
    '[ _ update-predecessor-successor ] 2each ;

: update-successor-predecessor ( copies old-bb succ -- )
    [
        swap 1array split swap join V{ } like
    ] change-predecessors drop ;

: update-successor-predecessors ( copies old-bb -- )
    dup successors>> [
        update-successor-predecessor
    ] with with each ;

: split-branch ( bb -- )
    [ new-blocks ] keep
    [ update-predecessor-successors ]
    [ update-successor-predecessors ]
    2bi ;

UNION: irrelevant ##peek ##replace ##inc-d ##inc-r ;

: split-instructions? ( insns -- ? )
    [ [ irrelevant? not ] count 5 <= ]
    [ last ##fixnum-overflow? not ]
    bi and ;

: split-branch? ( bb -- ? )
    {
        [ dup successors>> [ back-edge? ] with any? not ]
        [ predecessors>> length 2 4 between? ]
        [ instructions>> split-instructions? ]
    } 1&& ;

: split-branches ( cfg -- cfg' )
    dup [
        dup split-branch? [ split-branch ] [ drop ] if
    ] each-basic-block
    cfg-changed ;
