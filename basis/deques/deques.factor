! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math ;
IN: deques

GENERIC: push-front* ( obj deque -- node )
GENERIC: push-back* ( obj deque -- node )
GENERIC: peek-front ( deque -- obj )
GENERIC: peek-back ( deque -- obj )
GENERIC: pop-front* ( deque -- )
GENERIC: pop-back* ( deque -- )
GENERIC: delete-node ( node deque -- )
GENERIC: deque-length ( deque -- n )
GENERIC: deque-member? ( value deque -- ? )
GENERIC: clear-deque ( deque -- )
GENERIC: node-value ( node -- value )

: deque-empty? ( deque -- ? )
    deque-length zero? ;

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
    [ drop [ deque-empty? not ] curry ]
    [ [ pop-back ] prepose curry ] 2bi [ ] while ; inline

MIXIN: deque
