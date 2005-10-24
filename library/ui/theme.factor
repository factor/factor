! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-theme
USING: arrays gadgets kernel sequences styles ;

: solid-interior ( gadget -- )
    << solid >> interior set-paint-prop ;

: solid-boundary ( gadget -- )
    << solid >> boundary set-paint-prop ;

: button-theme ( gadget -- )
    << gradient f @{
        @{ 240 240 240 }@
        @{ 192 192 192 }@
        @{ 192 192 192 }@
        @{ 96 96 96 }@
    }@ >> interior set-paint-prop ;

: editor-theme ( editor -- )
    bold font-style set-paint-prop ;

: roll-button-theme ( button -- )
    dup <rollover-only> interior set-paint-prop
    <rollover-only> boundary set-paint-prop ;

: caret-theme ( caret -- )
    dup solid-interior
    red background set-paint-prop ;

: elevator-theme ( elevator -- )
    dup << gradient f @{
        @{ 64 64 64 }@
        @{ 96 96 96 }@
        @{ 128 128 128 }@
    }@ >> interior set-paint-prop
    light-gray background set-paint-prop ;

: divider-theme ( divider -- )
    dup solid-interior t reverse-video set-paint-prop ;

: display-title-theme
    dup @{ 216 232 255 }@ background set-paint-prop
    solid-interior ;

: menu-theme ( menu -- )
    dup solid-boundary
    << gradient f @{ @{ 216 216 216 }@ @{ 255 255 255 }@ }@ >>
    interior set-paint-prop ;

: icon-theme ( gadget -- )
    dup gray background set-paint-prop
    dup light-gray rollover-bg set-paint-prop
    gray foreground set-paint-prop ;

: world-theme
    {{
        [[ background @{ 255 255 255 }@ ]]
        [[ rollover-bg @{ 236 230 232 }@ ]]
        [[ foreground @{ 0 0 0 }@ ]]
        [[ reverse-video f ]]
        [[ font "Monospaced" ]]
        [[ font-size 12 ]]
        [[ font-style plain ]]
    }} add-paint ;
