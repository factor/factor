! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math.vectors opengl
ui.images ui.pens ;
IN: ui.pens.tile

! Tile pen
TUPLE: tile-pen left center right background foreground ;

: <tile-pen> ( left center right background foreground -- pen )
    tile-pen boa ;

: >tile-pen< ( pen -- left center right )
    [ left>> ] [ center>> ] [ right>> ] tri ; inline

M: tile-pen pen-pref-dim
    swap [
        >tile-pen< [ image-dim ] tri@
        [ vmax vmax ] [ v+ v+ ] 3bi
    ] dip orientation>> set-axis ;

: compute-tile-xs ( gadget pen -- x1 x2 x3 )
    [ 2drop { 0 0 } ]
    [ nip left>> image-dim ]
    [ [ dim>> ] [ right>> image-dim ] bi* v- ]
    2tri ;

: compute-tile-widths ( gadget pen -- w1 w2 w3 )
    [ nip left>> image-dim ]
    [ [ dim>> ] [ [ left>> ] [ right>> ] bi [ image-dim ] bi@ ] bi* v+ v- ]
    [ nip right>> image-dim ]
    2tri ;

: render-tile ( tile x width gadget -- )
    [ orientation>> '[ _ v* [ gl-round ] map ] dip ] keep
   '[
        _ _ [ dim>> swap ] [ orientation>> ] bi set-axis
        swap draw-scaled-image
   ] with-translation ;

M: tile-pen draw-interior
    {
        [ nip >tile-pen< ]
        [ compute-tile-xs ]
        [ compute-tile-widths ]
        [ drop ]
    } 2cleave
    [ render-tile ] curry tri-curry@ tri-curry* tri* ;

M: tile-pen pen-background nip background>> ;

M: tile-pen pen-foreground nip foreground>> ;
