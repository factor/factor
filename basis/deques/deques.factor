! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math fry ;
IN: deques

GENERIC: push-front* ( obj deque -- node )
GENERIC: push-back* ( obj deque -- node )
GENERIC: peek-front ( deque -- obj )
GENERIC: peek-back ( deque -- obj )
GENERIC: pop-front* ( deque -- )
GENERIC: pop-back* ( deque -- )
GENERIC: delete-node ( node deque -- )
GENERIC: deque-member? ( value deque -- ? )
GENERIC: clear-deque ( deque -- )
GENERIC: node-value ( node -- value )
GENERIC: deque-empty? ( deque -- ? )

: push-front ( obj deque -- )
    push-front* drop ;

: push-all-front ( seq deque -- )
    [ push-front ] curry each ;

: push-back ( obj deque -- )
    push-back* drop ;

: push-all-back ( seq deque -- )
    [ push-back ] curry each ;

: pop-front ( deque -- obj )
    [ peek-front ] [ pop-front* ] bi ;

: pop-back ( deque -- obj )
    [ peek-back ] [ pop-back* ] bi ;

: slurp-deque ( deque quot -- )
    [ drop '[ _ deque-empty? not ] ]
    [ '[ _ pop-back @ ] ]
    2bi while ; inline

MIXIN: deque
