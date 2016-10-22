! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs colors.constants fonts fry io.styles kernel literals
math namespaces sequences ui.theme ;
IN: help.stylesheet

: wrap-margin-full ( -- n )
    42 default-font-size * ;

: wrap-margin-table-content ( -- n )
    29 default-font-size * ;

: font-size-subsection ( -- n )
    7/6 default-font-size * >integer ;

: font-size-title ( -- n )
    5/3 default-font-size * >integer ;

: font-size-heading ( -- n )
    4/3 default-font-size * >integer ;

: font-size-span ( -- n )
    13/12 default-font-size * >integer ;

SYMBOL: default-span-style
H{
    { font-name $ default-sans-serif-font-name }
    { font-size $ font-size-span }
    { foreground $ text-color }
    { font-style plain }
} default-span-style set-global

SYMBOL: default-block-style
H{
    { wrap-margin $ wrap-margin-full }
} default-block-style set-global

SYMBOL: link-style
H{
    { foreground $ link-color }
    { font-style bold }
} link-style set-global

SYMBOL: emphasis-style
H{ { font-style italic } } emphasis-style set-global

SYMBOL: strong-style
H{ { font-style bold } } strong-style set-global

SYMBOL: title-style
H{
    { font-name $ default-sans-serif-font-name }
    { font-size $ font-size-title }
    { font-style bold }
    { wrap-margin $ wrap-margin-full }
    { foreground $ title-color }
    { page-color COLOR: FactorLightTan }
    { inset { 5 5 } }
} title-style set-global

SYMBOL: help-path-style
H{
    { font-size $ default-font-size }
    { table-gap { 5 5 } }
} help-path-style set-global

SYMBOL: heading-style
H{
    { font-name $ default-sans-serif-font-name }
    { font-size $ font-size-heading }
    { font-style bold }
    { foreground $ heading-color }
} heading-style set-global

SYMBOL: subsection-style
H{
    { font-name $ default-sans-serif-font-name }
    { font-size $ font-size-subsection }
    { font-style bold }
} subsection-style set-global

SYMBOL: snippet-style
H{
    { font-name $ default-monospace-font-name }
    { font-size $ default-font-size }
    { foreground $ snippet-color }
} snippet-style set-global

SYMBOL: code-char-style
H{
    { font-name $ default-monospace-font-name }
    { font-size $ default-font-size }
} code-char-style set-global

SYMBOL: code-style
H{
    { page-color $ code-background-color }
    { inset { 5 5 } }
    { wrap-margin f }
} code-style set-global

SYMBOL: output-style
H{
    { font-style bold }
    { foreground $ output-color }
} output-style set-global

SYMBOL: url-style
H{
    { font-name $ default-monospace-font-name }
    { foreground $ link-color }
} url-style set-global

SYMBOL: warning-style
H{
    { page-color $ warning-background-color }
    { border-color $ warning-border-color }
    { inset { 5 5 } }
    { wrap-margin $ wrap-margin-full }
} warning-style set-global

SYMBOL: deprecated-style
H{
    { page-color $ warning-background-color }
    { border-color $ warning-border-color }
    { inset { 5 5 } }
    { wrap-margin $ wrap-margin-full }
} deprecated-style set-global

SYMBOL: table-content-style
H{
    { wrap-margin $ wrap-margin-table-content }
} table-content-style set-global

SYMBOL: table-style
H{
    { table-gap { 5 5 } }
    { table-border $ table-border-color }
} table-style set-global

SYMBOL: list-style
H{ { table-gap { 10 2 } } } list-style set-global

SYMBOL: bullet
"• " bullet set-global

: adjust-help-font-size ( delta -- )
    [
        font-size
        {
            default-span-style title-style
            help-path-style heading-style
            subsection-style snippet-style
            code-char-style
        }
    ] dip '[ get-global [ _ + ] change-at ] with each ;
