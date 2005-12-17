! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: styles

! Colors are RGBA quadruples
: black      { 0.0 0.0 0.0 1.0 } ;
: dark-gray  { 0.25 0.25 0.25 1.0 } ;
: gray       { 0.5 0.5 0.5 1.0 } ;
: light-gray { 0.75 0.75 0.75 1.0 } ;
: white      { 1.0 1.0 1.0 1.0 } ;
: red        { 1.0 0.0 0.0 1.0 } ;
: green      { 0.0 1.0 0.0 1.0 } ;
: blue       { 0.0 0.0 1.0 1.0 } ;

! Character styles

SYMBOL: foreground ! Used for text and outline shapes.
SYMBOL: background ! Used for filled shapes.

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

! A quotation that writes an outline expansion to stdio
SYMBOL: outline

! Paragraph styles
SYMBOL: border-color
SYMBOL: border-width
SYMBOL: padding
SYMBOL: word-wrap
