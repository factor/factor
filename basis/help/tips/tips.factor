! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser arrays namespaces sequences random help.markup kernel io
io.styles colors.constants ;
IN: help.tips

SYMBOL: tips

tips [ V{ } clone ] initialize

SYNTAX: TIP: parse-definition >array tips get push ;

: a-tip ( -- tip ) tips get random ;

SYMBOL: tip-of-the-day-style

H{
    { page-color COLOR: lavender }
    { border-width 5 }
    { wrap-margin 500 }
} tip-of-the-day-style set-global

: $tip-of-the-day ( element -- )
    drop
    [
        tip-of-the-day-style get
        [
            last-element off
            "Tip of the day" $heading a-tip print-element nl
            "— " print-element "all-tips-of-the-day" ($link)
        ]
        with-nesting
    ] ($heading) ;

: tip-of-the-day. ( -- ) { $tip-of-the-day } print-content nl ;

: $tips-of-the-day ( element -- )
    drop tips get [ nl nl ] [ print-element ] interleave ;