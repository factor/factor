! Copyright (C) 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables hashtables.private kernel sequences ;
IN: digraphs

TUPLE: digraph < hashtable ;

: <digraph> ( -- digraph )
    0 digraph new [ reset-hash ] keep ;

TUPLE: vertex value edges ;

: <vertex> ( value -- vertex )
    V{ } clone vertex boa ;

: add-vertex ( key value digraph -- )
    [ <vertex> swap ] dip set-at ;

: children ( key digraph -- seq )
    at edges>> ;

: @edges ( from to digraph -- to edges ) swapd at edges>> ;
: add-edge ( from to digraph -- ) @edges push ;
: delete-edge ( from to digraph -- ) @edges remove! drop ;

: delete-to-edges ( to digraph -- )
    [ nip dupd edges>> remove! drop ] assoc-each drop ;

: delete-vertex ( key digraph -- )
    2dup delete-at delete-to-edges ;

: unvisited? ( unvisited key -- ? ) swap key? ;
: visited ( unvisited key -- ) swap delete-at ;

DEFER: (topological-sort)
: visit-children ( seq unvisited key -- seq unvisited )
    over children [ (topological-sort) ] each ;

: (topological-sort) ( seq unvisited key -- seq unvisited )
    2dup unvisited? [
        [ visit-children ] keep 2dup visited pick push
    ] [
        drop
    ] if ;

: topological-sort ( digraph -- seq )
    [ V{ } clone ] dip [ clone ] keep
    [ drop (topological-sort) ] assoc-each drop reverse ;

: topological-sorted-values ( digraph -- seq )
    dup topological-sort swap [ at value>> ] curry map ;
