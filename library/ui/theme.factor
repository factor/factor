! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-buttons
DEFER: <button-paint>

IN: gadgets-labels
DEFER: set-label-color
DEFER: set-label-font

IN: gadgets-theme
USING: arrays gadgets kernel sequences styles ;

: solid-black << solid f @{ 0 0 0 }@ >> ;

: solid-white << solid f @{ 255 255 255 }@ >> ;

: solid-interior solid-white swap set-gadget-interior ;

: solid-boundary solid-black swap set-gadget-boundary ;

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
    <button-paint> swap set-gadget-interior ;

: thumb-theme ( thumb -- )
    plain-gradient swap set-gadget-interior ;

: roll-button-theme ( button -- )
    f solid-black solid-black <button-paint> over set-gadget-boundary
    f f << solid f @{ 236 230 232 }@ >> <button-paint> swap set-gadget-interior ;

: caret-theme ( caret -- )
    << solid f @{ 255 0 0 }@ >> swap set-gadget-interior ;

: elevator-theme ( elevator -- )
    << gradient f @{
        @{ 64 64 64 }@
        @{ 96 96 96 }@
        @{ 128 128 128 }@
    }@ >> swap set-gadget-interior ;

: reverse-video-theme ( gadget -- )
    solid-black swap set-gadget-interior ;

: display-title-theme
    << solid f @{ 216 232 255 }@ >> swap set-gadget-interior ;

: menu-theme ( menu -- )
    dup solid-boundary
    << gradient f @{ @{ 216 216 216 }@ @{ 255 255 255 }@ }@ >>
    swap set-gadget-interior ;

: label-theme ( label -- )
    @{ 0 0 0 }@ over set-label-color
    @{ "Monospaced" plain 12 }@ swap set-label-font ;

: editor-theme ( editor -- )
    @{ 0 0 0 }@ over set-label-color
    @{ "Monospaced" bold 12 }@ swap set-label-font ;
