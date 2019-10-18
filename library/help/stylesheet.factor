IN: help
USING: styles ;

: default-style
    H{
        { font "sans-serif" }
        { font-size 12 }
        { wrap-margin 500 }
    } ;

: link-style
    H{ { foreground { 0.3 0 0 1 } } { font-style bold } } ;

: emphasis-style
    H{ { font-style italic } } ;

: heading-style H{ { font "serif" } { font-size 16 } } ;

: subheading-style H{ { font "serif" } { font-style bold } } ;

: subsection-style
    H{ { font "serif" } { font-size 14 } { font-style bold } } ;

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

: list-element-style
    H{ { border-color { 0.8 0.8 0.8 1 } } { border-width 5 } } ;
