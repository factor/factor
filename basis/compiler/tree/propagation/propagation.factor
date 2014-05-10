! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences namespaces hashtables arrays
compiler.tree
compiler.tree.propagation.copy
compiler.tree.propagation.info
compiler.tree.propagation.nodes
compiler.tree.propagation.simple
compiler.tree.propagation.inlining
compiler.tree.propagation.branches
compiler.tree.propagation.recursive
compiler.tree.propagation.constraints
compiler.tree.propagation.known-words ;
IN: compiler.tree.propagation

! This pass must run after normalization

: propagate ( nodes -- nodes )
    H{ } clone copies set
    H{ } clone 1array value-infos set
    H{ } clone 1array constraints set
    dup (propagate) ;
