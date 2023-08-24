! Copyright (C) 2015 Sankaranarayanan Viswanathan.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-vectors formatting
images images.loader kernel make math math.vectors
opengl.textures sequences ;

IN: snake-game.sprites

: new-image-like ( image w h -- image )
    [ clone ] 2dip
    [ 2array >>dim ] 2keep *
    over bytes-per-pixel * <byte-vector> >>bitmap ;

:: image-part ( image x y w h -- image )
    image w h new-image-like :> new-image
    h <iota> [| i |
        new-image bitmap>>
        x y i + w image pixel-row-slice-at
        append! drop
    ] each new-image ;

:: generate-sprite-sheet ( image rows cols -- seq )
    cols rows 2array :> split-dims
    image dim>> split-dims [ / ] 2map first2 :> ( sw sh )
    rows <iota> sh v*n :> ys
    cols <iota> sh v*n :> xs
    ys xs [
        swap [ image ] 2dip sw sh image-part
    ] cartesian-map f join ;

: load-snake-image ( filename -- image )
    "vocab:snake-game/_resources/%s" sprintf load-image ;

: load-snake-texture ( file-name -- texture )
    load-snake-image { 0 0 } <texture> ;

: load-sprite-textures ( filename cols rows -- seq )
    [ load-snake-image ] 2dip generate-sprite-sheet
    [ { 0 0 } <texture> ] map ;

: snake-head-textures ( -- assoc )
    { "head-up" "head-right" "head-down" "head-left" }
    "head.png" 1 4 load-sprite-textures zip ;

: snake-body-textures ( -- assoc )
    {
        "body-right-up" "body-down-right" "body-right-right"
        "body-up-up" "body-up-right" "body-right-down"
    }
    {
        "body-down-left" "body-left-up" "body-left-left"
        "body-down-down" "body-left-down" "body-up-left"
    }
    "body.png" 3 2 load-sprite-textures '[ _ zip ] bi@ append ;

: snake-tail-textures ( -- assoc )
    { "tail-down" "tail-left" "tail-up" "tail-right" }
    "tail.png" 2 2 load-sprite-textures zip ;

: food-texture ( -- assoc )
    "food" "food.png" load-snake-texture 2array 1array ;

: background-texture ( -- assoc )
    "background" "background.png" load-snake-texture 2array 1array ;

: snake-textures ( -- assoc )
    [
        snake-head-textures %%
        snake-body-textures %%
        snake-tail-textures %%
        food-texture %%
        background-texture %%
    ] H{ } make ;
