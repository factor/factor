! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: kernel lists namespaces prettyprint stdio unparser ;

DEFER: inspect

: actionize ( obj assoc -- assoc )
    [
        unswons >r >r unit [ car ] cons r> append r> swons
    ] map-with ;

: object-menu ( obj -- assoc )
    [
        [[ "Inspect" [ inspect ] ]]
    ] actionize ;

: press-presentation ( presentation obj -- )
    #! Called when mouse is pressed over a presentation.
    swap button-update  object-menu <menu> show-menu ;

: presentation-actions ( presentation obj -- )
    [ literal, \ press-presentation , ] make-list
    [ button-down 1 ] set-action ;

: <presentation> ( obj -- gadget )
    dup unparse [ drop ] <roll-button>
    [ swap  presentation-actions ] keep ;
