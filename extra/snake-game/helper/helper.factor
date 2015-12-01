! Copyright (C) 2015 Sankaranarayanan Viswanathan
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-vectors fry images kernel locals
math sequences ;

IN: snake-game.helper

: new-image-like ( image w h -- image )
    [ clone ] 2dip
    [ 2array >>dim ] 2keep *
    over bytes-per-pixel * <byte-vector> >>bitmap ;

:: image-part ( image x y w h -- image )
    image w h new-image-like :> new-image
    h iota [| i |
        new-image bitmap>>
        x y i + w image pixel-row-slice-at
        append! drop
    ] each new-image ;

:: generate-sprite-sheet ( image rows cols -- seq )
    cols rows 2array :> split-dims
    image dim>> split-dims [ / ] 2map first2 :> ( sw sh )
    rows iota [ sh * ] map :> ys
    cols iota [ sw * ] map :> xs
    ys xs [
        swap [ image ] 2dip sw sh image-part
    ] cartesian-map f join ;
