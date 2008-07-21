! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences namespaces hashtables
compiler.tree
compiler.tree.def-use
compiler.tree.propagation.constraints
compiler.tree.propagation.simple
compiler.tree.propagation.branches
compiler.tree.propagation.recursive ;
IN: compiler.tree.propagation

: (propagate) ( node -- )
    [
        [ node-defs-values [ introduce-value ] each ]
        [ propagate-around ]
        [ successor>> ]
        tri
        (propagate)
    ] when* ;

: propagate-with ( node classes literals intervals -- )
    [
        H{ } clone constraints set
        >hashtable value-intervals set
        >hashtable value-literals set
        >hashtable value-classes set
        (propagate)
    ] with-scope ;

: propagate ( node -- node )
    dup f f f propagate-with ;

: propagate/node ( node existing -- )
    #! Infer classes, using the existing node's class info as a
    #! starting point.
    [ classes>> ] [ literals>> ] [ intervals>> ] tri
    propagate-with ;
