! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: styles

! Colors are RGB triples.
: black { 0   0   0   } ;
: gray  { 128 128 128 } ;
: white { 255 255 255 } ;
: red   { 255 0   0   } ;
: green { 0   255 0   } ;
: blue  { 0   0   255 } ;

SYMBOL: foreground ! Used for text and outline shapes.
SYMBOL: background ! Used for filled shapes.
SYMBOL: rollover-bg
SYMBOL: rollover
SYMBOL: reverse-video

SYMBOL: font
SYMBOL: font-size
SYMBOL: font-style

SYMBOL: plain
SYMBOL: bold
SYMBOL: italic
SYMBOL: bold-italic

SYMBOL: underline

SYMBOL: presented
SYMBOL: file
