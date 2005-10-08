! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-theme
USING: gadgets kernel styles ;

: solid-interior ( gadget -- )
    << solid >> interior set-paint-prop ;

: solid-boundary ( gadget -- )
    << solid f >> boundary set-paint-prop ;

: bevel-theme ( gadget -- )
    dup solid-interior
    << bevel f 2 >> boundary set-paint-prop ;

: editor-theme ( editor -- )
    bold font-style set-paint-prop ;

: button-theme ( button -- )
    dup bevel-theme
    dup @{ 216 216 216 }@ background set-paint-prop
    f reverse-video set-paint-prop ;

: roll-button-theme ( button -- )
    dup f reverse-video set-paint-prop
    dup <rollover-only> interior set-paint-prop
    <rollover-only> boundary set-paint-prop ;

: caret-theme ( caret -- )
    dup solid-interior
    red background set-paint-prop ;

: elevator-theme ( elevator -- )
    dup solid-interior
    light-gray background set-paint-prop ;

: divider-theme ( divider -- )
    dup solid-interior t reverse-video set-paint-prop ;

: display-title-theme
    dup @{ 216 232 255 }@ background set-paint-prop
    solid-interior ;

: menu-theme ( menu -- )
    << gradient f @{ 1 0 0 }@ @{ 216 216 216 }@ @{ 255 255 255 }@ >>
    interior set-paint-prop ;

: icon-theme ( gadget -- )
    dup gray background set-paint-prop
    dup light-gray rollover-bg set-paint-prop
    gray foreground set-paint-prop ;

: world-theme
    {{
        [[ background @{ 255 255 255 }@ ]]
        [[ rollover-bg @{ 236 230 232 }@ ]]
        [[ bevel-1 { 160 160 160 }@ ]]
        [[ bevel-2 @{ 232 232 232 }@ ]]
        [[ foreground @{ 0 0 0 }@ ]]
        [[ reverse-video f ]]
        [[ font "Monospaced" ]]
        [[ font-size 12 ]]
        [[ font-style plain ]]
    }} add-paint ;
