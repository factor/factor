! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: kernel lists unparser ;

DEFER: inspect

: actionize ( obj assoc -- assoc )
    [
        unswons >r >r unit [ car ] cons r> append r> swons
    ] map-with ;

: object-menu ( obj -- assoc )
    [
        [[ "Inspect" [ inspect ] ]]
    ] actionize ;

TUPLE: presentation object delegate ;

: presentation-actions ( presentation -- )
    dup
    [ drop ] [ button-up 1 ] set-action
    [ presentation-object object-menu <menu> show-menu ]
    [ button-down 1 ] set-action ;

C: presentation ( obj -- gadget )
    over unparse <roll-label> over set-presentation-delegate
    [ set-presentation-object ] keep
    dup presentation-actions ;
