! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays vectors accessors assocs sets
namespaces math make fry sequences
combinators.short-circuit
compiler.cfg.instructions ;
IN: compiler.cfg

TUPLE: basic-block < identity-tuple
{ id integer }
number
{ instructions vector }
{ successors vector }
{ predecessors vector } ;

M: basic-block hashcode* nip id>> ;

: <basic-block> ( -- bb )
    basic-block new
        V{ } clone >>instructions
        V{ } clone >>successors
        V{ } clone >>predecessors
        \ basic-block counter >>id ;

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

: add-instructions ( bb quot -- )
    [ instructions>> building ] dip '[
        building get pop
        _ dip
        building get push
    ] with-variable ; inline

: back-edge? ( from to -- ? )
    [ number>> ] bi@ > ;

TUPLE: cfg { entry basic-block } word label spill-counts post-order ;

: <cfg> ( entry word label -- cfg ) f f cfg boa ;

TUPLE: mr { instructions array } word label ;

: <mr> ( instructions word label -- mr )
    mr new
        swap >>label
        swap >>word
        swap >>instructions ;
