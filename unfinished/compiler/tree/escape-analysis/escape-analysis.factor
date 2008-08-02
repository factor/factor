! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces search-dequeues
compiler.tree
compiler.tree.def-use
compiler.tree.escape-analysis.allocations
compiler.tree.escape-analysis.recursive
compiler.tree.escape-analysis.branches
compiler.tree.escape-analysis.nodes
compiler.tree.escape-analysis.simple
compiler.tree.escape-analysis.work-list ;
IN: compiler.tree.escape-analysis

: escape-analysis ( node -- node )
    H{ } clone slot-merging set
    H{ } clone allocations set
    <hashed-dlist> work-list set
    dup (escape-analysis) ;
