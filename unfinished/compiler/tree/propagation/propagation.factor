! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences namespaces hashtables
compiler.tree
compiler.tree.def-use
compiler.tree.propagation.info
compiler.tree.propagation.nodes
compiler.tree.propagation.simple
compiler.tree.propagation.branches
compiler.tree.propagation.recursive
compiler.tree.propagation.constraints
compiler.tree.propagation.known-words ;
IN: compiler.tree.propagation

: propagate-with ( node infos -- )
    [
        H{ } clone constraints set
        >hashtable value-infos set
        (propagate)
    ] with-scope ;

: propagate ( node -- node )
    dup f propagate-with ;

: propagate/node ( node existing -- )
    info>> propagate-with ;
