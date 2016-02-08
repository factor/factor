! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-vectors formatting fry
images images.loader kernel locals make math math.vectors
opengl.textures sequences ;

IN: snake-game.sprites

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
    rows iota sh v*n :> ys
    cols iota sh v*n :> xs
    ys xs [
        swap [ image ] 2dip sw sh image-part
    ] cartesian-map f join ;

: load-sprite-image ( filename -- image )
    "vocab:snake-game/_resources/%s" sprintf load-image ;

: make-texture ( image -- texture )
    { 0 0 } <texture> ;

: make-sprites ( filename cols rows -- seq )
    [ load-sprite-image ] 2dip generate-sprite-sheet
    [ make-texture ] map ;

: snake-head-textures ( -- assoc )
    "head.png" 1 4 make-sprites
    { "head-up" "head-right" "head-down" "head-left" }
    [ swap 2array ] 2map ;

:: assoc-with-value-like ( assoc key seq -- )
    key assoc at :> value
    seq [ [ value ] dip assoc set-at ] each ;

: snake-body-textures ( -- assoc )
    "body.png" 3 2 make-sprites
    { 1 2 3 4 5 6 }
    [ swap 2array ] 2map
    dup 1 { "body-right-up" "body-down-left" } assoc-with-value-like
    dup 2 { "body-down-right" "body-left-up" } assoc-with-value-like
    dup 3 { "body-right-right" "body-left-left" } assoc-with-value-like
    dup 4 { "body-up-up" "body-down-down" } assoc-with-value-like    
    dup 5 { "body-up-right" "body-left-down" } assoc-with-value-like
    dup 6 { "body-right-down" "body-up-left" } assoc-with-value-like
    dup [ { 1 2 3 4 5 6 } ] dip [ delete-at ] curry each ;

: snake-tail-textures ( -- assoc )
    "tail.png" 2 2 make-sprites
    { "tail-down" "tail-left" "tail-up" "tail-right" }
    [ swap 2array ] 2map ;

: food-texture ( -- assoc )
    "food" "food.png" load-sprite-image make-texture
    2array 1array ;

: background-texture ( -- assoc )
    "background" "background.png" load-sprite-image make-texture
    2array 1array ;
