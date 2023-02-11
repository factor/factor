! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.tuple combinators.short-circuit
compiler.tree compiler.tree.propagation.info kernel math
sequences ;
IN: compiler.tree.escape-analysis.check

GENERIC: run-escape-analysis* ( node -- ? )

: unbox-inputs? ( nodes -- ? )
    {
        [ length 2 >= ]
        [ first #introduce? ]
        [ second #declare? ]
    } 1&& ;

: run-escape-analysis? ( nodes -- ? )
    { [ unbox-inputs? ] [ [ run-escape-analysis* ] any? ] } 1|| ;

M: #push run-escape-analysis*
    literal>> class-of immutable-tuple-class? ;

M: #call run-escape-analysis*
    immutable-tuple-boa? ;

M: #recursive run-escape-analysis*
    child>> run-escape-analysis? ;

M: #branch run-escape-analysis*
    children>> [ run-escape-analysis? ] any? ;

M: node run-escape-analysis* drop f ;
