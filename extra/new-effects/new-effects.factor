USING: assocs kernel sequences ;
IN: new-effects

: new-nth ( seq n -- elt )
    swap nth ; inline

: new-set-nth ( seq obj n -- seq )
    pick set-nth ; inline

: new-at ( assoc key -- elt )
    swap at ; inline

: new-at* ( assoc key -- elt ? )
    swap at* ; inline

: new-set-at ( assoc value key -- assoc )
    pick set-at ; inline
