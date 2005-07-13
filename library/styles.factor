! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: styles
USING: kernel namespaces ;

! Colors are lists of three integers, 0..255.
SYMBOL: foreground ! Used for text and outline shapes.
SYMBOL: background ! Used for filled shapes.
SYMBOL: rollover-bg
SYMBOL: rollover
SYMBOL: reverse-video

: fg ( -- color )
    reverse-video get background foreground ? get ;

: bg ( -- color )
    reverse-video get [
        foreground
    ] [
        rollover get rollover-bg background ?
    ] ifte get ;

SYMBOL: font
SYMBOL: font-size
SYMBOL: font-style

SYMBOL: plain
SYMBOL: bold
SYMBOL: italic
SYMBOL: bold-italic

SYMBOL: underline

SYMBOL: icon

SYMBOL: presented
