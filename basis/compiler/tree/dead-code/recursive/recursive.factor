! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors sequences kernel
compiler.tree compiler.tree.dead-code.branches
compiler.tree.dead-code.liveness
compiler.tree.dead-code.simple ;
IN: compiler.tree.dead-code.recursive

M: #enter-recursive compute-live-values*
    [ out-d>> ] [ recursive-phi-in flip ] bi look-at-phi ;

: return-recursive-phi-in ( #return-recursive -- phi-in )
    [ label>> calls>> [ in-d>> ] map ] [ in-d>> ] bi suffix ;

M: #return-recursive compute-live-values*
    [ out-d>> ] [ return-recursive-phi-in flip ] bi look-at-phi ;

M: #recursive remove-dead-code*
    [ filter-live ] change-in-d ;

M: #call-recursive remove-dead-code*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d ;

M: #enter-recursive remove-dead-code*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d ;

M: #return-recursive remove-dead-code*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d ;
