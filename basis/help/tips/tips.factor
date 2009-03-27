! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser arrays namespaces sequences random help.markup help.stylesheet
kernel io io.styles colors.constants definitions accessors ;
IN: help.tips

SYMBOL: tips

tips [ V{ } clone ] initialize

TUPLE: tip < identity-tuple content loc ;

M: tip forget* tips get delq ;

M: tip where loc>> ;

M: tip set-where (>>loc) ;

: <tip> ( content -- tip ) f tip boa ;

: add-tip ( tip -- ) tips get push ;

SYNTAX: TIP:
    parse-definition >array <tip>
    [ save-location ] [ add-tip ] bi ;

: a-tip ( -- tip ) tips get random ;

SYMBOL: tip-of-the-day-style

H{
    { page-color COLOR: lavender }
    { border-width 5 }
    { wrap-margin 500 }
} tip-of-the-day-style set-global

: $tip-title ( tip -- )
    [
        heading-style get [
            [ "Tip of the day" ] dip write-object
        ] with-style
    ] ($block) ;

: $tip-of-the-day ( element -- )
    drop
    [
        tip-of-the-day-style get
        [
            last-element off
            a-tip [ $tip-title ] [ content>> print-element nl ] bi
            "— " print-element "all-tips-of-the-day" ($link)
        ]
        with-nesting
    ] ($heading) ;

: tip-of-the-day. ( -- ) { $tip-of-the-day } print-content nl ;

: $tips-of-the-day ( element -- )
    drop tips get [ nl nl ] [ content>> print-element ] interleave ;

INSTANCE: tip definition