! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math ;
IN: dequeues

GENERIC: push-front* ( obj dequeue -- node )
GENERIC: push-back* ( obj dequeue -- node )
GENERIC: peek-front ( dequeue -- obj )
GENERIC: peek-back ( dequeue -- obj )
GENERIC: pop-front* ( dequeue -- )
GENERIC: pop-back* ( dequeue -- )
GENERIC: delete-node ( node dequeue -- )
GENERIC: dequeue-length ( dequeue -- n )
GENERIC: dequeue-member? ( value dequeue -- ? )
GENERIC: clear-dequeue ( dequeue -- )
GENERIC: node-value ( node -- value )

: dequeue-empty? ( dequeue -- ? )
    dequeue-length zero? ;

: push-front ( obj dequeue -- )
    push-front* drop ;

: push-all-front ( seq dequeue -- )
    [ push-front ] curry each ;

: push-back ( obj dequeue -- )
    push-back* drop ;

: push-all-back ( seq dequeue -- )
    [ push-back ] curry each ;

: pop-front ( dequeue -- obj )
    [ peek-front ] [ pop-front* ] bi ;

: pop-back ( dequeue -- obj )
    [ peek-back ] [ pop-back* ] bi ;

: slurp-dequeue ( dequeue quot -- )
    over dequeue-empty? [ 2drop ] [
        [ [ pop-back ] dip call ] [ slurp-dequeue ] 2bi
    ] if ; inline

MIXIN: dequeue
