! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.short-circuit
compiler.cfg compiler.cfg.instructions cpu.architecture kernel
layouts locals make math namespaces sequences sets vectors fry ;
IN: compiler.cfg.utilities

: value-info-small-fixnum? ( value-info -- ? )
    literal>> {
        { [ dup fixnum? ] [ tag-fixnum small-enough? ] }
        [ drop f ]
    } cond ;

: value-info-small-tagged? ( value-info -- ? )
    dup literal?>> [
        literal>> {
            { [ dup fixnum? ] [ tag-fixnum small-enough? ] }
            { [ dup not ] [ drop t ] }
            [ drop f ]
        } cond
    ] [ drop f ] if ;

: set-basic-block ( basic-block -- )
    [ basic-block set ] [ instructions>> building set ] bi ;

: begin-basic-block ( -- )
    <basic-block> basic-block get [
        dupd successors>> push
    ] when*
    set-basic-block ;

: end-basic-block ( -- )
    building off
    basic-block off ;

: emit-primitive ( node -- )
    word>> ##call ##branch begin-basic-block ;

: with-branch ( quot -- final-bb )
    [
        begin-basic-block
        call
        basic-block get dup [ ##branch ] when
    ] with-scope ; inline

: emit-conditional ( branches -- )
    end-basic-block
    begin-basic-block
    basic-block get '[ [ _ swap successors>> push ] when* ] each ;

: back-edge? ( from to -- ? )
    [ number>> ] bi@ >= ;

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

! assoc mapping predecessors to sequences
SYMBOL: added-instructions

: add-instructions ( predecessor quot -- )
    [
        added-instructions get
        [ drop V{ } clone ] cache
        building
    ] dip with-variable ; inline

:: insert-basic-block ( from to bb -- )
    bb from 1vector >>predecessors drop
    bb to 1vector >>successors drop
    to predecessors>> [ dup from eq? [ drop bb ] when ] change-each
    from successors>> [ dup to eq? [ drop bb ] when ] change-each ;

: <simple-block> ( insns -- bb )
    <basic-block>
    swap >vector
    \ ##branch new-insn over push
    >>instructions ;

: insert-basic-blocks ( bb -- )
    [ added-instructions get ] dip
    '[ [ _ ] dip <simple-block> insert-basic-block ] assoc-each ;
