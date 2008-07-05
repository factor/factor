! Copyright (C) 2005, 2008 Slava Pestov.
! Copyright (C) 2006, 2007 Alex Chapman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel sequences io.styles ui.gadgets ui.render
colors accessors ;
IN: ui.gadgets.theme

: solid-interior ( gadget color -- gadget )
    <solid> >>interior ; inline

: solid-boundary ( gadget color -- gadget )
    <solid> >>boundary ; inline

: faint-boundary ( gadget -- gadget )
    gray solid-boundary ; inline

: selection-color ( -- color ) light-purple ;

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

: lowered-gradient
    T{ gradient f {
        { 0.37 0.37 0.37 1.0 }
        { 0.43 0.43 0.43 1.0 }
        { 0.5 0.5 0.5 1.0 }
    } } ;

: sans-serif-font { "sans-serif" plain 12 } ;

: monospace-font { "monospace" plain 12 } ;
