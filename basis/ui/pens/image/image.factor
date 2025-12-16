! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors images kernel math namespaces opengl
opengl.textures sequences ui.images ui.pens ui.render
ui.render.gl3 ;
IN: ui.pens.image

! Image pen
TUPLE: image-pen image fill? ;

: <image-pen> ( image -- pen ) f image-pen boa ;

:: draw-image-gl3 ( image -- )
    image cached-image :> img
    img make-texture-gl3 :> tex-id
    ! Convert device pixel dimensions to logical pixels
    { 0 0 } img dim>> [ gl-unscale ] map tex-id img upside-down?>> gl3-draw-texture
    tex-id delete-texture ;

:: draw-scaled-image-gl3 ( dim image -- )
    image cached-image :> img
    img make-texture-gl3 :> tex-id
    { 0 0 } dim tex-id img upside-down?>> gl3-draw-texture
    tex-id delete-texture ;

M: image-pen draw-interior
    [ dim>> ] [ [ image>> ] [ fill?>> ] bi ] bi*
    gl3-mode? get-global [
        ! GL3 path
        [ draw-scaled-image-gl3 ] [
            [ image-dim [ - 2 / gl-round ] 2map ] keep
            '[ _ draw-image-gl3 ] ui.render.gl3:with-gl3-translation
        ] if
    ] [
        ! Legacy GL path
        [ draw-scaled-image ] [
            [ image-dim [ - 2 / gl-round ] 2map ] keep
            '[ _ draw-image ] with-translation
        ] if
    ] if ;

M: image-pen pen-pref-dim nip image>> image-dim ;
