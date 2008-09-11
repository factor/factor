! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces assocs sequences sets fry ;
IN: compiler.cfg

TUPLE: procedure entry word label ;

C: <procedure> procedure

! - "id" is a globally unique id used for hashcode*.
! - "number" is assigned by linearization.
TUPLE: basic-block < identity-tuple
id
number
label
instructions
successors
predecessors ;

SYMBOL: next-block-id

: <basic-block> ( -- basic-block )
    basic-block new
        next-block-id counter >>id
        V{ } clone >>instructions
        V{ } clone >>successors
        V{ } clone >>predecessors ;

M: basic-block hashcode* id>> nip ;

! Utilities
SYMBOL: visited-blocks

: visit-block ( basic-block quot -- )
    over visited-blocks get 2dup key?
    [ 2drop 2drop ] [ conjoin call ] if ; inline

: (each-block) ( basic-block quot -- )
    '[
        _
        [ call ]
        [ [ successors>> ] dip '[ _ (each-block) ] each ]
        2bi
    ] visit-block ; inline

: each-block ( basic-block quot -- )
    H{ } clone visited-blocks [ (each-block) ] with-variable ; inline
