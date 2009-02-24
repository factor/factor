! Copyright (C) 2005, 2008 Slava Pestov.
! Copyright (C) 2006, 2007 Alex Chapman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel sequences io.styles ui.gadgets ui.render
colors colors.gray accessors ;
QUALIFIED: colors
IN: ui.gadgets.theme

: solid-interior ( gadget color -- gadget )
    <solid> >>interior ; inline

: solid-boundary ( gadget color -- gadget )
    <solid> >>boundary ; inline

: faint-boundary ( gadget -- gadget )
    colors:gray solid-boundary ; inline

: selection-color ( -- color ) light-purple ;

: plain-gradient ( -- gradient )
    {
        T{ gray f 0.94 1.0 }
        T{ gray f 0.83 1.0 }
        T{ gray f 0.83 1.0 }
        T{ gray f 0.62 1.0 }
    } <gradient> ;

: rollover-gradient ( -- gradient )
    {
        T{ gray f 1.0  1.0 }
        T{ gray f 0.9  1.0 }
        T{ gray f 0.9  1.0 }
        T{ gray f 0.75 1.0 }
    } <gradient> ;

: pressed-gradient ( -- gradient )
    {
        T{ gray f 0.75 1.0 }
        T{ gray f 0.9  1.0 }
        T{ gray f 0.9  1.0 }
        T{ gray f 1.0  1.0 }
    } <gradient> ;

: selected-gradient ( -- gradient )
    {
        T{ gray f 0.65 1.0 }
        T{ gray f 0.8  1.0 }
        T{ gray f 0.8  1.0 }
        T{ gray f 1.0  1.0 }
    } <gradient> ;

: lowered-gradient ( -- gradient )
    {
        T{ gray f 0.37 1.0 }
        T{ gray f 0.43 1.0 }
        T{ gray f 0.5  1.0 }
    } <gradient> ;

CONSTANT: sans-serif-font { "sans-serif" plain 12 }

CONSTANT: monospace-font { "monospace" plain 12 }
