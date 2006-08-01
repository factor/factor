! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: styles ;

: default-style
    H{
        { font "sans-serif" }
        { font-size 12 }
        { font-style plain }
        { wrap-margin 500 }
    } ;

: link-style
    H{
        { foreground { 0 0 0.3 1 } }
        { font-style bold }
    } ;

: emphasis-style
    H{ { font-style italic } } ;

: title-style
    H{
        { font "sans-serif" }
        { font-size 16 }
        { font-style bold }
        { wrap-margin 500 }
        { page-color { 0.8 0.8 1 1 } }
        { border-width 5 }
    } ;

: where-style
    H{ { font-size 10 } } ;

: heading-style
    H{
        { font "sans-serif" }
        { font-size 14 }
        { font-style bold }
    } ;

: subsection-style
    H{
        { font "sans-serif" }
        { font-size 14 }
        { font-style bold }
    } ;

: subtopic-style
    H{ { font-style bold } } ;

: snippet-style
    H{
        { font "monospace" }
        { foreground { 0.3 0.3 0.3 1 } }
    } ;

: code-style
    H{
        { font "monospace" }
        { font-size 12 }
        { page-color { 0.8 0.8 0.8 0.5 } }
        { border-width 5 }
        { wrap-margin f }
    } ;

: input-style
    H{ { font-style bold } } ;

: url-style
    H{
        { font "monospace" }
        { foreground { 0.0 0.0 1.0 1.0 } }
    } ;

: warning-style
    H{
        { page-color { 0.95 0.95 0.95 1 } }
        { border-color { 1 0 0 1 } }
        { border-width 5 }
    } ;

: table-content-style
    H{
        { wrap-margin 350 }
    } ;

: table-style
    H{
        { table-gap { 5 5 0 } }
        { table-border { 0.8 0.8 0.8 1.0 } }
    } ;

: list-style
    H{ { table-gap { 10 2 0 } } } ;
