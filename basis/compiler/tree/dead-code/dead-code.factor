! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.tree.dead-code.branches
compiler.tree.dead-code.liveness
compiler.tree.dead-code.recursive
compiler.tree.dead-code.simple ;
IN: compiler.tree.dead-code

: remove-dead-code ( nodes -- nodes )
    init-dead-code
    mark-live-values
    compute-live-values
    (remove-dead-code) ;
