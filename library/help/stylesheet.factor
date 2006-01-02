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

: heading-style H{ { font "Serif" } { font-size 18 } } ;

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
        { page-color { 0.9 0.9 0.9 0.5 } }
        { border-width 5 }
        { wrap-margin f }
    } ;

: url-style
    H{
        { font "Monospaced" }
        { foreground { 0.0 0.0 1.0 1.0 } }
    } ;
