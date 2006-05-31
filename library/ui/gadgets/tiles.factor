! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-tiles
USING: gadgets gadgets-buttons gadgets-labels gadgets-theme
kernel sequences ;

TUPLE: tile ;

: find-tile [ tile? ] find-parent ;

: <close-button> ( quot -- gadget | quot: tile -- )
    { 0.0 0.0 0.0 1.0 } close-box <polygon-gadget>
    [ find-tile ] rot append <bevel-button> ;

: <closable-title> ( title quot -- gadget )
    {
        { [ <close-button> ] f @right }
        { [ <label> ] f @center }
    } make-frame ;

: <title> ( title quot -- gadget | quot: tile -- )
    [ <closable-title> ] [ <label> ] if* dup title-theme ;

C: tile ( gadget title quot -- gadget )
    {
        { [ <title> ] f @top }
        { [ ] f @center }
    } make-frame* ;
