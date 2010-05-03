! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.short-circuit
cpu.architecture kernel layouts locals make math namespaces sequences
sets vectors fry arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.rpo compiler.utilities ;
IN: compiler.cfg.utilities

PREDICATE: kill-block < basic-block
    instructions>> {
        [ length 2 >= ]
        [ penultimate kill-vreg-insn? ]
    } 1&& ;

: back-edge? ( from to -- ? )
    [ number>> ] bi@ >= ;

: loop-entry? ( bb -- ? )
    dup predecessors>> [ swap back-edge? ] with any? ;

: empty-block? ( bb -- ? )
    instructions>> {
        [ length 1 = ]
        [ first ##branch? ]
    } 1&& ;

SYMBOL: visited

: (skip-empty-blocks) ( bb -- bb' )
    dup visited get key? [
        dup empty-block? [
            dup visited get conjoin
            successors>> first (skip-empty-blocks)
        ] when
    ] unless ;

: skip-empty-blocks ( bb -- bb' )
    H{ } clone visited [ (skip-empty-blocks) ] with-variable ;

:: update-predecessors ( from to bb -- )
    ! Update 'to' predecessors for insertion of 'bb' between
    ! 'from' and 'to'.
    to predecessors>> [ dup from eq? [ drop bb ] when ] map! drop ;

:: update-successors ( from to bb -- )
    ! Update 'from' successors for insertion of 'bb' between
    ! 'from' and 'to'.
    from successors>> [ dup to eq? [ drop bb ] when ] map! drop ;

:: insert-basic-block ( from to insns -- )
    ! Insert basic block on the edge between 'from' and 'to'.
    <basic-block> :> bb
    insns V{ } like bb (>>instructions)
    V{ from } bb (>>predecessors)
    V{ to } bb (>>successors)
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
    any-rep \ ##copy new-insn ;
