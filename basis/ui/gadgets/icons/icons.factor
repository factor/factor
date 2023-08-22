! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel ui.gadgets ui.gadgets.labels ui.images
ui.pens ui.pens.image ui.render ;
IN: ui.gadgets.icons

TUPLE: icon < gadget image ;

: <icon> ( image-name -- icon )
    icon new swap <image-pen> t >>fill? >>image ;

M: icon draw-gadget* dup image>> [ draw-interior ] [ drop ] if* ;

M: icon pref-dim* dup image>> pen-pref-dim ;

M: image-name >label <icon> ;
