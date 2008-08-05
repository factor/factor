! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences compiler.tree ;
IN: compiler.tree.escape-analysis.nodes

GENERIC: escape-analysis* ( node -- )

M: node escape-analysis* drop ;

: (escape-analysis) ( node -- ) [ escape-analysis* ] each ;
