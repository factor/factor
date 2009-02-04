! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.styles namespaces colors ;
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
    { foreground T{ rgba f 0 0 0.3 1 } }
    { font-style bold }
} link-style set-global

SYMBOL: emphasis-style
H{ { font-style italic } } emphasis-style set-global

SYMBOL: strong-style
H{ { font-style bold } } strong-style set-global

SYMBOL: title-style
H{
    { font-name "sans-serif" }
    { font-size 18 }
    { font-style bold }
    { wrap-margin 500 }
    { page-color T{ rgba f 0.8 0.8 0.8 1 } }
    { border-width 5 }
} title-style set-global

SYMBOL: help-path-style
H{ { font-size 10 } } help-path-style set-global

SYMBOL: heading-style
H{
    { font-name "sans-serif" }
    { font-size 16 }
    { font-style bold }
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
    { foreground T{ rgba f 0.1 0.1 0.4 1 } }
} snippet-style set-global

SYMBOL: code-style
H{
    { page-color T{ rgba f 0.8 0.8 0.8 0.5 } }
    { border-width 5 }
    { wrap-margin f }
} code-style set-global

SYMBOL: input-style
H{ { font-style bold } } input-style set-global

SYMBOL: url-style
H{
    { font-name "monospace" }
    { foreground T{ rgba f 0.0 0.0 1.0 1.0 } }
} url-style set-global

SYMBOL: warning-style
H{
    { page-color T{ rgba f 0.95 0.95 0.95 1 } }
    { border-color T{ rgba f 1 0 0 1 } }
    { border-width 5 }
    { wrap-margin 500 }
} warning-style set-global

SYMBOL: table-content-style
H{
    { wrap-margin 350 }
} table-content-style set-global

SYMBOL: table-style
H{
    { table-gap { 5 5 } }
    { table-border T{ rgba f 0.8 0.8 0.8 1.0 } }
} table-style set-global

SYMBOL: list-style
H{ { table-gap { 10 2 } } } list-style set-global

SYMBOL: bullet
"• " bullet set-global
