! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays
combinators.short-circuit images kernel math math.functions
math.order math.vectors sequences sorting ;
IN: images.atlas

! sort rects by height/width/whatever
! use least power of two greater than k * greatest width for atlas width
! pack stripes(y 0):
!   place first rect at x 0
!   place rects that fit in remaining stripe
!   pack stripes(y + height)
! if height > max height

TUPLE: image-placement
    { image read-only }
    loc ;

CONSTANT: atlas-waste-factor 1.25
CONSTANT: atlas-padding 1

ERROR: atlas-image-formats-dont-match images ;

<PRIVATE

: width  ( dim -- width  ) first  atlas-padding + ; inline
: height ( dim -- height ) second atlas-padding + ; inline
: area   ( dim -- area   ) [ width ] [ height ] bi * ; inline

:: (pack-stripe) ( image-placements atlas-width @y -- stripe-height/f )
    0 :> @x!
    f :> stripe-height!
    image-placements [| ip |
        ip loc>> [
            ip image>> dim>> :> dim
            stripe-height [ dim height stripe-height 0 or max stripe-height! ] unless
            dim width :> w
            atlas-width w @x + >= [
                ip { @x @y } >>loc drop
                @x w + @x!
            ] when
        ] unless
    ] each
    stripe-height ;

:: (pack-images) ( images atlas-width sort-quot -- placements )
    images sort-quot inv-sort-by [ f image-placement boa ] map :> image-placements
    0 :> @y!
    [ image-placements atlas-width @y (pack-stripe) ] [ @y + @y! ] while*
    image-placements ; inline

: atlas-image-format ( image-placements -- component-order component-type upside-down? )
    [ image>> ] map dup unclip '[
        _ {
            [ [ component-order>> ] same? ]
            [ [ component-type>>  ] same? ]
            [ [ upside-down?>>    ] same? ]
        } 2&&
    ] all?
    [ first [ component-order>> ] [ component-type>> ] [ upside-down?>> ] tri ]
    [ atlas-image-formats-dont-match ] if ; inline

: atlas-dim ( image-placements -- dim )
    [ [ loc>> ] [ image>> dim>> ] bi v+ atlas-padding v+n ] [ vmax ] map-reduce
    [ next-power-of-2 ] map ; inline

:: <atlas-image> ( image-placements component-order component-type upside-down? -- atlas )
    image-placements atlas-dim :> dim
    <image>
        dim >>dim
        component-order >>component-order
        component-type >>component-type
        upside-down? >>upside-down?
        dim product component-order component-type (bytes-per-pixel) * <byte-array> >>bitmap ; inline

:: copy-image-into-atlas ( image-placement atlas -- )
    image-placement image>> :> image
    image dim>> first2 :> ( w h )
    image-placement loc>> first2 :> ( x y )

    h <iota> [| row |
        0  row      w  image pixel-row-slice-at
        x  y row +  w  atlas set-pixel-row-at
    ] each ; inline

: copy-images-into-atlas ( image-placements atlas -- )
    '[ _ copy-image-into-atlas ] each ; inline

PRIVATE>

: (guess-atlas-dim) ( images -- width )
    [ dim>> area ] [ + ] map-reduce sqrt
    atlas-waste-factor *
    .5 + >integer ;

: guess-atlas-dim ( images -- width )
    [ (guess-atlas-dim) ] [ [ dim>> width ] [ max ] map-reduce ] bi max next-power-of-2 ;

: pack-images ( images atlas-width -- placements )
    [ dim>> second ] (pack-images) ;

: pack-atlas ( images -- image-placements )
    dup guess-atlas-dim pack-images ;

: (make-atlas) ( image-placements -- image )
    dup dup atlas-image-format <atlas-image> [ copy-images-into-atlas ] keep ;

:: image-placement>texcoords ( image-placement atlas-image -- image texcoords )
    atlas-image dim>> first2 :> ( aw ah )
    image-placement image>> :> image
    image-placement loc>> first2 :> ( x y )
    image dim>> first2 :> ( w h )

    x     aw /f :> left-u
    y     ah /f :> top-v
    x w + aw /f :> right-u
    y h + ah /f :> bottom-v

    image dup upside-down?>>
    [ left-u top-v    right-u bottom-v ]
    [ left-u bottom-v right-u top-v    ] if 4array ; inline

: make-atlas ( images -- image-texcoords atlas-image )
    pack-atlas dup (make-atlas) [ '[ _ image-placement>texcoords ] H{ } map>assoc ] keep ;

: make-atlas-assoc ( image-assoc -- texcoord-assoc atlas-image )
    dup values make-atlas [ '[ _ at ] assoc-map ] dip ;
