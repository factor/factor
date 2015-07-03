USING: accessors game.models.half-edge kernel sequences
tools.test ;
IN: game.models.half-edge.tests

CONSTANT: cube-edges
    {
        T{ edge { face 0 } { vertex  0 } { opposite-edge  6 } { next-edge  1 } }
        T{ edge { face 0 } { vertex  1 } { opposite-edge 19 } { next-edge  2 } }
        T{ edge { face 0 } { vertex  3 } { opposite-edge 12 } { next-edge  3 } }
        T{ edge { face 0 } { vertex  2 } { opposite-edge 21 } { next-edge  0 } }

        T{ edge { face 1 } { vertex  4 } { opposite-edge 10 } { next-edge  5 } }
        T{ edge { face 1 } { vertex  5 } { opposite-edge 16 } { next-edge  6 } }
        T{ edge { face 1 } { vertex  1 } { opposite-edge  0 } { next-edge  7 } }
        T{ edge { face 1 } { vertex  0 } { opposite-edge 20 } { next-edge  4 } }

        T{ edge { face 2 } { vertex  6 } { opposite-edge 14 } { next-edge  9 } }
        T{ edge { face 2 } { vertex  7 } { opposite-edge 17 } { next-edge 10 } }
        T{ edge { face 2 } { vertex  5 } { opposite-edge  4 } { next-edge 11 } }
        T{ edge { face 2 } { vertex  4 } { opposite-edge 23 } { next-edge  8 } }

        T{ edge { face 3 } { vertex  2 } { opposite-edge  2 } { next-edge 13 } }
        T{ edge { face 3 } { vertex  3 } { opposite-edge 22 } { next-edge 14 } }
        T{ edge { face 3 } { vertex  7 } { opposite-edge  8 } { next-edge 15 } }
        T{ edge { face 3 } { vertex  6 } { opposite-edge 18 } { next-edge 12 } }

        T{ edge { face 4 } { vertex  1 } { opposite-edge  5 } { next-edge 17 } }
        T{ edge { face 4 } { vertex  5 } { opposite-edge  9 } { next-edge 18 } }
        T{ edge { face 4 } { vertex  7 } { opposite-edge 13 } { next-edge 19 } }
        T{ edge { face 4 } { vertex  3 } { opposite-edge  1 } { next-edge 16 } }

        T{ edge { face 5 } { vertex  4 } { opposite-edge  7 } { next-edge 21 } }
        T{ edge { face 5 } { vertex  0 } { opposite-edge  3 } { next-edge 22 } }
        T{ edge { face 5 } { vertex  2 } { opposite-edge 15 } { next-edge 23 } }
        T{ edge { face 5 } { vertex  6 } { opposite-edge 11 } { next-edge 20 } }
    }

: connect-cube-edges ( -- )
    cube-edges [
        [ cube-edges nth ] change-opposite-edge
        [ cube-edges nth ] change-next-edge
        drop
    ] each ;

connect-cube-edges

{ 0 1 }
[ cube-edges first edge-vertices ] unit-test

{ { 0 0 0 } }
[ cube-edges first vertex-edges [ vertex>> ] map ] unit-test

{ 3 }
[ cube-edges first vertex-valence ] unit-test

{ { 0 1 3 2 } }
[ cube-edges first face-edges [ vertex>> ] map ] unit-test

{ 4 }
[ cube-edges first face-sides ] unit-test

{ { 1 4 2 } }
[ cube-edges first vertex-neighbors ] unit-test

{ { 3 5 6 } }
[ cube-edges first vertex-diagonals ] unit-test

{ { 1 4 3 5 } }
[ cube-edges first face-neighbors ] unit-test
