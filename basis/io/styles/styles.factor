! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: hashtables io colors summary make accessors splitting
kernel ;
IN: io.styles

SYMBOL: plain
SYMBOL: bold
SYMBOL: italic
SYMBOL: bold-italic

! Character styles
SYMBOL: foreground
SYMBOL: background
SYMBOL: font
SYMBOL: font-size
SYMBOL: font-style

! Presentation
SYMBOL: presented
SYMBOL: presented-path
SYMBOL: presented-printer

SYMBOL: href

! Paragraph styles
SYMBOL: page-color
SYMBOL: border-color
SYMBOL: border-width
SYMBOL: wrap-margin

! Table styles
SYMBOL: table-gap
SYMBOL: table-border

: standard-table-style ( -- style )
    H{
        { table-gap { 5 5 } }
        { table-border T{ rgba f 0.8 0.8 0.8 1.0 } }
    } ;

! Input history
TUPLE: input string ;

C: <input> input

M: input summary
    [
        "Input: " %
        string>> "\n" split1 swap %
        "..." "" ? %
    ] "" make ;

: write-object ( str obj -- ) presented associate format ;
