! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel math namespaces ;

! A tile is a gadget with a caption. Dragging the caption
! moves the gadget. The title bar also has buttons for
! performing various actions.

: click-rel ( gadget -- point )
    screen-pos
    hand [ hand-clicked screen-pos - ] keep hand-click-rel - ;

: drag-tile ( tile -- )
    dup click-rel hand screen-pos + >rect rot move-gadget ;

: raise ( gadget -- )
    dup gadget-parent >r dup unparent r> add-gadget ;

: caption-actions ( caption -- )
    dup [ [ raise ] swap handle-gesture drop ] [ button-down 1 ] set-action
    dup [ drop ] [ button-up 1 ] set-action
    [ [ drag-tile ] swap handle-gesture drop ] [ drag 1 ] set-action ;

: close-tile [ close-tile ] swap handle-gesture drop ;

: <close-box> ( -- gadget )
    <check> line-border dup [ close-tile ] button-actions ;

: caption-content ( text -- gadget )
    1/2 10 0 <shelf>
    [ <close-box> swap add-gadget ] keep
    [ >r <label> r> add-gadget ] keep ;

: <caption> ( text -- caption )
    caption-content filled-border
    dup t reverse-video set-paint-prop
    dup caption-actions ;

: tile-actions ( tile -- )
    dup [ unparent ] [ close-tile ] set-action
    dup [ raise ] [ raise ] set-action
    [ drag-tile ] [ drag-tile ] set-action ;

: tile-content ( child caption -- pile )
     <frame> [ >r <caption> r> add-top ] keep [ add-center ] keep ;

TUPLE: tile ;
C: tile ( child caption -- tile )
    [ f line-border swap set-delegate ] keep
    [ >r tile-content r> add-gadget ] keep
    [ tile-actions ] keep
    dup delegate pref-size pick resize-gadget ;

M: tile pref-size shape-size ;
