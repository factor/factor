! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays fry kernel locals math sequences ;
IN: game.models.half-edge

TUPLE: edge < identity-tuple face vertex opposite-edge next-edge ;

: edge-vertices ( edge -- start end )
    [ vertex>> ] [ opposite-edge>> vertex>> ] bi ;

! building blocks for edge loop iteration

: (collect) ( in quot iterator -- out )
    [ collector ] dip dip >array ; inline

: (reduce) ( in initial quot iterator -- accum )
    [ swap ] 2dip call ; inline

: (count) ( in iterator -- count )
    [ 0 [ drop 1 + ] ] dip (reduce) ; inline

: edge-loop ( ..a edge quot: ( ..a edge -- ..b ) next-edge-quot: ( ..b edge -- ..a edge' ) -- ..a )
    pick '[ _ _ bi dup _ eq? not ] loop drop ; inline

! iterate over related edges

: each-vertex-edge ( ... edge quot: ( ... edge -- ... ) -- ... )
    [ opposite-edge>> next-edge>> ] edge-loop ; inline

: each-face-edge ( ... edge quot: ( ... edge -- ... ) -- ... )
    [ next-edge>> ] edge-loop ; inline

!

: vertex-edges ( edge -- edges )
    [ ] [ each-vertex-edge ] (collect) ;

: vertex-neighbors ( edge -- edges )
    [ opposite-edge>> vertex>> ] [ each-vertex-edge ] (collect) ;

: vertex-diagonals ( edge -- edges )
    [ next-edge>> opposite-edge>> vertex>> ] [ each-vertex-edge ] (collect) ;

: vertex-valence ( edge -- count )
    [ each-vertex-edge ] (count) ;

: face-edges ( edge -- edges )
    [ ] [ each-face-edge ] (collect) ;

: face-neighbors ( edge -- edges )
    [ opposite-edge>> face>> ] [ each-face-edge ] (collect) ;

: face-sides ( edge -- count )
    [ each-face-edge ] (count) ;
