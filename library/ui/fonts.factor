! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien arrays errors hashtables io kernel lists namespaces
sdl sequences styles ;

: gadget-font ( gadget -- font )
    [ font paint-prop ] keep
    [ font-style paint-prop ] keep
    font-size paint-prop
    lookup-font ;
