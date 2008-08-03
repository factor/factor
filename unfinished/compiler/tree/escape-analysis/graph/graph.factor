! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors assocs fry sequences sets
dequeues search-dequeues namespaces ;
IN: compiler.tree.escape-analysis.graph

TUPLE: graph edges work-list ;

: <graph> ( -- graph )
    H{ } clone <hashed-dlist> graph boa ;

: mark-vertex ( vertex graph -- ) work-list>> push-front ;

: add-edge ( out in graph -- )
    [ edges>> push-at ] [ swapd edges>> push-at ] 3bi ;

: add-edges ( out-seq in graph -- )
    '[ , , add-edge ] each ;

<PRIVATE

SYMBOL: marked

: (mark-vertex) ( vertex graph -- )
    over marked get key? [ 2drop ] [
        [ drop marked get conjoin ]
        [ [ edges>> at ] [ work-list>> ] bi push-all-front ]
        2bi
    ] if ;

PRIVATE>

: marked-components ( graph -- vertices )
    #! All vertices in connected components of marked vertices.
    H{ } clone marked [
        [ work-list>> ] keep
        '[ , (mark-vertex) ] slurp-dequeue
    ] with-variable ;
