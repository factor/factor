! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel math matrices namespaces ;

! A tile is a gadget with a caption. Dragging the caption
! moves the gadget. The title bar also has buttons for
! performing various actions.
TUPLE: tile original ;

: click-rel ( gadget -- point )
    screen-loc
    hand [ hand-clicked screen-loc v- ] keep hand-click-rel v- ;

: move-tile ( tile -- )
    dup click-rel hand screen-loc v+ swap set-gadget-loc ;

: start-resizing ( tile -- )
    dup shape-dim swap set-tile-original ;

: resize-tile ( tile -- )
    dup screen-loc hand hand-click-loc v- over tile-original v+
    over hand relative v+ swap set-gadget-dim ;
 
: raise ( gadget -- )
    dup gadget-parent >r dup unparent r> add-gadget ;

: caption-actions ( caption -- )
    dup [ raise ] [ button-down 1 ] link-action
    dup [ drop ] [ button-up 1 ] set-action
    [ move-tile ] [ drag 1 ] link-action ;

: close-tile [ close-tile ] swap handle-gesture drop ;

: <close-box> ( -- gadget )
    <check> line-border dup [ close-tile ] button-gestures ;

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
    dup [ move-tile ] [ move-tile ] set-action
    dup [ resize-tile ] [ resize-tile ] set-action
    dup [ start-resizing ] [ start-resizing ] set-action
    [ drop ] [ button-down 1 ] set-action ;

: <resizer> ( -- gadget )
    <frame>
    dup [ resize-tile ] [ drag 1 ] link-action
    dup [ start-resizing ] [ button-down 1 ] link-action
    0 0 40 10 <plain-rect> <gadget>
    dup t reverse-video set-paint-prop
    over add-right ;

: tile-content ( child caption -- pile )
     <frame>
     [ >r <caption> r> add-top ] keep
     [ <resizer> swap add-bottom ] keep
     [ add-center ] keep ;

C: tile ( child caption -- tile )
    [ f line-border swap set-delegate ] keep
    [ >r tile-content r> add-gadget ] keep
    [ tile-actions ] keep ;

M: tile pref-size shape-size ;

: tile ( gadget title -- )
    #! Show the gadget in a new tile.
    <tile> [ world get add-gadget ] keep prefer ;
