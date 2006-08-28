! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-tiles
USING: gadgets gadgets-buttons gadgets-labels gadgets-frames
gadgets-theme kernel sequences ;

TUPLE: tile gadget ;

: find-tile [ tile? ] find-parent ;

: <close-button> ( quot -- gadget )
    { 0.0 0.0 0.0 1.0 } close-box <polygon-gadget>
    [ find-tile ] rot append <bevel-button> ;

: <closable-title> ( title quot -- gadget )
    {
        { [ <close-button> ] f f @left }
        { [ <label> ] f f @center }
    } make-frame ;

: <title> ( title quot -- gadget )
    [ <closable-title> ] [ <label> ] if* dup title-theme ;

C: tile ( gadget title quot -- gadget )
    {
        { [ <title> ] f f @top }
        { f set-tile-gadget f @center }
    } make-frame* ;

M: tile focusable-child* tile-gadget ;
