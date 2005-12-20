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

: heading-style H{ { font "Serif" } { font-size 24 } } ;

: subheading-style H{ { font "Serif" } { font-size 18 } } ;

: parameter-style
    H{
        { font "Monospaced" }
        { font-size 12 }
        { font-style italic }
    } ;

: code-style
    H{
        { font "Monospaced" }
        { font-size 12 }
        { page-color { 0.9 0.9 0.9 1 } }
        { border-color { 0.95 0.95 0.95 1 } }
        { border-width 5 }
        { wrap-margin f }
    } ;
