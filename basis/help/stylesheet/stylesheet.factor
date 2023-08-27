! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs colors fonts io.styles kernel literals math
math.order namespaces sequences ui.theme ;
IN: help.stylesheet

: wrap-margin-full ( -- n )
    48 default-font-size * ;

: wrap-margin-table-content ( -- n )
    32 default-font-size * ;

: wrap-margin-list-content ( -- n )
    40 default-font-size * ;

: font-size-subsection ( -- n )
    14/12 default-font-size * >integer ;

: font-size-title ( -- n )
    20/12 default-font-size * >integer ;

: font-size-heading ( -- n )
    16/12 default-font-size * >integer ;

: font-size-span ( -- n )
    14/12 default-font-size * >integer ;

SYMBOL: default-style
H{
    { font-name $ default-sans-serif-font-name }
    { font-size $ font-size-span }
    { foreground $ text-color }
    { font-style plain }
    { wrap-margin $ wrap-margin-full }
} default-style set-global

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
    { page-color $ help-header-background }
    { inset { 5 5 } }
} title-style set-global

SYMBOL: help-path-style
H{
    { font-name $ default-sans-serif-font-name }
    { font-size $ font-size-span }
    { font-style plain }
    { foreground $ text-color }
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

SYMBOL: code-style
H{
    { font-name $ default-monospace-font-name }
    { font-size $ default-font-size }
    { foreground $ text-color }
    { page-color $ code-background-color }
    { border-color $ code-border-color }
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

SYMBOL: list-content-style
H{
    { wrap-margin $ wrap-margin-list-content }
} list-content-style set-global

SYMBOL: list-style
H{
    { table-gap { 5 5 } }
} list-style set-global

SYMBOL: bullet
"• " bullet set-global

: adjust-help-font-size ( delta -- )
    [
        font-size
        {
            default-style title-style
            help-path-style heading-style
            subsection-style snippet-style
            code-style
        }
    ] dip '[ get-global [ _ + 1 max ] change-at ] with each ;
