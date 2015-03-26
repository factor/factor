! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators.short-circuit compiler.cfg
compiler.cfg.instructions compiler.cfg.rpo cpu.architecture fry
kernel locals make math namespaces sequences sets ;
IN: compiler.cfg.utilities

: block>cfg ( bb -- cfg )
    cfg new swap >>entry ;

: insns>block ( insns n -- bb )
    <basic-block> swap >>number swap V{ } like >>instructions ;

: insns>cfg ( insns -- cfg )
    0 insns>block block>cfg ;

: back-edge? ( from to -- ? )
    [ number>> ] bi@ >= ;

: loop-entry? ( bb -- ? )
    dup predecessors>> [ swap back-edge? ] with any? ;

: empty-block? ( bb -- ? )
    instructions>> {
        [ length 1 = ]
        [ first ##branch? ]
    } 1&& ;

: (skip-empty-blocks) ( visited bb -- visited bb' )
    dup empty-block? [
        dup pick ?adjoin [
            successors>> first (skip-empty-blocks)
        ] when
    ] when ; inline recursive

: skip-empty-blocks ( bb -- bb' )
    [ HS{ } clone ] dip (skip-empty-blocks) nip ;

:: update-predecessors ( from to bb -- )
    ! Whenever 'from' appears in the list of predecessors of 'to'
    ! replace it with 'bb'.
    to predecessors>> [ dup from eq? [ drop bb ] when ] map! drop ;

:: update-successors ( from to bb -- )
    ! Whenever 'to' appears in the list of successors of 'from'
    ! replace it with 'bb'.
    from successors>> [ dup to eq? [ drop bb ] when ] map! drop ;

:: insert-basic-block ( from to insns -- )
    insns f insns>block :> bb
    V{ from } bb predecessors<<
    V{ to } bb successors<<
    from to bb update-predecessors
    from to bb update-successors ;

: add-instructions ( bb quot -- )
    [ instructions>> building ] dip '[
        building get pop
        [ @ ] dip
        ,
    ] with-variable ; inline

: has-phis? ( bb -- ? )
    instructions>> first ##phi? ;

: cfg-has-phis? ( cfg -- ? )
    post-order [ has-phis? ] any? ;

: if-has-phis ( ..a bb quot: ( ..a bb -- ..b ) -- ..b )
    [ dup has-phis? ] dip [ drop ] if ; inline

: each-phi ( ... bb quot: ( ... ##phi -- ... ) -- ... )
    [ instructions>> ] dip
    '[ dup ##phi? [ @ t ] [ drop f ] if ] all? drop ; inline

: each-non-phi ( ... bb quot: ( ... insn -- ... ) -- ... )
    [ instructions>> ] dip
    '[ dup ##phi? [ drop ] _ if ] each ; inline

: predecessor ( bb -- pred )
    predecessors>> first ; inline

: <copy> ( dst src -- insn )
    any-rep ##copy new-insn ;

: apply-passes ( obj passes -- )
    [ execute( x -- ) ] with each ;

: connect-bbs ( from to -- )
    [ [ successors>> ] dip suffix! drop ]
    [ predecessors>> swap suffix! drop ] 2bi ;

: connect-Nto1-bbs ( froms to -- )
    '[ _ connect-bbs ] each ;

: make-edges ( block-map edgelist -- )
    [ [ of ] with map first2 connect-bbs ] with each ;
