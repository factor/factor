! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.tree.escape-analysis.allocations
compiler.tree.escape-analysis.nodes kernel namespaces ;

USE: compiler.tree.escape-analysis.recursive
USE: compiler.tree.escape-analysis.branches
USE: compiler.tree.escape-analysis.simple

IN: compiler.tree.escape-analysis

: escape-analysis ( nodes -- nodes )
    init-escaping-values
    H{ } clone allocations set
    H{ } clone slot-accesses set
    H{ } clone value-classes set
    dup (escape-analysis)
    compute-escaping-allocations ;
