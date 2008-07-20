! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces assocs sequences sets fry ;
IN: compiler.cfg

! The id is a globally unique id used for fast hashcode* and
! equal? on basic blocks. The number is assigned by
! linearization.
TUPLE: basic-block < identity-tuple
id
number
instructions
successors
predecessors
stack-frame ;

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
        ,
        [ call ]
        [ [ successors>> ] dip '[ , (each-block) ] each ]
        2bi
    ] visit-block ; inline

: each-block ( basic-block quot -- )
    H{ } clone visited-blocks [ (each-block) ] with-variable ; inline

: copy-at ( from to assoc -- )
    3dup nip at* [ -rot set-at drop ] [ 2drop 2drop ] if ; inline
