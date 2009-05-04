! Copyright (C) 2008 William Schlieper <schlieper@unc.edu>
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel sequences arrays vectors sets assocs hashtables graph-theory namespaces fry ;

IN: graph-theory.sparse

TUPLE: sparse-graph alist ; 

: <sparse-graph> ( -- sparse-graph )
    H{ } clone sparse-graph boa ;

: >sparse-graph ( graph -- sparse-graph )
    [ vertices ] keep
    '[ dup _ adjlist 2array ] map >hashtable sparse-graph boa ;

INSTANCE: sparse-graph graph

M: sparse-graph vertices
    alist>> keys ;

M: sparse-graph adjlist
    alist>> at ;

M: sparse-graph add-blank-vertex 
    alist>> V{ } clone -rot set-at ;

M: sparse-graph delete-blank-vertex
    alist>> delete-at ;

M: sparse-graph add-edge*
    alist>> swapd at adjoin ;

M: sparse-graph delete-edge*
    alist>> swapd at delete ;
