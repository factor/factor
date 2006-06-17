! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: styles ;

: default-char-style
    H{
        { font "sans-serif" }
        { font-size 12 }
    } ;

: default-para-style
    H{
        { wrap-margin 500 }
    } ;

: link-style
    H{ { foreground { 0.3 0 0 1 } } { font-style bold } } ;

: emphasis-style
    H{ { font-style italic } } ;

: title-style
    H{
        { font "sans-serif" }
        { font-size 16 }
        { font-style bold }
    } ;

: heading-style
    H{
        { font "sans-serif" }
        { font-size 14 }
        { font-style bold }
        { foreground { 0.2 0.2 0.4 1 } }
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
        { page-color { 0.9 0.9 1 0.5 } }
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

: table-style
    H{
        { wrap-margin 350 }
    } ;
