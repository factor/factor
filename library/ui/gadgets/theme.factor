! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-buttons
DEFER: <button-paint>

IN: gadgets-labels
DEFER: set-label-color
DEFER: set-label-font

IN: gadgets-text
DEFER: set-editor-color
DEFER: set-editor-caret-color
DEFER: set-editor-selection-color
DEFER: set-editor-font

IN: gadgets-theme
USING: arrays gadgets kernel sequences styles ;

: solid-black T{ solid f { 0.0 0.0 0.0 1.0 } } ;

: solid-white T{ solid f { 1.0 1.0 1.0 1.0 } } ;

: solid-interior solid-white swap set-gadget-interior ;

: solid-boundary solid-black swap set-gadget-boundary ;

: plain-gradient
    T{ gradient f {
        { 0.94 0.94 0.94 1.0 }
        { 0.83 0.83 0.83 1.0 }
        { 0.83 0.83 0.83 1.0 }
        { 0.62 0.62 0.62 1.0 }
    } } ;

: rollover-gradient
    T{ gradient f {
        { 1.0 1.0 1.0 1.0 }
        { 0.9 0.9 0.9 1.0 }
        { 0.9 0.9 0.9 1.0 }
        { 0.75 0.75 0.75 1.0 }
    } } ;

: pressed-gradient
    T{ gradient f {
        { 0.75 0.75 0.75 1.0 }
        { 0.9 0.9 0.9 1.0 }
        { 0.9 0.9 0.9 1.0 }
        { 1.0 1.0 1.0 1.0 }
    } } ;

: selected-gradient
    T{ gradient f {
        { 0.65 0.65 0.65 1.0 }
        { 0.8 0.8 0.8 1.0 }
        { 0.8 0.8 0.8 1.0 }
        { 1.0 1.0 1.0 1.0 }
    } } ;

: faint-boundary
    T{ solid f { 0.62 0.62 0.62 0.8 } } swap set-gadget-boundary ;

: bevel-button-theme ( gadget -- )
    plain-gradient
    rollover-gradient
    pressed-gradient
    selected-gradient
    <button-paint> over set-gadget-interior
    faint-boundary ;

: thumb-theme ( thumb -- )
    plain-gradient over set-gadget-interior faint-boundary ;

: roll-button-theme ( button -- )
    f solid-black solid-black f
    <button-paint> over set-gadget-boundary
    f f pressed-gradient solid-black
    <button-paint> swap set-gadget-interior ;

: caret-theme ( caret -- )
    T{ solid f { 1.0 0.0 0.0 1.0 } } swap set-gadget-interior ;

: elevator-theme ( elevator -- )
    T{ gradient f {
        { 0.37 0.37 0.37 1.0 }
        { 0.43 0.43 0.43 1.0 }
        { 0.5 0.5 0.5 1.0 }
    } } swap set-gadget-interior ;

: reverse-video-theme ( label -- )
    { 1.0 1.0 1.0 1.0 } over set-label-color
    solid-black swap set-gadget-interior ;

: label-theme ( gadget -- )
    { 0.0 0.0 0.0 1.0 } over set-label-color
    { "sans-serif" plain 12 } swap set-label-font ;

: text-theme ( gadget -- )
    { 0.0 0.0 0.0 1.0 } over set-label-color
    { "monospace" plain 12 } swap set-label-font ;

: editor-theme ( editor -- )
    { 0.0 0.0 0.0 1.0 } over set-editor-color
    { 1.0 0.0 0.0 1.0 } over set-editor-caret-color
    { 0.8 0.8 1.0 1.0 } over set-editor-selection-color
    { "monospace" plain 12 } swap set-editor-font ;
