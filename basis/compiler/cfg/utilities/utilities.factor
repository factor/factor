! Copyright (C) 2008, 2009 Slava Pestov.
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

:: insert-basic-block ( froms to bb -- )
    bb froms V{ } like >>predecessors drop
    bb to 1vector >>successors drop
    to predecessors>> [ dup froms memq? [ drop bb ] when ] map! drop
    froms [ successors>> [ dup to eq? [ drop bb ] when ] map! drop ] each ;

: add-instructions ( bb quot -- )
    [ instructions>> building ] dip '[
        building get pop
        [ @ ] dip
        ,
    ] with-variable ; inline

: <simple-block> ( insns -- bb )
    <basic-block>
    swap >vector
    \ ##branch new-insn over push
    >>instructions ;

: insert-simple-basic-block ( from to insns -- )
    [ 1vector ] 2dip <simple-block> insert-basic-block ;

: has-phis? ( bb -- ? )
    instructions>> first ##phi? ;

: cfg-has-phis? ( cfg -- ? )
    post-order [ has-phis? ] any? ;

: if-has-phis ( bb quot: ( bb -- ) -- )
    [ dup has-phis? ] dip [ drop ] if ; inline

: each-phi ( bb quot: ( ##phi -- ) -- )
    [ instructions>> ] dip
    '[ dup ##phi? [ @ t ] [ drop f ] if ] all? drop ; inline

: each-non-phi ( bb quot: ( insn -- ) -- )
    [ instructions>> ] dip
    '[ dup ##phi? [ drop ] _ if ] each ; inline

: predecessor ( bb -- pred )
    predecessors>> first ; inline

