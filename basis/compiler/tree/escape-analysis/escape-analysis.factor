! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces assocs fry sequences
compiler.tree
compiler.tree.escape-analysis.allocations
compiler.tree.escape-analysis.recursive
compiler.tree.escape-analysis.branches
compiler.tree.escape-analysis.nodes
compiler.tree.escape-analysis.simple ;
IN: compiler.tree.escape-analysis

! This pass must run after propagation

: escape-analysis ( node -- node )
    init-escaping-values
    H{ } clone allocations set
    H{ } clone slot-accesses set
    H{ } clone value-classes set
    dup (escape-analysis)
    compute-escaping-allocations ;
