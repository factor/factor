! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences combinators classes vectors
compiler.cfg compiler.cfg.instructions compiler.cfg.rpo ;
IN: compiler.cfg.useless-blocks

: update-predecessor-for-delete ( bb -- )
    dup predecessors>> first [
        [
            2dup eq? [ drop successors>> first ] [ nip ] if
        ] with map
    ] change-successors drop ;

: update-successor-for-delete ( bb -- )
    [ predecessors>> first ]
    [ successors>> first predecessors>> ]
    bi set-first ;

: delete-basic-block ( bb -- )
    [ update-predecessor-for-delete ]
    [ update-successor-for-delete ]
    bi ;

: delete-basic-block? ( bb -- ? )
    {
        { [ dup instructions>> length 1 = not ] [ f ] }
        { [ dup predecessors>> length 1 = not ] [ f ] }
        { [ dup successors>> length 1 = not ] [ f ] }
        { [ dup instructions>> first ##branch? not ] [ f ] }
        [ t ]
    } cond nip ;

: delete-useless-blocks ( cfg -- )
    [
        dup delete-basic-block? [ delete-basic-block ] [ drop ] if
    ] each-basic-block ;

: delete-conditional? ( bb -- ? )
    dup instructions>> [ drop f ] [
        peek class {
            ##compare-branch
            ##compare-imm-branch
            ##compare-float-branch
        } memq? [ successors>> first2 eq? ] [ drop f ] if
    ] if-empty ;

: delete-conditional ( bb -- )
    dup successors>> first 1vector >>successors
    [ but-last f \ ##branch boa suffix ] change-instructions
    drop ;

: delete-useless-conditionals ( cfg -- )
    [
        dup delete-conditional? [ delete-conditional ] [ drop ] if
    ] each-basic-block ;
