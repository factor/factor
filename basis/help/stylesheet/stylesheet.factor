! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs colors colors.constants fry io.styles kernel
math namespaces sequences ;
IN: help.stylesheet

SYMBOL: default-span-style
H{
    { font-name "sans-serif" }
    { font-size 12 }
    { font-style plain }
} default-span-style set-global

SYMBOL: default-block-style
H{
    { wrap-margin 500 }
} default-block-style set-global

SYMBOL: link-style
H{
    { foreground COLOR: DodgerBlue4 }
    { font-style bold }
} link-style set-global

SYMBOL: emphasis-style
H{ { font-style italic } } emphasis-style set-global

SYMBOL: strong-style
H{ { font-style bold } } strong-style set-global

SYMBOL: title-style
H{
    { font-name "sans-serif" }
    { font-size 20 }
    { font-style bold }
    { wrap-margin 500 }
    { foreground COLOR: gray20 }
    { page-color COLOR: FactorLightTan }
    { inset { 5 5 } }
} title-style set-global

SYMBOL: help-path-style
H{
    { font-size 10 }
    { table-gap { 5 5 } }
    { table-border COLOR: FactorLightTan }
} help-path-style set-global

SYMBOL: heading-style
H{
    { font-name "sans-serif" }
    { font-size 16 }
    { font-style bold }
    { foreground COLOR: FactorDarkSlateBlue }
} heading-style set-global

SYMBOL: subsection-style
H{
    { font-name "sans-serif" }
    { font-size 14 }
    { font-style bold }
} subsection-style set-global

SYMBOL: snippet-style
H{
    { font-name "monospace" }
    { font-size 12 }
    { foreground COLOR: DarkOrange4 }
} snippet-style set-global

SYMBOL: code-char-style
H{
    { font-name "monospace" }
    { font-size 12 }
} code-char-style set-global

SYMBOL: code-style
H{
    { page-color COLOR: FactorLightTan }
    { inset { 5 5 } }
    { wrap-margin f }
} code-style set-global

SYMBOL: output-style
H{
    { font-style bold }
    { foreground COLOR: DarkOrange4 }
} output-style set-global

SYMBOL: url-style
H{
    { font-name "monospace" }
    { foreground COLOR: DodgerBlue4 }
} url-style set-global

SYMBOL: warning-style
H{
    { page-color COLOR: gray90 }
    { border-color COLOR: red }
    { inset { 5 5 } }
    { wrap-margin 500 }
} warning-style set-global

SYMBOL: deprecated-style
H{
    { page-color COLOR: gray90 }
    { border-color COLOR: red }
    { inset { 5 5 } }
    { wrap-margin 500 }
} deprecated-style set-global

SYMBOL: table-content-style
H{
    { wrap-margin 350 }
} table-content-style set-global

SYMBOL: table-style
H{
    { table-gap { 5 5 } }
    { table-border COLOR: FactorTan }
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
