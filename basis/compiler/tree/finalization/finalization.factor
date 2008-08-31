! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences
compiler.tree compiler.tree.combinators ;
IN: compiler.tree.finalization

GENERIC: finalize* ( node -- nodes )

M: #copy finalize* drop f ;

M: #shuffle finalize*
    dup shuffle-effect
    [ in>> ] [ out>> ] bi sequence=
    [ drop f ] when ;

M: node finalize* ;

: finalize ( nodes -- nodes' ) [ finalize* ] map-nodes ;
