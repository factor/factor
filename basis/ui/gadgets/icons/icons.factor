! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors ui.images ui.render ui.gadgets ;
IN: ui.gadgets.icons

TUPLE: icon < gadget image ;

: <icon> ( image-name -- icon ) icon new swap >>image ;

M: icon draw-gadget* image>> draw-image ;

M: icon pref-dim* image>> image-dim ;