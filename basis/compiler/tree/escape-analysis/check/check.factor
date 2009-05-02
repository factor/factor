! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes classes.tuple math math.private accessors
combinators kernel compiler.tree compiler.tree.combinators
compiler.tree.propagation.info ;
IN: compiler.tree.escape-analysis.check

GENERIC: run-escape-analysis* ( node -- ? )

M: #push run-escape-analysis*
    literal>> [ class immutable-tuple-class? ] [ complex? ] bi or ;

M: #call run-escape-analysis*
    {
        { [ dup immutable-tuple-boa? ] [ t ] }
        [ f ] 
    } cond nip ;

M: node run-escape-analysis* drop f ;

: run-escape-analysis? ( nodes -- ? )
    [ run-escape-analysis* ] contains-node? ;
