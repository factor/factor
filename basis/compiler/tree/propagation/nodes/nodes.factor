! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.tree
compiler.tree.propagation.copy compiler.tree.propagation.info
kernel sequences ;
IN: compiler.tree.propagation.nodes

GENERIC: propagate-before ( node -- )

GENERIC: propagate-after ( node -- )

GENERIC: annotate-node ( node -- )

GENERIC: propagate-around ( node -- )

: (propagate) ( nodes -- )
    [ [ compute-copy-equiv ] [ propagate-around ] bi ] each ;

: extract-value-info ( values -- assoc )
    [ dup value-info ] H{ } map>assoc ;

: (annotate-node) ( node values -- )
    extract-value-info >>info drop ; inline

M: node propagate-before drop ;

M: node propagate-after drop ;

M: node annotate-node drop ;

M: node propagate-around
    [ propagate-before ] [ annotate-node ] [ propagate-after ] tri ;
