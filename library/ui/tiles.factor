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
: inspect-tile [ inspect-tile ] swap handle-gesture drop ;

: tile-menu ( button -- )
    [
        [ "Close" close-tile ]
        [ "Inspect" inspect-tile ]
    ] actionize <menu> show-menu ;

: caption-content ( text -- gadget )
    1/2 10 0 <shelf>
    [ "Menu" [ tile-menu ] <roll-button> swap add-gadget ] keep
    [ >r <label> r> add-gadget ] keep ;

: <caption> ( text -- caption )
    caption-content line-border
    dup t reverse-video set-paint-prop
    dup caption-actions ;

DEFER: inspect

: tile-actions ( tile -- )
    dup [ unparent ] [ close-tile ] set-action
    dup [ inspect ] [ inspect-tile ] set-action
    dup [ raise ] [ raise ] set-action
    [ drag-tile ] [ drag-tile ] set-action ;

: tile-content ( child caption -- pile )
    0 1 1 <pile>
    [ >r <caption> r> add-gadget ] keep
    [ add-gadget ] keep ;

TUPLE: tile ;
C: tile ( child caption -- tile )
    [ f line-border swap set-delegate ] keep
    [ >r tile-content r> add-gadget ] keep
    [ tile-actions ] keep
    dup delegate pref-size pick resize-gadget ;

M: tile pref-size shape-size ;
