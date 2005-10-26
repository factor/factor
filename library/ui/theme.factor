! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-buttons
DEFER: <button-paint>

IN: gadgets-theme
USING: arrays gadgets kernel sequences styles ;

: solid-interior ( gadget -- )
    << solid >> interior set-paint-prop ;

: solid-boundary ( gadget -- )
    << solid >> boundary set-paint-prop ;

: plain-gradient
    << gradient f @{
        @{ 240 240 240 }@
        @{ 192 192 192 }@
        @{ 192 192 192 }@
        @{ 96 96 96 }@
    }@ >> ;

: rollover-gradient
    << gradient f @{
        @{ 255 255 255 }@
        @{ 216 216 216 }@
        @{ 216 216 216 }@
        @{ 112 112 112 }@
    }@ >> ;

: pressed-gradient
    << gradient f @{
        @{ 112 112 112 }@
        @{ 216 216 216 }@
        @{ 216 216 216 }@
        @{ 255 255 255 }@
    }@ >> ;

: bevel-button-theme ( gadget -- )
    plain-gradient rollover-gradient pressed-gradient
    <button-paint> interior set-paint-prop ;

: thumb-theme ( thumb -- )
    plain-gradient interior set-paint-prop ;

: editor-theme ( editor -- )
    bold font-style set-paint-prop ;

: roll-button-theme ( button -- )
    dup << button-paint f f << solid >> << solid >> >> boundary set-paint-prop
    dup << button-paint f f f << solid >> >> interior set-paint-prop
    @{ 236 230 232 }@ background set-paint-prop ;

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

: reverse-video-theme ( gadget -- )
    dup black background set-paint-prop
    white foreground set-paint-prop ;

: divider-theme ( divider -- )
    dup solid-interior reverse-video-theme ;

: display-title-theme
    dup @{ 216 232 255 }@ background set-paint-prop
    solid-interior ;

: menu-theme ( menu -- )
    dup solid-boundary
    << gradient f @{ @{ 216 216 216 }@ @{ 255 255 255 }@ }@ >>
    interior set-paint-prop ;

: icon-theme ( gadget -- )
    dup gray background set-paint-prop
    gray foreground set-paint-prop ;

: world-theme
    {{
        [[ background @{ 255 255 255 }@ ]]
        [[ foreground @{ 0 0 0 }@ ]]
        [[ font "Monospaced" ]]
        [[ font-size 12 ]]
        [[ font-style plain ]]
    }} add-paint ;
