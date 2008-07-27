! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences accessors kernel
compiler.tree.def-use
compiler.tree.propagation.info ;
IN: compiler.tree.propagation.nodes

SYMBOL: +constraints+
SYMBOL: +outputs+

GENERIC: propagate-before ( node -- )

GENERIC: propagate-after ( node -- )

GENERIC: propagate-around ( node -- )

: (propagate) ( node -- )
    [
        USING: classes prettyprint ; dup class .
        [ propagate-around ] [ successor>> ] bi
        (propagate)
    ] when* ;
