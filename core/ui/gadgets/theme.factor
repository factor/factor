! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
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

IN: gadgets-panes
DEFER: set-pane-selection-color

IN: gadgets-theme
USING: arrays gadgets kernel sequences styles ;

: black { 0.0 0.0 0.0 1.0 } ;
: white { 1.0 1.0 1.0 1.0 } ;
: gray { 0.6 0.6 0.6 1.0 } ;
: red { 1.0 0.0 0.0 1.0 } ;
: light-purple { 0.8 0.8 1.0 1.0 } ;
: light-gray { 0.95 0.95 0.95 0.95 } ;

: solid-interior <solid> swap set-gadget-interior ;

: solid-boundary <solid> swap set-gadget-boundary ;

: faint-boundary gray solid-boundary ;

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
    f black <solid> dup f <button-paint>
    swap set-gadget-boundary ;

: elevator-theme ( elevator -- )
    T{ gradient f {
        { 0.37 0.37 0.37 1.0 }
        { 0.43 0.43 0.43 1.0 }
        { 0.5 0.5 0.5 1.0 }
    } } swap set-gadget-interior ;

: reverse-video-theme ( label -- )
    white over set-label-color
    black solid-interior ;

: label-theme ( gadget -- )
    black over set-label-color
    { "sans-serif" plain 12 } swap set-label-font ;

: text-theme ( gadget -- )
    black over set-label-color
    { "monospace" plain 12 } swap set-label-font ;

: editor-theme ( editor -- )
    black over set-editor-color
    red over set-editor-caret-color
    light-purple over set-editor-selection-color
    { "monospace" plain 12 } swap set-editor-font ;

: pane-theme ( editor -- )
    light-purple swap set-pane-selection-color ;

: menu-theme ( gadget -- )
    dup light-gray solid-interior
    faint-boundary ;

: title-theme ( gadget -- )
    { 1 0 } over set-gadget-orientation
    T{ gradient f {
        { 0.65 0.65 1.0 1.0 }
        { 0.65 0.45 1.0 1.0 }
    } } swap set-gadget-interior ;
