! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors ui.images ui.pens
ui.pens.image ui.gadgets ui.gadgets.labels ;
IN: ui.gadgets.icons

TUPLE: icon < gadget ;

: <icon> ( image-name -- icon )
    icon new swap <image-pen> t >>fill? >>interior ;

M: icon pref-dim* dup interior>> pen-pref-dim ;

M: image-name >label <icon> ;