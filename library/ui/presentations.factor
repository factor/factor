! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: kernel lists namespaces prettyprint io unparser ;

DEFER: inspect

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
    dup unparse f <roll-button>
    [ swap  presentation-actions ] keep ;
