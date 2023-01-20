! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors definitions help.markup
help.stylesheet io io.styles kernel literals namespaces parser
random sequences ui.theme ;
IN: help.tips

SYMBOL: tips

tips [ V{ } clone ] initialize

TUPLE: tip < identity-tuple content loc ;

M: tip forget* tips get remove-eq! drop ;

M: tip where loc>> ;

M: tip set-where loc<< ;

: <tip> ( content -- tip ) f tip boa ;

: add-tip ( tip -- ) tips get push ;

SYNTAX: TIP:
    parse-array-def <tip>
    [ save-location ] [ add-tip ] bi ;

: a-tip ( -- tip ) tips get random ;

SYMBOL: tip-of-the-day-style
H{
    { page-color $ tip-background-color }
    { inset { 5 5 } }
    { wrap-margin $ wrap-margin-full }
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

INSTANCE: tip definition-mixin
