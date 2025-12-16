! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators images kernel locals math.vectors
namespaces opengl opengl.textures sequences ui.images ui.pens
ui.render ui.render.gl3 ;
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

:: render-tile-gl3 ( tile x width gadget -- )
    x gadget orientation>> '[ _ v* [ gl-round ] map ] dip :> loc
    width gadget [ dim>> swap ] [ orientation>> ] bi set-axis :> dim
    tile cached-image :> img
    img make-texture-gl3 :> tex-id
    loc dim tex-id img upside-down?>> gl3-draw-texture
    tex-id delete-texture ;

: render-tile ( tile x width gadget -- )
    gl3-mode? get-global [
        ! GL3 path
        render-tile-gl3
    ] [
        ! Legacy GL path
        [ orientation>> '[ _ v* [ gl-round ] map ] dip ] keep
       '[
            _ _ [ dim>> swap ] [ orientation>> ] bi set-axis
            swap draw-scaled-image
       ] with-translation
    ] if ;

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
