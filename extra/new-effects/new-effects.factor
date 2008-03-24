USING: assocs kernel sequences ;
IN: new-effects

: new-nth ( seq n -- elt )
    swap nth ;

: new-set-nth ( seq obj n -- seq )
    pick set-nth ;

: new-at ( assoc key -- elt )
    swap at ;

: new-at* ( assoc key -- elt ? )
    swap at* ;

: new-set-at ( assoc value key -- assoc )
    pick set-at ;
