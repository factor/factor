! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: kernel math namespaces ;

! A tile is a gadget with a caption. Dragging the caption
! moves the gadget. The title bar also has buttons for
! performing various actions.

TUPLE: caption tile delegate ;

: click-rel ( gadget -- point )
    screen-pos
    hand [ hand-clicked screen-pos - ] keep hand-click-rel - ;

: drag-tile ( tile -- )
    dup click-rel hand screen-pos + >rect rot move-gadget ;

: raise ( gadget -- )
    dup gadget-parent >r dup unparent r> add-gadget ;

: caption-actions ( caption -- )
    dup [ caption-tile raise ] [ button-down 1 ] set-action
    dup [ drop ] [ button-up 1 ] set-action
    [ caption-tile drag-tile ] [ drag 1 ] set-action ;

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

C: caption ( text -- caption )
    [ f filled-border swap set-caption-delegate ] keep
    [ >r caption-content r> add-gadget ] keep
    dup caption-actions
    dup t reverse-video set-paint-prop ;

DEFER: inspect

: tile-actions ( tile -- )
    dup [ unparent ] [ close-tile ] set-action
    [ inspect ] [ inspect-tile ] set-action ;

: <tile> ( child caption -- )
    <caption> [
        0 1 1 <pile>
        [ add-gadget ] keep
        [ add-gadget ] keep
        line-border dup
    ] keep set-caption-tile
    dup tile-actions ;
