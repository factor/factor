! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences combinators combinators.short-circuit
classes vectors compiler.cfg compiler.cfg.instructions compiler.cfg.rpo ;
IN: compiler.cfg.useless-blocks

: update-predecessor-for-delete ( bb -- )
    ! We have to replace occurrences of bb with bb's successor
    ! in bb's predecessor's list of successors.
    dup predecessors>> first [
        [
            2dup eq? [ drop successors>> first ] [ nip ] if
        ] with map
    ] change-successors drop ;

: update-successor-for-delete ( bb -- )
    ! We have to replace occurrences of bb with bb's predecessor
    ! in bb's sucessor's list of predecessors.
    dup successors>> first [
        [
            2dup eq? [ drop predecessors>> first ] [ nip ] if
        ] with map
    ] change-predecessors drop ;

: delete-basic-block ( bb -- )
    [ update-predecessor-for-delete ]
    [ update-successor-for-delete ]
    bi ;

: delete-basic-block? ( bb -- ? )
    {
        [ instructions>> length 1 = ]
        [ predecessors>> length 1 = ]
        [ successors>> length 1 = ]
        [ instructions>> first ##branch? ]
    } 1&& ;

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
