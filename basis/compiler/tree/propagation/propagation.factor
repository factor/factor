! Copyright (C) 2004, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays
compiler.tree
compiler.tree.propagation.branches
compiler.tree.propagation.call-effect
compiler.tree.propagation.constraints
compiler.tree.propagation.copy
compiler.tree.propagation.info
compiler.tree.propagation.inlining
compiler.tree.propagation.known-words
compiler.tree.propagation.nodes
compiler.tree.propagation.recursive
compiler.tree.propagation.simple
compiler.tree.propagation.transforms
kernel namespaces ;
IN: compiler.tree.propagation

: propagate ( nodes -- nodes )
    H{ } clone copies set
    H{ } clone 1array value-infos set
    H{ } clone 1array constraints set
    dup (propagate) ;
