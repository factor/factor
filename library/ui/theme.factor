! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-buttons
DEFER: <button-paint>

IN: gadgets-labels
DEFER: set-label-color
DEFER: set-label-font

IN: gadgets-theme
USING: arrays gadgets kernel sequences styles ;

: solid-black << solid f @{ 0.0 0.0 0.0 1.0 }@ >> ;

: solid-white << solid f @{ 1.0 1.0 1.0 1.0 }@ >> ;

: solid-interior solid-white swap set-gadget-interior ;

: solid-boundary solid-black swap set-gadget-boundary ;

: plain-gradient
    << gradient f @{
        @{ 0.94 0.94 0.94 1.0 }@
        @{ 0.83 0.83 0.83 1.0 }@
        @{ 0.83 0.83 0.83 1.0 }@
        @{ 0.62 0.62 0.62 1.0 }@
    }@ >> ;

: rollover-gradient
    << gradient f @{
        @{ 1.0 1.0 1.0 1.0 }@
        @{ 0.9 0.9 0.9 1.0 }@
        @{ 0.9 0.9 0.9 1.0 }@
        @{ 0.75 0.75 0.75 1.0 }@
    }@ >> ;

: pressed-gradient
    << gradient f @{
        @{ 0.75 0.75 0.75 1.0 }@
        @{ 0.9 0.9 0.9 1.0 }@
        @{ 0.9 0.9 0.9 1.0 }@
        @{ 1.0 1.0 1.0 1.0 }@
    }@ >> ;

: faint-boundary
    << solid f @{ 0.62 0.62 0.62 0.8 }@ >> swap set-gadget-boundary ;

: bevel-button-theme ( gadget -- )
    plain-gradient rollover-gradient pressed-gradient
    <button-paint> over set-gadget-interior
    faint-boundary ;

: thumb-theme ( thumb -- )
    plain-gradient over set-gadget-interior faint-boundary ;

: roll-button-theme ( button -- )
    f solid-black solid-black <button-paint> over set-gadget-boundary
    f f pressed-gradient <button-paint> swap set-gadget-interior ;

: caret-theme ( caret -- )
    << solid f @{ 1.0 0.0 0.0 1.0 }@ >> swap set-gadget-interior ;

: elevator-theme ( elevator -- )
    << gradient f @{
        @{ 0.37 0.37 0.37 1.0 }@
        @{ 0.43 0.43 0.43 1.0 }@
        @{ 0.5 0.5 0.5 1.0 }@
    }@ >> swap set-gadget-interior ;

: reverse-video-theme ( gadget -- )
    solid-black swap set-gadget-interior ;

: display-title-theme
    << solid f @{ 0.84 0.9 1.0 1.0 }@ >> swap set-gadget-interior ;

: menu-theme ( menu -- )
    dup solid-boundary
    << solid f @{ 0.9 0.9 0.9 0.9 }@ >> swap set-gadget-interior ;

: label-theme ( label -- )
    @{ 0.0 0.0 0.0 1.0 }@ over set-label-color
    @{ "Monospaced" plain 12 }@ swap set-label-font ;

: editor-theme ( editor -- )
    @{ 0.0 0.0 0.0 1.0 }@ over set-label-color
    @{ "Monospaced" bold 12 }@ swap set-label-font ;
