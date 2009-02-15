! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences fry math
opengl ui.pens ui.images io.pathnames ;
IN: ui.pens.image

! Image pen
TUPLE: image-pen image fill? ;

: <image-pen> ( image -- pen ) f image-pen boa ;

M: image-pen draw-interior
    [ dim>> ] [ [ image>> ] [ fill?>> ] bi ] bi*
    [ draw-scaled-image ] [
        [ image-dim [ - 2/ ] 2map ] keep
        '[ _ draw-image ] with-translation
    ] if ;

M: image-pen pen-pref-dim nip image>> image-dim ;

: theme-image ( name -- image-name )
    "resource:basis/ui/gadgets/theme/" prepend-path ".tiff" append <image-name> ;