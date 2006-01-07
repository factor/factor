IN: help
USING: styles ;

: default-style
    H{
        { font "Sans Serif" }
        { font-size 12 }
        { wrap-margin 500 }
    } ;

: emphasis-style
    H{ { font-style italic } } ;

: heading-style H{ { font "Serif" } { font-size 16 } } ;

: subheading-style H{ { font "Serif" } { font-style bold } } ;

: subsection-style
    H{ { font "Serif" } { font-size 14 } { font-style bold } } ;

: snippet-style
    H{
        { font "Monospaced" }
        { foreground { 0.3 0.3 0.3 1 } }
    } ;

: code-style
    H{
        { font "Monospaced" }
        { page-color { 0.9 0.9 1 0.5 } }
        { border-width 5 }
        { wrap-margin f }
    } ;

: input-style
    H{ { font-style bold } } ;

: url-style
    H{
        { font "Monospaced" }
        { foreground { 0.0 0.0 1.0 1.0 } }
    } ;

: warning-style
    H{
        { page-color { 0.95 0.95 0.95 1 } }
        { border-color { 1 0 0 1 } }
        { border-width 5 }
    } ;
